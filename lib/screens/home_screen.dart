import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/glass_container.dart';
import 'setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // Deep Midnight Gradient
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          username,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Grading System',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGradingTable(),
                const SizedBox(height: 32),
                Text(
                  'GPA Ranking',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRankingSection(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SetupScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F2027),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      'START GPA CALCULATION',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradingTable() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGradeHeader(),
          const Divider(color: Colors.white24),
          _buildGradeRow('80 - 100', 'A', '4.0'),
          _buildGradeRow('70 - 79', 'B+', '3.5'),
          _buildGradeRow('60 - 69', 'B', '3.0'),
          _buildGradeRow('55 - 59', 'C+', '2.5'),
          _buildGradeRow('50 - 54', 'C', '2.0'),
          _buildGradeRow('45 - 49', 'D+', '1.5'),
          _buildGradeRow('40 - 44', 'D', '1.0'),
          _buildGradeRow('00 - 39', 'F', '0.0'),
        ],
      ),
    );
  }

  Widget _buildGradeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text('Mark Range', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.bold))),
          Expanded(child: Center(child: Text('Grade', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.bold)))),
          Expanded(child: Align(alignment: Alignment.centerRight, child: Text('GPA', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildGradeRow(String range, String grade, String gpa) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(range, style: GoogleFonts.poppins(color: Colors.white))),
          Expanded(child: Center(child: Text(grade, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(child: Align(alignment: Alignment.centerRight, child: Text(gpa, style: GoogleFonts.poppins(color: Colors.white)))),
        ],
      ),
    );
  }

  Widget _buildRankingSection() {
    return Row(
      children: [
        _buildRankingCard('Gold', '3.70 - 4.00', Colors.amber),
        const SizedBox(width: 12),
        _buildRankingCard('Silver', '3.30 - 3.69', Colors.grey[300]!),
        const SizedBox(width: 12),
        _buildRankingCard('Bronze', '3.00 - 3.29', Colors.orange[300]!),
      ],
    );
  }

  Widget _buildRankingCard(String title, String range, Color color) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(Icons.emoji_events, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(range, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
