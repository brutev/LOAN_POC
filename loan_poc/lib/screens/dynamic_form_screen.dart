import 'package:flutter/material.dart';
import '../models/metadata_models.dart';
import '../services/api_service.dart';

class DynamicFormScreen extends StatefulWidget {
  final String initialStage;
  const DynamicFormScreen({super.key, this.initialStage = 'PRE_SANCTION'});

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  late String _stage;
  FormMetadata? _formMetadata;
  final Map<String, String> _fieldValues = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;
    _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
   debugPrint('[POC] Fetching metadata: stage=$_stage, version=... , values=$_fieldValues');
    final metadata = await ApiService().fetchFormMetadata(
      _stage,
      versionId: _formMetadata?.versionId ?? 'WORKING_V1',
      values: _fieldValues,
    );
    if (metadata == null) {
      debugPrint('[POC] Metadata fetch failed or returned null');
    } else {
      debugPrint('[POC] Metadata fetch success: versionId=${metadata.versionId}');
    }
    setState(() {
      _formMetadata = metadata;
      _fieldValues.clear();
      for (final tile in metadata?.tiles ?? []) {
        for (final card in tile.cards) {
          for (final field in card.fields) {
            _fieldValues[field.fieldId] = '';
          }
        }
      }
    });
  }

  void _switchStage(String stage) {
    final previousValues = Map<String, String>.from(_fieldValues);
    setState(() {
      _stage = stage;
      _formMetadata = null;
    });
    _fetchMetadataWithPreservedValues(previousValues);
  }

  Future<void> _fetchMetadataWithPreservedValues(Map<String, String> previousValues) async {
    debugPrint('[POC] Fetching metadata: stage=$_stage, version=... , values=$previousValues');
    final metadata = await ApiService().fetchFormMetadata(
      _stage,
      versionId: _formMetadata?.versionId ?? 'WORKING_V1',
      values: previousValues,
    );
    if (metadata == null) {
      debugPrint('[POC] Metadata fetch failed or returned null');
    } else {
      debugPrint('[POC] Metadata fetch success: versionId=${metadata.versionId}');
    }
    setState(() {
      _formMetadata = metadata;
      _fieldValues.clear();
      for (final tile in metadata?.tiles ?? []) {
        for (final card in tile.cards) {
          for (final field in card.fields) {
            _fieldValues[field.fieldId] = previousValues[field.fieldId] ?? '';
          }
        }
      }
    });
  }

  void _onSubmit() {
    bool valid = true;
    String? firstErrorField;
    for (final tile in _formMetadata!.tiles) {
      for (final card in tile.cards) {
        for (final field in card.fields) {
          if (field.visible && field.mandatory && field.editable) {
            final value = _fieldValues[field.fieldId] ?? '';
            if (value.isEmpty) {
              valid = false;
              firstErrorField ??= field.label;
            }
          }
        }
      }
    }
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }
    final payload = {
      'values': Map<String, String>.from(_fieldValues),
      'versionId': _formMetadata?.versionId,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitted! Payload: \n$payload')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form POC'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _switchStage('PRE_SANCTION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stage == 'PRE_SANCTION' ? Colors.blue : Colors.grey,
                ),
                child: const Text('Pre-Sanction'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _switchStage('POST_SANCTION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stage == 'POST_SANCTION' ? Colors.blue : Colors.grey,
                ),
                child: const Text('Post-Sanction'),
              ),
            ],
          ),
          Expanded(
            child: _formMetadata == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._formMetadata!.tiles.map((tile) => _buildTile(tile)).toList(),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _onSubmit,
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ...existing code...

  Widget _buildTile(TileMetadata tile) {
    final isLocked = tile.completionStatus != null && tile.completionStatus != 'COMPLETE';
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      color: isLocked ? Colors.grey[200] : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tile.tile, style: Theme.of(context).textTheme.headlineSmall),
                if (isLocked)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.lock, color: Colors.grey[700]),
                  ),
              ],
            ),
            if (isLocked && tile.prerequisiteIncompleteReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  tile.prerequisiteIncompleteReason!,
                  style: const TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic),
                ),
              ),
            if (!isLocked)
              ...tile.cards.map((card) => _buildCard(card)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(CardMetadata card) {
    final visibleFields = card.fields.where((f) => f.visible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    if (visibleFields.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.cardName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ...visibleFields.map((field) => FieldWidget(
              field: field,
              value: _fieldValues[field.fieldId] ?? '',
              onChanged: field.editable
                  ? (val) => setState(() => _fieldValues[field.fieldId] = val)
                  : null,
            )),
          ],
        ),
      ),
    );
  }
}

class FieldWidget extends StatelessWidget {
  final FieldMetadata field;
  final String value;
  final ValueChanged<String>? onChanged;

  const FieldWidget({super.key, required this.field, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (!field.visible) return const SizedBox.shrink();
    final isFrozen = field.editable == false && field.freezeReason != null && field.freezeReason!.isNotEmpty;
    // Highlight if this field is in changedFields (from tile or card or field)
    bool highlight = false;
    // Check for changedFields at field, card, or tile level
    // (Assume changedFields is passed down or available in field)
    if (field.changedFields == true) {
      highlight = true;
    }
    // If parent changedFields is available, you can pass it as a parameter and check here as well
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: highlight
            ? BoxDecoration(
                color: Colors.yellow.withOpacity(0.15),
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    field.label + (field.mandatory ? ' *' : ''),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (isFrozen)
                  Tooltip(
                    message: field.freezeReason!,
                    child: const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  ),
              ],
            ),
            _FieldValueBinder(
              field: field,
              value: value,
              onChanged: onChanged,
              hideLabel: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldValueBinder extends StatefulWidget {
  final FieldMetadata field;
  final String value;
  final ValueChanged<String>? onChanged;
  final bool hideLabel;

  const _FieldValueBinder({
    required this.field,
    required this.value,
    this.onChanged,
    this.hideLabel = false,
  });

  @override
  State<_FieldValueBinder> createState() => _FieldValueBinderState();
}

class _FieldValueBinderState extends State<_FieldValueBinder> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _FieldValueBinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.field.editable,
      keyboardType: widget.field.type == 'number' ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: widget.hideLabel ? null : widget.field.label + (widget.field.mandatory ? ' *' : ''),
      ),
      validator: (val) {
        if (widget.field.mandatory && (val == null || val.isEmpty)) {
          return 'Required';
        }
        return null;
      },
      onChanged: widget.onChanged,
    );
  }
}
