class HistoryData {
  String songTitle;
  String station;

  HistoryData({
    required this.songTitle,
    required this.station,
  });

  static List<HistoryData> history = [];
}
