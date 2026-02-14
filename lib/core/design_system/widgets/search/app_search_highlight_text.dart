import 'package:flutter/material.dart';

class AppSearchHighlightText extends StatelessWidget {
  const AppSearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final spans = _buildSpans(text: text, query: normalizedQuery);
    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<TextSpan> _buildSpans({required String text, required String query}) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    var cursor = 0;
    while (cursor < text.length) {
      final index = lowerText.indexOf(lowerQuery, cursor);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(cursor), style: style));
        break;
      }

      if (index > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, index), style: style));
      }

      final end = index + query.length;
      spans.add(
        TextSpan(text: text.substring(index, end), style: highlightStyle),
      );
      cursor = end;
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
    }

    return spans;
  }
}
