import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Coda Meteo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 6, 36, 61)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'coda Meteo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String key = "villes";
  List<String> villes = [];
  var Villeschoisie;
  late Location location;
  late LocationData locationData;
  late Stream<LocationData> stream;
  @override
  void initState() async {
    super.initState();
    obtenir();
    location = Location();
    try {
      locationData = await location.getLocation();
      print(
          'Nouvelles position:${locationData.altitude} / ${locationData.longitude}');
    } catch (e) {
      print('NOus avons un erreur:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue,
          child: ListView.builder(
              itemCount: villes.length + 2,
              itemBuilder: ((context, i) {
                if (i == 0) {
                  return DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        texteavecstyle(
                          'Mes villes',
                        ),
                        ElevatedButton(
                          onPressed: ajoutville,
                          child: texteavecstyle("Ajouter une ville"),
                        )
                      ],
                    ),
                  );
                } else if (i == 1) {
                  return ListTile(
                    title: texteavecstyle('Ma ville actuel '),
                    onTap: () {
                      setState(() {
                        Villeschoisie = null;
                        Navigator.pop(context);
                      });
                    },
                  );
                } else {
                  String ville = villes[i - 2];
                  return ListTile(
                    trailing: IconButton(
                        onPressed: () => supprimer(ville),
                        icon: Icon(Icons.delete)),
                    title: texteavecstyle(ville),
                    onTap: () {
                      setState(() {
                        Villeschoisie = ville;
                        Navigator.pop(context);
                      });
                    },
                  );
                }
              })),
        ),
      ),
      body: Center(
        child: Text((Villeschoisie == null) ? "villes actuels" : Villeschoisie),
      ),
    );
  }

  Text texteavecstyle(
    String data,
  ) {
    return Text(
      data,
      textAlign: TextAlign.center,
      style: const TextStyle(
          color: Colors.black, fontStyle: FontStyle.normal, fontSize: 22.0),
    );
  }

  Future ajoutville() async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext buildContext) {
        return SimpleDialog(
          contentPadding: const EdgeInsetsDirectional.all(20.0),
          title: texteavecstyle("Ajouter une ville"),
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "ville:"),
              onSubmitted: (String str) {
                ajouter(str);
                Navigator.pop(buildContext);
              },
            )
          ],
        );
      },
    );
  }

  void obtenir() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? liste = await sharedPreferences.getStringList(key);
    if (liste != null) {
      setState(() {
        villes = liste;
      });
    }
  }

  void ajouter(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.add(str);
    await sharedPreferences.setStringList(key, villes);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
  }

  void supprimer(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.remove(str);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
  }
}
