import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import '../../generated/l10n.dart';
import '../../utils/widgets/common_background.dart';
import '../../controller/profile_controller.dart';
import '../../model/rating_review_model.dart';
import '../../utils/widgets/app_loader.dart';
import '../../utils/widgets/no_data_widget.dart';

class RatingReviewsScreen extends StatefulWidget {
  const RatingReviewsScreen({super.key});

  @override
  State<RatingReviewsScreen> createState() => _RatingReviewsScreenState();
}

class _RatingReviewsScreenState extends State<RatingReviewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final profileController = Get.find<ProfileController>();
      if (!profileController.isLoadMoreRatingLoading &&
          profileController.hasMoreReviews) {
        profileController.getRatingsReviews(
          context,
          page: profileController.currentRatingPage + 1,
          isLoadMore: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          S.of(context).ratingReviews,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      child: GetBuilder<ProfileController>(
        builder: (profileController) {
          final reviews = profileController.ratingReviewData?.reviews ?? [];
          if (profileController.isRatingReviewLoading && reviews.isEmpty) {
            return const AppLoader();
          }
          if (reviews.isEmpty) {
            return NoDataWidget(
              context,
              S.of(context).noReviewsFound,
              "",
              "lib/assets/images/nodata.png",
              imgHeight: MediaQuery.of(context).size.height * 0.25,
              imgWidth: MediaQuery.of(context).size.width * 0.6,
              fontSize: 18,
            );
          }
          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount:
                reviews.length + (profileController.hasMoreReviews ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < reviews.length) {
                return _buildReviewTile(context, reviews[index]);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: AppLoader(size: 40)),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewTile(BuildContext context, ReviewItem review) {
    double ratingVal = double.tryParse(review.rating?.toString() ?? "0") ?? 0.0;
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDCFCE7),
                    child: Text(
                      (review.username?.isNotEmpty == true)
                          ? review.username![0].toUpperCase()
                          : "S",
                      style: GoogleFonts.rubik(
                        color: const Color(0xFF166534),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.username ?? S.of(context).anonymous,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < ratingVal.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFF59E0B),
                              size: 14,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          review.rating?.toString() ?? "0.0",
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatOrderPlacedAt(DateTime.parse(review.createdAt.toString())),
                style: GoogleFonts.rubik(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment ?? S.of(context).noCommentProvided,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: const Color(0xFF4B5563),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  S.of(context).orderColon,
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  review.orderCode ?? "-",
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
