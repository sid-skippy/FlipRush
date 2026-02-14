import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

////////////////////////////////////////////////////////////
/// SOUND MANAGER
////////////////////////////////////////////////////////////

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool sfxEnabled = true;

  Future<void> playSfx(String sound) async {
    if (!sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$sound.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void toggleSfx() {
    sfxEnabled = !sfxEnabled;
  }

  void dispose() {
    _sfxPlayer.dispose();
  }
}


void main() {
  runApp(FlipRush());
}

class FlipRush extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipRush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.spaceGroteskTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

////////////////////////////////////////////////////////////
/// SPLASH SCREEN
////////////////////////////////////////////////////////////

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _ballController;
  late AnimationController _glowController;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;
  late Animation<double> _ballY;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4500),
    );

    _ballController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Interval(0.82, 1.0, curve: Curves.easeOut),
      ),
    );

    // Ball bounces: top → bottom → top → bottom → center
    _ballY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.55, end: 0.55).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.55, end: -0.55).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.55, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 40),
    ]).animate(_ballController);

    _glow = Tween<double>(begin: 8.0, end: 22.0).animate(_glowController);

    _fadeController.forward();
    _ballController.forward();

    // Simple timed haptic feedback for bounces
    Future.delayed(Duration(milliseconds: 960), () {
      if (mounted) HapticFeedback.mediumImpact(); // First bounce
    });
    Future.delayed(Duration(milliseconds: 1920), () {
      if (mounted) HapticFeedback.mediumImpact(); // Second bounce
    });

    Future.delayed(Duration(milliseconds: 5200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => StartScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _ballController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _ballController, _glowController]),
        builder: (context, _) {
          double opacity = _fadeController.value < 0.75
              ? _fadeIn.value
              : _fadeOut.value;

          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Stack(
              children: [
                // Glowing background pulse
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.15),
                          blurRadius: _glow.value * 6,
                          spreadRadius: _glow.value * 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bouncing ball
                Align(
                  alignment: Alignment(0, _ballY.value),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.7),
                          blurRadius: _glow.value,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                // Logo text
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'FlipRush',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: Colors.blueAccent.withOpacity(0.8),
                              blurRadius: 24,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'FLIP. DODGE. SURVIVE.',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.blueAccent.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Credits at bottom
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        'Made by',
                        style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Siddhartha Gupta',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '24BCE5063',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ANDROID CLUB · VIT CHENNAI',
                        style: TextStyle(
                          color: Colors.blueAccent.withOpacity(0.6),
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// INSTRUCTIONS SCREEN
////////////////////////////////////////////////////////////

class InstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[950] ?? Colors.black,
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'HOW TO PLAY',
                    style: GoogleFonts.orbitron(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HOW TO PLAY
                    _SectionTitle('🎮  CONTROLS'),
                    _InfoCard(
                      icon: Icons.touch_app,
                      iconColor: Colors.blueAccent,
                      title: 'Tap anywhere on screen',
                      subtitle: 'Flips gravity — ball switches between falling down and floating up.',
                    ),
                    _InfoCard(
                      icon: Icons.remove_road,
                      iconColor: Colors.redAccent,
                      title: 'Dodge the obstacles',
                      subtitle: 'Coloured bars scroll towards you. One hit and it\'s over — unless you have a shield.',
                    ),
                    _InfoCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.orange,
                      title: 'Difficulty increases',
                      subtitle: 'Every 15 points the obstacles and your ball move faster. Stay sharp.',
                    ),

                    SizedBox(height: 24),
                    _SectionTitle('🪙  COINS'),
                    _InfoCard(
                      icon: Icons.circle,
                      iconColor: Colors.amber,
                      title: 'Collect coins mid-game',
                      subtitle: 'Coins float across the play area just like obstacles. Fly through them to collect.',
                    ),
                    _InfoCard(
                      icon: Icons.shopping_cart,
                      iconColor: Colors.amber,
                      title: 'Spend in the shop bar',
                      subtitle: 'The bottom bar is the shop. Tap any power-up button to buy it instantly — tapping the shop never flips gravity.',
                    ),

                    SizedBox(height: 24),
                    _SectionTitle('⚡  POWER-UPS'),
                    _PowerUpRow(
                      icon: Icons.shield,
                      color: Colors.cyan,
                      name: 'SHIELD',
                      cost: 5,
                      duration: '7s',
                      desc: 'Surrounds the ball with a cyan barrier. Absorbs one obstacle hit and destroys it — or expires after 7 seconds. Blinks when about to run out.',
                    ),
                    _PowerUpRow(
                      icon: Icons.speed,
                      color: Colors.yellow,
                      name: 'SLOW-MO',
                      cost: 3,
                      duration: '5s',
                      desc: 'Slows everything down by half — obstacles, coins, and power-ups all move slower, giving you breathing room.',
                    ),
                    _PowerUpRow(
                      icon: Icons.compress,
                      color: Colors.green,
                      name: 'SHRINK',
                      cost: 3,
                      duration: '5s',
                      desc: 'Shrinks the ball to 70% of its size, making it easier to squeeze through tight gaps.',
                    ),
                    _PowerUpRow(
                      icon: Icons.star,
                      color: Colors.amber,
                      name: '2× POINTS',
                      cost: 4,
                      duration: '5s',
                      desc: 'Doubles your score gain rate for 5 seconds. Stack with good play to chase high scores.',
                    ),

                    SizedBox(height: 24),
                    _SectionTitle('💡  TIPS'),
                    _TipRow('Power-ups can also be collected by flying through them in the game area — no coins needed.'),
                    _TipRow('The shop bar dims power-up buttons you can\'t afford yet.'),
                    _TipRow('Shield is the most powerful — save coins for it when things get fast.'),
                    _TipRow('You can change your ball colour in the pause menu mid-game.'),

                    SizedBox(height: 32),
                    // Credits
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          Text('Made by', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
                          SizedBox(height: 6),
                          Text(
                            'Siddhartha Gupta',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('24BCE5063', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                            ),
                            child: Text(
                              'ANDROID CLUB · VIT CHENNAI',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _InfoCard({required this.icon, required this.iconColor, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerUpRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final int cost;
  final String duration;
  final String desc;
  const _PowerUpRow({required this.icon, required this.color, required this.name, required this.cost, required this.duration, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('¢$cost', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(width: 6),
                          Text(duration, style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(desc, style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('→  ', style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// BALL SKIN MODEL
////////////////////////////////////////////////////////////

class BallSkin {
  final String name;
  final Gradient gradient;
  final Color glowColor;
  final Color primaryColor; // used for glow/shield tinting

  const BallSkin({
    required this.name,
    required this.gradient,
    required this.glowColor,
    required this.primaryColor,
  });
}

final List<BallSkin> ballSkins = [
  // Classic solids
  BallSkin(
    name: 'Blue',
    gradient: LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.blueAccent,
    primaryColor: Colors.blueAccent,
  ),
  BallSkin(
    name: 'Red',
    gradient: LinearGradient(colors: [Color(0xFFEF9A9A), Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.redAccent,
    primaryColor: Colors.redAccent,
  ),
  BallSkin(
    name: 'Green',
    gradient: LinearGradient(colors: [Color(0xFFA5D6A7), Color(0xFF1B5E20)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.greenAccent,
    primaryColor: Colors.green,
  ),
  // Gradient specials
  BallSkin(
    name: 'Sunset',
    gradient: LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.orange,
    primaryColor: Colors.deepOrange,
  ),
  BallSkin(
    name: 'Ocean',
    gradient: LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.cyanAccent,
    primaryColor: Colors.cyan,
  ),
  BallSkin(
    name: 'Galaxy',
    gradient: LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFF00C9FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.purpleAccent,
    primaryColor: Colors.purple,
  ),
  BallSkin(
    name: 'Lava',
    gradient: RadialGradient(colors: [Color(0xFFFFD700), Color(0xFFFF4500), Color(0xFF8B0000)], stops: [0.0, 0.5, 1.0]),
    glowColor: Colors.deepOrange,
    primaryColor: Colors.orange,
  ),
  BallSkin(
    name: 'Neon',
    gradient: LinearGradient(colors: [Color(0xFF39FF14), Color(0xFF00FFFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Color(0xFF39FF14),
    primaryColor: Colors.greenAccent,
  ),
  BallSkin(
    name: 'Rose',
    gradient: LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFFF9A9E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.pinkAccent,
    primaryColor: Colors.pink,
  ),
  BallSkin(
    name: 'Obsidian',
    gradient: RadialGradient(colors: [Color(0xFF616161), Color(0xFF000000)], stops: [0.0, 1.0]),
    glowColor: Colors.white,
    primaryColor: Colors.grey,
  ),
  BallSkin(
    name: 'Plasma',
    gradient: LinearGradient(colors: [Color(0xFFFF00FF), Color(0xFF8B00FF), Color(0xFF00FFFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.purpleAccent,
    primaryColor: Colors.pinkAccent,
  ),
  BallSkin(
    name: 'Gold',
    gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    glowColor: Colors.amber,
    primaryColor: Colors.amber,
  ),
];

////////////////////////////////////////////////////////////
/// START SCREEN
////////////////////////////////////////////////////////////

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  BallSkin selectedSkin = ballSkins[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
              "FlipRush",
              style: GoogleFonts.orbitron(
                color: Colors.blueAccent,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "tap to flip gravity",
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 40),

            // Ball Skin Selection
            Text(
              "Choose Your Ball",
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              selectedSkin.name,
              style: GoogleFonts.spaceGrotesk(
                color: selectedSkin.glowColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: ballSkins.map((skin) {
                bool isSelected = skin == selectedSkin;
                return GestureDetector(
                  onTap: () => setState(() => selectedSkin = skin),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: skin.gradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: skin.glowColor.withOpacity(isSelected ? 0.8 : 0.3),
                          blurRadius: isSelected ? 20 : 8,
                          spreadRadius: isSelected ? 4 : 1,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: selectedSkin.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "START GAME",
                style: GoogleFonts.spaceGrotesk(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(ballSkin: selectedSkin),
                  ),
                );
              },
            ),
            SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InstructionsScreen()),
                );
              },
              icon: Icon(Icons.help_outline, color: Colors.white54, size: 18),
              label: Text(
                'HOW TO PLAY & POWER-UPS',
                style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1.5),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              icon: Icon(Icons.settings, color: Colors.white54, size: 18),
              label: Text(
                'SETTINGS',
                style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1.5),
              ),
            ),
            SizedBox(height: 32),
            // Credits
            Column(
              children: [
                Text('Made by', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
                SizedBox(height: 3),
                Text(
                  'Siddhartha Gupta',
                  style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text('24BCE5063', style: TextStyle(color: Colors.white30, fontSize: 11)),
                SizedBox(height: 4),
                Text(
                  'ANDROID CLUB · VIT CHENNAI',
                  style: TextStyle(
                    color: Colors.blueAccent.withOpacity(0.5),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
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

////////////////////////////////////////////////////////////
/// SETTINGS SCREEN
////////////////////////////////////////////////////////////

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundManager sound = SoundManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'SETTINGS',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  // Sound Effects Toggle
                  _buildSettingTile(
                    icon: Icons.volume_up,
                    title: 'Sound Effects',
                    subtitle: 'Flip, explosion, power-up sounds',
                    value: sound.sfxEnabled,
                    onChanged: (val) {
                      setState(() {
                        sound.toggleSfx();
                      });
                    },
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Credits Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ABOUT',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.blueAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'FlipRush',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Version 1.07',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        SizedBox(height: 16),
                        Divider(color: Colors.white24),
                        SizedBox(height: 16),
                        Text(
                          'Developed by',
                          style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Siddhartha Gupta',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '24BCE5063',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'ANDROID CLUB · VIT CHENNAI',
                          style: TextStyle(
                            color: Colors.blueAccent.withOpacity(0.7),
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
          inactiveThumbColor: Colors.grey,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// COLOR PICKER WIDGET (Reusable)
////////////////////////////////////////////////////////////

class SkinPicker extends StatelessWidget {
  final BallSkin selectedSkin;
  final Function(BallSkin) onSkinSelected;

  const SkinPicker({
    required this.selectedSkin,
    required this.onSkinSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Ball: ${selectedSkin.name}",
          style: TextStyle(
            color: selectedSkin.glowColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: ballSkins.map((skin) {
            bool isSelected = skin == selectedSkin;
            return GestureDetector(
              onTap: () => onSkinSelected(skin),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: skin.gradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: skin.glowColor.withOpacity(isSelected ? 0.8 : 0.2),
                      blurRadius: isSelected ? 12 : 4,
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// SIMPLE OBSTACLE MODEL
////////////////////////////////////////////////////////////

class Obstacle {
  double x; // Horizontal position (0.0 = left, 1.0 = right)
  double y; // Vertical position (-0.7 to 0.7)
  double width; // Width as fraction of screen (0.15 to 0.4)
  Color color;
  double opacity; // For smooth fade-in

  Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.color,
    this.opacity = 0.0, // Start invisible
  });
}

////////////////////////////////////////////////////////////
/// POWER-UP MODEL
////////////////////////////////////////////////////////////

enum PowerUpType {
  shield,      // Survive 1 hit
  slowMo,      // Slow down time
  shrink,      // Smaller ball
  doublePoints // 2x score multiplier
}

class PowerUp {
  double x;
  double y;
  PowerUpType type;
  double opacity;
  IconData icon;
  Color color;

  PowerUp({
    required this.x,
    required this.y,
    required this.type,
    this.opacity = 0.0,
  }) : icon = _getIcon(type),
       color = _getColor(type);

  static IconData _getIcon(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.slowMo:
        return Icons.speed;
      case PowerUpType.shrink:
        return Icons.compress;
      case PowerUpType.doublePoints:
        return Icons.star;
    }
  }

  static Color _getColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Colors.cyan;
      case PowerUpType.slowMo:
        return Colors.yellow;
      case PowerUpType.shrink:
        return Colors.green;
      case PowerUpType.doublePoints:
        return Colors.amber;
    }
  }
}

////////////////////////////////////////////////////////////
/// EXPLOSION PARTICLE
////////////////////////////////////////////////////////////

class ExplosionParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;

  ExplosionParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });
}

////////////////////////////////////////////////////////////
/// STAR MODEL (for parallax background)
////////////////////////////////////////////////////////////

class Star {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

////////////////////////////////////////////////////////////
/// COIN MODEL
////////////////////////////////////////////////////////////

class Coin {
  double x;
  double y;
  double opacity;
  double scale; // for pop-in animation

  Coin({
    required this.x,
    required this.y,
    this.opacity = 0.0,
    this.scale = 0.5,
  });
}

////////////////////////////////////////////////////////////
/// PURCHASE ANIMATION
////////////////////////////////////////////////////////////

class PurchaseAnimation {
  final PowerUpType type;
  double opacity;
  double offsetY; // drifts gently downward

  PurchaseAnimation({
    required this.type,
    this.opacity = 1.0,
    this.offsetY = 0.0,
  });
}

////////////////////////////////////////////////////////////
/// TAP RIPPLE
////////////////////////////////////////////////////////////

class TapRipple {
  final double x;
  final double y;
  double radius;
  double opacity;
  // Second outer ring starts delayed
  double radius2;
  double opacity2;

  TapRipple({required this.x, required this.y})
      : radius = 6.0,
        opacity = 1.0,
        radius2 = 0.0,
        opacity2 = 0.0;
}

////////////////////////////////////////////////////////////
/// GAME SCREEN
////////////////////////////////////////////////////////////

class GameScreen extends StatefulWidget {
  final BallSkin ballSkin;

  GameScreen({BallSkin? ballSkin}) : ballSkin = ballSkin ?? ballSkins[0];

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  late AnimationController _arrowAnimationController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final Random random = Random();

  // Ball state
  double ballY = 0;
  double velocity = 0.005;
  bool goingDown = true;
  final double ballSize = 30;
  bool showBallExplosion = false; // Separate flag for ball death
  List<ExplosionParticle> explosionParticles = [];
  late BallSkin currentSkin;

  // Game state
  bool isGameOver = false;
  bool isPaused = false;
  bool isDying = false; // New flag for death animation
  double deathTimer = 0; // Timer for death animation
  final double deathAnimationDuration = 1.0; // 1 second for explosion
  int score = 0;
  double scoreAccumulator = 0.0; // Accumulates fractional points
  static int highScore = 0; // Static - persists across game restarts
  double elapsedTime = 0;
  int lastSpeedIncrease = 0;
  int obstaclesDodged = 0; // Count obstacles passed
  Color backgroundColor = Color(0xFF0A0A0A); // Dynamic background color
  List<Star> stars = []; // Background stars for parallax effect
  
  // High score celebration
  List<ExplosionParticle> celebrationParticles = [];

  // Obstacle state
  List<Obstacle> obstacles = [];
  double obstacleSpeed = 0.006; // Increased speed
  final double obstacleHeight = 12.0;
  
  // Power-up state
  List<PowerUp> powerUps = [];
  double powerUpSpeed = 0.006;
  final double powerUpSize = 40.0;
  double lastPowerUpSpawn = 0;
  
  // Active power-up effects
  bool hasShield = false;
  bool isSlowMo = false;
  bool isShrunk = false;
  bool hasDoublePoints = false;
  double powerUpTimer = 0;
  double shieldTimer = 0;
  final double powerUpDuration = 8.0;
  final double shieldDuration = 10.0;
  double zoomScale = 1.0; // For slow-mo zoom effect
  
  // Tap ripples
  List<TapRipple> tapRipples = [];

  // Coin state
  List<Coin> coins = [];
  double coinSpeed = 0.006;
  final double coinSize = 24.0;
  double lastCoinSpawn = -5; // spawn first coin quickly
  int coinCount = 0;

  // Shop / purchase animations
  List<PurchaseAnimation> purchaseAnims = [];

  // Power-up shop prices
  static const Map<PowerUpType, int> powerUpPrices = {
    PowerUpType.shield: 5,
    PowerUpType.slowMo: 3,
    PowerUpType.shrink: 3,
    PowerUpType.doublePoints: 4,
  };

  // Color palette
  final List<Color> obstacleColors = [
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.lime,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize ball color
    currentSkin = widget.ballSkin;
    
    // Initialize background stars
    for (int i = 0; i < 50; i++) {
      stars.add(Star(
        x: random.nextDouble() * 2 - 1, // -1 to 1
        y: random.nextDouble() * 2 - 1,
        size: random.nextDouble() * 2 + 1, // 1-3px
        speed: random.nextDouble() * 0.002 + 0.001, // Slow drift
        opacity: random.nextDouble() * 0.5 + 0.2, // 0.2-0.7
      ));
    }
    
    // Initialize arrow animation
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Shake animation: rapid back-and-forth, decays quickly
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Create initial obstacles - simple and spaced out
    createInitialObstacles();

    // Start game loop
    _ticker = createTicker((elapsed) {
      if (!isPaused) {
        if (!isGameOver) {
          updateGame();
        } else {
          // Keep updating celebration animation even when game is over
          if (celebrationParticles.isNotEmpty) {
            setState(() {
              updateCelebration();
            });
          }
        }
      }
    });
    _ticker.start();
  }

  ////////////////////////////////////////////////////////////
  /// OBSTACLE CREATION - SUPER SIMPLE
  ////////////////////////////////////////////////////////////

  void createInitialObstacles() {
    // Start with 3 obstacles, well spaced apart
    for (int i = 0; i < 3; i++) {
      double xPos = -1.2 - (i * 1.0); // More spacing: 1.0 units apart
      obstacles.add(Obstacle(
        x: xPos,
        y: (random.nextDouble() * 1.4) - 0.7,
        width: 0.2 + (random.nextDouble() * 0.15),
        color: obstacleColors[random.nextInt(obstacleColors.length)],
      ));
    }
  }

  void spawnNewObstacle() {
    // Generate Y position that doesn't overlap with existing obstacles
    double newY;
    bool validPosition = false;
    int attempts = 0;
    
    do {
      newY = (random.nextDouble() * 1.4) - 0.7;
      validPosition = true;
      
      // Check if too close to any existing obstacle vertically
      for (var obstacle in obstacles) {
        double verticalDistance = (newY - obstacle.y).abs();
        // Ensure at least 0.3 units vertical separation
        if (verticalDistance < 0.3) {
          validPosition = false;
          break;
        }
      }
      
      attempts++;
    } while (!validPosition && attempts < 20);
    
    // Spawn obstacle well off-screen to the left
    obstacles.add(Obstacle(
      x: -1.5, // Further off-screen for smoother appearance
      y: newY,
      width: 0.2 + (random.nextDouble() * 0.15),
      color: obstacleColors[random.nextInt(obstacleColors.length)],
      opacity: 0.0, // Start invisible
    ));
  }

  ////////////////////////////////////////////////////////////
  /// GAME LOOP
  ////////////////////////////////////////////////////////////

  void updateGame() {
    setState(() {
      // Update celebration particles if showing
      if (celebrationParticles.isNotEmpty) {
        updateCelebration();
      }
      
      // Handle death animation
      if (isDying) {
        deathTimer += 0.016;
        updateExplosion(); // Keep updating particles during death
        
        if (deathTimer >= deathAnimationDuration) {
          // Animation complete - show game over
          isGameOver = true;
          isDying = false;
          saveHighScore();
        }
        return; // Don't update game while dying
      }

      // Get current speed multiplier
      double speedMultiplier = isSlowMo ? 0.5 : 1.0;
      
      // Update zoom scale smoothly for slow-mo effect
      double targetZoom = isSlowMo ? 1.15 : 1.0; // Zoom in to 115% when slow-mo
      zoomScale += (targetZoom - zoomScale) * 0.1; // Smooth interpolation
      
      // Update background stars (parallax effect)
      for (var star in stars) {
        star.x += star.speed * speedMultiplier;
        if (star.x > 1.2) {
          star.x = -1.2;
          star.y = random.nextDouble() * 2 - 1;
        }
      }
      
      // Update background color dynamically based on score
      Color targetBg;
      if (score < 20) {
        targetBg = Color(0xFF0A0A0A); // Dark black
      } else if (score < 50) {
        targetBg = Color(0xFF0D0D1A); // Dark blue tint
      } else if (score < 100) {
        targetBg = Color(0xFF1A0D1A); // Dark purple tint
      } else if (score < 150) {
        targetBg = Color(0xFF1A0D0F); // Dark red tint
      } else {
        targetBg = Color(0xFF1A1A0D); // Dark gold tint (master level)
      }
      
      // Smooth color transition
      backgroundColor = Color.lerp(backgroundColor, targetBg, 0.02)!;
      
      // Update ball (only if not dying)
      ballY += (goingDown ? velocity : -velocity) * speedMultiplier;


      // Update score properly - ~1 point per second (or 2 with double points)
      elapsedTime += 0.016;
      
      // Add fractional points to accumulator
      double pointsPerSecond = hasDoublePoints ? 2.0 : 1.0;
      scoreAccumulator += 0.016 * pointsPerSecond;
      
      // Convert to integer score
      score = scoreAccumulator.toInt();

      // Update power-up timer
      if (powerUpTimer > 0) {
        powerUpTimer -= 0.016;
        if (powerUpTimer <= 0) {
          deactivatePowerUp();
        }
      }

      // Update shield timer separately
      if (shieldTimer > 0) {
        shieldTimer -= 0.016;
        if (shieldTimer <= 0) {
          hasShield = false;
          shieldTimer = 0;
        }
      }

      // Increase difficulty every 15 seconds
      if (score >= lastSpeedIncrease + 15) {
        velocity += 0.001;
        obstacleSpeed += 0.0005;
        powerUpSpeed += 0.0005;
        lastSpeedIncrease = score;
      }

      // Move obstacles, power-ups, and coins
      moveObstacles();
      movePowerUps();
      moveCoins();

      // Check power-up and coin collection
      checkPowerUpCollection();
      checkCoinCollection();

      // Update purchase animations
      updatePurchaseAnims();

      // Update tap ripples
      for (var r in tapRipples) {
        // First ring: moderate expand, gentle fade
        r.radius += 4.5;
        r.opacity -= 0.055;

        // Second ring: starts when first reaches r~35, slightly slower
        if (r.radius >= 35 && r.opacity2 == 0.0) r.opacity2 = 0.55;
        if (r.opacity2 > 0) {
          r.radius2 += 3.5;
          r.opacity2 -= 0.05;
        }
      }
      tapRipples.removeWhere((r) => r.opacity <= 0 && r.opacity2 <= 0);

      // Always update explosion particles (for both ball and obstacle explosions)
      updateExplosion();

      // Check collisions (shield protects from one hit and destroys obstacle)
      Obstacle? hitObstacle = checkCollision();
      if (hitObstacle != null && !isGameOver && !isDying) {
        if (hasShield) {
          // Shield destroys the obstacle!
          HapticFeedback.heavyImpact(); // Strong haptic when shield blocks hit
          hasShield = false; // Use up shield
          shieldTimer = 0;
          triggerShake();
          explodeObstacle(hitObstacle);
          obstacles.remove(hitObstacle);
        } else {
          // No shield - start death animation
          HapticFeedback.heavyImpact(); // Strong haptic on death
          triggerBallExplosion();
          triggerShake();
          isDying = true;
          deathTimer = 0;
        }
      }

      // Check bounds
      if ((ballY > 0.98 || ballY < -0.98) && !isGameOver && !isDying) {
        HapticFeedback.heavyImpact(); // Strong haptic on boundary death
        triggerBallExplosion();
        triggerShake();
        isDying = true;
        deathTimer = 0;
      }
    });
  }

  ////////////////////////////////////////////////////////////
  /// MOVE OBSTACLES - SMOOTH APPEARANCE WITH NO OVERLAP
  ////////////////////////////////////////////////////////////

  void moveObstacles() {
    // Move each obstacle to the right and handle opacity
    for (var obstacle in obstacles) {
      obstacle.x += obstacleSpeed;
      
      // Smooth fade-in effect (when entering from left edge)
      // Fade in from x = -1.5 to x = -0.8 (fully in view)
      if (obstacle.x < -0.8) {
        double fadeProgress = (obstacle.x + 1.5) / 0.7; // 0.0 to 1.0
        obstacle.opacity = fadeProgress.clamp(0.0, 1.0);
      } else if (obstacle.x <= 0.8) {
        // Fully visible in middle section
        obstacle.opacity = 1.0;
      } else {
        // Smooth fade-out effect (when exiting to right edge)
        // Fade out from x = 0.8 to x = 1.5 (fully out of view)
        double fadeProgress = (1.5 - obstacle.x) / 0.7; // 1.0 to 0.0
        obstacle.opacity = fadeProgress.clamp(0.0, 1.0);
      }
    }

    // Remove obstacles that are completely off-screen to the right and count them as dodged
    int beforeCount = obstacles.length;
    obstacles.removeWhere((obstacle) => obstacle.x > 1.6);
    int afterCount = obstacles.length;
    obstaclesDodged += (beforeCount - afterCount); // Count dodged obstacles

    // Find the leftmost obstacle (the one we just spawned)
    double leftmostX = 999;
    for (var obstacle in obstacles) {
      if (obstacle.x < leftmostX) {
        leftmostX = obstacle.x;
      }
    }

    // Only spawn new obstacle when previous one is well into view
    // This ensures proper spacing and no overlap
    if (obstacles.isEmpty || leftmostX > -0.5) {
      spawnNewObstacle();
    }
  }

  ////////////////////////////////////////////////////////////
  /// POWER-UP SYSTEM
  ////////////////////////////////////////////////////////////

  void spawnPowerUp() {
    // Random power-up type
    PowerUpType type = PowerUpType.values[random.nextInt(PowerUpType.values.length)];
    
    powerUps.add(PowerUp(
      x: -1.2,
      y: (random.nextDouble() * 1.4) - 0.7,
      type: type,
    ));
    
    lastPowerUpSpawn = score.toDouble();
  }

  void movePowerUps() {
    // Move power-ups
    for (var powerUp in powerUps) {
      powerUp.x += powerUpSpeed;
      
      // Fade in
      if (powerUp.x < -0.8 && powerUp.opacity < 1.0) {
        powerUp.opacity += 0.04;
        if (powerUp.opacity > 1.0) powerUp.opacity = 1.0;
      }
      
      // Fade out
      if (powerUp.x > 0.8 && powerUp.opacity > 0.0) {
        powerUp.opacity -= 0.04;
        if (powerUp.opacity < 0.0) powerUp.opacity = 0.0;
      }
    }

    // Remove off-screen power-ups
    powerUps.removeWhere((powerUp) => powerUp.x > 1.5);

    // Spawn new power-up every 10 seconds (allow up to 2 on screen)
    if (score - lastPowerUpSpawn >= 10 && powerUps.length < 2) {
      spawnPowerUp();
    }
  }

  void moveCoins() {
    for (var coin in coins) {
      coin.x += coinSpeed;

      // Fade in
      if (coin.x < -0.8) {
        double fadeProgress = (coin.x + 1.5) / 0.7;
        coin.opacity = fadeProgress.clamp(0.0, 1.0);
      } else {
        coin.opacity = 1.0;
      }

      // Scale pop-in
      if (coin.scale < 1.0) {
        coin.scale += 0.05;
        if (coin.scale > 1.0) coin.scale = 1.0;
      }
    }

    // Remove off-screen coins
    coins.removeWhere((coin) => coin.x > 1.5);

    // Spawn a single coin every ~3 seconds at a random position
    if (score - lastCoinSpawn >= 3 && coins.length < 5) {
      _spawnCoin();
      lastCoinSpawn = score.toDouble();
    }
  }

  void _spawnCoin() {
    coins.add(Coin(
      x: -1.5,
      y: (random.nextDouble() * 1.4) - 0.7,
    ));
  }

  void checkCoinCollection() {
    final size = MediaQuery.of(context).size;
    const double topBarHeight = 70.0;
    const double shopBarHeight = 80.0;
    final double W = size.width;
    final double H = size.height - topBarHeight - shopBarHeight;

    final double actualBallSize = isShrunk ? ballSize * 0.45 : ballSize;
    final double ballRadius = actualBallSize / 2;
    final double ballCenterX = W / 2;
    final double ballCenterY = H / 2 + ballY * (H / 2 - ballRadius);

    coins.removeWhere((coin) {
      // Coins are coinSize x coinSize, centered via Alignment
      final double coinCenterX = W / 2 + coin.x * (W / 2 - coinSize / 2);
      final double coinCenterY = H / 2 + coin.y * (H / 2 - coinSize / 2);

      final double dx = ballCenterX - coinCenterX;
      final double dy = ballCenterY - coinCenterY;
      final double collectR = ballRadius + coinSize / 2;

      if (dx * dx + dy * dy < collectR * collectR) {
        coinCount++;
        SoundManager().playSfx('coin'); // Play sound when collecting coin
        return true;
      }
      return false;
    });
  }

  void buyPowerUp(PowerUpType type) {
    int price = powerUpPrices[type]!;
    if (coinCount >= price) {
      HapticFeedback.mediumImpact();
      coinCount -= price;
      activatePowerUp(type);
      purchaseAnims.add(PurchaseAnimation(type: type));
    } else {
      HapticFeedback.selectionClick(); // subtle "can't afford" nudge
    }
  }

  void updatePurchaseAnims() {
    for (var anim in purchaseAnims) {
      anim.offsetY += 0.3;       // slow drift downward
      anim.opacity -= 0.008;     // slow fade (~2.5s visible at 60fps)
    }
    purchaseAnims.removeWhere((a) => a.opacity <= 0);
  }

  void checkPowerUpCollection() {
    final size = MediaQuery.of(context).size;
    const double topBarHeight = 70.0;
    const double shopBarHeight = 80.0;
    final double W = size.width;
    final double H = size.height - topBarHeight - shopBarHeight;

    final double actualBallSize = isShrunk ? ballSize * 0.45 : ballSize;
    final double ballRadius = actualBallSize / 2;
    final double ballCenterX = W / 2;
    final double ballCenterY = H / 2 + ballY * (H / 2 - ballRadius);

    powerUps.removeWhere((powerUp) {
      final double puCenterX = W / 2 + powerUp.x * (W / 2 - powerUpSize / 2);
      final double puCenterY = H / 2 + powerUp.y * (H / 2 - powerUpSize / 2);

      final double dx = ballCenterX - puCenterX;
      final double dy = ballCenterY - puCenterY;
      final double collectR = ballRadius + powerUpSize / 2;

      if (dx * dx + dy * dy < collectR * collectR) {
        activatePowerUp(powerUp.type);
        return true;
      }
      return false;
    });
  }

  void activatePowerUp(PowerUpType type) {
    if (type == PowerUpType.shield) {
      hasShield = true;
      shieldTimer = shieldDuration; // 7 seconds, then expires
      SoundManager().playSfx('powerup'); // Shield pickup sound
    } else {
      // Deactivate any previous timed power-up
      isSlowMo = false;
      isShrunk = false;
      hasDoublePoints = false;

      powerUpTimer = powerUpDuration;

      switch (type) {
        case PowerUpType.slowMo:
          isSlowMo = true;
          SoundManager().playSfx('slowmo'); // Special slow-mo sound effect
          break;
        case PowerUpType.shrink:
          isShrunk = true;
          SoundManager().playSfx('powerup'); // Shrink pickup sound
          break;
        case PowerUpType.doublePoints:
          hasDoublePoints = true;
          SoundManager().playSfx('powerup'); // Double points pickup sound
          break;
        default:
          break;
      }
    }
  }

  void deactivatePowerUp() {
    isSlowMo = false;
    isShrunk = false;
    hasDoublePoints = false;
    powerUpTimer = 0;
  }

  ////////////////////////////////////////////////////////////
  /// COLLISION DETECTION - SIMPLE & RELIABLE
  ////////////////////////////////////////////////////////////

  // Flutter's Alignment(ax, ay) inside a container of size (W x H) places the
  // *center* of a child sized (cw x ch) at:
  //   centerX = W/2 + ax * (W/2 - cw/2)
  //   centerY = H/2 + ay * (H/2 - ch/2)
  // We use this exact formula so collision perfectly matches what is rendered.
  Obstacle? checkCollision() {
    final size = MediaQuery.of(context).size;
    const double topBarHeight = 70.0;
    const double shopBarHeight = 80.0;
    final double W = size.width;
    final double H = size.height - topBarHeight - shopBarHeight;

    // --- Ball center (alignment.x == 0, so centerX == W/2) ---
    final double actualBallSize = isShrunk ? ballSize * 0.45 : ballSize;
    final double ballRadius = actualBallSize / 2;
    final double ballCenterX = W / 2;
    final double ballCenterY = H / 2 + ballY * (H / 2 - ballRadius);

    for (var obstacle in obstacles) {
      if (obstacle.x < -1.5 || obstacle.x > 1.5) continue;

      final double obsW = W * obstacle.width;
      final double obsH = obstacleHeight;

      // Exact Flutter Alignment → pixel center
      final double obsCenterX = W / 2 + obstacle.x * (W / 2 - obsW / 2);
      final double obsCenterY = H / 2 + obstacle.y * (H / 2 - obsH / 2);

      final double left   = obsCenterX - obsW / 2;
      final double right  = obsCenterX + obsW / 2;
      final double top    = obsCenterY - obsH / 2;
      final double bottom = obsCenterY + obsH / 2;

      // Closest point on the rectangle to the ball center
      final double closestX = ballCenterX.clamp(left, right);
      final double closestY = ballCenterY.clamp(top, bottom);

      final double dx = ballCenterX - closestX;
      final double dy = ballCenterY - closestY;

      if (dx * dx + dy * dy < ballRadius * ballRadius) {
        return obstacle;
      }
    }

    return null;
  }

  ////////////////////////////////////////////////////////////
  /// EXPLOSION ANIMATION
  ////////////////////////////////////////////////////////////

  void triggerBallExplosion() {
    showBallExplosion = true;
    SoundManager().playSfx('explosion'); // Death explosion sound

    final size = MediaQuery.of(context).size;
    const double topBarHeight = 70.0;
    const double shopBarHeight = 80.0;
    final double W = size.width;
    final double H = size.height - topBarHeight - shopBarHeight;
    final double actualBallSize = isShrunk ? ballSize * 0.45 : ballSize;
    final double ballRadius = actualBallSize / 2;

    final double ballCenterX = W / 2;
    final double ballCenterY = H / 2 + ballY * (H / 2 - ballRadius);
    
    // Create 30 particles exploding outward from ball
    for (int i = 0; i < 30; i++) {
      double angle = (i / 30) * 2 * pi;
      double speed = 3 + random.nextDouble() * 4;
      
      explosionParticles.add(ExplosionParticle(
        x: ballCenterX,
        y: ballCenterY,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 4 + random.nextDouble() * 8,
        color: currentSkin.glowColor,
        opacity: 1.0,
      ));
    }
  }

  void updateExplosion() {
    for (var particle in explosionParticles) {
      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.vy += 0.2; // Gravity
      particle.opacity -= 0.02;
    }
    
    // Remove faded particles
    explosionParticles.removeWhere((p) => p.opacity <= 0);
  }

  void explodeObstacle(Obstacle obstacle) {
    SoundManager().playSfx('shield_hit'); // Shield destroys obstacle sound
    final size = MediaQuery.of(context).size;
    
    // Obstacle center position in pixels
    double obstacleCenterX = ((obstacle.x + 1) / 2) * size.width;
    double obstacleCenterY = ((obstacle.y + 1) / 2) * size.height;
    
    // Create 20 particles exploding from obstacle
    for (int i = 0; i < 20; i++) {
      double angle = (i / 20) * 2 * pi;
      double speed = 2 + random.nextDouble() * 3;
      
      explosionParticles.add(ExplosionParticle(
        x: obstacleCenterX,
        y: obstacleCenterY,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 3 + random.nextDouble() * 6,
        color: obstacle.color, // Use obstacle's color
        opacity: 1.0,
      ));
    }
  }

  ////////////////////////////////////////////////////////////
  /// TRAIL PARTICLE SYSTEM
  ////////////////////////////////////////////////////////////


  ////////////////////////////////////////////////////////////
  /// CONTROLS
  ////////////////////////////////////////////////////////////

  void triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  void flipGravity({Offset? tapPosition}) {
    if (!isGameOver && !isPaused && !isDying) {
      HapticFeedback.lightImpact();
      SoundManager().playSfx('flip'); // Sound effect for gravity flip
      setState(() {
        goingDown = !goingDown;
        if (goingDown) {
          _arrowAnimationController.reverse();
        } else {
          _arrowAnimationController.forward();
        }
        if (tapPosition != null) {
          tapRipples.add(TapRipple(x: tapPosition.dx, y: tapPosition.dy));
        }
      });
    }
  }


  void restartGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(ballSkin: currentSkin)),
    );
  }

  void togglePause() {
    if (!isDying) {
      setState(() {
        isPaused = !isPaused;
      });
    }
  }

  // High Score Functions (in-memory only - resets on app restart)
  void saveHighScore() {
    if (score > highScore) {
      setState(() {
        highScore = score;
        triggerCelebration();
      });
    }
  }
  
  void triggerCelebration() {
    // Create confetti particles all over the screen
    final size = MediaQuery.of(context).size;
    celebrationParticles.clear();
    
    // Create 50 colorful confetti particles
    for (int i = 0; i < 50; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height * 0.3; // Top third of screen
      
      celebrationParticles.add(ExplosionParticle(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 4,
        vy: random.nextDouble() * 5 + 3, // Falling down
        size: 6 + random.nextDouble() * 8,
        color: [Colors.amber, Colors.yellow, Colors.orange, Colors.pink, 
                Colors.cyan, Colors.lime, Colors.purple][random.nextInt(7)],
        opacity: 1.0,
      ));
    }
  }
  
  void updateCelebration() {
    for (var particle in celebrationParticles) {
      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.vy += 0.15; // Gravity
      particle.vx *= 0.99; // Air resistance
      particle.opacity -= 0.01;
    }
    
    celebrationParticles.removeWhere((p) => p.opacity <= 0 || p.y > MediaQuery.of(context).size.height);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _arrowAnimationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    const double topBarHeight = 70.0;
    const double shopBarHeight = 80.0;
    // Full height minus safe-area insets minus both bars
    final double gameAreaHeight = size.height
        - padding.top
        - padding.bottom
        - topBarHeight
        - shopBarHeight;

    return Scaffold(
      backgroundColor: backgroundColor, // Use smooth transitioning background color // Dynamic color
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP HUD BAR (non-tappable) ──────────────────────────────
            _buildHudBar(topBarHeight),

            // ── GAME AREA (tappable for gravity flip) ──────────────────
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                // sin-based horizontal shake that decays as animation progresses
                final double progress = _shakeController.value;
                final double shakeX = progress < 1.0
                    ? sin(progress * pi * 8) * 10 * (1.0 - progress)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(shakeX, 0),
                  child: Transform.scale(
                    scale: zoomScale, // Zoom effect for slow-mo
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => flipGravity(tapPosition: details.localPosition),
                child: SizedBox(
                  width: size.width,
                  height: gameAreaHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                  // BACKGROUND STARS (parallax effect)
                  ...stars.map((star) {
                    return Positioned(
                      left: ((star.x + 1) / 2) * size.width,
                      top: ((star.y + 1) / 2) * gameAreaHeight,
                      child: Opacity(
                        opacity: star.opacity,
                        child: Container(
                          width: star.size,
                          height: star.size,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: star.size * 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // BALL
                  if (!showBallExplosion)
                    Align(
                      alignment: Alignment(0, ballY),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (hasShield)
                            Builder(builder: (_) {
                              // Blink in last 3 seconds: frequency ramps up as timer drops
                              bool blink = false;
                              if (shieldTimer <= 3.0) {
                                // Speed goes from ~2Hz at 3s to ~8Hz at 0s
                                double freq = 2.0 + (3.0 - shieldTimer) * 2.0;
                                blink = sin(elapsedTime * freq * 2 * pi) < 0;
                              }
                              return AnimatedOpacity(
                                opacity: blink ? 0.15 : 1.0,
                                duration: Duration(milliseconds: 60),
                                child: Container(
                                  width: (isShrunk ? ballSize * 0.45 : ballSize) + 20,
                                  height: (isShrunk ? ballSize * 0.45 : ballSize) + 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.cyanAccent, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(blink ? 0.1 : 0.6),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          Builder(builder: (_) {
                              // Flicker when shrink is about to expire (last 2s)
                              bool shrinkFlicker = false;
                              if (isShrunk && powerUpTimer <= 2.0) {
                                double freq = 3.0 + (2.0 - powerUpTimer) * 3.0;
                                shrinkFlicker = sin(elapsedTime * freq * 2 * pi) < 0;
                              }
                              final double sz = isShrunk ? ballSize * 0.45 : ballSize;
                              return AnimatedOpacity(
                                opacity: shrinkFlicker ? 0.25 : 1.0,
                                duration: Duration(milliseconds: 50),
                                child: Container(
                                  width: sz,
                                  height: sz,
                                  decoration: BoxDecoration(
                                    gradient: currentSkin.gradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: currentSkin.glowColor.withOpacity(shrinkFlicker ? 0.1 : 0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                  // TAP RIPPLES
                  ...tapRipples.expand((r) {
                    final Color c = currentSkin.glowColor;
                    return [
                      if (r.opacity > 0)
                        Positioned(
                          left: r.x - r.radius,
                          top: r.y - r.radius,
                          child: IgnorePointer(
                            child: Container(
                              width: r.radius * 2,
                              height: r.radius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: c.withOpacity(r.opacity.clamp(0.0, 1.0)),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: c.withOpacity((r.opacity * 0.25).clamp(0.0, 1.0)),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (r.opacity2 > 0)
                        Positioned(
                          left: r.x - r.radius2,
                          top: r.y - r.radius2,
                          child: IgnorePointer(
                            child: Container(
                              width: r.radius2 * 2,
                              height: r.radius2 * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: c.withOpacity(r.opacity2.clamp(0.0, 1.0)),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ];
                  }).toList(),

                  // EXPLOSION PARTICLES
                  ...explosionParticles.map((particle) {
                    return Positioned(
                      left: particle.x - particle.size / 2,
                      top: particle.y - particle.size / 2,
                      child: Opacity(
                        opacity: particle.opacity.clamp(0.0, 1.0),
                        child: Container(
                          width: particle.size,
                          height: particle.size,
                          decoration: BoxDecoration(
                            color: particle.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: particle.color.withOpacity(0.5 * particle.opacity.clamp(0.0, 1.0)),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // CELEBRATION CONFETTI
                  ...celebrationParticles.map((particle) {
                    return Positioned(
                      left: particle.x - particle.size / 2,
                      top: particle.y - particle.size / 2,
                      child: Opacity(
                        opacity: particle.opacity.clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: particle.x + particle.y,
                          child: Container(
                            width: particle.size,
                            height: particle.size,
                            decoration: BoxDecoration(
                              color: particle.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // OBSTACLES
                  ...obstacles.map((obstacle) {
                    return Align(
                      alignment: Alignment(obstacle.x, obstacle.y),
                      child: Opacity(
                        opacity: obstacle.opacity,
                        child: Container(
                          width: size.width * obstacle.width,
                          height: obstacleHeight,
                          decoration: BoxDecoration(
                            color: obstacle.color,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: obstacle.color.withOpacity(0.3 * obstacle.opacity),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // POWER-UPS (floating)
                  ...powerUps.map((powerUp) {
                    return Align(
                      alignment: Alignment(powerUp.x, powerUp.y),
                      child: Opacity(
                        opacity: powerUp.opacity,
                        child: Container(
                          width: powerUpSize,
                          height: powerUpSize,
                          decoration: BoxDecoration(
                            color: powerUp.color.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: powerUp.color, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: powerUp.color.withOpacity(0.5 * powerUp.opacity),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(powerUp.icon, color: powerUp.color, size: 24),
                        ),
                      ),
                    );
                  }).toList(),

                  // COINS
                  ...coins.map((coin) {
                    return Align(
                      alignment: Alignment(coin.x, coin.y),
                      child: Opacity(
                        opacity: coin.opacity.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: coin.scale,
                          child: Container(
                            width: coinSize,
                            height: coinSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Colors.yellow[300]!, Colors.amber[700]!],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.7 * coin.opacity),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '¢',
                                style: TextStyle(
                                  color: Colors.brown[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // ── PURCHASE POPUP (floats at top of game area) ──────
                  ...purchaseAnims.map((anim) {
                    Color animColor = PowerUp._getColor(anim.type);
                    String label = _powerUpLabel(anim.type);
                    return Positioned(
                      top: 10 + anim.offsetY,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: anim.opacity.clamp(0.0, 1.0),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: animColor, width: 2),
                              boxShadow: [
                                BoxShadow(color: animColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PowerUp._getIcon(anim.type), color: animColor, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  '$label ACTIVATED!',
                                  style: TextStyle(
                                    color: animColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // PAUSE MENU
                  if (isPaused && !isGameOver)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blueAccent, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("PAUSED", style: GoogleFonts.orbitron(color: Colors.blueAccent, fontSize: 30, fontWeight: FontWeight.bold)),
                            SizedBox(height: 15),
                            Text("Score: $score", style: TextStyle(color: Colors.white, fontSize: 24)),
                            SizedBox(height: 20),
                            SkinPicker(
                              selectedSkin: currentSkin,
                              onSkinSelected: (skin) => setState(() => currentSkin = skin),
                            ),
                            SizedBox(height: 25),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: Size(150, 50)),
                              onPressed: togglePause,
                              child: Text("RESUME", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                            SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], minimumSize: Size(150, 50)),
                              onPressed: restartGame,
                              child: Text("RESTART", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // GAME OVER
                  if (isGameOver)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("GAME OVER", style: GoogleFonts.orbitron(color: Colors.red, fontSize: 30, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            
                            // Stats Container
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                children: [
                                  // Final Score
                                  Text(
                                    "$score",
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "FINAL SCORE",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Divider(color: Colors.white12),
                                  SizedBox(height: 16),
                                  
                                  // Stats Grid
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatCard(
                                        icon: Icons.timer_outlined,
                                        value: "${elapsedTime.toInt()}s",
                                        label: "SURVIVED",
                                      ),
                                      _buildStatCard(
                                        icon: Icons.block,
                                        value: "$obstaclesDodged",
                                        label: "DODGED",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            if (score >= highScore && score > 0)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.amber, Colors.orange, Colors.amber]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 20, spreadRadius: 3)],
                                  ),
                                  child: Text("🎉 NEW HIGH SCORE! 🎉",
                                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            if (score < highScore)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text("High Score: $highScore", style: TextStyle(color: Colors.amber, fontSize: 18)),
                              ),
                            SizedBox(height: 20),
                            SkinPicker(
                              selectedSkin: currentSkin,
                              onSkinSelected: (skin) => setState(() => currentSkin = skin),
                            ),
                            SizedBox(height: 25),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                              onPressed: restartGame,
                              child: Text("PLAY AGAIN", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),   // AnimatedBuilder

          // ── SHOP BAR (separate, never triggers gravity flip) ────────
          _buildShopBar(),
        ],
      ),    // Column
    ),      // SafeArea
  );        // Scaffold
  }

  Widget _buildHudBar(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[950] ?? Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gravity arrow
            RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.5)
                  .animate(_arrowAnimationController),
              child: Icon(Icons.arrow_downward, color: Colors.white70, size: 26),
            ),
            SizedBox(width: 8),
            // Pause button
            GestureDetector(
              onTap: togglePause,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            // Centre: active power-up pill
            Expanded(
              child: Center(child: _buildActivePowerUpPill()),
            ),

            // Right: score · best · coins
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Score: $score",
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Best: $highScore",
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.yellow[300]!, Colors.amber[700]!],
                        ),
                      ),
                      child: Center(
                        child: Text('¢', style: TextStyle(fontSize: 7, color: Colors.brown[800], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      '$coinCount',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _powerUpLabel(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield: return 'SHIELD';
      case PowerUpType.slowMo: return 'SLOW-MO';
      case PowerUpType.shrink: return 'SHRINK';
      case PowerUpType.doublePoints: return '2X PTS';
    }
  }

  Widget _buildActivePowerUpPill() {
    // Show shield timer if active
    if (hasShield) {
      bool blinkOff = false;
      if (shieldTimer <= 3.0) {
        double freq = 2.0 + (3.0 - shieldTimer) * 2.0;
        blinkOff = sin(elapsedTime * freq * 2 * pi) < 0;
      }
      final Color pillColor = blinkOff ? Colors.cyan.withOpacity(0.3) : Colors.cyan;
      return AnimatedContainer(
        duration: Duration(milliseconds: 60),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pillColor, width: 1.5),
          boxShadow: [BoxShadow(color: pillColor.withOpacity(0.35), blurRadius: 8)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: pillColor, size: 16),
            SizedBox(width: 4),
            Text("${shieldTimer.toInt()}s", style: TextStyle(color: pillColor, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    if (powerUpTimer > 0) {
      Color c = isSlowMo ? Colors.yellow : isShrunk ? Colors.green : Colors.amber;
      IconData ic = isSlowMo ? Icons.speed : isShrunk ? Icons.compress : Icons.star;
      String label = isSlowMo ? "SLOW-MO" : isShrunk ? "SHRINK" : "2X";
      // Flicker pill in last 2s for shrink
      bool flickerOff = false;
      if (isShrunk && powerUpTimer <= 2.0) {
        double freq = 3.0 + (2.0 - powerUpTimer) * 3.0;
        flickerOff = sin(elapsedTime * freq * 2 * pi) < 0;
      }
      final Color pillC = flickerOff ? c.withOpacity(0.25) : c;
      return AnimatedContainer(
        duration: Duration(milliseconds: 50),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pillC, width: 1.5),
          boxShadow: [BoxShadow(color: pillC.withOpacity(0.35), blurRadius: 8)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ic, color: pillC, size: 16),
            SizedBox(width: 4),
            Text("$label ${powerUpTimer.toInt()}s", style: TextStyle(color: pillC, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildShopBar() {
    final List<PowerUpType> shopItems = [
      PowerUpType.shield,
      PowerUpType.slowMo,
      PowerUpType.shrink,
      PowerUpType.doublePoints,
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[950] ?? Colors.black,
        border: Border(top: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: shopItems.map((type) {
          int price = powerUpPrices[type]!;
          bool canAfford = coinCount >= price;
          Color itemColor = PowerUp._getColor(type);
          bool isActive = (type == PowerUpType.shield && hasShield) ||
              (type == PowerUpType.slowMo && isSlowMo) ||
              (type == PowerUpType.shrink && isShrunk) ||
              (type == PowerUpType.doublePoints && hasDoublePoints);

          return GestureDetector(
            onTap: (isGameOver || isPaused) ? null : () => buyPowerUp(type),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 150),
              width: 70,
              height: 62,
              decoration: BoxDecoration(
                color: isActive
                    ? itemColor.withOpacity(0.25)
                    : canAfford
                        ? itemColor.withOpacity(0.12)
                        : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? itemColor
                      : canAfford
                          ? itemColor.withOpacity(0.5)
                          : Colors.white12,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: itemColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PowerUp._getIcon(type),
                    color: isActive ? itemColor : canAfford ? itemColor : Colors.white24,
                    size: 22,
                  ),
                  SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '¢',
                        style: TextStyle(
                          color: canAfford ? Colors.amber : Colors.white24,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '$price',
                        style: TextStyle(
                          color: canAfford ? Colors.white : Colors.white24,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isActive)
                    Text(
                      'ON',
                      style: TextStyle(color: itemColor, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
