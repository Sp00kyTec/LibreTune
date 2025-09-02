import 'dart:math';
import 'package:flutter/material.dart';

class Visualizer extends StatefulWidget {
  final bool isActive;
  final Color color;

  const Visualizer({
    super.key,
    this.isActive = false,
    this.color = Colors.purple,
  });

  @override
  State<Visualizer> widget => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<double> _bars = List.filled(20, 0.0);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.isActive) {
        _updateBars();
        _controller.reset();
        _controller.forward();
      } else if (status == AnimationStatus.completed && !widget.isActive) {
        _resetBars();
      }
    });

    if (widget.isActive) {
      _controller.forward();
    }
  }

  void _updateBars() {
    setState(() {
      for (int i = 0; i < _bars.length; i++) {
        // Create a wave-like pattern with random variations
        final baseHeight = sin(i * 0.5 + _controller.value * 2 * pi) * 0.5 + 0.5;
        final randomFactor = _random.nextDouble() * 0.3;
        _bars[i] = (baseHeight + randomFactor).clamp(0.1, 1.0);
      }
    });
  }

  void _resetBars() {
    setState(() {
      for (int i = 0; i < _bars.length; i++) {
        _bars[i] = 0.1;
      }
    });
  }

  @override
  void didUpdateWidget(covariant Visualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.stop();
        _resetBars();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_bars.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 4,
            height: 40 * _bars[index],
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}