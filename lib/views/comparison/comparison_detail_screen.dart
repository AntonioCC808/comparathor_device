import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';

class ComparisonDetailScreen extends ConsumerStatefulWidget {
  final int comparisonId;

  const ComparisonDetailScreen({super.key, required this.comparisonId});

  @override
  _ComparisonDetailScreenState createState() => _ComparisonDetailScreenState();
}

class _ComparisonDetailScreenState extends ConsumerState<ComparisonDetailScreen> {
  ApiService apiService = ApiService();
  Map<String, dynamic>? comparison;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchComparisonDetails();
  }

  void fetchComparisonDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      Response response = await apiService.getComparisonDetails(widget.comparisonId);
      setState(() {
        comparison = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load comparison details";
        isLoading = false;
      });
    }
  }

  Widget buildStars(double score) {
    int fullStars = score.floor();
    bool hasHalfStar = (score - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          Icon(Icons.star, color: Colors.amber, size: 22),
        if (hasHalfStar) Icon(Icons.star_half, color: Colors.amber, size: 22),
        for (int i = fullStars + (hasHalfStar ? 1 : 0); i < 5; i++)
          Icon(Icons.star_border, color: Colors.amber, size: 22),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (comparison == null || comparison!['products'] == null || comparison!['products'].isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Comparison Details"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text("No comparison data available")),
      );
    }

    var bestProduct = comparison!['products'].reduce((a, b) => (a['product']['score'] as double) > (b['product']['score'] as double) ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text("Comparison Details"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Best Choice", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.green[50],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    bestProduct['product']['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
                  ),
                  Text("Price: \$${bestProduct['product']['price'].toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  buildStars(bestProduct['product']['score'] as double),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text("Product Comparison", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blue[100]! ),
                  columns: [
                    DataColumn(label: Text("Attribute", style: TextStyle(fontWeight: FontWeight.bold))),
                    for (var product in comparison!['products'])
                      DataColumn(label: Text(product['product']['name'], style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    for (var attribute in comparison!['products'][0]['product']['product_metadata'])
                      DataRow(
                        cells: [
                          DataCell(Text(attribute['attribute'], style: TextStyle(fontWeight: FontWeight.w600))),
                          for (var product in comparison!['products'])
                            DataCell(Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product['product']['product_metadata']
                                      .firstWhere(
                                        (meta) => meta['attribute'] == attribute['attribute'],
                                    orElse: () => {'value': 'N/A'},
                                  )['value']
                                      .toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                buildStars(
                                  product['product']['product_metadata']
                                      .firstWhere(
                                        (meta) => meta['attribute'] == attribute['attribute'],
                                    orElse: () => {'score': 0.0},
                                  )['score'] as double,
                                ),
                              ],
                            )),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
