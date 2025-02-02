
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MixedText extends StatelessWidget {
  final String text;
  final Color color;
  final FontWeight? fontWeight;
  final double fontSize;

  const MixedText(
      {super.key,
      required this.text,
      required this.color,
      required this.fontWeight,
      required this.fontSize});

  List<String> parseText(String text) {
    List<String> parts = [];
    bool insideLatex = false; // To track if we're inside a LaTeX block
    String currentPart = ''; // To build the current part (text or LaTeX)

    for (int i = 0; i < text.length; i++) {
      // Check for the $ sign to toggle LaTeX block
      if (text[i] == r'$') {
        // If we're already inside LaTeX, end the LaTeX part
        if (insideLatex) {
          currentPart += text[i]; // Add the closing $
          parts.add(currentPart);
          currentPart = ''; // Reset current part
        } else {
          // We're entering a LaTeX part
          if (currentPart.isNotEmpty) {
            parts.add(
                currentPart); // Add any regular text encountered before this LaTeX part
            currentPart = ''; // Reset current part
          }
          currentPart += text[i]; // Add the opening $
        }
        insideLatex = !insideLatex; // Toggle the insideLatex flag
      } else {
        currentPart += text[i]; // Add characters to the current part
      }
    }

    if (currentPart.isNotEmpty) {
      parts.add(
          currentPart); // Add any remaining part (either regular text or LaTeX)
    }

    return parts;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> parts = parseText(text);
    // Split the text by a delimiter (e.g., "$") to separate LaTeX from regular text
    final List<InlineSpan> children = [];
    // Loop through the parts, adding Text or Math.tex as needed
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].startsWith(r'$') && parts[i].endsWith(r'$')) {
        String latex = parts[i].substring(1, parts[i].length - 1);
        children.add(WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Math.tex(
              latex,
              textStyle: TextStyle(
                  fontSize: fontSize, fontWeight: fontWeight, color: color),
            )));
      } else {
        children.add(TextSpan(
          text: parts[i], // Wrap LaTeX content with $ signs
          style: TextStyle(
              fontSize: fontSize, fontWeight: fontWeight, color: color),
          //textAlign: TextAlign.center,
        ));
      }
    }
    return RichText(
      text: TextSpan(children: children),
      textAlign: TextAlign.center,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }
}
