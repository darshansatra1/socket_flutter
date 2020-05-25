var express = require("express");
var app = express();
var server = require("http").createServer(app);
var io = require("socket.io")(server);

let ON_CONNECTION = "connection";
let ON_DISCONNECT = "disconnect";

// Main Events
let EVENT_IS_USER_ONLINE = "check_online";
let EVENT_SINGLE_CHAT_MESSAGE = "single_chat_message";

// Sub Events
let SUB_EVENT_RECEIVE_MESSAGE = "receive_message";
let SUB_EVENT_IS_USER_CONNECTED = "is_user_connected";

let listen_port = 4000;

let STATUS_MESSAGE_NOT_SENT = 10001;
let STATUS_MESSAGE_SENT = 10001;

const userMap = new Map();

io.sockets.on(ON_CONNECTION, (socket) => {
  onEachUserConnection(socket);
});

function onEachUserConnection(socket) {
  var query = stringifyJson(socket.handshake.query);
  print("-----");
  print("Connected => Socket ID: " + socket.id + ", Users: " + query);

  var from_user_id = socket.handshake.query.from;
  var userMapVal = { socket_id: socket.id };
  addUserToMap(from_user_id, userMapVal);
  printOnlineUser();

  onMessage(socket);
  checkOnline(socket);
  onDisconnect(socket);
}

function checkOnline(socket) {
  socket.on(EVENT_IS_USER_ONLINE, function (chat_message) {
    onlineCheckHandler(socket, chat_message);
  });
}

function onlineCheckHandler(socket, chat_user_details) {
  let to_user_id = chat_user_details.to;
  print("Checking Online User => " + to_user_id);
  let to_user_socket_id = getSocketIDFromMapForThisUser(to_user_id);
  let isOnline = undefined != to_user_socket_id;
  chat_user_details.to_user_online_status = isOnline;
  sendBackToClient(
    socket,
    to_user_socket_id,
    SUB_EVENT_IS_USER_CONNECTED,
    chat_user_details
  );
}

function sendBackToClient(socket, to_user_socket_id, event, chat_message) {
  socket.emit(event, stringifyJson(chat_message));
}

function onMessage(socket) {
  socket.on(EVENT_SINGLE_CHAT_MESSAGE, function (chat_message) {
    singleChatHandler(socket, chat_message);
  });
}

function singleChatHandler(socket, chat_message) {
  print("onMessage: " + stringifyJson(chat_message));
  let to_user_id = chat_message.to;
  let from_user_id = chat_message.from;
  print(from_user_id + "=>" + to_user_id);
  // to_user_id
  var to_user_socket_id = getSocketIDFromMapForThisUser(to_user_id);
  if (to_user_socket_id == undefined) {
    print("User not online");
    chat_message.to_user_online_status = false;
    return;
  }
  chat_message.to_user_online_status = true;
  sentToConnectedSocket(
    socket,
    to_user_socket_id,
    SUB_EVENT_RECEIVE_MESSAGE,
    chat_message
  );
}

function sentToConnectedSocket(socket, to_user_socket_id, event, chat_message) {
  socket.to(to_user_socket_id).emit(event, stringifyJson(chat_message));
  // socket.emit(event, stringifyJson(chat_message));
}

function getSocketIDFromMapForThisUser(to_user_id) {
  let userMapVal = userMap.get(to_user_id.toString());
  if (undefined == userMapVal) {
    return undefined;
  }
  return userMapVal.socket_id;
}

function onDisconnect(socket) {
  socket.on(ON_DISCONNECT, function () {
    removeUserWithSocketIDFromMap(socket.id);
    socket.removeAllListeners(SUB_EVENT_RECEIVE_MESSAGE);
    socket.removeAllListeners(SUB_EVENT_IS_USER_CONNECTED);
    socket.removeAllListeners(ON_DISCONNECT);
  });
}

function removeUserWithSocketIDFromMap(socket_id) {
  print("Deleting User : " + socket_id);
  let toDeleteUser;
  for (let key of userMap) {
    let userMapVal = key[1];
    if (userMapVal.socket_id == socket_id) {
      toDeleteUser = key[0];
    }
  }
  print("Deleting User : " + toDeleteUser);
  if (undefined != toDeleteUser) {
    userMap.delete(toDeleteUser);
  }
  print(userMap);
  printOnlineUser();
}

function addUserToMap(key_user_id, socket_id) {
  userMap.set(key_user_id, socket_id);
}

function printOnlineUser() {
  print("Online Users : " + userMap.size);
}

function print(txt) {
  console.log(txt);
}

function stringifyJson(data) {
  return JSON.stringify(data);
}
app.get("/", (req, res) => {
  res.send("Hello");
});

server.listen(listen_port, () => print("Listening"));
