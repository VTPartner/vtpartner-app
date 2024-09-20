import 'package:flutter/material.dart';

class CircularNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const CircularNetworkImage({
    Key? key,
    required this.imageUrl,
    this.radius = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(imageUrl),
      backgroundColor: Colors.transparent,
    );
  }
}
