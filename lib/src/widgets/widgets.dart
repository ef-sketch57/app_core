import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Champ de saisie avec libellé au-dessus, comme dans la maquette.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.labelHint,
    this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.suffixText,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
  });

  final String label;

  /// Précision discrète après le libellé (« (pour l'envoi) »).
  final String? labelHint;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
          text: label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          children: [
            if (labelHint != null)
              TextSpan(
                text: ' $labelHint',
                style: TextStyle(fontWeight: FontWeight.w400, color: p.muted),
              ),
          ],
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: TextStyle(fontSize: 16, color: p.ink),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Titre de section gris en capitales (« LOGEMENT », « MES BIENS »).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: context.palette.muted,
          ),
        ),
      );
}

/// Carte blanche à coins arrondis.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.highlighted = false,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Bordure foncée pour attirer l'œil (bien à traiter).
  final bool highlighted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: color ?? p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(
          color: highlighted ? p.ink : p.border,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Pastille de statut (« Envoyée », « Prête »).
class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.tone = StatusTone.success});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg) = switch (tone) {
      StatusTone.success => (p.accentSoft, p.accent),
      StatusTone.neutral => (p.subtle, p.muted),
      StatusTone.warning => (const Color(0xFFF7ECD9), const Color(0xFF8A5A14)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

enum StatusTone { success, neutral, warning }

/// Sélecteur à deux options façon « Tout le loyer | Une partie ».
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.subtle,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Row(
        children: [
          for (final e in options.entries)
            Expanded(
              child: Semantics(
                selected: e.key == value,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: e.key == value ? p.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(kRadius - 3),
                      boxShadow: e.key == value
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            e.key == value ? FontWeight.w700 : FontWeight.w500,
                        color: e.key == value ? p.ink : p.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Encart d'information vert clair avec icône.
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.text, this.icon = Icons.lock_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.accentSoft,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: p.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: p.accent, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// Bouton en pointillés (« + Ajouter un bien »).
class DashedButton extends StatelessWidget {
  const DashedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DashedBorder(
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadius),
        onTap: onPressed,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: p.ink, size: 22),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bordure en pointillés arrondie.
class DashedBorder extends StatelessWidget {
  const DashedBorder({super.key, required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedPainter(color ?? context.palette.muted.withValues(alpha: 0.5)),
        child: child,
      );
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(kRadius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color;
}

/// Ligne « libellé … valeur » d'un récapitulatif.
class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: strong ? 18 : 16,
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w400,
                  color: strong ? p.ink : p.muted,
                )),
          ),
          Text(value,
              style: TextStyle(
                fontSize: strong ? 18 : 16,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
