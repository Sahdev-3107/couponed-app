import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // 1. Import Provider

import 'claim_screen.dart';
import 'coupon_model.dart';

// App's main color theme inspired by couponed.com
const Color couponedPrimary = Color(0xFF16A34A);
const Color couponedBackground = Color(0xFFF8FAFC);
const Color couponedBodyText = Color(0xFF334155);
const Color couponedHeaderText = Color(0xFF1E293B);
const Color couponedBorder = Color(0xFFE2E8F0);

// 2. STATE MANAGEMENT: Create the CouponProvider
class CouponProvider with ChangeNotifier {
  List<Coupon> _coupons = [];
  final Set<int> _claimedCouponIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isClaimed(int couponId) => _claimedCouponIds.contains(couponId);

  void claimCoupon(int couponId) {
    _claimedCouponIds.add(couponId);
    notifyListeners(); // Notify widgets to rebuild
  }

  Future<void> fetchCoupons() async {
    const String apiUrl = 'http://localhost:3000/api/coupons';
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _coupons = jsonResponse.map((coupon) => Coupon.fromJson(coupon)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load coupons. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to connect to the server: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}


void main() {
  // 3. Wrap the app with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CouponProvider(),
      child: const MyApp(),
    ),
  );
}

// ------------------- Root App Widget -------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coupon App - Save More',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: couponedPrimary,
        scaffoldBackgroundColor: couponedBackground,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: couponedBodyText,
          displayColor: couponedHeaderText,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: couponedPrimary,
          brightness: Brightness.light,
          background: couponedBackground,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: couponedBackground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.manrope(
            color: couponedHeaderText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: couponedPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIconColor: Colors.grey[600],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: couponedBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: couponedBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: couponedPrimary, width: 2.0),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ------------------- Home Screen Widget -------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Food', 'Travel', 'Fashion', 'Entertainment', 'Recharge'];
  
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 4. Fetch initial data using the provider
    Provider.of<CouponProvider>(context, listen: false).fetchCoupons();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Coupons & Deals"),
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: couponedBorder, height: 1.0),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find the best deals for you",
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: couponedHeaderText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for brands, stores...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryFilters(),
                  const SizedBox(height: 24),
                  Text(
                    "Trending Deals",
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: couponedHeaderText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 5. Use Consumer instead of FutureBuilder
          Consumer<CouponProvider>(
            builder: (context, couponProvider, child) {
              if (couponProvider.isLoading) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (couponProvider.errorMessage != null) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error: ${couponProvider.errorMessage}'),
                    ),
                  ),
                );
              }
              
              List<Coupon> filteredCoupons = couponProvider.coupons;

              if (selectedCategory != 'All') {
                filteredCoupons = filteredCoupons.where((c) => c.category == selectedCategory).toList();
              }

              if (_searchQuery.isNotEmpty) {
                filteredCoupons = filteredCoupons.where((coupon) {
                  final query = _searchQuery.toLowerCase();
                  return coupon.title.toLowerCase().contains(query) ||
                         coupon.brand.toLowerCase().contains(query) ||
                         coupon.description.toLowerCase().contains(query);
                }).toList();
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 1200 ? 3 :
                        MediaQuery.of(context).size.width > 800 ? 2 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final coupon = filteredCoupons[index];
                      return OpenContainer(
                        transitionDuration: const Duration(milliseconds: 500),
                        closedShape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                        closedElevation: 0,
                        closedColor: Colors.transparent,
                        openBuilder: (context, _) =>
                            ClaimScreen(couponTitle: coupon.title),
                        closedBuilder: (context, action) =>
                            CouponCard(coupon: coupon, onTap: action),
                      );
                    },
                    childCount: filteredCoupons.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    isSelected ? couponedPrimary.withOpacity(0.1) : Colors.transparent,
                foregroundColor:
                    isSelected ? couponedPrimary : couponedBodyText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSelected
                      ? BorderSide.none
                      : const BorderSide(color: couponedBorder),
                ),
              ),
              onPressed: () {
                setState(() => selectedCategory = category);
              },
              child: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------- Coupon Card and Custom Painters -------------------
class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback onTap;

  const CouponCard({super.key, required this.coupon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 6. Use Consumer here to listen for changes in claimed status
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        final isClaimed = couponProvider.isClaimed(coupon.id);
        
        return GestureDetector(
          onTap: onTap,
          child: ClipPath(
            clipper: CouponClipper(notchRadius: 15, stubWidth: 100),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _buildStubPart(),
                    CustomPaint(
                      size: const Size(2, double.infinity),
                      painter: DashedLinePainter(color: Colors.grey.shade300),
                    ),
                    _buildMainContentPart(context, isClaimed),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStubPart() {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: coupon.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(coupon.icon, color: coupon.color, size: 32),
          ),
          const SizedBox(height: 12),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              coupon.brand,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: coupon.color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentPart(BuildContext context, bool isClaimed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coupon.title.toUpperCase(),
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: couponedHeaderText,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              coupon.description,
              style: GoogleFonts.inter(
                color: couponedBodyText,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // 7. Update button state and action
                onPressed: isClaimed
                  ? null // Disable button if claimed
                  : () {
                      // Claim the coupon via the provider
                      context.read<CouponProvider>().claimCoupon(coupon.id);
                      // Trigger the navigation
                      onTap();
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isClaimed ? Colors.grey : coupon.color,
                ),
                child: Text(
                  isClaimed ? "Claimed" : "Claim Deal",
                  style:
                      GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CouponClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double stubWidth;

  CouponClipper({required this.notchRadius, required this.stubWidth});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final leftNotchPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(stubWidth, size.height / 2),
        radius: notchRadius,
      ));

    return Path.combine(PathOperation.difference, path, leftNotchPath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) =>
      oldClipper is! CouponClipper ||
      notchRadius != oldClipper.notchRadius ||
      stubWidth != oldClipper.stubWidth;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

