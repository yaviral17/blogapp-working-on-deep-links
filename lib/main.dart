import 'dart:convert';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:blogapp/firebase_options.dart';
import 'package:blogapp/models/Blog.dart';
import 'package:blogapp/routes.dart';
import 'package:blogapp/screens/bloglist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final _appLinks = AppLinks();

  _appLinks.stringLinkStream.listen((link) {
    if (link != null) {
      log('Link: $link');
      Uri uri = Uri.parse(link);
      if (uri.pathSegments.contains('blogs')) {
        log('id is --${uri.queryParametersAll}');
        log('id is -${uri.queryParameters}');
        log('id is ${uri.queryParameters['id']}');
        if (uri.queryParameters['id'] == null) {
          navigatorKey.currentState!.pushNamed('/blogs');
          log('id is null');
        } else {
          Navigator.of(navigatorKey.currentContext!).pushNamed('/blogs');
        }
        // navigatorKey.currentState!
        //     .pushNamed('/blogs', arguments: uri.queryParameters['id']);
      }
    }
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(App());
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoRouter Example',
      navigatorKey: navigatorKey,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: '/blogs',
      // home: const BlogListScreen(),
    );
  }
}
