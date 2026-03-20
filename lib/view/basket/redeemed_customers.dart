import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../generated/l10n.dart';
import '../../model/basket_customers_model.dart';
import '../../resources/colors.dart';
import '../../utils/widgets/common_background.dart';
import '../../utils/widgets/no_data_widget.dart';
import '../../controller/redeemed_customers_controller.dart';

/// Demo customer who redeemed basket points (replace with API model later).
class RedeemedCustomer {
  const RedeemedCustomer({
    required this.name,
    required this.phone,
    required this.points,
    required this.date,
  });

  final String name;
  final String phone;
  final String points;
  final String date;
}

/// Mock list for basket details preview + full redeemed-customers screen.
final List<RedeemedCustomer> kMockRedeemedCustomers = [
  const RedeemedCustomer(
    name: 'Aicha Mint Ahmed',
    phone: '+222 62345678',
    points: '2000',
    date: 'Feb 18 2025, 10:23 AM',
  ),
  const RedeemedCustomer(
    name: 'Mohamed Ould Sidi',
    phone: '+222 61234567',
    points: '1500',
    date: 'Feb 17 2025, 3:45 PM',
  ),
  const RedeemedCustomer(
    name: 'Fatima Mint Ely',
    phone: '+222 63456789',
    points: '2000',
    date: 'Feb 16 2025, 9:12 AM',
  ),
  const RedeemedCustomer(
    name: 'Brahim Ould Cheikh',
    phone: '+222 64567890',
    points: '500',
    date: 'Feb 15 2025, 6:30 PM',
  ),
  const RedeemedCustomer(
    name: 'Mariem Mint Baba',
    phone: '+222 65678901',
    points: '2000',
    date: 'Feb 14 2025, 11:00 AM',
  ),
  const RedeemedCustomer(
    name: 'Sidi Ould Hamadi',
    phone: '+222 66789012',
    points: '1200',
    date: 'Feb 12 2025, 2:15 PM',
  ),
];

String redeemedCustomerInitials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.length >= 2) {
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return '$a$b'.toUpperCase();
  }
  if (parts.isNotEmpty && parts[0].length >= 2) {
    return parts[0].substring(0, 2).toUpperCase();
  }
  if (parts.isNotEmpty) return parts[0][0].toUpperCase();
  return '?';
}

/// Full list of redeemed customers (opened from basket details "View All").
class RedeemedCustomersScreen extends StatefulWidget {
  const RedeemedCustomersScreen({
    super.key,
    required this.basketId,
  });

  final int basketId;

  @override
  State<RedeemedCustomersScreen> createState() => _RedeemedCustomersScreenState();
}

class _RedeemedCustomersScreenState extends State<RedeemedCustomersScreen> {
  late final RedeemedCustomersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(RedeemedCustomersController());
    _controller.basket_id = widget.basketId.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getBasketsCustomers(context);
    });
  }

  @override
  void dispose() {
    Get.delete<RedeemedCustomersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RedeemedCustomersController>(
      builder: (c) {
        final list = c.basketList;

        return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).redeemedCustomers,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      body: CommonBackground(
        child: (c.isLoading && list.isEmpty)
            ? const Center(
                child: CircularProgressIndicator(color: colorPrimary),
              )
            : list.isEmpty
                ? NoDataWidget(
                    context,
                    S.of(context).noOrdersFound,
                    S.of(context).noOrdersFound,
                    'lib/assets/images/nonotifications.png',
                  )
                : ListView.separated(
                controller: c.scrollController,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return RedeemedCustomerTile(customer: list[index]);
                },
              ),
      ),
    );
      },
    );
  }
}

/// Card matching basket details redeemed-customer row.
class RedeemedCustomerTile extends StatelessWidget {
  const RedeemedCustomerTile({super.key, required this.customer});

  final Datum customer;

  @override
  Widget build(BuildContext context) {
    final initials =
        redeemedCustomerInitials(customer.userName ?? customer.userMobile ?? '');

    final phone = [
      customer.countryCode,
      customer.userMobile,
    ].where((e) => (e ?? '').toString().isNotEmpty).join(' ');

    final points = (customer.redeemPoints ?? 0).toString();

    final createdAtStr = customer.createdAt != null
        ? DateFormat('MMM dd, yyyy, h:mm a').format(customer.createdAt!)
        : '-';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  initials,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF5216),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.userName ?? '-',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      phone,
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  S.of(context).redeemedStatus,
                  style: GoogleFonts.rubik(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).pointsLabel,
                      style: GoogleFonts.rubik(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      points,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).dateLabel,
                      style: GoogleFonts.rubik(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAtStr,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
