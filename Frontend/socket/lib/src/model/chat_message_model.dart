class ChatMessageModel {
  int chatId;
  int to;
  int from;
  String message;
  bool toUserOnlineStatus;
  String chatType;
  bool isFromMe;

  ChatMessageModel(
      {this.chatId,
      this.to,
      this.from,
      this.message,
      this.toUserOnlineStatus,
      this.chatType,
      this.isFromMe});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
          chatId: json["chat_id"],
          to: json["to"],
          from: json["from"],
          message: json["message"],
          toUserOnlineStatus: json["to_user_online_status"],
          chatType: json["chatType"]);

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "to": to,
        "from": from,
        "message": message,
        "to_user_online_status": toUserOnlineStatus,
        "chatType": chatType
      };
}
