import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/craft_floating_buttons.dart';
import '../../widgets/accessible_speaker_button.dart';
import 'customer_home_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  String _selectedPaymentMethod = 'UPI';
  String _deliveryAddress = 'Meera Shah, 18 Lake View Road, Bengaluru 560001';
  bool _isProcessingPayment = false;

  void _showChangeAddressDialog() {
    final controller = TextEditingController(text: _deliveryAddress);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Delivery Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Enter complete shipping address...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _deliveryAddress = controller.text.trim());
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracotta,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  void _handlePlaceOrder() async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (appState.cart.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Your cart is empty!')));
      return;
    }

    // 1. Create real/simulated Razorpay order via backend
    final rzpOrder = await ApiService.createRazorpayOrder(
      amount: appState.cartTotal,
      productName: 'KalaSetu Cart (${appState.cartItemCount} items)',
    );
    final rzpOrderId = rzpOrder?['id'] ?? 'order_KS_${DateTime.now().millisecondsSinceEpoch}';

    if (!mounted) return;

    // Open Razorpay Gateway Sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C2340),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'RAZORPAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Verified Indian Gateway',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paying ₹${appState.cartTotal.toStringAsFixed(0)} to KalaSetu Artisans',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF6EE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rzpOrderId.length > 16 ? rzpOrderId.substring(0, 16) : rzpOrderId,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Direct benefit transfer to artisan bank accounts.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedPaymentMethod == 'UPI') ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBCE3C6)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            color: AppTheme.forestGreen,
                            size: 36,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Google Pay / PhonePe / Paytm UPI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Zero-fee instant bank verification',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EFEA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: AppTheme.textDark,
                            size: 32,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Visa / Mastercard / RuPay Debit & Credit',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessingPayment
                          ? null
                          : () async {
                              setSheetState(() => _isProcessingPayment = true);

                              // 2. Verify payment signature with backend
                              await ApiService.verifyRazorpayPayment(
                                razorpayOrderId: rzpOrderId,
                                razorpayPaymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                                razorpaySignature: 'test_sig_${DateTime.now().millisecondsSinceEpoch}',
                              );

                              // 3. Save order to PostgreSQL / SQLite database
                              await appState.checkoutCurrentCart(
                                paymentMethod: _selectedPaymentMethod,
                                deliveryAddress: _deliveryAddress,
                              );

                              if (context.mounted) {
                                Navigator.of(context).pop(); // Close sheet
                                _showOrderSuccessDialog();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forestGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isProcessingPayment
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              'Confirm & Pay ₹${appState.cartTotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFEBF6EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppTheme.forestGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Confirmed!!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your handmade pieces are being lovingly prepared by the master artisans. Tracking code #AX1049 generated.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const CustomerHomeScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Back to Marketplace'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final cart = appState.cart;

    return Scaffold(
      body: DecorativeBackground(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart & Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AccessibleSpeakerButton(
                    textToRead:
                        'आपके कार्ट में ${cart.length} हस्तनिर्मित उत्पाद हैं। कुल देय राशि ₹${appState.cartTotal.toStringAsFixed(0)} है।',
                    tooltip: 'Listen to cart summary via Bhashini',
                    size: 38,
                    glowColor: AppTheme.terracotta,
                  ),
                ],
              ),
            ),

            // Main Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle matching Figma: "2 beautiful handmade pieces."
                    Text(
                      '${appState.cartItemCount} beautiful handmade ${appState.cartItemCount == 1 ? 'piece' : 'pieces'}.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cart Items List
                    if (cart.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 50,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Your craft basket is empty',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.terracotta,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Discover Crafts'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cart[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Product Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 58,
                                    height: 58,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, trace) =>
                                        Container(
                                          width: 58,
                                          height: 58,
                                          color: AppTheme.surfaceWarm,
                                          child: const Icon(
                                            Icons.palette_outlined,
                                          ),
                                        ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Title & Artisan
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.product.sellerName.split(' ')[0]} • ${item.product.sellerLocation.split(',')[0]}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.product.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.terracotta,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Vertical Quantity Stepper matching Figma: [+] 1 [-]
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F7F3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.borderLight,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            appState.updateCartQuantity(
                                              item.product.id,
                                              1,
                                            ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 16,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            appState.updateCartQuantity(
                                              item.product.id,
                                              -1,
                                            ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    // Delivery Address Card matching Figma
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: AppTheme.terracotta,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'DELIVER TO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showChangeAddressDialog,
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.terracotta,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _deliveryAddress,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Method Selector
                    const Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tabs: [UPI] and [Card]
                    Row(
                      children: [
                        // UPI Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPaymentMethod = 'UPI'),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _selectedPaymentMethod == 'UPI'
                                    ? const Color(0xFFEAF5EE)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedPaymentMethod == 'UPI'
                                      ? const Color(0xFF2E854B)
                                      : AppTheme.borderLight,
                                  width: _selectedPaymentMethod == 'UPI'
                                      ? 1.5
                                      : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 18,
                                    color: _selectedPaymentMethod == 'UPI'
                                        ? const Color(0xFF2E854B)
                                        : AppTheme.textDark,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'UPI',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedPaymentMethod == 'UPI'
                                          ? const Color(0xFF2E854B)
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Card Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPaymentMethod = 'Card'),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _selectedPaymentMethod == 'Card'
                                    ? const Color(0xFFEAF5EE)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedPaymentMethod == 'Card'
                                      ? const Color(0xFF2E854B)
                                      : AppTheme.borderLight,
                                  width: _selectedPaymentMethod == 'Card'
                                      ? 1.5
                                      : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card_outlined,
                                    size: 18,
                                    color: _selectedPaymentMethod == 'Card'
                                        ? const Color(0xFF2E854B)
                                        : AppTheme.textDark,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Card',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedPaymentMethod == 'Card'
                                          ? const Color(0xFF2E854B)
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Total Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total price',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '₹${appState.cartTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Primary Button: Place Order (Deep Navy Indigo)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: cart.isEmpty ? null : _handlePlaceOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navyIndigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 1,
                        ),
                        child: Text(
                          'Place order • ₹${appState.cartTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Craft & AI Floating Action Buttons
            const CraftFloatingButtons(),
          ],
        ),
      ),
    );
  }
}
