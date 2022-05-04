import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:ui';
// import 'dart:html';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

Future<List<News>> fetchNews(http.Client client) async {
  final responce = await client.get(Uri.parse('https://kubsau.ru/api/getNews.php?key=6df2f5d38d4e16b5a923a6d4873e2ee295d0ac90'));
  return compute(parseNews, responce.body);
}

List<News> parseNews(String responceBody) {
  final parsed = jsonDecode(responceBody).cast<Map<String, dynamic>>();
  return parsed.map<News>((json) => News.fromJson(json)).toList();
}

//------------Начало класса Новость------------\\
class News{
  final String id;
  final String activeF;
  final String title;
  final String preview;
  final String previewP;
  final String detailU;
  final String detailT;
  final String modified;

  const News({
    required this.id,
    required this.activeF,
    required this.title,
    required this.preview,
    required this.previewP,
    required this.detailU,
    required this.detailT,
    required this.modified
  });

  factory News.fromJson(Map<String, dynamic> json){
    return News (
        id: json['ID'] as String,
        activeF: json['ACTIVE_FROM'] as String,
        title: json['TITLE'] as String,
        preview: json['PREVIEW_TEXT'] as String,
        previewP: json['PREVIEW_PICTURE_SRC'] as String,
        detailU: json['DETAIL_PAGE_URL'] as String,
        detailT: json['DETAIL_TEXT'] as String,
        modified: json['LAST_MODIFIED'] as String
    );
  }
}

//------------Конец класса Новость------------\\

class NewsList extends StatelessWidget{
  const NewsList({Key? key, required this.newsL}) : super(key: key);
  final List<News> newsL;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1, // устанавливает кол-во изображений в строке
    ),
      itemCount: newsL.length,
      itemBuilder: (context, index) {
        // return Image.network(newsL[index].previewP);
        return  Card(
          margin: const EdgeInsets.all(10),
          shadowColor: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
            Image.network(newsL[index].previewP),
            Container(child: Text(newsL[index].activeF, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic), textAlign: TextAlign.left,),
              margin: const EdgeInsets.fromLTRB(10, 10, 0, 0)),
              Container(child: Text(newsL[index].title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontStyle: FontStyle.normal), textAlign: TextAlign.left,),
                  margin: const EdgeInsets.fromLTRB(10, 10, 0, 0)),
              const Divider(
                color: Colors.black,
                height: 10,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              Container(child: Text(Bidi.stripHtmlIfNeeded(newsL[index].preview), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic), textAlign: TextAlign.left,),
                  margin: const EdgeInsets.fromLTRB(10, 5, 0, 0)),
            ],
          ),
        );
      },);
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Лента новостей КубГАУ';

    return MaterialApp(
      title: 'Лабораторная работа №7',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key:key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<News>>(
        future: fetchNews(http.Client()),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return const Text('Ошибка запроса');
          }
          else if (snapshot.hasData) {
            return NewsList(newsL: snapshot.data!);
            // return Text('HAve date');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}