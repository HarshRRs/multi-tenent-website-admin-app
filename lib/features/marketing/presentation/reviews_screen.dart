import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/marketing/presentation/marketing_provider.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(marketingProvider.notifier).loadReviews());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews Moderation'),
      ),
      body: state.isLoading && state.reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(marketingProvider.notifier).loadReviews(),
              child: state.reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No reviews submitted yet', style: AppTextStyles.labelLarge),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.reviews.length,
                      itemBuilder: (context, index) {
                        final review = state.reviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ...List.generate(5, (i) => Icon(
                                      i < review.rating ? Icons.star : Icons.star_border,
                                      size: 20,
                                      color: Colors.amber,
                                    )),
                                    const Spacer(),
                                    Text(
                                      DateFormat('MMM dd, HH:mm').format(review.createdAt),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review.customerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                if (review.productName != null)
                                  Text(
                                    'Product: ${review.productName}',
                                    style: TextStyle(fontSize: 12, color: AppColors.primaryLight),
                                  ),
                                const SizedBox(height: 8),
                                if (review.comment != null && review.comment!.isNotEmpty)
                                  Text('"${review.comment}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _confirmDelete(review.id),
                                    ),
                                    if (!review.isApproved)
                                      ElevatedButton.icon(
                                        onPressed: () => ref.read(marketingProvider.notifier).approveReview(review.id),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    if (review.isApproved)
                                      const Chip(
                                        label: Text('Approved'),
                                        backgroundColor: Colors.greenAccent,
                                        labelStyle: TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(marketingProvider.notifier).deleteReview(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
