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

class _ComparisonDetailScreenState
    extends ConsumerState<ComparisonDetailScreen> {
  ApiService apiService = ApiService();
  Map<String, dynamic>? comparison;
  bool isLoading = true;
  String? errorMessage;
  String? selectedSortAttribute;

  @override
  void initState() {
    super.initState();
    fetchComparisonDetails();
  }

  void fetchComparisonDetails({String? sortBy}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      Response response = sortBy == null
          ? await apiService.getComparisonDetails(widget.comparisonId)
          : await apiService.getSortedComparisonDetails(
              widget.comparisonId, sortBy);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comparison Details")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: selectedSortAttribute,
                        hint: Text("Sort by Attribute"),
                        items: comparison!["products"][0]["product_metadata"]
                            .map<DropdownMenuItem<String>>((attribute) {
                          return DropdownMenuItem<String>(
                            value: attribute["attribute"],
                            child: Text(attribute["attribute"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSortAttribute = value;
                            fetchComparisonDetails(sortBy: value);
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.blueGrey[100]!),
                          dataRowHeight: 60,
                          columns: [
                            DataColumn(
                                label: Text("Attribute",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            for (var product in comparison!["products"])
                              DataColumn(
                                  label: Text(product["name"],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                          ],
                          rows: [
                            for (var attribute in comparison!["products"][0]
                                ["product_metadata"])
                              DataRow(
                                cells: [
                                  DataCell(Text(attribute["attribute"],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600))),
                                  for (var product in comparison!["products"])
                                    DataCell(Text(
                                      product["product_metadata"]
                                          .firstWhere(
                                            (meta) =>
                                                meta["attribute"] ==
                                                attribute["attribute"],
                                            orElse: () => {"value": "N/A"},
                                          )["value"]
                                          .toString(),
                                    )),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
