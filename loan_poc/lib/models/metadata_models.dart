class FieldMetadata {
  final String fieldId;
  final String label;
  final String type;
  final bool visible;
  final bool mandatory;
  final bool editable;
  final int order;
  final String? cardName;
  final bool? changedFields;
  final String? freezeReason;
  final String? completionStatus;
  final String? versionId;

  FieldMetadata({
    required this.fieldId,
    required this.label,
    required this.type,
    required this.visible,
    required this.mandatory,
    required this.editable,
    required this.order,
    this.cardName,
    this.changedFields,
    this.freezeReason,
    this.completionStatus,
    this.versionId,
  });

  factory FieldMetadata.fromJson(Map<String, dynamic> json) {
    return FieldMetadata(
      fieldId: json['fieldId'],
      label: json['label'],
      type: json['type'],
      visible: json['visible'],
      mandatory: json['mandatory'],
      editable: json['editable'],
      order: json['order'],
      cardName: json['cardName'],
      changedFields: json['changedFields'],
      freezeReason: json['freezeReason'],
      completionStatus: json['completionStatus'],
      versionId: json['versionId'],
    );
  }
}

class CardMetadata {
  final String cardName;
  final List<FieldMetadata> fields;
  final String? completionStatus;
  final String? versionId;

  CardMetadata({
    required this.cardName,
    required this.fields,
    this.completionStatus,
    this.versionId,
  });

  factory CardMetadata.fromJson(Map<String, dynamic> json) {
    var fieldsList = (json['fields'] as List)
        .map((f) => FieldMetadata.fromJson(f))
        .toList();
    return CardMetadata(
      cardName: json['cardName'],
      fields: fieldsList,
      completionStatus: json['completionStatus'],
      versionId: json['versionId'],
    );
  }
}

class TileMetadata {
  final String tile;
  final List<CardMetadata> cards;
  final String? completionStatus;
  final String? versionId;
  final String? prerequisiteIncompleteReason;

  TileMetadata({
    required this.tile,
    required this.cards,
    this.completionStatus,
    this.versionId,
    this.prerequisiteIncompleteReason,
  });

  factory TileMetadata.fromJson(Map<String, dynamic> json) {
    var cardsList = (json['cards'] as List)
        .map((c) => CardMetadata.fromJson(c))
        .toList();
    return TileMetadata(
      tile: json['tile'],
      cards: cardsList,
      completionStatus: json['completionStatus'],
      versionId: json['versionId'],
      prerequisiteIncompleteReason: json['prerequisiteIncompleteReason'],
    );
  }
}

class FormMetadata {
  final List<TileMetadata> tiles;
  final String? completionStatus;
  final String? versionId;

  FormMetadata({
    required this.tiles,
    this.completionStatus,
    this.versionId,
  });

  factory FormMetadata.fromJson(Map<String, dynamic> json) {
    var tilesList = (json['tiles'] as List)
        .map((t) => TileMetadata.fromJson(t))
        .toList();
    return FormMetadata(
      tiles: tilesList,
      completionStatus: json['completionStatus'],
      versionId: json['versionId'],
    );
  }
}
