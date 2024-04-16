class ChildSubTaskModel{
  int subTaskID;
  int parent;
  int projectID;
  String title;
  bool isDone;
  bool isTotallyDone;
  int executorID;
  String completionDate;
  String deadLine;
  ChildSubTaskModel(this.subTaskID,this.parent,this.projectID,this.title,this.isDone,this.isTotallyDone,this.executorID,this.completionDate,this.deadLine);
  ChildSubTaskModel.fromJson(Map<String,dynamic> json)
      :subTaskID = json['subTaskID'],
        parent = json['parent'],
        projectID = json['projectID'],
        title = json['title'],
        isDone = json['isDone'],
        isTotallyDone = json['isTotallyDone'],
        executorID = json['executorID'],
        completionDate = json['completionDate'],
        deadLine = json['deadLine'];
  Map<String,dynamic> toJson() => {
    'subTaskID' : subTaskID,
    'parent' : parent,
    'projectID' : projectID,
    'title' : title,
    'isDone' : isDone,
    'isTotallyDone' : isTotallyDone,
    'executorID' : executorID,
    'completionDate' : completionDate,
    'deadLine' : deadLine
  };
}