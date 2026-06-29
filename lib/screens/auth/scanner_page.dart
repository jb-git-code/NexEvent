import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum _ScanStatus { scanning, verifying, success, alreadyMarked, invalid }

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  bool _scanned = false;
  bool _torchOn = false;
  _ScanStatus _status = _ScanStatus.scanning;
  String _message = '';

  static const double _cutoutSize = 260;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    if (capture.barcodes.isEmpty) {
      _resolve(_ScanStatus.invalid, "Invalid QR Code");
      return;
    }

    final code = capture.barcodes.first.rawValue;
    if (code == null) {
      _resolve(_ScanStatus.invalid, "Invalid QR Code");
      return;
    }

    _scanned = true;
    setState(() => _status = _ScanStatus.verifying);

    try {
      final ref = FirebaseFirestore.instance
          .collection("registrations")
          .doc(code);
      final doc = await ref.get();

      if (!doc.exists) {
        _resolve(_ScanStatus.invalid, "Invalid QR Code");
        return;
      }

      if (doc["attended"] == true) {
        _resolve(_ScanStatus.alreadyMarked, "Attendance already marked");
        return;
      }

      await ref.update({"attended": true});
      _resolve(_ScanStatus.success, "Attendance Marked");
    } catch (e) {
      _resolve(_ScanStatus.invalid, "Something went wrong");
    }
  }

  void _resolve(_ScanStatus status, String message) {
    if (!mounted) return;

    if (status == _ScanStatus.success) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _status = status;
      _message = message;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan QR',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                key: ValueKey(_torchOn),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetect),

          // dimmed mask with a clear cutout for the scan area
          IgnorePointer(
            child: CustomPaint(
              painter: _ScannerMaskPainter(cutoutSize: _cutoutSize),
              child: const SizedBox.expand(),
            ),
          ),

          // scan frame: corner brackets + moving scan line
          Center(
            child: SizedBox(
              width: _cutoutSize,
              height: _cutoutSize,
              child: Stack(
                children: [
                  ..._corners(),
                  if (_status == _ScanStatus.scanning) const _ScanLine(),
                ],
              ),
            ),
          ),

          // instruction text
          if (_status == _ScanStatus.scanning)
            Positioned(
              left: 24,
              right: 24,
              bottom: 64,
              child: Text(
                "Point the camera at a registration QR code",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ),

          // verifying / result overlay
          if (_status != _ScanStatus.scanning)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(child: _buildResultCard()),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    return [
      Positioned(top: 0, left: 0, child: _corner(top: true, left: true)),
      Positioned(top: 0, right: 0, child: _corner(top: true, left: false)),
      Positioned(bottom: 0, left: 0, child: _corner(top: false, left: true)),
      Positioned(bottom: 0, right: 0, child: _corner(top: false, left: false)),
    ];
  }

  Widget _corner({required bool top, required bool left}) {
    const double size = 28;
    const double thickness = 4;
    final color = _status == _ScanStatus.scanning
        ? Colors.white
        : Colors.white.withOpacity(0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
          bottom: !top
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
          left: left
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
          right: !left
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(14) : Radius.zero,
          topRight: top && !left ? const Radius.circular(14) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(14) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(14) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_status == _ScanStatus.verifying) {
      return const Column(
        key: ValueKey('verifying'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Verifying...",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 250.ms);
    }

    late IconData icon;
    late Color color;
    switch (_status) {
      case _ScanStatus.success:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF16A34A);
        break;
      case _ScanStatus.alreadyMarked:
        icon = Icons.info_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case _ScanStatus.invalid:
        icon = Icons.cancel_rounded;
        color = const Color(0xFFEF4444);
        break;
      default:
        icon = Icons.qr_code_rounded;
        color = Colors.white;
    }

    return Container(
          key: ValueKey(_status),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 52)
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 450.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 14),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// Dims the whole screen except a centered rounded-square cutout,
// so the scan area is clearly the focal point.
class _ScannerMaskPainter extends CustomPainter {
  final double cutoutSize;
  _ScannerMaskPainter({required this.cutoutSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20)),
      );

    final maskPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(maskPath, Paint()..color = Colors.black.withOpacity(0.55));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated horizontal line that sweeps up and down inside the scan frame.
class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, -1 + _controller.value * 2),
          child: Container(
            height: 2.5,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent.withOpacity(0),
                  Colors.greenAccent,
                  Colors.greenAccent.withOpacity(0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
