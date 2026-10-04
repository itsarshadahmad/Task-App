import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../../core/services/voice_service.dart';
import '../../core/services/haptic_service.dart';

class VoiceInputButton extends ConsumerStatefulWidget {
  final ValueChanged<String> onTextRecognized;
  final String? hintText;

  const VoiceInputButton({
    super.key,
    required this.onTextRecognized,
    this.hintText,
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  bool _isListening = false;
  String _recognizedText = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final voiceService = ref.watch(voiceServiceProvider);
    final hapticService = ref.watch(hapticServiceProvider);
    
    return AvatarGlow(
      glowColor: colorScheme.primary,
      endRadius: 30,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      showTwoGlows: true,
      repeatPauseDuration: const Duration(milliseconds: 100),
      glowShape: BoxShape.circle,
      child: FloatingActionButton(
        onPressed: () async {
          if (_isListening) {
            await voiceService.stopListening();
            setState(() => _isListening = false);
            if (_recognizedText.isNotEmpty) {
              widget.onTextRecognized(_recognizedText);
            }
            return;
          }
          
          await hapticService.lightImpact();
          
          final success = await voiceService.startListening((text) {
            setState(() => _recognizedText = text);
          });
          
          if (success) {
            setState(() => _isListening = true);
          }
        },
        backgroundColor: _isListening ? colorScheme.error : colorScheme.primary,
        foregroundColor: _isListening ? colorScheme.onError : colorScheme.onPrimary,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isListening
            ? const Icon(Icons.mic_off_rounded)
            : const Icon(Icons.mic_rounded),
        ),
      ),
    );
  }
}

class VoiceInputBar extends ConsumerStatefulWidget {
  final ValueChanged<String> onTextRecognized;
  final String hintText;

  const VoiceInputBar({
    super.key,
    required this.onTextRecognized,
    required this.hintText,
  });

  @override
  ConsumerState<VoiceInputBar> createState() => _VoiceInputBarState();
}

class _VoiceInputBarState extends ConsumerState<VoiceInputBar> {
  bool _isListening = false;
  String _recognizedText = '';
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final voiceService = ref.watch(voiceServiceProvider);
    final hapticService = ref.watch(hapticServiceProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
              ),
              style: theme.textTheme.bodyMedium,
              onChanged: (value) {
                if (value.isEmpty) {
                  _recognizedText = '';
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          AvatarGlow(
            animate: _isListening,
            glowColor: colorScheme.primary,
            endRadius: 20,
            duration: const Duration(milliseconds: 2000),
            repeat: true,
            showTwoGlows: true,
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: _isListening ? colorScheme.error : colorScheme.primary,
              ),
              onPressed: () async {
                if (_isListening) {
                  await voiceService.stopListening();
                  setState(() => _isListening = false);
                  if (_recognizedText.isNotEmpty) {
                    _textController.text = _recognizedText;
                    widget.onTextRecognized(_recognizedText);
                  }
                  return;
                }
                
                await hapticService.lightImpact();
                
                final success = await voiceService.startListening((text) {
                  setState(() => _recognizedText = text);
                  _textController.text = text;
                });
                
                if (success) {
                  setState(() => _isListening = true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
