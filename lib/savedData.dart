class SavedData {
  int id; //used as an index not actual id
  String songTitle;

  SavedData({
    required this.id,
    required this.songTitle,
  });

  static List<SavedData> saved = [];
}
