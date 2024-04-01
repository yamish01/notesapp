class NotesModel {
  String? title;
  String? description;
  String? id;

  NotesModel({
    this.title,
    this.description,
    this.id,
  });

  factory NotesModel.fromJson(Map<String, dynamic> json) => NotesModel(
        title: json["title"],
        description: json["description"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "id": id,
      };
}
