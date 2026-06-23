import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilight_foodz_customer/views/pages/home.dart';

// ---- palette (matches TwilightWelcomeScreen) ----
const _ink = Color(0xFF1B1410);
const _inkDeep = Color(0xFF140F0B);
const _inkSoft = Color(0xFF2A2018);
const _cream = Color(0xFFF7EFE3);
const _amber = Color(0xFFE8A33D);
const _coral = Color(0xFFE8603C);
const _sage = Color(0xFF8A9A5B);

class Verification extends StatefulWidget {
  final String phoneNumber;
  const Verification({super.key, required this.phoneNumber});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  bool _isLoading = false;
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isComplete = false;
  bool _hasError = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _focusNodes[index].unfocus();
    }
    setState(() {
      _hasError = false;
      _isComplete = _controllers.every((c) => c.text.isNotEmpty);
    });
  }

  Future<void> _verify() async {
    if (!_isComplete || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final code = _controllers.map((c) => c.text).join();

      final Map<String, String> queryParameters = {
        'm': widget.phoneNumber,
        'o': code,
      };

      const backend = String.fromEnvironment(
        'BACKEND_URL',
        defaultValue: 'NOT_FOUND',
      );

      final Uri url = Uri.https(backend, '/auth/verify', queryParameters);

      final response = await http
          .post(url)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['jwt'] != null) {
        String token = responseBody['jwt'].toString();

        final SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('jwt', token);

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(jwt: token),
          ),
          (route) => false,
        );

        FocusScope.of(context).unfocus();
      } else {
        setState(() => _hasError = true);

        for (final c in _controllers) {
          c.clear();
        }

        _focusNodes.first.requestFocus();
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resend(String channel) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Code resent via $channel')));
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
              // Same overflow-safe combo as the welcome / phone-number
              // screens: Spacer pins the footer to the bottom when there's
              // room, and it scrolls instead of overflowing when there isn't.
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
                          _buildTopBar(),
                          const SizedBox(height: 28),
                          Text(
                            'Enter verification code',
                            style: GoogleFonts.fraunces(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: _cream,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sent to ${widget.phoneNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              color: _cream.withAlpha(140),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildOtpRow(),
                          if (_hasError) ...[
                            const SizedBox(height: 14),
                            _buildErrorMessage(),
                          ],
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _ChannelPill(
                                icon: Icons.sms_outlined,
                                iconColor: _cream,
                                label: 'Resend via SMS',
                                onTap: () => _resend('SMS'),
                              ),
                              _ChannelPill(
                                icon: Icons.chat_bubble_outline,
                                iconColor: _sage,
                                label: 'Send via WhatsApp',
                                onTap: () => _resend('WhatsApp'),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'By tapping on "Send via WhatsApp", you agree to '
                            'receive important communications such as OTP '
                            'and payment details, over WhatsApp.',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              height: 1.5,
                              color: _cream.withValues(alpha:.45),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _NextButton(enabled: _isComplete, onTap: _verify),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _cream.withValues(alpha:.25)),
            ),
            child: Icon(
              Icons.arrow_back,
              size: 18,
              color: _cream.withValues(alpha:.9),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Verify OTP',
          style: GoogleFonts.inter(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _cream,
          ),
        ),
        const Spacer(),
        _HelpPill(
          onTap: () {
          },
        ),
      ],
    );
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return Container(
          width: 46,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasError
                  ? _coral.withValues(alpha:.6*255)
                  : _cream.withValues(alpha:.22*255),
            ),
            color: _cream.withValues(alpha:.04*225),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _cream,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (value) => _onDigitChanged(i, value),
          ),
        );
      }),
    );
  }

  Widget _buildErrorMessage() {
    return Row(
      children: [
        const Icon(Icons.error, size: 16, color: _coral),
        const SizedBox(width: 6),
        Text(
          'Incorrect OTP, please try again.',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: _coral,
          ),
        ),
      ],
    );
  }
}

// ---------------- small reusable widgets ----------------
// Self-contained copies for this file — see the note in
// twilight_phone_number_screen.dart if you'd rather share one copy.

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
          border: Border.all(color: _cream.withValues(alpha:.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, size: 16, color: _cream.withValues(alpha:.85)),
            const SizedBox(width: 6),
            Text(
              'Help',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _cream.withValues(alpha:.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ChannelPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _cream.withValues(alpha:.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _cream.withValues(alpha:.9),
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
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.enabled ? _amber : _cream.withValues(alpha:.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              'Next',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: widget.enabled ? _ink : _cream.withValues(alpha:.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
