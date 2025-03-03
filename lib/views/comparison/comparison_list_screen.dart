import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/providers/comparison_provider.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'comparison_detail_screen.dart'; // Import the details screen

class ComparisonListScreen extends ConsumerWidget {
  const ComparisonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsyncValue = ref.watch(comparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Comparisons"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: comparisonAsyncValue.when(
        data: (comparisons) => ListView.builder(
          itemCount: comparisons.length,
          itemBuilder: (context, index) {
            final comparison = comparisons[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  comparison["title"],
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                subtitle: Text(comparison["description"]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Delete Comparison"),
                            content: Text("Are you sure you want to delete this comparison?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await ApiService().deleteComparison(comparison["id"] as int);
                          ref.refresh(comparisonProvider);
                        }
                      },
                    ),
                    Icon(Icons.arrow_forward, color: Colors.blue),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComparisonDetailScreen(
                        comparisonId: comparison["id"],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Failed to load comparisons")),
      ),
    );
  }
}
