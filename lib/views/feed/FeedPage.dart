import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/FeedController.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/feed/CreatePostPage.dart';
import 'package:manager/views/feed/PostCard.dart';


class FeedPage extends StatelessWidget {
  final FeedController _feedController = Get.find<FeedController>();
  
  final WorkSpaceController _workspaceController = Get.find<WorkSpaceController>();

  FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        title: Text('Feed'),
        centerTitle: true,
        backgroundColor: backColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (_workspaceController.selectedWorkSpace.value.uid.isEmpty) {
                Get.snackbar('Error', 'Please select a workspace first');
                return;
              }
              Get.to(() => CreatePostPage());
            },
            icon: const Icon(Iconsax.add_circle, color: royalBlue),
          )
        ],
      ),
      body: Obx(() {
        if (_workspaceController.selectedWorkSpace.value.uid.isEmpty) {
          return const Center(
            child: Text('Please select a workspace to view posts'),
          );
        }

        if (_feedController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_feedController.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.document, size: 64, color: royalGray),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    color: royalGray,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.to(() => CreatePostPage()),
                  child: const Text('Create First Post'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _feedController.fetchPosts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _feedController.posts.length,
            itemBuilder: (context, index) {
              final post = _feedController.posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PostCard(post: post),
              );
            },
          ),
        );
      }),
    );
  }
}