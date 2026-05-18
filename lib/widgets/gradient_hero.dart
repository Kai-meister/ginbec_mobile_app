import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Short orange→amber gradient hero used at the top of main tabs.
///
/// Extends under the status bar; child receives the top safe-area inset
/// as additional top padding. [bottomPadding] is how far below the child
/// the gradient continues — pick larger values when content below the hero
/// (stat cards, segmented tabs) should overlap the hero edge.
class GradientHero extends StatelessWidget {
  final Widget child;
  final double bottomPadding;
  final EdgeInsets contentPadding;

  const GradientHero({
    super.key,
    required this.child,
    this.bottomPadding = 28,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topInset + 12,
        left: contentPadding.left,
        right: contentPadding.right,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GColor.primarycolor, GColor.secondarycolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}