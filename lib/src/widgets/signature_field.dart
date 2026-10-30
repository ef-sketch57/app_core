import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../theme/app_theme.dart';
import 'widgets.dart';

/// Zone de signature au doigt. Affiche la signature enregistrée avec un
/// bouton « Refaire », ou une zone de dessin vide.
///
/// [onChanged] reçoit le PNG (fond transparent) à chaque fin de tracé, ou
/// `null` quand l'utilisateur efface.
class SignatureField extends StatefulWidget {
  const SignatureField({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 140,
  });

  final Uint8List? value;
  final ValueChanged<Uint8List?> onChanged;
  final double height;

  @override
  State<SignatureField> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<SignatureField> {
  late final SignatureController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2.6,
      penColor: const Color(0xFF1F3A7A),
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
      onDrawEnd: _export,
    );
  }

  Future<void> _export() async {
    if (_controller.isEmpty) return;
    final png = await _controller.toPngBytes();
    if (png != null) widget.onChanged(png);
  }

  void _redo() {
    _controller.clear();
    setState(() => _editing = true);
    widget.onChanged(null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final showImage = widget.value != null && !_editing;
    return DashedBorder(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Stack(
            children: [
              if (showImage)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.memory(widget.value!, fit: BoxFit.contain),
                  ),
                )
              else ...[
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => _controller.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.gesture, color: p.muted),
                              const SizedBox(height: 6),
                              Text('Signez ici avec le doigt',
                                  style: TextStyle(color: p.muted, fontSize: 15)),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned.fill(
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => (showImage || _controller.isNotEmpty)
                    ? Positioned(
                        right: 8,
                        bottom: 8,
                        child: Material(
                          color: p.subtle,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: p.border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _redo,
                            child: const SizedBox(
                              height: 44,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Center(
                                  child: Text('Refaire',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
