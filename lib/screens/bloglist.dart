import 'dart:convert';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:blogapp/models/Blog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class BlogListScreen extends StatefulWidget {
  BlogListScreen({
    super.key,
  });

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final _scrollController = ScrollController();
  String? newFocusedBlogId;
  List<Blog> blogList = [];
  List<GlobalKey> keys = [];

  Future<Map<String, dynamic>> getDataFromAPI() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://newsapi.org/v2/everything?q=india&from=2024-05-03&sortBy=publishedAt&apiKey=9fd3938bfe364652a96b4ca2b76a9831'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> data =
          await jsonDecode(await response.stream.bytesToString());
      data['isSuccess'] = true;
      return data;
    } else {
      return {'isSuccess': false, 'error': response.reasonPhrase};
    }
  }

  void _scrollToIndex(int index) {
    final position = index * 108.toDouble();
    _scrollController.animateTo(
      position,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  Future<List<Blog>> getBlogList() async {
    // get blogs from api
    Map<String, dynamic> data = await getDataFromAPI();
    List<Blog> blogList = [];

    if (data['isSuccess']) {
      // navigate to blog detail screen
      for (var blog in data['articles']) {
        if (blog['author'] == null) {
          blog['author'] = 'Unknown';
          log("Author is null");
        }
        if (blog['urlToImage'] == null) {
          blog['urlToImage'] =
              'https://previews.123rf.com/images/lirch/lirch1705/lirch170500227/78435669-floral-template-card-in-red-and-blue-tones-with-room-for-your-text.jpg';
          log("Image is null");
        }
        blogList.add(Blog(
          id: Uuid().v4(),
          title: blog['title'],
          summary: blog['description'],
          imageurl: blog['urlToImage'],
          source: blog['url'],
          author: blog['author'],
          date: DateTime.parse(blog['publishedAt']),
        ));
      }
    }

    return blogList;
  }

  Future<bool> postToFirebase() async {
    // post blogs to firebase
    bool isDone = false;
    List<Blog> blogList = await getBlogList();
    if (blogList.length > 0) {
      isDone = true;
    }
    log('Blog List: ${blogList.length}');
    for (Blog blog in blogList) {
      await FirebaseFirestore.instance
          .collection('blogs')
          .doc(blog.id)
          .set(blog.toJson())
          .whenComplete(() => log('Blog Added'))
          .catchError((error) => log('Failed to add blog: $error'));
    }
    return isDone;
  }

  Future<List<Blog>> getblogsFromFirebase() async {
    // get blogs from firebase
    List<Blog> blogList = [];
    await FirebaseFirestore.instance
        .collection('blogs')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        blogList.add(Blog.fromJson(doc.data() as Map<String, dynamic>));
      });
    });
    Uri? id = await AppLinks().getLatestLink();
    newFocusedBlogId = id?.queryParameters['id'];
    return blogList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   Uri? id = await AppLinks().getLatestLink();
    //   _focusedBlogId = id?.queryParameters['id'];
    //   log('Focused Blog Id: $_focusedBlogId');
    //   int index =
    //       blogList.indexWhere((element) => element.id == _focusedBlogId);
    //   _scrollToIndex(index);
    // });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Blog List'),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder(
          future: getblogsFromFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.requireData.length == 0) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    postToFirebase().then((value) {
                      if (value) {
                        setState(() {});
                      }
                    });
                  },
                  child: const Text('Fetch Blogs'),
                ),
              );
            }

            blogList = snapshot.requireData;
            for (int i = 0; i < blogList.length; i++) {
              keys.add(GlobalKey());
            }

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              log('Focused Blog Id: $newFocusedBlogId');

              int index = blogList
                  .indexWhere((element) => element.id == newFocusedBlogId);
              if (index != -1) {
                _scrollToIndex(index);
              }
            });
            return SingleChildScrollView(
              controller: _scrollController,
              child: ListView.builder(
                itemCount: snapshot.requireData.length,
                physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return BlogTile(
                    keys: keys[index],
                    focusedBlogId: newFocusedBlogId,
                    blog: snapshot.requireData[index],
                  );
                },
              ),
            );
          },
        ));
  }
}

class BlogTile extends StatefulWidget {
  BlogTile({
    required this.keys,
    required this.blog,
    this.focusedBlogId,
  });
  GlobalKey<State<StatefulWidget>> keys;
  String? focusedBlogId;
  Blog blog;

  @override
  State<BlogTile> createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> {
  double _opacity = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (widget.focusedBlogId == widget.blog.id) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _opacity = 0.0;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isFocused = widget.focusedBlogId == widget.blog.id;
    log('Building Blog Tile: ${widget.blog.id} :: ${widget.focusedBlogId}');
    return AnimatedContainer(
      height: 108,
      duration: const Duration(seconds: 1),
      color: isFocused ? Colors.blue.shade100.withOpacity(_opacity) : null,
      child: ListTile(
        key: widget.keys,

        autofocus: true,

        // autofocus: true,
        trailing: IconButton(
          icon: Text(
            'Read More',
            style: TextStyle(color: Colors.blue.shade800),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/blogs/details',
                arguments: widget.blog.id);
          },
        ),
        onLongPress: () {
          String baseurl = "https://www.test-blog-app.com/blogs?id=";
          // copy to clipboard
          Clipboard.setData(ClipboardData(text: baseurl + widget.blog.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Link copied to clipboard'),
              duration: const Duration(seconds: 1),
              action: SnackBarAction(
                label: 'ok',
                onPressed: () {},
              ),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: widget.blog.imageurl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return LinearProgressIndicator(
                minHeight: 100,
                color: Colors.blue.shade100,
              );
            },
            errorWidget: (context, url, error) {
              log('Error: $error in loading image ${widget.blog.id}');
              return const Icon(Icons.error);
            },
            errorListener: (value) {
              log('Error in loading image ${widget.blog.id}');
            },
          ),
        ),
        // leading: Image.network(
        //   snapshot.requireData[index].imageurl,
        //   width: 100,
        //   height: 100,
        //   fit: BoxFit.cover,
        // ),
        title: Text(widget.blog.title),
        subtitle: Text(widget.blog.author),
      ),
    );
  }
}
