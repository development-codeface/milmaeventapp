import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:milma_group/const.dart';
import 'package:milma_group/model/eventmodel.dart';
import 'package:milma_group/screens/QRDetailsPage.dart';
import 'package:milma_group/screens/allocation_list.dart';
import 'package:milma_group/screens/livetrack.dart';
import 'package:milma_group/screens/login_page.dart';
import 'package:milma_group/screens/openscanner.dart';
import 'package:milma_group/screens/scanner_page.dart';
import 'package:milma_group/session/shared_preferences.dart';
import 'package:milma_group/shimmer/squircle_clipper.dart';
import 'package:provider/provider.dart';
import '../../provider/commonviewmodel.dart';
import '../shimmer/serviceshimmer.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late Future<void> _eventsFuture;

  List<EventModel> eventlist = [];
  List<EventModel> filteredEvents = [];

  String scannedResult = "";

  Future<void> _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );

    if (result != null && mounted) {
      final scannedResult = result.toString();
      log("scanned result----$scannedResult");

      // Extract last part after last slash
      final qrCode = scannedResult.split("/").last;

      // Navigate to QR Details Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QRDetailsPage(qrCode: qrCode)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CommonViewModel>(context, listen: false);

    // load events first
    _eventsFuture = vm.getallevents().then((_) {
      setState(() {
        eventlist = List.from(vm.eventlist);
        filteredEvents = List.from(vm.eventlist);
      });

      // attach search listener after loading
      _searchController.addListener(_onSearchChanged);
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchEvents(_searchController.text.trim());
    });
  }

  void searchEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEvents = List.from(eventlist);
      } else {
        filteredEvents = eventlist
            .where(
              (e) =>
                  (e.title ?? '').toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "MILMA EVENTS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 5),
              child: SvgPicture.asset('assets/images/export.svg'),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Store.clear();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 58,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.transparent),
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18), // 👈 curve corners
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextFormField(
                  controller: _searchController,
                  cursorColor: const Color(0xFF062f21),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    hintText: "Search events...",

                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      letterSpacing: 0,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: SvgPicture.asset(
                        'assets/images/search-status.svg',
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minHeight: 5,
                      minWidth: 5,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              searchEvents('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const DoctorShimmerPage();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  } else {
                    if (filteredEvents.isEmpty) {
                      return const Center(
                        child: Text(
                          "No events available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final vm = Provider.of<CommonViewModel>(
                          context,
                          listen: false,
                        );
                        final refreshFuture = vm.getallevents();
                        setState(() {
                          _eventsFuture = refreshFuture;
                        });
                        await refreshFuture;
                        setState(() {
                          eventlist = List.from(vm.eventlist);
                          filteredEvents = List.from(vm.eventlist);
                        });
                      },
                      child: ListView.builder(
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          return Card(
                            color: Color(0xFFdfebf5),
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 Section with padding
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Status : ",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            TextSpan(
                                              text: event.status ?? '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        event.title ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Start Date :  ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            TextSpan(
                                              text: event.startDate != null
                                                  ? DateFormat(
                                                      "d.MM.yyyy",
                                                    ).format(
                                                      DateTime.parse(
                                                        event.startDate
                                                            .toString(),
                                                      ),
                                                    )
                                                  : "No Date",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "End Date   :  ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            TextSpan(
                                              text: event.endDate != null
                                                  ? DateFormat(
                                                      "d.MM.yyyy",
                                                    ).format(
                                                      DateTime.parse(
                                                        event.endDate
                                                            .toString(),
                                                      ),
                                                    )
                                                  : "No Date",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                ),

                                // 🔹 Section WITHOUT padding
                                Container(
                                  height: 80,

                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF214bb8),

                                            // background color
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                20,
                                              ), // curve bottom left
                                              //  bottomRight: Radius.circular(20),  // curve bottom right
                                            ),
                                          ),
                                          //  color: Colors.blue.shade100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignatureListPage(
                                                            id: event.id ?? 0,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                icon: SvgPicture.asset(
                                                  color: Colors.white,
                                                  'assets/images/analytics-01-stroke-rounded.svg',
                                                ),
                                              ),
                                              const Text(
                                                "MEMBERS",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  letterSpacing: 0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Color(0xFFfe634e),
                                          //   color: Colors.green.shade100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: _openScanner,
                                                icon: SvgPicture.asset(
                                                  color: Colors.white,
                                                  'assets/images/qr-code-stroke-rounded.svg',
                                                ),
                                              ),
                                              const Text(
                                                "SCAN",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  letterSpacing: 0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          //color: Colors.orange.shade100,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF44adda),
                                            borderRadius: const BorderRadius.only(
                                              //   bottomLeft: Radius.circular(20),   // curve bottom left
                                              bottomRight: Radius.circular(
                                                20,
                                              ), // curve bottom right
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Livetrack(
                                                            eventid:
                                                                event.id ?? 0,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                icon: SvgPicture.asset(
                                                  color: Colors.white,
                                                  'assets/images/analysis-text-link-stroke-rounded.svg',
                                                ),
                                              ),
                                              const Text(
                                                "LIVE",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
