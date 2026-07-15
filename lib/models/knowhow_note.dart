/// つまずきノウハウ集の1ノート。
/// knowhow Lambda の {"Method":"GET","exam_id":...} 応答（KnowhowNote テーブル）に対応する。
class KnowhowNote {
  final int tagNo;
  final String tagName;
  final String content;
  final int sourceCount;
  final String updateDate;

  KnowhowNote.fromMap(Map<String, dynamic> data)
    : tagNo = data['tag_no'],
      tagName = data['tag_name'] ?? '',
      content = data['content'] ?? '',
      sourceCount = data['source_count'] ?? 0,
      updateDate = data['update_date'] ?? '';

  static List<KnowhowNote> fromList(List<dynamic> data) {
    return data.map<KnowhowNote>((item) => KnowhowNote.fromMap(item)).toList();
  }
}
