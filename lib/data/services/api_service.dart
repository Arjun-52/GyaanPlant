import '../../network/api_manager.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/drive_repository.dart';
import '../../repositories/gamification_repository.dart';
import '../../repositories/learning_repository.dart';
import '../../repositories/student_repository.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final NetworkAPIManager _api = NetworkAPIManager.instance;

  late final AuthRepository _auth = AuthRepository(_api);
  late final StudentRepository _student = StudentRepository(_api);
  late final DriveRepository _drive = DriveRepository(_api);
  late final LearningRepository _learning = LearningRepository(_api);
  late final GamificationRepository _gamification = GamificationRepository(_api);

  AuthRepository get auth => _auth;
  StudentRepository get student => _student;
  DriveRepository get drive => _drive;
  LearningRepository get learning => _learning;
  GamificationRepository get gamification => _gamification;
}
