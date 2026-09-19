import 'package:flutter/material.dart';

import '../models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case OrderStatus.readyToShip:
        bg = const Color(0xFFFDECE7);
        text = const Color(0xFFD64D29);
        label = 'Ready to ship';
        break;
      case OrderStatus.processing:
        bg = const Color(0xFFFEF5E5);
        text = const Color(0xFFC07E1F);
        label = 'Processing';
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFEBF6EE);
        text = const Color(0xFF2E854B);
        label = 'Delivered';
        break;
      case OrderStatus.pending:
        bg = const Color(0xFFF2EFE9);
        text = const Color(0xFF7A7570);
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
