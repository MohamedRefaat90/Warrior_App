import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart'
    as entity;
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

  entity.SearchHistoryEntity toEntity() {
    return entity.SearchHistoryEntity(
      searchQuery: searchQuery,
      timestamp: timestamp,
      resultCount: resultCount,
      searchType: _mapSearchTypeToEntity(searchType),
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

  entity.SearchType _mapSearchTypeToEntity(SearchType type) {
    switch (type) {
      case SearchType.barcode:
        return entity.SearchType.barcode;
      case SearchType.text:
        return entity.SearchType.text;
      case SearchType.category:
        return entity.SearchType.category;
      case SearchType.brand:
        return entity.SearchType.brand;
    }
  }

  static SearchHistoryModel fromEntity(entity.SearchHistoryEntity entityModel) {
    return SearchHistoryModel(
      searchQuery: entityModel.searchQuery,
      timestamp: entityModel.timestamp,
      resultCount: entityModel.resultCount,
      searchType: _mapSearchTypeFromEntity(entityModel.searchType),
    );
  }

  static SearchType _mapSearchTypeFromEntity(entity.SearchType type) {
    switch (type) {
      case entity.SearchType.barcode:
        return SearchType.barcode;
      case entity.SearchType.text:
        return SearchType.text;
      case entity.SearchType.category:
        return SearchType.category;
      case entity.SearchType.brand:
        return SearchType.brand;
    }
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
