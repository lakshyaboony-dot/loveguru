import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    voiceProvider.startListening();
    _animationController.forward();
  }

  void _onPanEnd(DragEndDetails details) {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    voiceProvider.stopListening();
    _animationController.reverse();
  }

  void _onPanCancel() {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    voiceProvider.stopListening();
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        return GestureDetector(
          onPanStart: _onPanStart,
          onPanEnd: _onPanEnd,
          onPanCancel: _onPanCancel,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: voiceProvider.isListening
                          ? [
                              const Color(0xFFFF4081),
                              const Color(0xFFE91E63),
                            ]
                          : [
                              const Color(0xFFE91E63),
                              const Color(0xFFC2185B),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                        blurRadius: voiceProvider.isListening ? 20 : 10,
                        spreadRadius: voiceProvider.isListening ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse effect when listening
                      if (voiceProvider.isListening)
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      
                      // Microphone icon
                      Icon(
                        voiceProvider.isListening 
                            ? Icons.mic 
                            : Icons.mic_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}