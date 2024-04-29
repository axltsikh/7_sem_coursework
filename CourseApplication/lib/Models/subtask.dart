class SubTask{
  int id=0;
  int? parent;
  int ProjectID=0;
  String title="";
  bool isDone=false;
  bool isTotallyDone=false;
  String? completionDate = "";
  String deadLine = "";
  SubTask(this.id,this.parent,this.ProjectID,this.title,this.isDone,this.isTotallyDone,this.completionDate,this.deadLine);
  SubTask.empty();
    SubTask.fromJson(Map<String,dynamic> json)
        :id = json['id'],
          parent = json['parent'],
          ProjectID = json['projectID'],
          title = json['title'],
          isTotallyDone = json['isTotallyDone'],
          isDone = json['isDone'],
          completionDate = json['completionDate'] ?? "",
          deadLine = json['deadLine'] ?? "";
    Map<String,dynamic> toJson() => {
      'id' : id,
      'parent' : parent,
      'projectID' : ProjectID,
      'title' : title,
      'isDone' : isDone,
      'isTotallyDone':isTotallyDone,
      'completionDate' : completionDate,
      'deadLine' : deadLine
    };
}