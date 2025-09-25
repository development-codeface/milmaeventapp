import 'package:flutter/material.dart';
import 'package:milma_group/const.dart';

class TableScreen extends StatelessWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> participants = [
      {"name": "John Doe", "phone": "9876543210"},
      {"name": "Alice Smith", "phone": "9876543211"},
      {"name": "Bob Johnson", "phone": "9876543212"},
      {"name": "David Lee", "phone": "9876543213"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          "Participants List",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 17,
                weight: 5,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text("Table data", style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.blue.shade100,
                ),
                border: TableBorder.all(width: 1, color: Colors.grey.shade300),
                columns: const [
                  DataColumn(
                    label: Text(
                      "S.No",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Name",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Phone",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: List.generate(
                  participants.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(participants[index]["name"]!)),
                      DataCell(Text(participants[index]["phone"]!)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
