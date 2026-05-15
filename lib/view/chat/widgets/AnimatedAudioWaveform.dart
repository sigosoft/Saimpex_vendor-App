import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedAudioWaveform extends StatefulWidget {
  final bool isRecording;
  final bool isPaused;
  final double amplitude;
  final Color color;

  const AnimatedAudioWaveform({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.amplitude,
    required this.color,
  });

  @override
  State<AnimatedAudioWaveform> createState() => _AnimatedAudioWaveformState();
}

class _AnimatedAudioWaveformState extends State<AnimatedAudioWaveform> {
  // Store a history of amplitudes for the scrolling effect
  final List<double> _amplitudeHistory = List.generate(35, (index) => 0.0);

  @override
  void didUpdateWidget(AnimatedAudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !widget.isPaused) {
      if (widget.amplitude != oldWidget.amplitude || widget.amplitude > 0) {
        setState(() {
          // Remove the first (oldest) and add the new one to the end (right)
          _amplitudeHistory.removeAt(0);
          
          // Map amplitude to height
          double targetHeight = 4.0 + (widget.amplitude * 35.0);
          _amplitudeHistory.add(targetHeight);
        });
      }
    } else if (!widget.isRecording) {
      setState(() {
        _amplitudeHistory.fillRange(0, _amplitudeHistory.length, 0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      alignment: Alignment.centerRight, // Align to the right so it "fills" from the right
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_amplitudeHistory.length, (index) {
          final height = _amplitudeHistory[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            width: 2.2,
            height: height > 4.0 ? height : 4.0,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(widget.isPaused ? 0.2 : 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }
}
