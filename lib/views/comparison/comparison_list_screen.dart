import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/providers/comparison_provider.dart';
import 'comparison_detail_screen.dart'; // Import the details screen

class ComparisonListScreen extends ConsumerWidget {
  const ComparisonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsyncValue = ref.watch(comparisonProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Comparisons")),
      body: comparisonAsyncValue.when(
        data: (comparisons) => ListView.builder(
          itemCount: comparisons.length,
          itemBuilder: (context, index) {
            final comparison = comparisons[index];
            return ListTile(
              title: Text(comparison["title"]),
              subtitle: Text(comparison["description"]),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComparisonDetailScreen(
                      comparisonId: comparison["id"], // Ensure "id" exists in API response
                    ),
                  ),
                );
              },
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text("Failed to load comparisons")),
      ),
    );
  }
}
