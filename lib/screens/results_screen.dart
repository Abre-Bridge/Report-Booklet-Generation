import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/ue.dart';
import '../utils/gpa_calculator.dart';
import '../widgets/glass_container.dart';
import 'home_screen.dart';

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

    final primaryColor = PdfColor.fromInt(0xFF1D976C);
    final accentColor = PdfColor.fromInt(0xFF2C5364);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("BGMAX", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 32, color: primaryColor)),
                      pw.Text("Academic Performance Report", style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
                      pw.Text("Status: Official"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2, color: primaryColor),
              pw.SizedBox(height: 30),

              // Student Info
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("STUDENT NAME", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        pw.Text(username ?? 'N/A', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        pw.SizedBox(height: 10),
                        pw.Text("MATRICULE", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        pw.Text(matricule ?? 'N/A', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("OVERALL GPA", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        pw.Text(gpa.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 32, color: primaryColor)),
                        pw.Text("RANK: $ranking", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),

              // Table
              pw.Text("SUBJECT RECORD", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: accentColor)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: primaryColor),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1),
                },
                headers: ['U.E. Name', 'Score', 'Grade', 'Credits', 'Points'],
                data: widget.ues.map((ue) {
                  final result = GpaCalculator.getGradeAndGpa(ue.mark);
                  return [
                    ue.name,
                    ue.mark.toStringAsFixed(1),
                    result.grade,
                    ue.credits.toString(),
                    (result.gpaItemLevel * ue.credits).toStringAsFixed(1),
                  ];
                }).toList(),
              ),

              pw.Spacer(),
              
              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Generated by BGMax Student Assistant", style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500)),
                  pw.Text("Page 1 of 1", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                ],
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
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
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
