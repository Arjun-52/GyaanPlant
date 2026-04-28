class ApiEndpoints {
  ApiEndpoints._();

  // ── Health ──────────────────────────────────────────────────────────────
  static const String health = '/api/v1/health';

  // ── Uploads ─────────────────────────────────────────────────────────────
  static const String presigned = '/api/v1/uploads/presigned';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String logout = '/api/v1/auth/logout';
  static const String refresh = '/api/v1/auth/refresh';
  static const String me = '/api/v1/auth/me';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/change-password';

  // ── Users ────────────────────────────────────────────────────────────────
  static const String users = '/api/v1/users';
  static const String updateMyProfile = '/api/v1/users/me';

  // ── Colleges ─────────────────────────────────────────────────────────────
  static const String colleges = '/api/v1/colleges';

  // ── Students ─────────────────────────────────────────────────────────────
  static const String students = '/api/v1/student';
  static const String studentMe = '/api/v1/student/me';
  static const String studentReadiness = '/api/v1/student/readiness';

  // ── Organizations ────────────────────────────────────────────────────────
  static const String organizations = '/api/v1/organization';

  // ── Employees ────────────────────────────────────────────────────────────
  static const String employees = '/api/v1/employees';
  static const String employeeProfile = '/api/v1/employees/profile';
  static const String employeeMe = '/api/v1/employees/me';
  static const String employeeCollarTypes = '/api/v1/employees/collar-types';
  static const String employeeStats = '/api/v1/employees/stats';
  static const String employeeDepartments = '/api/v1/employees/departments';
  static const String employeeAppraisals = '/api/v1/employees/appraisals';

  // ── MOU ──────────────────────────────────────────────────────────────────
  static const String mou = '/api/v1/mou';
  static const String mouStats = '/api/v1/mou/stats';

  // ── Mentors ──────────────────────────────────────────────────────────────
  static const String mentors = '/api/v1/mentor';

  // ── Sessions ─────────────────────────────────────────────────────────────
  static const String sessionMy = '/api/v1/session/my';
  static const String sessions = '/api/v1/session';

  // ── Placement Drives ─────────────────────────────────────────────────────
  static const String drives = '/api/v1/drive';
  static const String driveShortlistSummary = '/api/v1/drive/shortlist-summary';
  static const String driveMyApplications = '/api/v1/drive/my-applications';

  // ── Learning ─────────────────────────────────────────────────────────────
  static const String learning = '/api/v1/learning';
  static const String myEnrollments = '/api/v1/learning/my-courses';
  static const String bulkAssign = '/api/v1/learning/bulk-assign';
  static const String learningPaths = '/api/v1/learning/paths';
  static const String assessments = '/api/v1/learning/assessments';
  static const String myAssessmentHistory = '/api/v1/learning/assessments/my-history';

  // ── Gamification ─────────────────────────────────────────────────────────
  static const String gamificationProfile = '/api/v1/gamification/profile';
  static const String leaderboard = '/api/v1/gamification/leaderboard';
  static const String collarLeaderboard = '/api/v1/gamification/leaderboard/collar';
  static const String badges = '/api/v1/gamification/badges';
  static const String pointHistory = '/api/v1/gamification/point-history';
  static const String awardPoints = '/api/v1/gamification/award';
  static const String gamificationOrgStats = '/api/v1/gamification/org-stats';

  // ── Invites ──────────────────────────────────────────────────────────────
  static const String invites = '/api/v1/invites';
  static const String invitesBulk = '/api/v1/invites/bulk';
  static const String myInvites = '/api/v1/invites/my-invites';
  static const String invitesAccept = '/api/v1/invites/invites/accept';
  static const String invitesCleanup = '/api/v1/invites/cleanup';

  // ── Problems ─────────────────────────────────────────────────────────────
  static const String problems = '/api/v1/problems';
  static const String problemsRun = '/api/v1/problems/run';
  static const String mySubmissions = '/api/v1/problems/me/submissions';

  // ── Departments ──────────────────────────────────────────────────────────
  static const String departments = '/api/v1/departments';
  static const String departmentHods = '/api/v1/departments/hods';

  // ── Syllabus ─────────────────────────────────────────────────────────────
  static const String syllabus = '/api/v1/syllabus';

  // ── Dashboard ────────────────────────────────────────────────────────────
  static const String dashboardAdmin = '/api/v1/dashboard/admin';
  static const String dashboardCollegeAdmin = '/api/v1/dashboard/college-admin';
  static const String dashboardExecutive = '/api/v1/dashboard/executive';
  static const String dashboardHr = '/api/v1/dashboard/hr';
  static const String dashboardLd = '/api/v1/dashboard/ld';
  static const String dashboardEmployee = '/api/v1/dashboard/employee';
  static const String dashboardStudent = '/api/v1/dashboard/student';
  static const String dashboardDeptHead = '/api/v1/dashboard/dept-head';
  static const String dashboardMentor = '/api/v1/dashboard/mentor';
  static const String dashboardTpo = '/api/v1/dashboard/tpo';
  static const String dashboardHod = '/api/v1/dashboard/hod';
  static const String dashboardAnalytics = '/api/v1/dashboard/analytics';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notifications = '/api/v1/notification';
}
