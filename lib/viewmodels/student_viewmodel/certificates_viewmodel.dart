import 'package:flutter/foundation.dart';

/// Model for certificate data
class CertificateModel {
  final String id;
  final String title;
  final String issuer;
  final String date;
  final String certificateId;
  final bool isVerified;
  final String shareUrl;

  CertificateModel({
    required this.id,
    required this.title,
    required this.issuer,
    required this.date,
    required this.certificateId,
    this.isVerified = true,
    required this.shareUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      issuer: json['issuer']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      certificateId: json['certificateId']?.toString() ?? '',
      isVerified: json['isVerified'] ?? true,
      shareUrl: json['shareUrl']?.toString() ?? '',
    );
  }
}

/// ViewModel for managing certificates
class CertificatesViewModel extends ChangeNotifier {
  // State variables
  List<CertificateModel> _certificates = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CertificateModel> get certificates => _certificates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCertificates => _certificates.isNotEmpty;
  bool get hasError => _errorMessage != null;

  /// Initialize the ViewModel and fetch certificates
  Future<void> initialize() async {
    await fetchCertificates();
  }

  /// Fetch certificates from API (placeholder for future API integration)
  Future<void> fetchCertificates() async {
    print("📜 CertificatesViewModel: Fetching certificates...");
    
    _setLoading(true);
    _clearError();

    try {
      // TODO: Replace with actual API call when completed courses API is ready
      // final response = await ApiClient.getCertificates();
      // _certificates = response.data.map((json) => CertificateModel.fromJson(json)).toList();
      
      // For now, keep empty to show empty state
      _certificates = [];
      
      print("✅ CertificatesViewModel: Fetched ${_certificates.length} certificates");
      
    } catch (e) {
      print("❌ CertificatesViewModel: Error fetching certificates: $e");
      _setError('Failed to load certificates: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Share certificate
  Future<void> shareCertificate(CertificateModel certificate) async {
    try {
      print("📤 Sharing certificate: ${certificate.title}");
      
      // TODO: Implement share functionality
      // await Share.share(certificate.shareUrl);
      
    } catch (e) {
      print("❌ Error sharing certificate: $e");
    }
  }

  /// Download certificate PDF
  Future<void> downloadCertificate(CertificateModel certificate) async {
    try {
      print("📥 Downloading certificate: ${certificate.title}");
      
      // TODO: Implement download functionality
      // await ApiClient.downloadCertificate(certificate.id);
      
    } catch (e) {
      print("❌ Error downloading certificate: $e");
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Retry fetching certificates
  Future<void> retry() async {
    await fetchCertificates();
  }

  // Private helper methods

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("📜 CertificatesViewModel: Disposed");
    super.dispose();
  }
}
