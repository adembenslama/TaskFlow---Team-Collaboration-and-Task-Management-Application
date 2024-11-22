import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/FeedController.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:manager/model/comment.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final FeedController _feedController = Get.find();
  final AuthController _authController = Get.find();
  final TextEditingController _commentController = TextEditingController();
  Comment? replyingTo;

  Widget _buildUserAvatar(String userId) {
    final photoUrl = _authController.getUserPhotoSync(userId);
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(photoUrl),
        radius: 16,
      );
    }
    
    return CircleAvatar(
      backgroundColor: royalBlue,
      radius: 16,
      child: Text(
        _authController.getUserInitials(userId),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Pre-cache user data for existing comments
    _feedController.getComments(widget.postId).first.then((comments) {
      for (var comment in comments) {
        _authController.cacheUserData(comment.createdBy);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reply indicator
        if (replyingTo != null)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Row(
              children: [
                _buildUserAvatar(replyingTo!.createdBy),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Replying to ${_authController.getUserNameSync(replyingTo!.createdBy)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => replyingTo = null),
                ),
              ],
            ),
          ),

        // Comment input
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: replyingTo != null ? 'Write a reply...' : 'Write a comment...',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    _feedController.addComment(
                      widget.postId,
                      _commentController.text.trim(),
                      replyTo: replyingTo?.id,
                    );
                    _commentController.clear();
                    setState(() => replyingTo = null);
                  }
                },
              ),
            ],
          ),
        ),

        // Comments list
        StreamBuilder<List<Comment>>(
          stream: _feedController.getComments(widget.postId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data!;
            final topLevelComments = comments.where((c) => c.replyTo == null).toList();
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topLevelComments.length,
              itemBuilder: (context, index) {
                return _buildCommentThread(topLevelComments[index], comments);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentThread(Comment comment, List<Comment> allComments) {
    final replies = allComments.where((c) => c.replyTo == comment.id).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentTile(comment),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: replies.map((reply) => _buildCommentTile(reply)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment) {
    final isMyComment = comment.createdBy == _authController.userData.value.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildUserAvatar(comment.createdBy),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authController.getUserNameSync(comment.createdBy),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeago.format(comment.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(comment.content),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => replyingTo = comment),
                    child: const Text('Reply'),
                  ),
                  if (isMyComment)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => _feedController.deleteComment(
                        widget.postId,
                        comment.id,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 