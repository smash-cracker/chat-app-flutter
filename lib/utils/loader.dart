import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.flickr(
            leftDotColor: Color(0xFFEB455F),
            rightDotColor: Color(0xFF2B3467),
            size: 30),
      ),
    );
  }
}
