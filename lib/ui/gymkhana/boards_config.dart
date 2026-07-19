/// Central place for board display info — label + banner/card asset.
/// Add a new entry here whenever a new board is introduced; both the
/// Explore grid and every BoardPage banner read from this same list.
class BoardConfig {
  final String label; // e.g. "Cult", "Tech"
  final String board; // Firestore value, e.g. "cultural", "tech"
  final String assetPath; // local image asset

  const BoardConfig({
    required this.label,
    required this.board,
    required this.assetPath,
  });
}

// TODO: drop your images at these paths and register them in
// pubspec.yaml under flutter: assets:
const List<BoardConfig> boardConfigs = [
  BoardConfig(
    label: 'Cultural',
    board: 'cultural',
    assetPath: 'assets/images/cult.jpeg',
  ),
  BoardConfig(
    label: 'Tech',
    board: 'tech',
    assetPath: 'assets/images/tech.jpeg',
  ),
  BoardConfig(
    label: 'Sports',
    board: 'sports',
    assetPath: 'assets/images/sports.jpeg',
  ),
  BoardConfig(
    label: 'Academics',
    board: 'academic',
    assetPath: 'assets/images/academics.jpeg',
  ),
  BoardConfig(
    label: 'Hostels',
    board: 'hostels',
    assetPath: 'assets/images/hostel.jpg',
  ),
  BoardConfig(
    label: 'Workshops',
    board: 'workshops',
    assetPath: 'assets/images/ws.jpeg',
  ),
];

/// Looks up config for a board id, falling back to a generic entry
/// (capitalized label, no image) if a new board hasn't been added above yet.
BoardConfig boardConfigFor(String board) {
  return boardConfigs.firstWhere(
    (c) => c.board.toLowerCase() == board.toLowerCase(),
    orElse: () => BoardConfig(
      label: board.isEmpty
          ? 'Board'
          : '${board[0].toUpperCase()}${board.substring(1)}',
      board: board,
      assetPath: '',
    ),
  );
}
