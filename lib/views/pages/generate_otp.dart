import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:twilight_foodz_customer/views/pages/help.dart';
import 'package:twilight_foodz_customer/views/widgets/page_transition.dart';

import 'verification.dart';

// ---- palette (matches TwilightWelcomeScreen) ----
const _ink = Color(0xFF1B1410);
const _inkDeep = Color(0xFF140F0B);
const _inkSoft = Color(0xFF2A2018);
const _cream = Color(0xFFF7EFE3);
const _amber = Color(0xFFE8A33D);
const _coral = Color(0xFFE8603C);
const _coralDeep = Color(0xFFC9491F);

class GenerateOtp extends StatefulWidget {
  const GenerateOtp({super.key});

  @override
  State<GenerateOtp> createState() => _GenerateOtpState();
}

class _GenerateOtpState extends State<GenerateOtp> {
  static const backend = String.fromEnvironment('BACKEND_URL');
  bool _isValid = false;
  final _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(() {
      _validate(_mobileController.text);
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_isValid) return;

    final Map<String, String> queryParameters = {'m': _mobileController.text};

    final Uri url = Uri.https(
      backend, // Authority / Domain
      '/auth/login', // Unencoded path
      queryParameters, // Query parameters
    );

    await http.get(url);

    if (!mounted) {
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Verification(phoneNumber: _mobileController.text),
      ),
    );
  }

  void _validate(String? text) {
    final RegExp mobileRegex = RegExp(r'^[0-9]{10}$');
    if (mobileRegex.hasMatch(text!.trim()) && text.trim().length == 10) {
      setState(() {
        _isValid = true;
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.1,
            colors: [_inkSoft, _ink, _inkDeep],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: _HelpPill(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransitions.getSlideTransitonOfPage(
                                    page: Help(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildBrandMark(),
                          const SizedBox(height: 40),
                          Text(
                            "What's your number?",
                            style: GoogleFonts.fraunces(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: _cream,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPhoneField(),
                          const Spacer(),
                          _buildTermsText(),
                          const SizedBox(height: 16),
                          _NextButton(
                            enabled: _isValid,
                            onTap: () => _submit(),
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
      ),
    );
  }

  Widget _buildBrandMark() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_coral, _coralDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: _coral.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.nightlight_round, color: _cream, size: 24),
        ),
        const SizedBox(width: 14),
        Text(
          'Twilight',
          style: GoogleFonts.fraunces(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            fontSize: 28,
            color: _cream,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(135, 110, 110, 110)),
        color: const Color.fromARGB(44, 247, 239, 227),
      ),

      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              '+91',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _cream,
              ),
            ),
          ),
          Container(width: 1, height: 22, color: _cream.withValues(alpha: .18)),
          Expanded(
            child: TextField(
              onEditingComplete: () => _validate(_mobileController.text),
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              maxLength: 10,
              onSubmitted: (_) => _submit(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _cream,
                letterSpacing: .5,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                hintText: '98765 43210',
                hintStyle: GoogleFonts.inter(
                  color: const Color.fromARGB(
                    77,
                    106,
                    106,
                    106,
                  ).withValues(alpha: .3),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 12.5,
          height: 1.5,
          color: _cream.withValues(alpha: .5),
        ),
        children: [
          const TextSpan(
            text:
                'By continuing, you confirm that you are 18 years of '
                'age and agree to the ',
          ),
          TextSpan(
            text: 'Terms & Conditions',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: _amber,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: _amber,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- small reusable widgets ----------------
// Dart privacy is per-file, so Verification keeps its own copies of
// these two below — that keeps each screen file self-contained (drop
// either one into a project on its own), at the cost of small duplication.
// If you'd rather share one copy, move these into their own file (e.g.
// twilight_widgets.dart) without the leading underscore and import it.

class _HelpPill extends StatelessWidget {
  final VoidCallback onTap;
  const _HelpPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _cream.withValues(alpha: .25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              size: 16,
              color: _cream.withValues(alpha: .85),
            ),
            const SizedBox(width: 6),
            Text(
              'Help',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _cream.withValues(alpha: .85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _NextButton({required this.enabled, required this.onTap});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.enabled
                ? _amber
                : const Color.fromARGB(255, 63, 63, 63),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: _pressed
                ? CircularProgressIndicator(
                    strokeWidth: 3,
                    color: const Color.fromARGB(255, 53, 52, 52),
                  )
                : Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: widget.enabled
                          ? _ink
                          : _cream.withValues(alpha: .35),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
