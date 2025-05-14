import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/models/lost_item.dart';

class AdminDashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<LostItem>> getAllLostItems() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _db.collection('lostItems').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure document ID is present
        data['itemId'] = doc.id;

        // Conversion of date fields from Timestamp to String for fromJson
        // The fromJson factory will then parse the String back into DateTime
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        } else if (data['date'] is DateTime) {
           // If it's already a DateTime (less likely from Firestore directly)
           data['date'] = (data['date'] as DateTime).toIso8601String();
        } else if (data['date'] is! String) {
            // Handle unexpected types, perhaps defaulting or logging
             if (kDebugMode) {
                 print('Unexpected type for date in LostItem: ${data['date'].runtimeType}');
             }
             data['date'] = DateTime.now().toIso8601String(); // Provide a fallback
        }


        if (data['lostDate'] is Timestamp) {
          data['lostDate'] = (data['lostDate'] as Timestamp).toDate().toIso8601String();
        } else if (data['lostDate'] is DateTime) {
           data['lostDate'] = (data['lostDate'] as DateTime).toIso8601String();
        } else if (data['lostDate'] is! String) {
             if (kDebugMode) {
                 print('Unexpected type for lostDate in LostItem: ${data['lostDate'].runtimeType}');
             }
             data['lostDate'] = DateTime.now().toIso8601String(); // Fallback
        }


        // Ensure userId exists
        if (!data.containsKey('userId') || data['userId'] == null) {
          data['userId'] = 'unknown';
        }

        return LostItem.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching lost items: $e');
      }
      // Return an empty list in case of error
      return [];
    }
  }

  Future<List<FoundItem>> getAllFoundItems() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _db.collection('foundItems').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure document ID is present
        data['itemId'] = doc.id;

        // Conversion of date fields from Timestamp to String for fromJson
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        } else if (data['date'] is DateTime) {
          data['date'] = (data['date'] as DateTime).toIso8601String();
        } else if (data['date'] is! String) {
            if (kDebugMode) {
                print('Unexpected type for date in FoundItem: ${data['date'].runtimeType}');
            }
            data['date'] = DateTime.now().toIso8601String(); // Fallback
        }


        if (data['foundDate'] is Timestamp) {
          data['foundDate'] = (data['foundDate'] as Timestamp).toDate().toIso8601String();
        } else if (data['foundDate'] is DateTime) {
          data['foundDate'] = (data['foundDate'] as DateTime).toIso8601String();
        } else if (data['foundDate'] is! String) {
             if (kDebugMode) {
                print('Unexpected type for foundDate in FoundItem: ${data['foundDate'].runtimeType}');
            }
            data['foundDate'] = DateTime.now().toIso8601String(); // Fallback
        }


        // Ensure userId exists
        if (!data.containsKey('userId') || data['userId'] == null) {
          data['userId'] = 'unknown';
        }

        return FoundItem.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching found items: $e');
      }
      // Return an empty list in case of error
      return [];
    }
  }

  Future<Map<String, Map<String, int>>> getMonthlyItemsCount() async {
    try {
      final lostItems = await getAllLostItems();
      final foundItems = await getAllFoundItems();

      // Function to group items by month
      Map<String, int> groupByMonth(List<Item> items) {
        final Map<String, int> monthlyCount = {};

        for (final item in items) {
          // item.date is already a DateTime object because it was parsed in fromJson
          final DateTime dateTime = item.date; // Use the DateTime object directly

          final String monthYear = '${dateTime.month}-${dateTime.year}';

          // Increment the counter for this month
          monthlyCount.update(
            monthYear,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }

        return monthlyCount;
      }

      final lostByMonth = groupByMonth(lostItems);
      final foundByMonth = groupByMonth(foundItems);

      // Combine the two sets of months
      final allMonths = {...lostByMonth.keys, ...foundByMonth.keys};

      final result = <String, Map<String, int>>{};

      for (final month in allMonths) {
        result[month] = {
          'lost': lostByMonth[month] ?? 0,
          'found': foundByMonth[month] ?? 0,
        };
      }

      // Sort by year and month (descending order)
      final sortedEntries = result.entries.toList()
        ..sort((a, b) {
          try {
            final aParts = a.key.split('-');
            final bParts = b.key.split('-');

            if (aParts.length < 2 || bParts.length < 2) return 0;

            final aYear = int.tryParse(aParts[1]) ?? 0;
            final bYear = int.tryParse(bParts[1]) ?? 0;

            if (aYear != bYear) return bYear.compareTo(aYear);

            final aMonth = int.tryParse(aParts[0]) ?? 0;
            final bMonth = int.tryParse(bParts[0]) ?? 0;
            return bMonth.compareTo(aMonth);
          } catch (e) {
            // If sorting fails, maintain original order
            return 0;
          }
        });

      return Map.fromEntries(sortedEntries);
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating monthly items: $e');
      }
      // Return an empty map in case of error
      return {};
    }
  }
}