import 'dart:io';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:socket/src/model/chat_message_model.dart';
import 'package:socket/src/model/user.dart';

class SocketUtils {
  // static String _serverIP = "http://10.0.0.2";
  static String _serverIP = "http://192.168.0.107";
  static const int SERVER_PORT = 4000;
  static String _connectUrl = "$_serverIP:$SERVER_PORT";

  static const String _ON_MESSAGE_RICEIVED = "receive_message";
  static const String _IS_USER_ONLINE_EVENT = "check_online";
  static const EVENT_SINGLE_CHAT_MESSAGE = "single_chat_message";
  static const EVENT_USER_ONLINE = "is_user_connected";

  static const int STATUS_MESSAGE_NOT_SENT = 10001;
  static const int STATIS_MESSAGE_SENT = 10002;

  static const String SINGLE_CHAT = "single_chat";

  User _fromUser;

  SocketIO _socket;
  SocketIOManager _manager;

  initSocket(User fromUser) async {
    this._fromUser = fromUser;
    print('Connecting ...${_fromUser.name}.....');
    await _init();
  }

  _init() async {
    _manager = SocketIOManager();
    _socket = await _manager.createInstance(_socketOptions());
  }

  connectToSocket() {
    if (null == _socket) {
      print('Socket is null');
      return;
    }
    _socket.connect();
  }

  _socketOptions() {
    final Map<String, String> userMap = {"from": _fromUser.id.toString()};

    return SocketOptions(_connectUrl,
        enableLogging: true,
        transports: [Transports.WEB_SOCKET],
        query: userMap);
  }

  setOnConnection(Function onConnection) {
    _socket.onConnect((data) {
      onConnection(data);
    });
  }

  setOnConnetionTimeOut(Function onConnectionTimeOut) {
    _socket.onConnectTimeout((data) {
      onConnectionTimeOut(data);
    });
  }

  setOnConnectionErrorListener(Function onConnectionError) {
    _socket.onConnectError((data) {
      onConnectionError(data);
    });
  }

  setOnErrorListener(Function onError) {
    _socket.onError((data) {
      onError(data);
    });
  }

  setOnDisconnectListener(Function onDisconnect) {
    _socket.onError((data) {
      onDisconnect(data);
    });
  }

  closeConnection() {
    if (_socket != null) {
      print('Closing Connection');
      _manager.clearInstance(_socket);
    }
  }

  sendSingleChatMessage(ChatMessageModel chatMessageModel) {
    if (_socket == null) {
      print('Cannot Send Message');
      return;
    }
    _socket.emit(EVENT_SINGLE_CHAT_MESSAGE, [chatMessageModel.toJson()]);
  }

  setOnChatMessageReceiveListener(Function onChatMessageReceived) {
    _socket.on(_ON_MESSAGE_RICEIVED, (data) {
      print('Message Received');
      onChatMessageReceived(data);
    });
  }

  setOnlinUserStatusListener(Function onUserStatus) {
    _socket.on(EVENT_USER_ONLINE, (data) {
      onUserStatus(data);
    });
  }

  checkOnline(ChatMessageModel chatMessageModel) {
    if (_socket == null) {
      print('Cannot check the online status');
      return;
    }
    _socket.emit(_IS_USER_ONLINE_EVENT, [chatMessageModel.toJson()]);
  }
}
