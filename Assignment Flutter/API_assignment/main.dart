import 'package:flutter/material.dart';
import 'package:tops/capstone-session_1/capstone_session_1.dart';
import 'package:tops/capstone-session_2/capstone_session_2.dart';
import 'package:tops/session_3/session_3_file.dart';
import 'package:tops/session_4/session_4.dart';
import 'package:tops/session_5/session_5.dart';
import 'package:tops/session_6/session_6.dart';
import 'package:tops/session_7/session_7.dart';

import 'session_2/fetch_movies.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,

        home:TrendingMoviesScreen3()
    );
  }
}