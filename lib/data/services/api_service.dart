import '../../models/auth/college_dropdown_model.dart';
import '../../models/mentor_models/mentor_earnings_model.dart';
import '../../network/api_manager.dart';
import '../../network/api_response.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/drive_repository.dart';
import '../../repositories/gamification_repository.dart';
import '../../repositories/learning_repository.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/student_repository.dart';
import '../../repositories/tpo_repository.dart';
import '../../repositories/hod_repository.dart';
import '../../repositories/mentor_repository.dart';
import '../../repositories/college_repository.dart';
import '../../repositories/organization_repository.dart';
import '../../repositories/assessment_repository.dart';
import '../../repositories/tpo_notification_repository.dart';
import '../../repositories/support_repository.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final NetworkAPIManager _api = NetworkAPIManager.instance;

  late final AuthRepository _auth = AuthRepository(_api);
  late final StudentRepository _student = StudentRepository(_api);
  late final DriveRepository _drive = DriveRepository(_api);
  late final LearningRepository _learning = LearningRepository(_api);
  late final PaymentRepository _payment = PaymentRepository(_api);
  late final GamificationRepository _gamification = GamificationRepository(
    _api,
  );
  late final TpoRepository _tpo = TpoRepository(_api);
  late final HodRepository _hod = HodRepository(_api);
  late final MentorRepository _mentor = MentorRepository(_api);
  late final CollegeRepository _college = CollegeRepository(_api);
  late final OrganizationRepository _organization = OrganizationRepository(_api);
  late final AssessmentRepository _assessment = AssessmentRepository(_api);
  late final TpoNotificationRepository _tpoNotification = TpoNotificationRepository(_api);
  late final SupportRepository _support = SupportRepository(_api);

  AuthRepository get auth => _auth;
  StudentRepository get student => _student;
  DriveRepository get drive => _drive;
  LearningRepository get learning => _learning;
  PaymentRepository get payment => _payment;
  GamificationRepository get gamification => _gamification;
  TpoRepository get tpo => _tpo;
  HodRepository get hod => _hod;
  MentorRepository get mentor => _mentor;
  CollegeRepository get college => _college;
  OrganizationRepository get organization => _organization;
  AssessmentRepository get assessment => _assessment;
  TpoNotificationRepository get tpoNotification => _tpoNotification;
  SupportRepository get support => _support;

  /// Pass-through used by registration flow to fetch the college dropdown list.
  Future<ApiResponse<List<CollegeDropdownModel>>> getColleges() =>
      _college.getColleges();

  /// Pass-through to fetch mentor earnings details.
  Future<ApiResponse<MentorEarningsModel>> getMentorEarnings() =>
      _mentor.getMentorEarnings();
}
