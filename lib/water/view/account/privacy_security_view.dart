import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class PrivacySecurityView extends StatefulWidget {
  const PrivacySecurityView({super.key});

  static const orange = Color(0xFFFF5216);
  static const page = Color(0xFFFDF9F0);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PrivacySecurityView()),
    );
  }

  @override
  State<PrivacySecurityView> createState() => _PrivacySecurityViewState();
}

class _PrivacySecurityViewState extends State<PrivacySecurityView> {
  bool _isLoading = true;
  String _content = '';

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getSavedObject('token');
      if (token != null &&
          token.toString() != 'null' &&
          token.toString().isNotEmpty) {
        DioClient().updateToken(token);
      }

      debugPrint("==================== GET PRIVACY POLICY ====================");
      debugPrint("Endpoint: ${ApiEndPoints.getPrivacyPolicy}");

      final response = await DioClient().get(ApiEndPoints.getPrivacyPolicy);

      debugPrint("==================== GET PRIVACY POLICY RESPONSE ====================");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status']?.toString() == 'true')) {
        final data = response.data['data'];
        dynamic privacy =
            data is Map ? (data['privacy_policy'] ?? data['privacy'] ?? data) : data;

        String resolved = '';
        if (privacy is Map) {
          final lang = LocalizationService.currentLanguageCode;
          if (lang == 'fr' && privacy['content_fr'] != null) {
            resolved = privacy['content_fr'].toString();
          } else if (lang == 'ar' && privacy['content_ar'] != null) {
            resolved = privacy['content_ar'].toString();
          } else {
            resolved = (privacy['content_en'] ??
                    privacy['content'] ??
                    privacy['description'] ??
                    '')
                .toString();
          }
        } else if (privacy is String) {
          resolved = privacy;
        }

        if (mounted) {
          setState(() {
            _content = resolved.trim();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching privacy policy: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isHtml(String text) {
    return text.contains('<p') ||
        text.contains('<div') ||
        text.contains('<br') ||
        text.contains('<span') ||
        text.contains('<h') ||
        text.contains('<ul');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: PrivacySecurityView.page,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 8),
            _Header(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: RefreshIndicator(
                color: PrivacySecurityView.orange,
                onRefresh: _fetchPrivacyPolicy,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: PrivacySecurityView.orange,
        ),
      );
    }

    if (_content.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Text(
                S.of(context).waterNoPrivacyPolicyAvailable,
                style: appFont('Inter', 
                  color: const Color(0xFF888888),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_isHtml(_content)) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Html(
            data: _content,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(13),
                fontFamily: appFontFamily('Inter'),
                lineHeight: const LineHeight(1.5),
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w400,
              ),
              "p": Style(
                margin: Margins.only(bottom: 16),
                padding: HtmlPaddings.zero,
                fontSize: FontSize(13),
                fontFamily: appFontFamily('Inter'),
                lineHeight: const LineHeight(1.5),
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w400,
              ),
            },
          ),
        ],
      );
    }

    final paragraphs = _content
        .split(RegExp(r'\r?\n\r?\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      paragraphs.add(_content);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        for (var i = 0; i < paragraphs.length; i++) ...[
          Text(
            paragraphs[i],
            style: appFont('Inter', 
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (i < paragraphs.length - 1) const SizedBox(height: 16),
        ],
      ],
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
              S.of(context).waterPrivacySecurity,
              style: appFont('Inter', 
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: PrivacySecurityView.orange,
                    size: 26,
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
