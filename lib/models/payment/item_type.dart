enum ItemType {
  course,
  preparationPack,
  session;

  String get value {
    switch (this) {
      case ItemType.course:
        return 'Course';
      case ItemType.preparationPack:
        return 'PreparationPack';
      case ItemType.session:
        return 'Session';
    }
  }

  static ItemType fromString(String value) {
    switch (value) {
      case 'Course':
        return ItemType.course;
      case 'PreparationPack':
        return ItemType.preparationPack;
      case 'Session':
        return ItemType.session;
      default:
        throw ArgumentError('Invalid ItemType: $value');
    }
  }
}
