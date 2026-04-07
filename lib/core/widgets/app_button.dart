import 'dart:async';
import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  final String text;
  final FutureOr<void> Function()? onTap;
  final Duration debounceDuration;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _busy = false;
  Timer? _debounce;

  Future<void> _handleTap() async {
    // prevent tap if disabled or busy
    if (widget.onTap == null || _busy) return;

    // debounce: ignore rapid taps
    if (_debounce?.isActive ?? false) return;

    _debounce = Timer(widget.debounceDuration, () {});

    setState(() => _busy = true);

    try {
      await widget.onTap!.call();
    } catch (e) {
      debugPrint("Button error: $e");
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || _busy;

    return GestureDetector(
      onTap: disabled ? null : _handleTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _busy
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}