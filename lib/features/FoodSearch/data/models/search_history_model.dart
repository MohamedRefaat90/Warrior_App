import 'package:hive/hive.dart';

part 'search_history_model.g.dart';

/// Model for search history
/// Tracks user searches for quick access
@HiveType(typeId: 12)
class SearchHistoryModel extends HiveObject {
  @HiveField(0)
  final String searchQuery;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final int resultCount;

  @HiveField(3)
  final SearchType searchType;

  SearchHistoryModel({
    required this.searchQuery,
    required this.timestamp,
    required this.resultCount,
    required this.searchType,
  });

  factory SearchHistoryModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryModel(
      searchQuery: map['search_query'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      resultCount: map['result_count'] as int,
      searchType: SearchType.values.firstWhere(
        (e) => e.toString() == 'SearchType.${map['search_type']}',
        orElse: () => SearchType.text,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'search_query': searchQuery,
      'timestamp': timestamp.toIso8601String(),
      'result_count': resultCount,
      'search_type': searchType.name,
    };
  }

  SearchHistoryModel copyWith({
    String? searchQuery,
    DateTime? timestamp,
    int? resultCount,
    SearchType? searchType,
  }) {
    return SearchHistoryModel(
      searchQuery: searchQuery ?? this.searchQuery,
      timestamp: timestamp ?? this.timestamp,
      resultCount: resultCount ?? this.resultCount,
      searchType: searchType ?? this.searchType,
    );
  }
}

@HiveType(typeId: 13)
enum SearchType {
  @HiveField(0)
  barcode,

  @HiveField(1)
  text,

  @HiveField(2)
  category,

  @HiveField(3)
  brand,
}

