import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/accessibility/accessibility_bloc.dart';
import '../bloc/accessibility/accessibility_event.dart';
import '../bloc/accessibility/accessibility_state.dart';

/// An accessible speaker icon button that speaks the provided text on tap.
/// Tapping this button forces playback even if automatic speech is turned off.
class SpeakerButton extends StatelessWidget {
  final String textToSpeak;
  final String? tooltip;
  final Color? color;
  final double size;

  const SpeakerButton({
    super.key,
    required this.textToSpeak,
    this.tooltip,
    this.color,
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    AccessibilityBloc? bloc;
    try {
      bloc = context.read<AccessibilityBloc>();
    } catch (_) {
      bloc = null;
    }

    if (bloc == null) {
      return IconButton(
        iconSize: size,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        tooltip: tooltip ?? 'आवाजात ऐका',
        icon: Icon(
          Icons.volume_down_alt,
          color: color ?? const Color(0xFF2E7D32),
        ),
        onPressed: null,
      );
    }

    return BlocBuilder<AccessibilityBloc, AccessibilityState>(
      bloc: bloc,
      buildWhen: (prev, curr) =>
          prev.isSpeaking != curr.isSpeaking ||
          prev.lastSpokenText != curr.lastSpokenText,
      builder: (context, state) {
        final isThisSpeaking =
            state.isSpeaking && state.lastSpokenText == textToSpeak;
        final iconColor = isThisSpeaking
            ? Colors.orange.shade700
            : (color ?? const Color(0xFF2E7D32));

        return IconButton(
          iconSize: size,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: tooltip ?? 'आवाजात ऐका',
          icon: Icon(
            isThisSpeaking ? Icons.volume_up : Icons.volume_down_alt,
            color: iconColor,
          ),
          onPressed: () {
            bloc?.add(
              AccessibilitySpeakRequested(
                textToSpeak,
                force: true,
              ),
            );
          },
        );
      },
    );
  }
}
