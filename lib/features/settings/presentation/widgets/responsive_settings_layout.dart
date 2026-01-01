import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';

class ResponsiveSettingsLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveSettingsLayout({
    super.key,
    required this.child,
  });

  static Future<void> show(BuildContext context, {required Widget child}) {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    if (isMobile) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: ResponsiveSettingsLayout(child: child),
          ),
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ResponsiveSettingsLayout(child: child),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: isMobile
            ? null
            : BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

