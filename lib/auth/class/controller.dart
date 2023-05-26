import 'package:chat/auth/class/auth.dart';
import 'package:chat/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class AuthController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getUserCurrentData();
    return user;
  }

  Stream<UserModel> userDataById(String userID) {
    return authRepository.userData(userID);
  }

  void setUserState(bool isOnline) async {
    authRepository.setUserState(isOnline);
  }
}
