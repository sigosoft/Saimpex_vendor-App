import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/resources/colors.dart';

class VoiceMessageBubble extends StatefulWidget {
  final String audioUrl;
  final bool isSender;
  final String time;

  const VoiceMessageBubble({
    super.key,
    required this.audioUrl,
    required this.isSender,
    required this.time,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        if (mounted) setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play(UrlSource(widget.audioUrl));
        if (mounted) setState(() => _isPlaying = true);
      }
    } catch (e) {
      debugPrint("Playback error: $e");
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isSender ? Colors.white : Colors.black;
    final activeColor = widget.isSender ? Colors.white : colorPrimary;

    return Column(
      crossAxisAlignment:
          widget.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: widget.isSender ? colorPrimary : Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                      activeTrackColor: activeColor,
                      inactiveTrackColor: activeColor.withOpacity(0.3),
                      thumbColor: activeColor,
                      trackShape: const RectangularSliderTrackShape(),
                    ),
                    child: Slider(
                      min: 0,
                      max: _duration.inMilliseconds.toDouble() > 0
                          ? _duration.inMilliseconds.toDouble()
                          : 1.0,
                      value: _position.inMilliseconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(milliseconds: value.toInt());
                        await _audioPlayer.seek(position);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: GoogleFonts.rubik(
                            fontSize: 9,
                            color: themeColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.mic,
                              size: 10,
                              color: themeColor.withOpacity(0.6),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _formatDuration(_duration),
                              style: GoogleFonts.rubik(
                                fontSize: 9,
                                color: themeColor.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
