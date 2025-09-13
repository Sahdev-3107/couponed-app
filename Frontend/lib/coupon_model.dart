import 'package:flutter/material.dart';

class Coupon {
  final int id;
  final String title;
  final String description;
  final String category;
  final String discount;
  final String brand;
  final IconData icon;
  final Color color;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.discount,
    required this.brand,
    required this.icon,
    required this.color,
  });

  // Factory constructor to create a Coupon from JSON
  factory Coupon.fromJson(Map<String, dynamic> json) {
    // Helper function to assign an icon and color based on the category
    Map<String, dynamic> getVisuals(String category) {
      switch (category) {
        case 'Food':
          return {'icon': Icons.restaurant_menu, 'color': const Color(0xFFEF4444)};
        case 'Entertainment':
          return {'icon': Icons.theaters, 'color': const Color(0xFFF97316)};
        case 'Recharge':
          return {'icon': Icons.smartphone, 'color': const Color(0xFF8B5CF6)};
        case 'Travel':
          return {'icon': Icons.flight_takeoff, 'color': const Color(0xFF3B82F6)};
        case 'Fashion':
          return {'icon': Icons.shopping_bag, 'color': const Color(0xFFEC4899)};
        default:
          return {'icon': Icons.local_offer, 'color': Colors.grey};
      }
    }

    final visuals = getVisuals(json['category'] ?? 'General');

    return Coupon(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      category: json['category'] ?? 'General',
      discount: json['discount'] ?? '',
      brand: json['brand'] ?? 'Unknown Brand',
      icon: visuals['icon'],
      color: visuals['color'],
    );
  }
}

