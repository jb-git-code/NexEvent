import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexevent/ui/gymkhana/boards.dart';
import 'package:nexevent/ui/gymkhana/boards_config.dart';

/// ---------------------------------------------------------------------
/// Explore page — page CONTENT only (no Scaffold/bottom nav, since your
/// app already has a shared nav shell around it).
///
/// Grid cards come from `boardConfigs` (board_config.dart) — add a new
/// entry there whenever a new board is introduced; nothing here needs
/// to change.
/// ---------------------------------------------------------------------

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Explore',
              style: GoogleFonts.storyScript(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover Your Campus',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          _SearchBar(controller: _searchController),
          const SizedBox(height: 28),

          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: boardConfigs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, i) => _BoardGridCard(card: boardConfigs[i]),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search clubs, events, users...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFF14202E), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFF14202E), width: 1.5),
        ),
      ),
      // TODO: wire this up to real search once you decide where results
      // should go (its own results page? filters the grid below?).
    );
  }
}

class _BoardGridCard extends StatelessWidget {
  final BoardConfig card;
  const _BoardGridCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => BoardPage(board: card.board)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              card.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF14202E)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Text(
                card.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
