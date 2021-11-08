import 'package:flutter/material.dart';
import 'package:dart_lol/client_manager.dart';
import 'package:dart_lol/dart_lol.dart';

class HomeView{


  Widget homeView(ClientManager clientManager)
  {
    return Container(child: Column(
      children: [
        FutureBuilder<NetworkImage>(
          future: summonerIcon(5),
          builder: (context, snapshot) {
            if(snapshot.hasData)
              {
                return CircleAvatar(foregroundImage: snapshot.data);
              }
            return CircleAvatar();
          }
        )
      ],
    ));
  }
}

