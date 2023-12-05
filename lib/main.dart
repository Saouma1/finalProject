
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saints Athletics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Athletics> parseSaints = [];
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String url = selectedTabIndex == 0
        ? "https://csssaints.com/sports/mens-soccer/roster"
        : "https://csssaints.com/sports/womens-soccer/roster";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var data = document.querySelectorAll("li.sidearm-roster-player");
        List<Athletics> tempList = [];
        for (var element in data) {
          var imgUrl = element.querySelector("div.sidearm-roster-player-image img")?.attributes['data-src'] ?? '';
          if (imgUrl.isEmpty) {
            imgUrl = element.querySelector("div.sidearm-roster-player-image img")?.attributes['src'] ?? '';
          }
          String baseUrl = "https://dxbhsrqyrr690.cloudfront.net/sidearm.nextgen.sites/csssaints.com";
          String fullImgUrl = baseUrl + imgUrl;
          String encodedUrl = Uri.encodeComponent(fullImgUrl);
          String finalUrl = "https://images.sidearmdev.com/resize?url=" + encodedUrl + "&width=240&type=png&quality=100";
          String title = element.querySelector("h3 a")?.text ?? '';
          String number = element.querySelector(".sidearm-roster-player-jersey-number")?.text ?? '';
          tempList.add(Athletics(imgUrl: finalUrl, title: title, number: number));
        }
        setState(() {
          parseSaints = tempList;
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saints Athletics'),
      ),
      body: Saints(parseAthletics: parseSaints),
    );
  }
}

class Saints extends StatelessWidget {
  final List<Athletics> parseAthletics;

  Saints({required this.parseAthletics});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: parseAthletics.length,
      itemBuilder: (context, index) {
        return AthleticsItem(athletics: parseAthletics[index]);
      },
    );
  }
}

class AthleticsItem extends StatelessWidget {
  final Athletics athletics;

  AthleticsItem({required this.athletics});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Image.network(
            athletics.imgUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              athletics.title,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              athletics.number,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class Athletics {
  final String imgUrl;
  final String title;
  final String number;

  Athletics({required this.imgUrl, required this.title, required this.number});
}
