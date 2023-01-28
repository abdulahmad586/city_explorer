import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CardImage extends StatelessWidget {
  CardImage(
      {Key? key,
      required this.imageString,
      required this.size,
      this.radius = 0,
      this.child,
      this.showBorder = false,
      this.borderColor,
      this.padding})
      : super(key: key);

  Size size;
  double radius = 5;
  String imageString;
  Widget? child;
  bool showBorder = false;
  Color? borderColor;
  EdgeInsets? padding;

  @override
  build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageString,
      imageBuilder: (context, imageProvider) => Container(
          padding: padding,
          width: size.width,
          height: (size.height),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            boxShadow: [
              BoxShadow(color: borderColor ?? Colors.white, spreadRadius: 3)
            ],
            color: const Color.fromARGB(0, 0, 0, 0),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
          child: Center(child: child)),
    );
  }
}
