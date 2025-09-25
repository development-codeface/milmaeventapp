import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DoctorShimmerPage extends StatelessWidget {
  const DoctorShimmerPage({super.key});

  Widget _buildShimmerCard(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column -> Profile Image + Ratings + Distance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating shimmer
                      Row(
                        children: [
                          Icon(Icons.star, size: 25, color: Colors.grey.shade300),
                          const SizedBox(width: 4),
                          Container(
                            width: 20,
                            height: 10,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Distance shimmer
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 18, color: Colors.grey.shade300),
                          const SizedBox(width: 4),
                          Container(
                            width: 40,
                            height: 10,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // Right Column -> Text Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Name
                    Container(
                      height: 15,
                      width: 140,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),

                    // Specialist
                    Container(
                      height: 12,
                      width: 100,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),

                    // Opening Time Label
                    Container(
                      height: 12,
                      width: 120,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 5),

                    // Opening Time Value
                    Container(
                      height: 12,
                      width: 100,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),

            // Right Location Icon
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.location_on_rounded,
                  color: Colors.grey.shade300, size: 25),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: _buildShimmerCard(context),
        );
      },
    );
  }





}
