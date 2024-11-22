import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/post.dart';
import '../model/comment.dart';
import 'AuthController.dart';
import 'WorkspaceController.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../model/notification.dart';

class FeedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = Get.find<AuthController>();
  final WorkSpaceController _workspaceController = Get.find<WorkSpaceController>();

  RxList<Post> posts = <Post>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_workspaceController.selectedWorkSpace, (workspace) {
      if (workspace.uid.isNotEmpty) {
        fetchPosts();
      }
    });
    
    // Initial fetch if workspace is already selected
    if (_workspaceController.selectedWorkSpace.value.uid.isNotEmpty) {
      fetchPosts();
    }
  }

  Future<void> fetchPosts() async {
    try {
      isLoading(true);
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      if (workspaceId.isEmpty) {
        posts.clear();
        return;
      }

      final snapshots = await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      posts.value = snapshots.docs.map((doc) => Post.fromJson(doc)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch posts');
    } finally {
      isLoading(false);
    }
  }

  Future<void> createPost(String content, List<XFile> images, {String? taskId}) async {
    try {
      isLoading(true);
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      final List<String> imageUrls = [];

      // Upload images
      for (var image in images) {
        final ref = _storage.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Create post
      final postRef = _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .doc();

      final post = Post(
        id: postRef.id,
        content: content,
        workspaceId: workspaceId,
        createdBy: _authController.userData.value.uid,
        createdAt: DateTime.now(),
        images: imageUrls,
        linkedTaskId: taskId,
      );

      await postRef.set(post.toJson());
      await fetchPosts();
      Get.back();
      Get.snackbar('Success', 'Post created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post');
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      final userId = _authController.userData.value.uid;
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      final postRef = _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .doc(postId);

      final post = posts.firstWhere((p) => p.id == postId);
      if (post.likes.contains(userId)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
      await fetchPosts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update like');
    }
  }
// Add to FeedController class
  Future<void> addComment(String postId, String content, {String? replyTo}) async {
    try {
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      // Create comment
      final commentRef = _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc();

      final comment = Comment(
        id: commentRef.id,
        content: content,
        createdBy: _authController.userData.value.uid,
        createdAt: DateTime.now(),
        replyTo: replyTo,
      );

      await commentRef.set(comment.toJson());

      // Update comment count in post
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .doc(postId)
          .update({
        'commentCount': FieldValue.increment(1)
      });

      Get.snackbar('Success', 'Comment added successfully');

      // Create notification for post owner
      final post = posts.firstWhere((p) => p.id == postId);
      if (replyTo == null) {
        // New comment notification
        await createNotification(
          type: 'comment',
          userId: post.createdBy,
          postId: postId,
          commentId: commentRef.id,
        );
      } else {
        // Reply notification
        final parentComment = (await _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(replyTo)
            .get()).data();
            
        if (parentComment != null) {
          await createNotification(
            type: 'reply',
            userId: parentComment['createdBy'],
            postId: postId,
            commentId: commentRef.id,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment');
    }
  }

  Stream<List<Comment>> getComments(String postId) {
    final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
    
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Comment.fromJson(doc)).toList());
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Update comment count
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .doc(postId)
          .update({
        'commentCount': FieldValue.increment(-1)
      });

      Get.snackbar('Success', 'Comment deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete comment');
    }
  }
  Future<void> togglePin(String postId) async {
    try {
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      final post = posts.firstWhere((p) => p.id == postId);
      
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('posts')
          .doc(postId)
          .update({'isPinned': !post.isPinned});
      
      await fetchPosts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to pin/unpin post');
    }
  }

  Future<void> createNotification({
    required String type,
    required String userId,
    required String postId,
    String? commentId,
  }) async {
    try {
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      // Don't create notification if user is triggering it for themselves
      if (userId == _authController.userData.value.uid) return;

      final notificationRef = _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('notifications')
          .doc();

      final notification = AppNotification(
        id: notificationRef.id,
        type: type,
        userId: userId,
        triggeredBy: _authController.userData.value.uid,
        postId: postId,
        commentId: commentId,
        createdAt: DateTime.now(),
      );

      await notificationRef.set(notification.toJson());
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  Stream<List<AppNotification>> getNotifications() {
    final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
    final userId = _authController.userData.value.uid;
    
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => AppNotification.fromJson(doc)).toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}