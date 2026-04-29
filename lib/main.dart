import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pages/cooling_calculation_page.dart';
import 'pages/heating_calculation_page.dart';
import 'pages/radiator_heating_page.dart';
import 'pages/underfloor_heating_page.dart';

void main() {
  runApp(const TermoPlanApp());
}

class TermoPlanApp extends StatelessWidget {
  const TermoPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TermoPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF2A257),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7FA),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color sunOrange = Color(0xFFF2A257);
  static const Color softOrange = Color(0xFFFFF4E8);
  static const Color softOrange2 = Color(0xFFFFE7CC);
  static const Color brandTeal = Color(0xFF27B8B0);
  static const Color dividerDark = Color(0xFF23404D);
  static const Color lightText = Color(0xFF728391);
  static const Color borderColor = Color(0xFFDCE7EE);
  static const Color premiumPurple = Color(0xFF7C4DFF);
  static const Color premiumBg = Color(0xFFF2EDFF);
  static const Color freeGreen = Color(0xFF18A957);
  static const Color freeBg = Color(0xFFEAF8EF);
  static const Color iceBlue = Color(0xFF8CCEF0);

  Future<void> _openExpertSupport(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/905307847260');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp bağlantısı açılamadı.')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp bağlantısı açılamadı.')),
      );
    }
  }

  Route<void> _premiumRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FA),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
  const _TopHeroImage(),
  const _PremiumInfoBanner(),
  Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ModuleCard(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Isıtma Hesabı',
                    subtitle:
                        'Alan, konum, cam ve izolasyon bilgilerine göre yaklaşık ısı ihtiyacı hesabı',
                    badgeText: 'FREE',
                    badgeColor: freeGreen,
                    badgeBackground: freeBg,
                    iconBackground: const Color(0xFFFFF1E7),
                    iconColor: sunOrange,
                    accentColor: sunOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        _premiumRoute(const HeatingCalculationPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ModuleCard(
                    icon: Icons.grid_view_rounded,
                    title: 'Yerden Isıtma Hesabı',
                    subtitle:
                        'Konut bilgileri ve mahal bazlı verilerle yerden ısıtma hesabı',
                    badgeText: 'PREMIUM',
                    badgeColor: premiumPurple,
                    badgeBackground: premiumBg,
                    iconBackground: const Color(0xFFFFF1E7),
                    iconColor: sunOrange,
                    accentColor: sunOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        _premiumRoute(const UnderfloorHeatingPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ModuleCard(
                    icon: Icons.ac_unit_rounded,
                    title: 'Oda Bazlı Klima Hesabı',
                    subtitle: 'Mahale göre uygun klima kapasitesi öneri modülü',
                    badgeText: 'PREMIUM',
                    badgeColor: premiumPurple,
                    badgeBackground: premiumBg,
                    iconBackground: const Color(0xFFEAF6FB),
                    iconColor: iceBlue,
                    accentColor: iceBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        _premiumRoute(const CoolingCalculationPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ModuleCard(
                    icon: Icons.waterfall_chart_rounded,
                    title: 'Radyatör Bazlı Hesap',
                    subtitle:
                        'Radyatör metrajı ve kapasite kontrolü için premium modül',
                    badgeText: 'PREMIUM',
                    badgeColor: premiumPurple,
                    badgeBackground: premiumBg,
                    iconBackground: const Color(0xFFE8F7F5),
                    iconColor: brandTeal,
                    accentColor: brandTeal,
                    onTap: () {
                      Navigator.push(
                        context,
                        _premiumRoute(const RadiatorHeatingPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _ExpertSupportCard(
                    onTap: () => _openExpertSupport(context),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHero extends StatelessWidget {
  const _TopHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFE8CA),
            Color(0xFFEAF8F5),
            Color(0xFFEAF6FB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFD8AA)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.thermostat_rounded,
                  color: HomePage.sunOrange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TermoPlan',
                      style: TextStyle(
                        fontSize: 27,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: HomePage.dividerDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Isıtma & Soğutma Hesap Programı',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: HomePage.brandTeal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white),
                ),
                child: const Text(
                  'BETA',
                  style: TextStyle(
                    fontSize: 11,
                    color: HomePage.dividerDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MiniColorIcon(
                      icon: Icons.auto_awesome_rounded,
                      bg: Color(0xFFFFF1E7),
                      color: HomePage.sunOrange,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Akıllı kapasite hesabı',
                        style: TextStyle(
                          fontSize: 17,
                          color: HomePage.dividerDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Kombi, klima, yerden ısıtma ve radyatör sistemleri için hızlı ön hesap ve raporlama aracı.',
                  style: TextStyle(
                    fontSize: 13.6,
                    height: 1.45,
                    color: HomePage.lightText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _HeroInfoStrip(),
        ],
      ),
    );
  }
}

class _HeroInfoStrip extends StatelessWidget {
  const _HeroInfoStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.75)),
      ),
      child: const Row(
        children: [
          _TinyInfo(
            icon: Icons.flash_on_rounded,
            text: 'Hızlı ön hesap',
            color: HomePage.sunOrange,
          ),
          SizedBox(width: 10),
          _TinyInfo(
            icon: Icons.picture_as_pdf_rounded,
            text: 'PDF rapor',
            color: HomePage.premiumPurple,
          ),
          SizedBox(width: 10),
          _TinyInfo(
            icon: Icons.support_agent_rounded,
            text: 'Uzman destek',
            color: HomePage.brandTeal,
          ),
        ],
      ),
    );
  }
}

class _TinyInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _TinyInfo({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: HomePage.dividerDark,
                fontSize: 11.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniColorIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const _MiniColorIcon({
    required this.icon,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBackground;
  final Color iconBackground;
  final Color iconColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBackground,
    required this.iconBackground,
    required this.iconColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HomePage.borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x13000000),
                blurRadius: 22,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 74,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HomePage.dividerDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HomePage.lightText,
                        fontSize: 13.2,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F6FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF8FA0B3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpertSupportCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ExpertSupportCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HomePage.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _MiniColorIcon(
                icon: Icons.support_agent_rounded,
                bg: Color(0xFFE8F7F5),
                color: HomePage.brandTeal,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Uzman Desteği',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                    color: HomePage.dividerDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bu destek premium özelliği değildir. Tüm modüller için keşif ve uzman yönlendirmesi alabilirsiniz.',
            style: TextStyle(
              fontSize: 13.4,
              color: HomePage.lightText,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text(
                'UZMAN DESTEĞİ AL',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: HomePage.brandTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _TopHeroImage extends StatelessWidget {
  const _TopHeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Image.asset(
          'assets/header/termoplan_home_header.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
class _PremiumInfoBanner extends StatelessWidget {
  const _PremiumInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: HomePage.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            _MiniColorIcon(
              icon: Icons.workspace_premium_rounded,
              bg: Color(0xFFF2EDFF),
              color: HomePage.premiumPurple,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Premium modüllerde PDF rapor, paylaşım ve detaylı kapasite analizi kullanılabilir.',
                style: TextStyle(
                  fontSize: 13.4,
                  height: 1.45,
                  color: HomePage.lightText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}