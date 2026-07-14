import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'campus_scaffold.dart';

class ModernCampusApp extends StatelessWidget {
  const ModernCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom theme matching the Stitch design tokens.
    final primaryColor = const Color(0xFF0D2B22);
    final secondaryColor = const Color(0xFFF4743B);
    final tertiaryColor = const Color(0xFF8DAA91);
    final surfaceColor = const Color(0xFFF8FAFC);
    final onSurfaceColor = const Color(0xFF0B1C30);
    final onSurfaceVariantColor = const Color(0xFF414845);

    return MaterialApp(
      title: 'Modern Campus Redesign',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: surfaceColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFC9EADC),
          onPrimaryContainer: const Color(0xFF022018),
          secondary: secondaryColor,
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFFDBCE),
          onSecondaryContainer: const Color(0xFF370E00),
          tertiary: tertiaryColor,
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFCCEACF),
          onTertiaryContainer: const Color(0xFF062010),
          surface: surfaceColor,
          onSurface: onSurfaceColor,
          outline: const Color(0xFF727975),
          shadow: primaryColor.withOpacity(0.04),
        ),
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.02,
            ),
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.01,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            labelMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceColor,
          foregroundColor: primaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const QRCampusHubScreen(),
    );
  }
}

class QRCampusHubScreen extends StatefulWidget {
  const QRCampusHubScreen({super.key});

  @override
  State<QRCampusHubScreen> createState() => _QRCampusHubScreenState();
}

class _QRCampusHubScreenState extends State<QRCampusHubScreen> {
  String selectedMeal = 'Breakfast';

  final List<String> meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  final Map<String, String> mealTimes = {
    'Breakfast': '7:30 AM – 10:00 AM',
    'Lunch': '12:00 PM – 2:30 PM',
    'Snacks': '4:30 PM – 6:00 PM',
    'Dinner': '7:30 PM – 10:00 PM',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      // title: 'Campus Hub',
      // activeIndex: 0, // Maps to the Home context
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mess Menu Section
              _buildSectionTitle(
                context,
                'Mess Menu',
                trailing: _buildMessDropdown(context),
              ),
              const SizedBox(height: 16),
              _buildMessMenuSection(
                context,
                primaryColor,
                secondaryColor,
                onSurfaceVariant,
              ),
              const SizedBox(height: 32),

              // My QR Hub Card
              _buildMyQRCard(context, primaryColor, secondaryColor),
              const SizedBox(height: 32),

              // Services Grid Section
              _buildSectionTitle(context, 'Services'),
              const SizedBox(height: 16),
              _buildServicesGrid(
                context,
                primaryColor,
                secondaryColor,
                onSurfaceVariant,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildMessDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tue, H-1',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF414845),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: Color(0xFF414845),
          ),
        ],
      ),
    );
  }

  Widget _buildMessMenuSection(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
    Color onSurfaceVariant,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal Type Filters (Vertical list of buttons on the left)
        Column(
          children: meals.map((meal) {
            final isSelected = selectedMeal == meal;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedMeal = meal;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? secondaryColor
                      : const Color(0xFFEFF4FF),
                  foregroundColor: isSelected ? Colors.white : onSurfaceVariant,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  meal,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(width: 16),

        // Menu Card (Right side)
        Expanded(
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Inner "No menu uploaded" area
                Expanded(
                  child: Center(
                    child: Text(
                      'No menu uploaded',
                      style: TextStyle(
                        color: onSurfaceVariant.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                // Footer with timing gradient
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(15),
                    ),
                    gradient: LinearGradient(
                      colors: [secondaryColor, const Color(0xFFFFDBCE)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealTimes[selectedMeal] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyQRCard(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening Campus QR Code...')),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative background shape top-right
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFDBCE).withOpacity(0.15),
                  ),
                ),
              ),
              // Decorative background shape bottom-left
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: secondaryColor.withOpacity(0.08),
                  ),
                ),
              ),
              // Card Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'My QR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Mess • Gym • Swimming & more...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
    Color onSurfaceVariant,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: [
        // Buy & Sell Service Card
        _buildServiceCard(
          context: context,
          title: 'Buy & Sell',
          subtitle: 'Deals made easy',
          badge: 'NEW!',
          iconWidget: Opacity(
            opacity: 0.9,
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 44,
              color: primaryColor,
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Buy & Sell catalog...')),
            );
          },
        ),
        // Maps Service Card
        _buildServiceCard(
          context: context,
          title: 'Maps',
          subtitle: 'Navigate Insti',
          iconWidget: Opacity(
            opacity: 0.9,
            child: Icon(Icons.map_outlined, size: 44, color: primaryColor),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Campus Map...')),
            );
          },
        ),
        // Blogs Service Card
        _buildServiceCard(
          context: context,
          title: 'Blogs',
          subtitle: 'Updates',
          iconWidget: SizedBox(
            width: 44,
            height: 44,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida/AP1WRLtgpGEJQGpKCAm4WTsQp1gngLpoD4VF9HkUUdQQUAiqI4sfpvPuPLtKQ26JDdOqMcuiWCizZlj_rvbIkBXhxT1kkN9acT9U0E4p2fIeFeD2ipeAv93PznomsH8P_ZdZRNxTWpCB-YJei9SMqZ0mIr-UTN1i3-Dr7rHommbtRI69Kep80Q7OEhe2ts0Gmz39ANJUUnMYYON_w3TNotIpa2BUThhCvdMPZxldANttn7gne9e7iTXV4UlruIY',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.article_outlined, size: 44, color: primaryColor),
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Campus Blogs...')),
            );
          },
        ),
        // Quick Links Service Card
        _buildServiceCard(
          context: context,
          title: 'Quick Links',
          subtitle: 'Useful Insti Links',
          iconWidget: SizedBox(
            width: 44,
            height: 44,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida/AP1WRLs81_pepat3rPg_WQ6Mg7tlq7FntdqAlOVdXf-U_Z4tjEW8xjuTDe6TmlMfMoeySXTBbejwzwXIsuGE-a6SkVTfAUTATm9kpJwrueu4vaDIaNd8L5X3FYickWqmiZsTMLJ98qASI9xmDMIO45RgLkHHw57REKLKtIxAqZK3i00O4TxErsTXa1s_wq0pViPy_Znm2IvE2ZaO6-swc2J2z53MAmbNwvQRdlfVPmeRGxCYj-Kuowxff7GGVw',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.link_rounded, size: 44, color: primaryColor),
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Quick Links...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    String? badge,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: SizedBox(width: 56, height: 56, child: iconWidget),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
