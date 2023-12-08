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

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Athletics> menSoccer = [];
  List<Athletics> womenSoccer = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData(0); // Fetch data for the first tab initially
    fetchData(1);
  }

  Future<void> fetchData(int tabIndex) async {
    String url = tabIndex == 0
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
          if (tabIndex == 0) {
            menSoccer = tempList;
          } else {
            womenSoccer = tempList;
          }
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
        title: const Text('Saints Athletics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Men\'s Soccer'),
            Tab(text: 'Women\'s Soccer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Saints(parseAthletics: menSoccer),
          Saints(parseAthletics: womenSoccer),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            height: 100, // Adjust height as needed
            fit: BoxFit.scaleDown,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0), // Removed bottom padding
            child: Text(
              athletics.title,
              style: const TextStyle(fontSize: 18, color: Colors.black), // Style as needed
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
