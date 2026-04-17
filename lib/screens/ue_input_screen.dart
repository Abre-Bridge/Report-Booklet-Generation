import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ue.dart';
import '../widgets/glass_container.dart';
import 'results_screen.dart';

class UeInputScreen extends StatefulWidget {
  final int ueCount;
  const UeInputScreen({super.key, required this.ueCount});

  @override
  State<UeInputScreen> createState() => _UeInputScreenState();
}

class _UeInputScreenState extends State<UeInputScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _markControllers = [];
  final List<TextEditingController> _creditControllers = [];
  final List<GlobalKey<FormState>> _formKeys = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.ueCount; i++) {
      _nameControllers.add(TextEditingController());
      _markControllers.add(TextEditingController());
      _creditControllers.add(TextEditingController());
      _formKeys.add(GlobalKey<FormState>());
    }
  }

  void _nextOrSubmit() {
    if (_formKeys[_currentIndex].currentState!.validate()) {
      if (_currentIndex < widget.ueCount - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Collect data
        List<UE> ues = [];
        for (int i = 0; i < widget.ueCount; i++) {
          ues.add(UE(
            name: _nameControllers[i].text,
            mark: double.parse(_markControllers[i].text),
            credits: int.parse(_creditControllers[i].text),
          ));
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResultsScreen(ues: ues)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)], // Sunset gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Text(
                      'U.E. ${_currentIndex + 1} of ${widget.ueCount}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for icon button
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Prevent swipe for validation
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: widget.ueCount,
                  itemBuilder: (context, index) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(32.0),
                          child: Form(
                            key: _formKeys[index],
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Details for U.E. ${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: _nameControllers[index],
                                  label: 'U.E. Name',
                                  icon: Icons.book,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _markControllers[index],
                                  label: 'Mark (/100)',
                                  icon: Icons.score,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v!.isEmpty) return 'Required';
                                    final val = double.tryParse(v);
                                    if (val == null || val < 0 || val > 100) return '0 - 100';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _creditControllers[index],
                                  label: 'Credits',
                                  icon: Icons.stars,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v!.isEmpty) return 'Required';
                                    if (int.tryParse(v) == null) return 'Must be a number';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _nextOrSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFFFC466B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      index == widget.ueCount - 1 ? 'CALCULATE GPA' : 'NEXT U.E.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
      validator: validator,
    );
  }
}
