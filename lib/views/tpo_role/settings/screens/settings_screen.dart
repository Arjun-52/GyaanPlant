import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/settings_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/settings/screens/security_screen.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/support_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _vm;
  bool _pushNotifications = true;
  bool _emailNotifications = true;

  @override
  void initState() {
    super.initState();
    _vm = SettingsViewModel();
    _vm.initialize();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        body: Consumer<SettingsViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  /// 🟢 TITLE BAR
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          _buildVerificationPill(),
                        ],
                      ),
                    ),
                  ),

                  /// 🟢 PROFILE HERO SECTION
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: _buildProfileHero(vm),
                    ),
                  ),

                  /// 🟢 QUICK STATS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildQuickStats(),
                    ),
                  ),

                  /// 🟢 SETTINGS CATEGORIES
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            "Preferences & Settings",
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        /// 🎧 Support Center
                        const SupportCard(),

                        const SizedBox(height: 12),

                        /// 🔒 Security Card
                        _buildSecurityCard(),

                        const SizedBox(height: 12),

                        /// 🔔 Notification Card
                        _buildNotificationCard(),

                        const SizedBox(height: 24),

                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            "Account Actions",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        /// 🚪 Logout Danger Card
                        _buildLogoutCard(),

                        const SizedBox(height: 30),

                        /// 📈 PROFILE INSIGHTS FOOTER
                        _buildProfileInsightsFooter(),

                        const SizedBox(height: 30),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔷 VERIFICATION PILL
  Widget _buildVerificationPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00C853).withOpacity(0.3),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: Color(0xFF00E676), size: 13),
          SizedBox(width: 4),
          Text(
            "VERIFIED PARTNER",
            style: TextStyle(
              color: Color(0xFF00E676),
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔷 PROFILE HERO CARD
  Widget _buildProfileHero(SettingsViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B2E), Color(0xFF031410)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.06),
            blurRadius: 25,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00E676),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.3),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF0A1F1A),
                  child: Text(
                    vm.userName.isNotEmpty ? vm.userName.substring(0, 1).toUpperCase() : 'T',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Director of Placements (TPO)',
                      style: TextStyle(
                        color: const Color(0xFF00E676).withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vm.collegeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.greenAccent.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Institutional Profile Status",
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "92% Complete",
                        style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: const LinearProgressIndicator(
                      value: 0.92,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔷 QUICK STATISTICS GRID
  Widget _buildQuickStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard("👨‍🎓 Students", "1,250 Total", "Managed profiles"),
          const SizedBox(width: 12),
          _buildStatCard("🚀 Active Drives", "8 Ongoing", "Placement drives"),
          const SizedBox(width: 12),
          _buildStatCard("📊 Placements", "85% Rate", "Current success"),
          const SizedBox(width: 12),
          _buildStatCard("🏫 College Rating", "A++ / Premium", "Institutional rating"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF091F18), Color(0xFF04100C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔷 SECURITY CARD
  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C221B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.08),
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SecurityScreen(),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_outline, color: Color(0xFF00E676), size: 20),
        ),
        title: const Text(
          "Security & Privacy",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: const Row(
          children: [
            Icon(Icons.shield, color: Color(0xFF00E676), size: 10),
            SizedBox(width: 4),
            Text(
              "2FA Enabled • Protected Account",
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
      ),
    );
  }

  /// 🔷 NOTIFICATIONS CARD WITH SWITCHES
  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C221B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none, color: Color(0xFF00E676), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Notifications Preferences",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSwitchRow(
            title: "Push Notifications",
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          const Divider(color: Colors.white10),
          _buildSwitchRow(
            title: "Email Notifications",
            value: _emailNotifications,
            onChanged: (val) => setState(() => _emailNotifications = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({required String title, required bool value, required Function(bool) onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00E676),
          activeTrackColor: const Color(0xFF00C853).withOpacity(0.2),
          inactiveThumbColor: Colors.white30,
          inactiveTrackColor: Colors.white10,
        ),
      ],
    );
  }

  /// 🔷 HELP & SUPPORT CARD
  Widget _buildHelpSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C221B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: Color(0xFF00E676), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Help & Support Center",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSupportPill(" FAQs ", Icons.question_answer_outlined),
              _buildSupportPill("Raise Ticket", Icons.add_circle_outline),
              _buildSupportPill("Contact Us", Icons.mail_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// 🔷 LOGOUT DANGER CARD
  Widget _buildLogoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B0C0C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        onTap: _showLogoutConfirmDialog,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
        ),
        title: const Text(
          "🚪 Logout",
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: const Text(
          "Securely clear credentials and sign out of session",
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.redAccent, size: 14),
      ),
    );
  }

  void _showLogoutConfirmDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF020B08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 25,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sign Out",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to logout of your TPO partner credentials?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Logout"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout == true) {
      await LocalStorageService.clearToken();
      if (mounted) context.go('/');
    }
  }

  /// 🔷 PROFILE INSIGHTS FOOTER
  Widget _buildProfileInsightsFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF051410),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.05),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 14),
              SizedBox(width: 8),
              Text(
                "Profile Guidelines",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Insight: Your institutional security index is rated High. Update credentials periodically to keep your partner college portal completely secured.",
            style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            "Application Version: v1.0.2 - Premium Tier",
            style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
