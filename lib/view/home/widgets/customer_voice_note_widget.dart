import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerVoiceNoteWidget extends StatefulWidget {
  final String audioUrl;

  const CustomerVoiceNoteWidget({
    super.key,
    required this.audioUrl,
  });

  @override
  State<CustomerVoiceNoteWidget> createState() =>
      _CustomerVoiceNoteWidgetState();
}

class _CustomerVoiceNoteWidgetState extends State<CustomerVoiceNoteWidget> {
  static const Color _orange = Color(0xFFFF5C22);
  static const Color _waveIdle = Color(0xFFC9D0DB);

  static const _heights = <double>[
    0.35, 0.55, 0.42, 0.78, 0.50, 0.92, 0.60, 0.70, 0.45, 0.85,
    0.38, 0.62, 0.90, 0.48, 0.72, 0.40, 0.68, 0.55, 0.82, 0.46,
    0.74, 0.58, 0.36, 0.80, 0.52, 0.66, 0.44, 0.76, 0.50, 0.60,
    0.42, 0.70, 0.48, 0.64, 0.38, 0.72,
  ];

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position >= _duration && _duration > Duration.zero) {
          await _audioPlayer.seek(Duration.zero);
        }
        final url = widget.audioUrl.trim();
        final Source source =
            (url.startsWith('http://') || url.startsWith('https://'))
                ? UrlSource(url)
                : DeviceFileSource(url);
        await _audioPlayer.play(source);
      }
    } catch (e) {
      debugPrint("Voice note playback error: $e");
    }
  }

  String get _durationLabel {
    final d = (_isPlaying || _position > Duration.zero) ? _position : _duration;
    if (d == Duration.zero && _duration == Duration.zero) {
      return '0:15';
    }
    final totalSecs = d.inSeconds;
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_duration.inMilliseconds > 0)
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFEF3C7),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Material(
              color: _orange,
              shape: const CircleBorder(),
              elevation: 0,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _togglePlayback,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      if (_duration > Duration.zero) {
                        final double ratio =
                            (details.localPosition.dx / constraints.maxWidth)
                                .clamp(0.0, 1.0);
                        final targetMs =
                            (_duration.inMilliseconds * ratio).round();
                        _audioPlayer.seek(Duration(milliseconds: targetMs));
                      }
                    },
                    child: SizedBox(
                      height: 24,
                      child: CustomPaint(
                        painter: _VoiceWaveformPainter(
                          heights: _heights,
                          progress: progress,
                          activeColor: _orange,
                          idleColor: _waveIdle,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _durationLabel,
              style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _VoiceWaveformPainter extends CustomPainter {
  const _VoiceWaveformPainter({
    required this.heights,
    required this.progress,
    required this.activeColor,
    required this.idleColor,
  });

  final List<double> heights;
  final double progress;
  final Color activeColor;
  final Color idleColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (heights.isEmpty) return;

    const barWidth = 2.4;
    final gap =
        (size.width - (heights.length * barWidth)) / (heights.length - 1);
    final activeCount = (heights.length * progress).floor();

    for (var i = 0; i < heights.length; i++) {
      final h = heights[i].clamp(0.18, 1.0) * size.height;
      final x = i * (barWidth + gap);
      final top = (size.height - h) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, h),
        const Radius.circular(1.2),
      );
      final paint = Paint()
        ..color = progress == 0
            ? (i < 8 ? activeColor : idleColor)
            : (i < activeCount ? activeColor : idleColor);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.idleColor != idleColor;
}
