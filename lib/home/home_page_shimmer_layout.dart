import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePageShimmerLayout extends StatelessWidget {
  const HomePageShimmerLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 8.0),
            itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey[300] ?? Colors.grey,
                highlightColor: Colors.grey[100] ?? Colors.grey,
                enabled: true,
                child: Chip(
                  label: Container(
                    height: 16,
                    width: 48,
                    color: Colors.white,
                  ),
                )),
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            separatorBuilder: (context, index) => Divider(
              color: Colors.black.withAlpha(25),
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Container(height: 20, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 20, color: Colors.white)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
