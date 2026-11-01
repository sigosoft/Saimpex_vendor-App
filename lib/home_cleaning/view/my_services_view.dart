import 'package:saimpex_vendor/home_cleaning/model/service_kind.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/services_api.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_item_model.dart';
import 'package:saimpex_vendor/home_cleaning/view/add_service_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/home_cleaning_home.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class MyServicesView extends StatefulWidget {
  const MyServicesView({super.key, required this.controller});

  final HomeCleaningController controller;

  static const _orange = Color(0xFFFF5216);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF757575);

  @override
  State<MyServicesView> createState() => _MyServicesViewState();
}

class _MyServicesViewState extends State<MyServicesView> {
  final TextEditingController _searchController = TextEditingController();
  List<CleaningServiceItem> _services = [];
  bool _loading = true;
  String? _error;

  String get _lang => LocalizationService.currentLanguageCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final services = await CleaningServicesApi.fetchServices();
      if (!mounted) return;
      setState(() {
        _services = services;
        _error = null;
        _loading = false;
      });
    } on CleaningApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? S.of(context).cleaningSvcLoadError;
        _loading = false;
      });
    }
  }

  List<CleaningServiceItem> get _filteredServices {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _services;
    return _services.where((s) {
      return s.localizedName(_lang).toLowerCase().contains(query) ||
          (s.nameEn ?? '').toLowerCase().contains(query) ||
          (s.description ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openEditor([CleaningServiceItem? item]) async {
    HapticFeedback.lightImpact();
    // The editor is the home cleaning form. Laundry (per kg / per item) and
    // car wash (price per vehicle type) forms come in V14 part B; until
    // then those vendors add and edit services on the web panel.
    if (!ServiceKinds.isCleaning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).serviceEditOnWebPanel)),
      );
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddServiceView(initialService: item),
      ),
    );
    if (saved == true && mounted) _load(quiet: true);
  }

  Future<void> _handleDelete(CleaningServiceItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          S.of(context).waterConfirmDeleteNamedItem(item.localizedName(_lang)),
          style: appFont('Inter', 
            fontSize: 13.5,
            color: const Color(0xFF424242),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              S.of(context).cancel,
              style: appFont('Inter', 
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyServicesView._orange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              S.of(context).delete,
              style: appFont('Inter', 
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final message = await CleaningServicesApi.deleteService(item.id);
      if (!mounted) return;
      setState(() => _services.removeWhere((s) => s.id == item.id));
      if (message != null) showToast(context, message);
    } on CleaningApiException catch (e) {
      if (!mounted) return;
      showToast(context, e.message ?? S.of(context).cleaningSvcGenericError);
    }
  }

  Widget _buildBody(List<CleaningServiceItem> services) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: MyServicesView._orange),
      );
    }
    if (_error != null && _services.isEmpty) {
      return RefreshIndicator(
        color: MyServicesView._orange,
        onRefresh: () => _load(quiet: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: appFont('Inter', 
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: OutlinedButton(
                onPressed: _load,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: MyServicesView._orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  S.of(context).tryAgain,
                  style: appFont('Inter', 
                    color: MyServicesView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: MyServicesView._orange,
      onRefresh: () => _load(quiet: true),
      child: services.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 120),
              children: [
                Center(
                  child: Text(
                    S.of(context).cleaningNoServicesFound,
                    style: appFont('Inter', 
                      color: const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: services.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceCard(
                  service: service,
                  onEdit: () => _openEditor(service),
                  onDelete: () => _handleDelete(service),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE8DC), Color(0xFFFFF3EC), Color(0xFFFFFFFF)],
          stops: [0, 0.22, 0.45],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    S.of(context).cleaningMyServices,
                    style: appFont('Inter', 
                      color: MyServicesView._ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.controller.selectNav(0);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE0D0)),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: MyServicesView._orange,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() {}),
                style: appFont('Inter', 
                  color: MyServicesView._ink,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).cleaningSearchServices,
                  hintStyle: appFont('Inter', 
                    color: const Color(0xFFBDBDBD),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFBDBDBD),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                S.of(context).cleaningYourServicesHeader,
                style: appFont('Inter', 
                  color: const Color(0xFF9AA3B2),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(services)),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _openEditor(),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: MyServicesView._orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  S.of(context).cleaningAddServiceButton,
                  style: appFont('Inter', 
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  final CleaningServiceItem service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final lang = LocalizationService.currentLanguageCode;
    final firstSpace = service.spaces.isNotEmpty ? service.spaces.first : null;
    final rate = formatServicePrice(firstSpace?.price ?? service.price);
    final unit = firstSpace?.unit;
    final rateUnit = unit == null || unit.isEmpty
        ? 'MRU'
        : 'MRU / ${cleaningUnitLabel(context, unit)}';
    final description = service.description ?? '';
    final placeholder = Container(
      height: 155,
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      child: const Icon(
        Icons.cleaning_services,
        size: 40,
        color: MyServicesView._orange,
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          service.imageUrl == null
              ? placeholder
              : Image.network(
                  service.imageUrl!,
                  height: 155,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => placeholder,
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        service.localizedName(lang),
                        style: appFont('Inter', 
                          color: MyServicesView._ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (service.status != 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          S.of(context).inactiveLabel,
                          style: appFont('Inter', 
                            color: const Color(0xFF757575),
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    _ServicePopupMenu(onEdit: onEdit, onDelete: onDelete),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: appFont('Inter', 
                      color: MyServicesView._muted,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).cleaningStartingRateHeader,
                        style: appFont('Inter', 
                          color: MyServicesView._orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$rate ',
                              style: appFont('Inter', 
                                color: MyServicesView._orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: rateUnit,
                              style: appFont('Inter', 
                                color: const Color(0xFFFF8A65),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (service.addons.isNotEmpty)
                  _BadgeSection(
                    label: S.of(context).cleaningAddonServicesHeader,
                    badges: [
                      for (final addon in service.addons)
                        _ServiceBadge(
                          label: addon.name,
                          price: '+${formatServicePrice(addon.price)} MRU',
                        ),
                    ],
                  ),
                if (service.issues.isNotEmpty)
                  _BadgeSection(
                    label: S.of(context).cleaningIssuesCoveredHeader,
                    badges: [
                      for (final issue in service.issues)
                        _ServiceBadge(
                          label: cleaningIssueLabel(context, issue),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceBadge {
  const _ServiceBadge({required this.label, this.price});

  final String label;
  final String? price;
}

class _BadgeSection extends StatelessWidget {
  const _BadgeSection({required this.label, required this.badges});

  final String label;
  final List<_ServiceBadge> badges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          label,
          style: appFont('Inter', 
            color: const Color(0xFF424242),
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final badge in badges) _ServiceBadgeChip(badge: badge),
          ],
        ),
      ],
    );
  }
}

class _ServiceBadgeChip extends StatelessWidget {
  const _ServiceBadgeChip({required this.badge});

  final _ServiceBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: badge.price == null
          ? Text(
              badge.label,
              style: appFont('Inter', 
                color: const Color(0xFF424242),
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            )
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${badge.label} ',
                    style: appFont('Inter', 
                      color: const Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                  TextSpan(
                    text: badge.price!,
                    style: appFont('Inter', 
                      color: MyServicesView._orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ServicePopupMenu extends StatelessWidget {
  const _ServicePopupMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: const Color(0xFFEAEAEA),
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFFEAEAEA),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E), size: 20),
        offset: const Offset(-10, 30),
        onSelected: (value) {
          HapticFeedback.lightImpact();
          if (value == 'edit') {
            onEdit();
          } else if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'edit',
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Color(0xFF424242),
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).edit,
                  style: appFont('Inter', 
                    color: const Color(0xFF212121),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFF757575),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'delete',
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: Color(0xFF424242),
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).delete,
                  style: appFont('Inter', 
                    color: const Color(0xFF212121),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFF757575),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
