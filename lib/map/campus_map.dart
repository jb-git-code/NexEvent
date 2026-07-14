import 'package:flutter/material.dart';

/// NexEvent — Digital Campus Map
/// Schematic vector recreation of the campus layout board (main gate →
/// entrance road → circular hub → academic/residential blocks → river).
/// Buildings are PLACEHOLDERS (B1..B11 etc.) — just edit `campusBuildings`
/// below with your real names; nothing else needs to change.
class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

// ── EDIT THIS: swap in real building names ───────────────────────
// `pos` is a fraction (0.0–1.0) of the map canvas, matching each
// block's rough position on the physical board. Reposition freely.
final List<CampusBuilding> campusBuildings = [
  CampusBuilding('B1', 'Block B1', Offset(0.44, 0.40), Color(0xFF4361EE)),
  CampusBuilding('B2', 'Block B2', Offset(0.53, 0.37), Color(0xFF4361EE)),
  CampusBuilding('B3', 'Block B3', Offset(0.62, 0.39), Color(0xFF4361EE)),
  CampusBuilding('B4', 'Block B4', Offset(0.56, 0.22), Color(0xFF20C997)),
  CampusBuilding('B5', 'Block B5', Offset(0.47, 0.18), Color(0xFF20C997)),
  CampusBuilding('B6', 'Block B6', Offset(0.66, 0.52), Color(0xFFEE6C9C)),
  CampusBuilding('B7', 'Block B7', Offset(0.63, 0.30), Color(0xFFFF9F43)),
  CampusBuilding('B8', 'Block B8', Offset(0.62, 0.14), Color(0xFF9B6BFF)),
  CampusBuilding('B9', 'Block B9', Offset(0.38, 0.28), Color(0xFF9B6BFF)),
  CampusBuilding('B10', 'Block B10', Offset(0.60, 0.46), Color(0xFFEE6C9C)),
  CampusBuilding('B11', 'Block B11', Offset(0.70, 0.42), Color(0xFF20C997)),
  CampusBuilding('MG', 'Main Gate', Offset(0.30, 0.90), Color(0xFF14151A)),
  CampusBuilding(
      'GT', 'Guest House', Offset(0.34, 0.62), Color(0xFF4361EE)),
  CampusBuilding(
      'SP', 'Sports Complex', Offset(0.70, 0.34), Color(0xFFFF9F43)),
];

class CampusBuilding {
  final String code;
  final String name;
  final Offset pos; // fractional position on the canvas
  final Color color;
  CampusBuilding(this.code, this.name, this.pos, this.color);
}

class _CampusMapPageState extends State<CampusMapPage> {
  static const _text = Color(0xFF14151A);
  static const _muted = Color(0xFF8A8D9A);
  static const _primary = Color(0xFF4361EE);

  CampusBuilding? _selected;
  final TransformationController _viewCtrl = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _text,
        title: const Text('Campus Map',
            style: TextStyle(fontWeight: FontWeight.w700, color: _text)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _viewCtrl,
              minScale: 1,
              maxScale: 4,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return GestureDetector(
                      onTapUp: (details) =>
                          _handleTap(details.localPosition, size),
                      child: CustomPaint(
                        size: size,
                        painter: _CampusPainter(),
                        foregroundPainter: null,
                        child: Stack(
                          children: campusBuildings.map((b) {
                            final selected = b == _selected;
                            return Positioned(
                              left: b.pos.dx * size.width - 16,
                              top: b.pos.dy * size.height - 16,
                              child: GestureDetector(
                                onTap: () => setState(() => _selected = b),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: selected ? 38 : 32,
                                  height: selected ? 38 : 32,
                                  decoration: BoxDecoration(
                                    color: b.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: b.color.withOpacity(0.5),
                                        blurRadius: selected ? 10 : 4,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    b.code,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(top: 14, right: 14, child: _compass()),
          Positioned(bottom: 16, left: 16, child: _zoomControls()),
          if (_selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _infoCard(_selected!),
            ),
        ],
      ),
    );
  }

  void _handleTap(Offset local, Size size) {
    // Deselect when tapping empty canvas space (not on a marker).
    final hit = campusBuildings.any((b) {
      final center = Offset(b.pos.dx * size.width, b.pos.dy * size.height);
      return (local - center).distance < 20;
    });
    if (!hit) setState(() => _selected = null);
  }

  Widget _compass() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: const Icon(Icons.explore_rounded, color: _primary, size: 26),
    );
  }

  Widget _zoomControls() {
    return Column(
      children: [
        _zoomBtn(Icons.add_rounded, () => _zoom(1.2)),
        const SizedBox(height: 8),
        _zoomBtn(Icons.remove_rounded, () => _zoom(0.8)),
      ],
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 18, color: _text),
      ),
    );
  }

  void _zoom(double factor) {
    final m = _viewCtrl.value.clone()..scale(factor);
    _viewCtrl.value = m;
  }

  Widget _infoCard(CampusBuilding b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: b.color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(b.code,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: _text)),
                const Text('Tap directions for route',
                    style: TextStyle(fontSize: 12, color: _muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
                color: _primary, borderRadius: BorderRadius.circular(12)),
            child: const Text('Directions',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Draws the schematic base: river, green zones, entrance road,
/// circular hub road and connector paths — mirrors the physical board.
class _CampusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // River (top-right)
    final river = Path()
      ..moveTo(w * 0.55, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.30)
      ..lineTo(w * 0.68, h * 0.18)
      ..close();
    canvas.drawPath(river, Paint()..color = const Color(0xFFBFDCF7));

    // Campus green zone (rough outline of the developed area)
    final green = Path()
      ..moveTo(w * 0.20, h * 0.62)
      ..lineTo(w * 0.30, h * 0.20)
      ..lineTo(w * 0.55, h * 0.05)
      ..lineTo(w * 0.75, h * 0.20)
      ..lineTo(w * 0.75, h * 0.55)
      ..lineTo(w * 0.55, h * 0.60)
      ..lineTo(w * 0.40, h * 0.60)
      ..close();
    canvas.drawPath(green, Paint()..color = const Color(0xFFE4F0D8));

    // Entrance road: main gate -> hub
    final road = Path()
      ..moveTo(w * 0.30, h * 0.92)
      ..quadraticBezierTo(w * 0.32, h * 0.70, w * 0.40, h * 0.50);
    canvas.drawPath(
      road,
      Paint()
        ..color = const Color(0xFFD8DAE2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Circular hub road around B1/B2/B3
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.36),
      w * 0.13,
      Paint()
        ..color = const Color(0xFFD8DAE2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Outer loop road (matches the tree-lined curved road on the board)
    final loop = Path()
      ..moveTo(w * 0.22, h * 0.60)
      ..quadraticBezierTo(w * 0.14, h * 0.38, w * 0.30, h * 0.20)
      ..quadraticBezierTo(w * 0.45, h * 0.06, w * 0.62, h * 0.14);
    canvas.drawPath(
      loop,
      Paint()
        ..color = const Color(0xFFD8DAE2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Sports track (oval) near B7
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.70, h * 0.34), width: w * 0.13, height: h * 0.08),
      Paint()..color = const Color(0xFFFCD9C0),
    );

    // Main gate marker base
    canvas.drawCircle(
      Offset(w * 0.30, h * 0.90),
      6,
      Paint()..color = const Color(0xFFFFCB77),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}