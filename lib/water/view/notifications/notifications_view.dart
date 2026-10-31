import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/water/core/water_state_view.dart';

class AppNotification {
  const AppNotification({
    required this.title,
    required this.body,
    required this.timeAgo,
  });

  final String title;
  final String body;
  final String timeAgo;

  /// `GET vendorapp/notifications` row: `title_en|fr|ar`, `content_en|fr|ar`,
  /// `created_at`. The row carries no order/subscription link, so no action
  /// button is shown.
  factory AppNotification.fromJson(Map<String, dynamic> json, String lang) {
    String pick(String base) {
      final local = json['${base}_$lang']?.toString().trim() ?? '';
      if (local.isNotEmpty && local != 'null') return local;
      final en = json['${base}_en']?.toString().trim() ?? '';
      return en == 'null' ? '' : en;
    }

    return AppNotification(
      title: pick('title'),
      body: pick('content'),
      timeAgo: WaterApi.timeAgo(json['created_at']),
    );
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  static const _limit = 20;

  final _scroll = ScrollController();
  final List<AppNotification> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasMore &&
        !_loadingMore &&
        !_loading &&
        _scroll.position.extentAfter < 300) {
      _load(more: true);
    }
  }

  Future<void> _load({bool more = false}) async {
    if (more) {
      setState(() => _loadingMore = true);
    } else if (_items.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final page = more ? _page + 1 : 1;
    try {
      await WaterApi.prepare();
      final response = await DioClient().get(
        ApiEndPoints.getNotifications,
        query: {
          'vendor_type': await WaterApi.vendorType(),
          'limit': _limit,
          'page': page,
        },
      );
      final body = response.data;
      if (!WaterApi.isOk(body)) {
        throw WaterApi.message(body) ?? S.current.waterSomethingWentWrong;
      }
      if (!mounted) return;
      final lang = Localizations.localeOf(context).languageCode;
      final data = body['data'];
      final rows = WaterApi.pageItems(data)
          .map((e) => AppNotification.fromJson(e, lang))
          .toList();
      setState(() {
        if (!more) _items.clear();
        _items.addAll(rows);
        _page = page;
        _hasMore = WaterApi.hasMore(data);
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (more || _items.isNotEmpty) {
        showToast(context, WaterApi.errorText(e));
      } else {
        setState(() => _error = WaterApi.errorText(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Widget _body() {
    if (_loading && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [WaterStateView.loading()],
      );
    }
    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [WaterStateView.error(message: _error!, onRetry: _load)],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          WaterStateView.empty(
            title: S.of(context).noNotificationsFound,
            icon: Icons.notifications_none_rounded,
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          );
        }
        return _NotificationCard(item: _items[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundMid,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.backgroundMid,
                Colors.white,
              ],
              stops: [0, 0.25, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryOrange,
                    onRefresh: _load,
                    child: _body(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              S.of(context).notifications,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryOrange,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.notifOrderAccent;
    const iconBg = AppColors.notifOrderIconBg;
    const icon = Icons.notifications_none_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.timeAgo,
                                style: const TextStyle(
                                  color: AppColors.notifTimeText,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (item.body.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            item.body,
                            style: const TextStyle(
                              color: AppColors.notifBodyText,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
