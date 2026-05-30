import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _oldFocusNode = FocusNode();
  final _newFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Trigger local listeners for real-time validation
    _oldPasswordController.addListener(() => setState(() {}));
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldFocusNode.dispose();
    _newFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  // Reactive Validation states
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasConfirmMatch =>
      _newPasswordController.text == _confirmPasswordController.text && _confirmPasswordController.text.isNotEmpty;
  bool get _hasSecureStandards =>
      _newPasswordController.text.contains(RegExp(r'[A-Z]')) &&
      _newPasswordController.text.contains(RegExp(r'[0-9]'));

  bool get _isValid => _hasMinLength && _hasConfirmMatch && _hasSecureStandards && _oldPasswordController.text.isNotEmpty;

  void _handleUpdate() {
    if (!_isValid) return;

    // Premium Floating Success State
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1F18).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00E676).withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.12),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF020B08),
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Password updated successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: SafeArea(
        child: Column(
          children: [
            /// Premium Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Security Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      /// Security Hero Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0C241B).withOpacity(0.6),
                              const Color(0xFF04100C).withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: const Color(0xFF00E676).withOpacity(0.15),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: Color(0xFF00E676),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Security Settings',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage and protect your account credentials.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Password Form Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1410).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF00E676).withOpacity(0.1),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPasswordField(
                              'Old Password',
                              _oldPasswordController,
                              _oldFocusNode,
                              _obscureOld,
                              () => setState(() => _obscureOld = !_obscureOld),
                            ),
                            const SizedBox(height: 20),
                            _buildPasswordField(
                              'New Password',
                              _newPasswordController,
                              _newFocusNode,
                              _obscureNew,
                              () => setState(() => _obscureNew = !_obscureNew),
                            ),
                            const SizedBox(height: 20),
                            _buildPasswordField(
                              'Confirm Password',
                              _confirmPasswordController,
                              _confirmFocusNode,
                              _obscureConfirm,
                              () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Password Requirements Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1410).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF00E676).withOpacity(0.08),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF00E676),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Password Requirements',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildRequirementRow('Minimum 8 characters length', _hasMinLength),
                            const SizedBox(height: 10),
                            _buildRequirementRow('Passwords match each other', _hasConfirmMatch),
                            const SizedBox(height: 10),
                            _buildRequirementRow('Contains Uppercase (A-Z) and Number (0-9)', _hasSecureStandards),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// Update Password Button (Gradient CTA)
                      MouseRegion(
                        cursor: _isValid ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: _isValid
                                ? const LinearGradient(
                                    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: _isValid ? null : const Color(0xFF1A2D25),
                            boxShadow: [
                              if (_isValid)
                                BoxShadow(
                                  color: const Color(0xFF00E676).withOpacity(0.3),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isValid ? _handleUpdate : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_person_rounded,
                                  color: _isValid ? const Color(0xFF031B15) : Colors.white24,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Update Password',
                                  style: TextStyle(
                                    color: _isValid ? const Color(0xFF031B15) : Colors.white24,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    bool isObscure,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E1A16).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isObscure,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: const TextStyle(
                color: Colors.white24,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isChecked) {
    final activeColor = const Color(0xFF00E676);
    final inactiveColor = Colors.white24;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isChecked ? activeColor.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isChecked ? activeColor : inactiveColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            color: isChecked ? activeColor : Colors.transparent,
            size: 12,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: isChecked ? Colors.white : Colors.white38,
              fontSize: 12,
              fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.2,
            ),
            child: Text(text),
          ),
        ),
      ],
    );
  }
}

