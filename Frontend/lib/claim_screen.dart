import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Import the new color constants from main.dart
import 'main.dart'; 

class ClaimScreen extends StatefulWidget {
  final String couponTitle;

  const ClaimScreen({super.key, required this.couponTitle});

  @override
  State<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends State<ClaimScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _codeCopied = false;

  String _generatedCode = '';

  @override
  void initState() {
    super.initState();
    _generateCouponCode();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));
    
    _mainController.forward();
  }

  void _generateCouponCode() {
    final random = math.Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    _generatedCode = String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coupon Claimed"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: couponedBorder, height: 1.0),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: couponedPrimary, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    "Congratulations!",
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: couponedHeaderText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your coupon code is ready to use.",
                    style: TextStyle(fontSize: 16, color: couponedBodyText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // The Coupon Code Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: couponedBorder)
                    ),
                    child: Column(
                      children: [
                         Text(
                          widget.couponTitle,
                          style: TextStyle(fontSize: 16, color: couponedBodyText, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: couponedBackground,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Center(
                            child: Text(
                              _generatedCode,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: couponedPrimary,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(_codeCopied ? Icons.check : Icons.copy_rounded, size: 18),
                            label: Text(_codeCopied ? "Copied!" : "Copy Code"),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _generatedCode));
                              setState(() => _codeCopied = true);
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() => _codeCopied = false);
                                }
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: couponedBorder),
                      foregroundColor: couponedBodyText,
                      fixedSize: const Size.fromWidth(double.maxFinite)
                    ),
                    onPressed: () => Navigator.of(context).pop(), 
                    child: const Text("Browse More Deals")
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}