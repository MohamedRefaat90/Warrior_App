import 'package:equatable/equatable.dart';

class SearchHistoryEntity extends Equatable {
  final String searchQuery;
  final DateTime timestamp;
  final int resultCount;
  final SearchType searchType;

  const SearchHistoryEntity({
    required this.searchQuery,
    required this.timestamp,
    required this.resultCount,
    required this.searchType,
  });

  @override
  List<Object?> get props => [searchQuery, timestamp, resultCount, searchType];
}

enum SearchType {
  barcode,
  text,
  category,
  brand,
}
