import 'package:flutter/material.dart';
import 'package:milma_group/screens/allocation_list.dart';
import 'package:milma_group/screens/livetrack.dart';
import 'package:milma_group/screens/openscanner.dart';
import 'package:milma_group/screens/scanner_page.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home page",),automaticallyImplyLeading: false,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(
                height: 55,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color.fromARGB(255, 2, 56, 100),
                    ),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       return SignatureListPage();
                    //     },
                    //   ),
                    // );
                  },
                  child: Text("View Partcipants",  style: TextStyle(fontSize: 14, color: Colors.white),),
                ),
              ),
              SizedBox(height: 20),
          
               SizedBox(
              height: 55,
              width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color.fromARGB(255, 2, 56, 100),
                    ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Openscanner();
                        },
                      ),
                    );
                  },
                  child: Text("Scan" , style: TextStyle(fontSize: 14, color: Colors.white),),
                ),
              ),


                 SizedBox(height: 20),
          
               SizedBox(
              height: 55,
              width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color.fromARGB(255, 2, 56, 100),
                    ),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       return Livetrack();
                    //     },
                    //   ),
                    // );
                  },
                  child: Text("Live track" , style: TextStyle(fontSize: 14, color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
