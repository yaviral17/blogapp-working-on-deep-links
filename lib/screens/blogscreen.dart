import 'dart:developer';

import 'package:blogapp/models/Blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogDetailScreen extends StatefulWidget {
  BlogDetailScreen({
    super.key,
    required this.blogId,
  });
  String blogId;

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Future<Blog> fetchBlogFromFirestore() async {
    log('Fetching blog from firestore ${widget.blogId}');
    Map<String, dynamic> data = await FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blogId)
        .get()
        .then((value) => value.data() as Map<String, dynamic>);
    Blog blog = Blog.fromJson(data);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(blog.source));
    return blog;
  }

  WebViewController controller = WebViewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Blog Detail'),
        ),
        body: FutureBuilder(
          future: fetchBlogFromFirestore(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Error fetching blog'),
              );
            }

            Blog blog = snapshot.data as Blog;
            return WebViewWidget(controller: controller);
          },
        ));
  }
}
