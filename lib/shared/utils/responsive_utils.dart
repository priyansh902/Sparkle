
import 'package:flutter/material.dart';

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1201;
}

/// Extension on BuildContext for easy responsive checks
extension ResponsiveContext on BuildContext {
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  Orientation get orientation => MediaQuery.of(this).orientation;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
  
  // Responsive checks
  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;
  
  // Responsive spacing
  double get responsivePadding => isMobile ? 16 : (isTablet ? 24 : 32);
  double get responsiveSpacing => isMobile ? 12 : (isTablet ? 16 : 24);
  double get smallSpacing => isMobile ? 8 : 12;
  double get largeSpacing => isMobile ? 24 : (isTablet ? 32 : 40);
  
  // Responsive font sizes
  double get headlineSize => isMobile ? 24 : (isTablet ? 28 : 32);
  double get titleSize => isMobile ? 18 : (isTablet ? 20 : 22);
  double get subtitleSize => isMobile ? 14 : (isTablet ? 15 : 16);
  double get bodySize => isMobile ? 14 : (isTablet ? 15 : 16);
  double get captionSize => isMobile ? 12 : 13;
  
  // Responsive grid columns
  int get gridColumns => isMobile ? 2 : (isTablet ? 3 : 4);
  int get actionsPerRow => isMobile ? 2 : (isTablet ? 3 : 4);
  double get quickActionHeight => isMobile ? 100 : 120;
  
  // Theme-aware spacing (NEW)
  EdgeInsets get screenPadding => EdgeInsets.all(responsivePadding);
  EdgeInsets get cardPadding => EdgeInsets.all(isMobile ? 12 : 16);
}

/// Responsive widget that builds different child based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;
  
  const ResponsiveBuilder({super.key, required this.builder});
  
  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;
    
    return builder(context, isMobile, isTablet, isDesktop);
  }
}

/// Responsive grid that automatically adjusts columns
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    this.childAspectRatio,
  });
  
  @override
  Widget build(BuildContext context) {
    final columns = context.gridColumns;
    final aspectRatio = childAspectRatio ?? (context.isMobile ? 1.2 : 1.0);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio: aspectRatio,
      children: children,
    );
  }
}

/// Responsive row that wraps on mobile
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  
  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 12,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });
  
  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.map((child) {
          return Flexible(
            child: Padding(
              padding: EdgeInsets.only(right: spacing),
              child: child,
            ),
          );
        }).toList(),
      );
    }
  }
}

/// Responsive text with auto-sizing font
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });
  
  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle();
    final fontSize = baseStyle.fontSize;
    
    double responsiveFontSize = 14;
    if (fontSize != null) {
      if (context.isTablet) {
        responsiveFontSize = fontSize * 1.1;
      } else if (context.isDesktop) {
        responsiveFontSize = fontSize * 1.2;
      } else {
        responsiveFontSize = fontSize.toDouble();
      }
    } else {
      if (baseStyle.fontWeight == FontWeight.bold && fontSize == null) {
        responsiveFontSize = context.headlineSize;
      } else {
        responsiveFontSize = context.bodySize;
      }
    }
    
    return Text(
      text,
      style: baseStyle.copyWith(fontSize: responsiveFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  
  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? context.screenPadding,
      child: child,
    );
  }
}

/// Two-column layout that becomes one column on mobile
class ResponsiveTwoColumns extends StatelessWidget {
  final Widget leftColumn;
  final Widget rightColumn;
  final double spacing;
  final double leftFlex;
  final double rightFlex;
  
  const ResponsiveTwoColumns({
    super.key,
    required this.leftColumn,
    required this.rightColumn,
    this.spacing = 24,
    this.leftFlex = 1,
    this.rightFlex = 1,
  });
  
  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Column(
        children: [
          leftColumn,
          SizedBox(height: spacing),
          rightColumn,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: leftFlex.toInt(), child: leftColumn),
          SizedBox(width: spacing),
          Expanded(flex: rightFlex.toInt(), child: rightColumn),
        ],
      );
    }
  }
}