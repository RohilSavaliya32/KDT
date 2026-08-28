import '../services/firebase_otp_service.dart';

class FirebaseRepository {
  final FirebaseOtpService otpService;

  FirebaseRepository(this.otpService);

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) {
    return otpService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  Future verifyOtp({
    required String verificationId,
    required String otp,
  }) {
    return otpService.verifyOtp(
      verificationId: verificationId,
      otp: otp,
    );
  }
}