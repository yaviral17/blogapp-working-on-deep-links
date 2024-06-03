import 'dart:developer';

import 'package:blogapp/main.dart';
import 'package:blogapp/screens/bloglist.dart';
import 'package:blogapp/screens/blogscreen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/blogs':
        {
          return MaterialPageRoute(builder: (_) => BlogListScreen());
        }

      case '/blogs/details':
        {
          return MaterialPageRoute(builder: (_) {
            final String blogId = settings.arguments as String;
            return BlogDetailScreen(blogId: blogId);
          });
        }

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
        body: Center(
          child: Text(
            'Page does not exist',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
      );
    });
  }
}

class FromDeep extends StatefulWidget {
  FromDeep({
    super.key,
    required this.screen,
    required this.id,
    required this.fetchFunction,
  });
  Widget screen;
  String id;
  Future<dynamic> fetchFunction;

  @override
  State<FromDeep> createState() => _FromDeepState();
}

class _FromDeepState extends State<FromDeep> {
  dynamic data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.fetchFunction.then((value) {
      setState(() {
        data = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : widget.screen;
  }
}
