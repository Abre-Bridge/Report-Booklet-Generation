import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/ue.dart';
import '../utils/gpa_calculator.dart';
import '../widgets/glass_container.dart';
import 'setup_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<UE> ues;
  const ResultsScreen({super.key, required this.ues});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? username;
  String? matricule;
  double gpa = 0.0;
  String ranking = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    gpa = GpaCalculator.calculateOverallGpa(widget.ues);
    ranking = GpaCalculator.getRanking(gpa);
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Unknown';
      matricule = prefs.getString('matricule') ?? 'Unknown';
    });
  }

  Future<void> _exportTranscript() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text("Official Transcript - GPA Pro", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Student: $username", style: const pw.TextStyle(fontSize: 18)),
              pw.Text("Matricule: $matricule", style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text("Ranking: $ranking", style: const pw.TextStyle(fontSize: 18)),
              pw.Text("Total GPA: ${gpa.toStringAsFixed(2)} / 4.0", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                headers: ['U.E. Name', 'Mark (/100)', 'Grade', 'Credits', 'Quality Pts'],
                data: widget.ues.map((ue) {
                  final result = GpaCalculator.getGradeAndGpa(ue.mark);
                  return [
                    ue.name,
                    ue.mark.toString(),
                    result.grade,
                    ue.credits.toString(),
                    (result.gpaItemLevel * ue.credits).toStringAsFixed(1),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${matricule}_Transcript',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D976C), Color(0xFF93F9B9)], // Success gradient
          ),
        ),
        child: SafeArea(
          child: username == null ? const Center(child: CircularProgressIndicator()) : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Results',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SetupScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(24.0),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        '🏆 $ranking',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        gpa.toStringAsFixed(2),
                        style: GoogleFonts.poppins(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Cumulative GPA on 4.0',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$username • $matricule',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject Details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.ues.map((ue) {
                        final result = GpaCalculator.getGradeAndGpa(ue.mark);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ue.name,
                                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Credits: ${ue.credits} | Mark: ${ue.mark}',
                                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  result.grade,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _exportTranscript,
                    icon: const Icon(Icons.download),
                    label: Text(
                      'EXPORT TRANSCRIPT',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1D976C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
