import 'package:flutter/material.dart';

class HomeErrorWidget extends StatelessWidget {
  const HomeErrorWidget({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Something went wrong, check your internet connection and try again.',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ]),
      ),
    );
  }
}
