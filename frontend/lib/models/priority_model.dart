enum PriorityLevel {
  none,
  low,
  medium,
  high,
  critical,
}

enum SortOption {
  newest,
  oldest,
  alphabetical,
  priority,
}

class DocumentPriority {
  final PriorityLevel level;
  final bool isLoved;
  final int? customRank; // For manual ranking within priority levels
  final DateTime? setPriorityDate;

  DocumentPriority({
    this.level = PriorityLevel.none,
    this.isLoved = false,
    this.customRank,
    this.setPriorityDate,
  });

  DocumentPriority copyWith({
    PriorityLevel? level,
    bool? isLoved,
    int? customRank,
    DateTime? setPriorityDate,
  }) {
    return DocumentPriority(
      level: level ?? this.level,
      isLoved: isLoved ?? this.isLoved,
      customRank: customRank ?? this.customRank,
      setPriorityDate: setPriorityDate ?? this.setPriorityDate,
    );
  }

  // Calculate overall priority score for sorting
  int get priorityScore {
    int score = 0;
    
    // Base score from priority level
    switch (level) {
      case PriorityLevel.none:
        score += 0;
        break;
      case PriorityLevel.low:
        score += 100;
        break;
      case PriorityLevel.medium:
        score += 200;
        break;
      case PriorityLevel.high:
        score += 300;
        break;
      case PriorityLevel.critical:
        score += 400;
        break;
    }
    
    // Bonus for loved documents
    if (isLoved) {
      score += 50;
    }
    
    // Custom rank adjustment (lower rank = higher priority)
    if (customRank != null) {
      score += (1000 - customRank!);
    }
    
    return score;
  }

  bool get hasPriority => level != PriorityLevel.none || isLoved;
}

extension PriorityLevelExtension on PriorityLevel {
  String get displayName {
    switch (this) {
      case PriorityLevel.none:
        return 'None';
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.critical:
        return 'Critical';
    }
  }

  String get icon {
    switch (this) {
      case PriorityLevel.none:
        return '⚪';
      case PriorityLevel.low:
        return '🟢';
      case PriorityLevel.medium:
        return '🟡';
      case PriorityLevel.high:
        return '🟠';
      case PriorityLevel.critical:
        return '🔴';
    }
  }
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.alphabetical:
        return 'Alphabetical';
      case SortOption.priority:
        return 'Priority & Loved';
    }
  }

  String get icon {
    switch (this) {
      case SortOption.newest:
        return '🆕';
      case SortOption.oldest:
        return '📅';
      case SortOption.alphabetical:
        return '🔤';
      case SortOption.priority:
        return '⭐';
    }
  }
}