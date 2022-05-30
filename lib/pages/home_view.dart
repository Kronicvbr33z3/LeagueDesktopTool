import 'package:dart_lol/lol_api/summoner.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lol_api/dart_lol.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';

class HomeView {
  Widget homeView(BuildContext context) {
    //create list to store ranks
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/kaisa_corrupted_opt.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(.2), BlendMode.dstATop))),
      child: Center(child: Text("Enter Champion Select", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),),
    );
  }
}
