import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_finder/data/cities.dart';
import 'package:place_finder/widgets/components/search_bar.dart';
import 'package:place_finder/widgets/pages/main_map.dart';

void main() async {
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
            options: const ParticleOptions(
                spawnMinSpeed: 10, spawnMaxSpeed: 12, baseColor: Colors.green)),
        vsync: this,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'City',
                  textScaleFactor: 2,
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Explorer',
                  textScaleFactor: 2,
                ),
              ],
            ),
            Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withAlpha(70),
                        blurRadius: 10,
                        spreadRadius: 15)
                  ],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: FancySearchField(
                          hint: "Explore world cities",
                          loader: _loadCities,
                          itemBuilder: (city) => ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(
                                    (city as Map<String, dynamic>)['city']!),
                                subtitle: Text(
                                    (city as Map<String, dynamic>)['country']!),
                              ),
                          onSelected: (obj) {
                            var city = obj as Map<String, dynamic>;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainMap(LatLng(
                                  city['lat']!,
                                  city['lng']!,
                                )),
                              ),
                            );
                          }),
                    ),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.search)),
                  ],
                )),
          ],
        )),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadCities(String search) async {
    return Cities.list
        .where((element) => element['city']!
            .toString()
            .toLowerCase()
            .startsWith(search.toLowerCase()))
        .toList();
  }
}
