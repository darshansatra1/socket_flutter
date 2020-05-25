import 'package:socket/services/socket_utils.dart';
import 'package:socket/src/model/user.dart';

class G {
  static List<User> dummyUsers;
  static User loggedInUsers;
  static User toChatUser;
  static SocketUtils socketUtils;

  static void initDummyUsers() {
    User userA = User(id: 1000, name: 'A', email: 'testa@gmail.com');
    User userB = User(id: 1001, name: 'B', email: 'testb@gmail.com');
    dummyUsers = List();
    dummyUsers.add(userA);
    dummyUsers.add(userB);
  }

  static List<User> getUsersFor(User user) {
    List<User> filterUsers = dummyUsers
        .where((u) => (!u.name.toLowerCase().contains(user.name.toLowerCase())))
        .toList();
    return filterUsers;
  }

  static initSocket() {
    if (socketUtils == null) {
      socketUtils = SocketUtils();
    }
  }
}
