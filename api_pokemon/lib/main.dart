//main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pokemons {
  List<Dados>? dados;

  Pokemons({this.dados});

  Pokemons.fromJson(Map<String, dynamic> json) {
    if (json['dados'] != null) {
      dados = <Dados>[];
      json['dados'].forEach((v) {
        dados!.add(new Dados.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dados != null) {
      data['dados'] = this.dados!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dados {
  int? id;
  String? name;
  String? img;
  String? type;
  String? height;
  String? weight;
  List<String>? weaknesses;

  Dados({
    this.id,
    this.name,
    this.img,
    this.type,
    this.height,
    this.weight,
    this.weaknesses,
  });

  Dados.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    img = json['img'];
    type = json['type'][0];
    height = json['height'];
    weight = json['weight'];
    weaknesses = json['weaknesses'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['img'] = this.img;
    data['type'] = this.type;
    data['height'] = this.height;
    data['weight'] = this.weight;
    data['weaknesses'] = this.weaknesses;
    return data;
  }
}

Future<List<Dados>> dados() async {
  final List<dynamic> result = await fetchUsers();
  //print(result);
  List<Dados> pokemons;
  pokemons = (result).map((pokemon) => Dados.fromJson(pokemon)).toList();
  return pokemons;
}

const String url =
    "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json";

Future<List<dynamic>> fetchUsers() async {
  var result = await http.get(Uri.parse(url));
  return jsonDecode(result.body)['pokemon'];
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Lista de Pokemons';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // controller
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // campo de busca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pesquisar',
              ),
              controller: controller,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // construção da lista com base na pesquisa
          Expanded(
            child: FutureBuilder<List<Dados>>(
              future: dados(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<Dados> pokemons = snapshot.data!;
                  return PokemonsList(
                    pokemons: pokemons
                        .where((pokemon) => pokemon.name!
                            .toLowerCase()
                            .contains(controller.text.toLowerCase()))
                        .toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonsList extends StatelessWidget {
  const PokemonsList({Key? key, required this.pokemons}) : super(key: key);

  final List<Dados> pokemons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pokemons.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          padding: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              // link animado de navegação para página de detalhes com design chamativo
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 500),
                  transitionsBuilder:
                      (context, animation, animationTime, child) {
                    animation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticInOut,
                    );
                    return ScaleTransition(
                      alignment: Alignment.center,
                      scale: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, animationTime) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text("${pokemons[index].name}"),
                      ),
                      body: Container(
                        child: Column(
                          children: [
                            Image.network(
                              "${pokemons[index].img}",
                              height: 200.0,
                              width: 200.0,
                            ),
                            Text(
                              "Tipo: ${pokemons[index].type}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Altura: ${pokemons[index].height}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Peso: ${pokemons[index].weight}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Fraquezas: ${pokemons[index].weaknesses}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            child: ListTile(
              leading: Image.network(
                "${pokemons[index].img}",
                height: 48.0,
                width: 48.0,
              ),
              title: Text(
                "${pokemons[index].name}",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
