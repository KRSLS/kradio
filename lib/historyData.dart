class HistoryData {
  int id;
  String songTitle;
  String station;

  HistoryData({
    required this.id,
    required this.songTitle,
    required this.station,
  });

  static List<HistoryData> history = [];
}
