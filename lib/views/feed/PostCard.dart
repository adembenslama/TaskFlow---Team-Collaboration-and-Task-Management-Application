import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/FeedController.dart';
import 'package:manager/model/post.dart';
import 'package:manager/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final FeedController _feedController = Get.find<FeedController>();
  final AuthController _authController = Get.find<AuthController>();

  PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final bool isLiked = post.likes.contains(_authController.userData.value.uid);
    final bool isCreator = post.createdBy == _authController.userData.value.uid;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: royalBlue,
                  child: Text(
                    _authController.getUserInitials(post.createdBy),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authController.getUserName(post.createdBy),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.isPinned)
                  const Icon(Icons.pin, color: royalBlue, size: 20),
                if (isCreator)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(
                            post.isPinned ? Icons.pin_drop : Iconsax.programming_arrow,
                            size: 20,
                          ),
                          title: Text(post.isPinned ? 'Unpin' : 'Pin'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () => _feedController.togglePin(post.id),
                      ),
                      const PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Iconsax.trash, size: 20),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (post.images.length == 1)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: post.images.first,
                    fit: BoxFit.cover,
                  ),
                )
              else
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: post.images
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () => _feedController.toggleLike(post.id),
                  icon: Icon(
                    isLiked ? Iconsax.heart5 : Iconsax.heart,
                    color: isLiked ? Colors.red : null,
                  ),
                ),
                Text('${post.likes.length}'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    // Show comments
                  },
                  icon: const Icon(Iconsax.message),
                ),
                Text('${post.commentCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}