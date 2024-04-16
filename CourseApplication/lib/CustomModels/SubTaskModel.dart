class SubTaskModel{
  int SubTaskExecutorID;
  int SubTaskID;
  String username;
  String title;
  bool isDone;
  bool isTotallyDone;
  int parent;
  String completionDate = "";
  String deadLine = "";
  SubTaskModel(this.SubTaskExecutorID,this.SubTaskID,this.username,this.title,this.isDone,this.isTotallyDone,this.parent,this.completionDate,this.deadLine);
  SubTaskModel.fromJson(Map<String,dynamic> json)
      :SubTaskExecutorID = json['subTaskExecutorID'],
        SubTaskID = json['subTaskID'],
        username = json['username'],
        title = json['title'],
        isDone = json['isDone'],
        isTotallyDone = json['isTotallyDone'],
        parent = json['parent'],
        completionDate = json['completionDate'] ?? "",
        deadLine = json['deadLine'];
  Map<String,dynamic> toJson() => {
    'subTaskExecutorID' : SubTaskExecutorID,
    'subTaskID' : SubTaskID,
    'username' : username,
    'title' : title,
    'isDone' : isDone,
    'isDisTotallyDoneone' : isTotallyDone,
    'parent' : parent,
    'completionDate' : completionDate,
    'deadLine' : deadLine
  };
}