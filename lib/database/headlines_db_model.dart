class HeadLineListDbModel {
  int id;
  dynamic listdata;

  HeadLineListDbModel(this.id, this.listdata);
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'listdata': listdata,
    };
    return map;
  }

  HeadLineListDbModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    listdata = map['listdata'];
  }
}
