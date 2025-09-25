import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:milma_group/const.dart';
import 'package:milma_group/shimmer/squircle_clipper.dart';
import 'package:provider/provider.dart';
import 'package:milma_group/screens/draw_sign.dart';
import 'package:milma_group/provider/commonviewmodel.dart';
import 'package:milma_group/model/insightmodel.dart';
import 'package:shimmer/shimmer.dart';

class SignatureListPage extends StatefulWidget {
  final int id;
  const SignatureListPage({Key? key, required this.id}) : super(key: key);

  @override
  State<SignatureListPage> createState() => _SignatureListPageState();
}

class _SignatureListPageState extends State<SignatureListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _timer;
  late Future<void> _insightsFuture;

  List<InsightModel> insightList = [];
  List<InsightModel> filteredInsights = [];

  @override
  void initState() {
    super.initState();

    final vm = Provider.of<CommonViewModel>(context, listen: false);
    _insightsFuture = vm.getinsights(widget.id).then((_) {
      setState(() {
        insightList = List.from(vm.insightlist);
        filteredInsights = List.from(insightList);
      });
    });

    _timer = Timer.periodic(refreshInterval, (timer) async {
      if (mounted) {
        final vm = Provider.of<CommonViewModel>(context, listen: false);
        _insightsFuture = vm.getinsights(widget.id);
        setState(() {
          insightList = List.from(vm.insightlist);
          _applySearch(_searchController.text);
        });
      }
    });

    _searchController.addListener(() {
      _applySearch(_searchController.text);
    });
  }

  void _applySearch(String query) {
    if (query.isEmpty) {
      filteredInsights = List.from(insightList);
    } else {
      final lowerQuery = query.toLowerCase();
      filteredInsights = insightList.where((e) {
        final name = (e.name ?? '').toLowerCase();
        final mobile = (e.mobile ?? '').toLowerCase();
        return name.contains(lowerQuery) || mobile.contains(lowerQuery);
      }).toList();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSignaturePressed(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignatureScreen(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommonViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text(
              "MEMBERS",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: primaryColor),
                onPressed: () async {
                  _insightsFuture = vm.getinsights(widget.id);
                  setState(() {
                    insightList = List.from(vm.insightlist);
                    _applySearch(_searchController.text);
                  });
                },
              ),
            ],
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
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
            child: Column(
              children: [
                ClipPath(
                  clipper: SquircleClipper(radius: 24),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 58,
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.transparent),
                      color: Colors.grey.shade100,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextFormField(
                        controller: _searchController,
                        cursorColor: const Color(0xFF062f21),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          hintText: "Search by name or mobile...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            letterSpacing: 0,
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
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applySearch('');
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
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: FutureBuilder(
                    future: _insightsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildShimmerList();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        );
                      } else {
                        if (filteredInsights.isEmpty) {
                          return const Center(
                            child: Text(
                              "No members found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            await vm.getinsights(widget.id);
                            setState(() {
                              insightList = List.from(vm.insightlist);
                              _applySearch(_searchController.text);
                            });
                          },
                          child: ListView.builder(
                            itemCount: filteredInsights.length,
                            itemBuilder: (context, index) {
                              final user = filteredInsights[index];
                              return InkWell(
                                onTap: () {
                                    _onSignaturePressed(user.name ?? "");
                                },
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    title: Text(
                                      user.name ?? "Unknown",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 3),
                                        Text("Mobile: ${user.mobile ?? 'N/A'}"),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Login Time : ${user.loginDate != null ? DateFormat("hh:mm a").format(DateTime.parse(user.loginDate.toString()).toLocal()) : "No Time"}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        _onSignaturePressed(user.name ?? "");
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/images/signature-stroke-rounded.svg',
                                      ),
                                    ),
                                  ),
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
      },
    );
  }

  Widget buildShimmerList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(height: 16, width: 120, color: Colors.white),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(height: 14, width: 100, color: Colors.white),
              ),
            ),
            trailing: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 35,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
