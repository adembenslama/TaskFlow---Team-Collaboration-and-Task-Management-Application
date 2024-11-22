import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/FeedController.dart';
import 'package:manager/model/post.dart';
import 'package:manager/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manager/views/feed/CommentSection.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final FeedController _feedController = Get.find<FeedController>();
  final AuthController _authController = Get.find<AuthController>();

  PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  void initState() {
    super.initState();
    // Cache the user data when the card is created
    widget._authController.cacheUserData(widget.post.createdBy);
  }

  Widget _buildUserAvatar(String userId) {
    final photoUrl = widget._authController.getUserPhotoSync(userId);
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(photoUrl),
        radius: 20,
      );
    }
    
    return CircleAvatar(
      backgroundColor: royalBlue,
      radius: 20,
      child: Text(
        widget._authController.getUserInitials(userId),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLiked = widget.post.likes.contains(widget._authController.userData.value.uid);
    final bool isCreator = widget.post.createdBy == widget._authController.userData.value.uid;

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
                _buildUserAvatar(widget.post.createdBy),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget._authController.getUserNameSync(widget.post.createdBy),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.post.isPinned)
                  const Icon(Icons.pin, color: royalBlue, size: 20),
                if (isCreator)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(
                            widget.post.isPinned ? Icons.pin_drop : Iconsax.programming_arrow,
                            size: 20,
                          ),
                          title: Text(widget.post.isPinned ? 'Unpin' : 'Pin'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () => widget._feedController.togglePin(widget.post.id),
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
            Text(widget.post.content),
            if (widget.post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (widget.post.images.length == 1)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.images.first,
                    fit: BoxFit.cover,
                  ),
                )
              else
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: widget.post.images
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
                  onPressed: () => widget._feedController.toggleLike(widget.post.id),
                  icon: Icon(
                    isLiked ? Iconsax.heart5 : Iconsax.heart,
                    color: isLiked ? Colors.red : null,
                  ),
                ),
                Text('${widget.post.likes.length}'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    Get.bottomSheet(
                      Container(
                        height: Get.height * 0.8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Comments',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Get.back(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: CommentSection(postId: widget.post.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.message),
                ),
                Text('${widget.post.commentCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}