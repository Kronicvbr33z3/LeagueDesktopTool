import 'package:flutter/material.dart';

class ChampionSelectHelper {

  Widget champSelect() {


    return Container(
      color: Colors.blueGrey,
      alignment: Alignment.centerRight,
      width: 300,
      height: 280,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(6, 0, 6, 8),
                  child: ListTile(
                    title: Text("Hello World")
                  )
                );
              },
            )
          ),

        ],
      ),
    );

  }


}

/**
    DataTable(
    columns: const <DataColumn>[
    DataColumn(
    label: Text("Summoner")
    )
    ],
    rows: const <DataRow>[
    DataRow(
    cells:<DataCell>[
    DataCell(Text('Kronic')),
    ]
    )
    ],
    ),
    **/