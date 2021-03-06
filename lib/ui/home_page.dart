import 'dart:convert';

import 'package:buscador_de_gifs/api_keys.dart';
import 'package:buscador_de_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null)
      response = await http.get(getDatas);
    else
      response = await http.get(searchGif(_search, _offset));

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  if (text.isEmpty) {
                    _search = null;
                    _offset = 0;
                  } else {
                    _search = text;
                    _offset = 0;
                  }
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: buildWidget,
            ),
          )
        ],
      ),
    );
  }

  Widget buildWidget(context, snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:

      case ConnectionState.waiting:
        return Container(
          width: 200.0,
          height: 200.0,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5.0,
          ),
        );
        break;
      case ConnectionState.active:
        break;
      case ConnectionState.done:
        if (snapshot.hasError)
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.not_interested,
                size: 100.0,
                color: Colors.white,
              ),
              Text(
                "Não foi possível carregar os Gifs",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              )
            ],
          );
        else
          return _createGifTable(context, snapshot);
        break;
    }
  }

  int _getCount(List data) {
    if (_search == null)
      return data.length;
    else
      return data.length + 1;
  }

  Widget _createGifTable(context, snapshot) {
    return GridView.builder(

        /// Grade, muito semelhante ao Row ou Column
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

          /// Quantidade de itens na horizontal
          crossAxisSpacing: 10.0,

          /// Espaçamentos entre os itens na horizontal
          mainAxisSpacing: 10.0,

          /// Espaçamento entre os itens na vertical
        ),
        itemCount: _getCount(snapshot.data["data"]),

        /// Quantidade de itens no GridView

        /// A cada novo item é executado essa função
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]
                    ["fixed_height_small"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height_small"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }
}
