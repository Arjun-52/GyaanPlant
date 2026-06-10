import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';
import 'package:gyaanplant/network/auth_cache.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';

class GoogleAuthWebViewScreen extends StatefulWidget {
  const GoogleAuthWebViewScreen({super.key});

  @override
  State<GoogleAuthWebViewScreen> createState() => _GoogleAuthWebViewScreenState();
}

class _GoogleAuthWebViewScreenState extends State<GoogleAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            print("🌐 WebView navigating to: $url");

            if (url.contains('/auth/success')) {
              // Existing User Login Success
              try {
                final uri = Uri.parse(url);
                final token = uri.queryParameters['token'];
                final encodedUser = uri.queryParameters['user'];

                if (token != null && token.isNotEmpty && encodedUser != null) {
                  print("✅ Login Success intercepted. Token and User JSON extracted.");
                  final userData = jsonDecode(Uri.decodeComponent(encodedUser));
                  final roleStr = userData['role']?.toString().toLowerCase() ?? 'student';

                  // Save credentials
                  AuthCache.token = token;
                  AuthCache.role = roleStr;
                  await LocalStorageService.saveToken(token);
                  await LocalStorageService.saveRole(roleStr);
                  await LocalStorageService.saveUser(userData);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logged in successfully!"),
                        backgroundColor: Color(0xFF00E676),
                      ),
                    );
                    context.go('/');
                  }
                }
              } catch (e) {
                print("💥 Error parsing success redirect: $e");
              }
              return NavigationDecision.prevent;
            } else if (url.contains('google=true')) {
              // New User Registration pre-fill
              try {
                final uri = Uri.parse(url);
                final tempToken = uri.queryParameters['tempToken'];
                final email = uri.queryParameters['email'];
                final name = uri.queryParameters['name'];
                final picture = uri.queryParameters['picture'];

                if (tempToken != null && tempToken.isNotEmpty) {
                  print("✅ Registration pre-fill intercepted. tempToken extracted.");
                  if (mounted) {
                    final vm = Provider.of<AuthViewModel>(context, listen: false);
                    vm.prefillGoogleData(
                      name: Uri.decodeComponent(name ?? ''),
                      email: email ?? '',
                      tempToken: tempToken,
                      picture: picture != null ? Uri.decodeComponent(picture) : null,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile pre-filled from Google!"),
                        backgroundColor: Color(0xFF00E676),
                      ),
                    );
                    context.go('/signup');
                  }
                }
              } catch (e) {
                print("💥 Error parsing registration redirect: $e");
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://prod-apis.gyaanplant.co.in/api/v1/auth/google'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F1A),
        elevation: 0,
        title: const Text(
          'Google Sign-In',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00E676),
              ),
            ),
        ],
      ),
    );
  }
}
