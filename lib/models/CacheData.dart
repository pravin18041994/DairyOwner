class CacheData{
  int id;
  String data;
  String context;  

  CacheData({this.id,this.data,this.context});
  Map<String, dynamic> toMap() {
    return {
      'id' :id,
      'data': data,
      'context': context,      
    };
  }
}