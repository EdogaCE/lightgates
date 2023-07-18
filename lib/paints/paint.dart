import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final height=size.height;
    final width=size.width;
    Paint paint=Paint();

    Path mainBackground=Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color= Colors.white54;
    canvas.drawPath(mainBackground, paint);

    Path ovalPath=Path();
    //Starting paint from 20% height to left
    ovalPath.moveTo(0, height*0.2);
    //Paint a curve from current position to middle of the screen
    ovalPath.quadraticBezierTo(width*0.45, height*0.25, width*0.51, height*0.5);
    //Paint a curve from current position to to bottom left of the screen at width*0.1
    ovalPath.quadraticBezierTo(width*0.58, height*0.8, width*0.1, height);
    //Draw the remaining height to bottom left side
    ovalPath.lineTo(0, height);
    //Close line to reset it back
    ovalPath.close();
    paint.color=Colors.deepPurple.withOpacity(0.5);
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate!=this;
  }
}




class DashBoardBackgroundPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final height=size.height;
    final width=size.width;

    // create a bounding square, based on the centre and radius of the arc
   /* Rect rect = new Rect.fromCircle(
      center: new Offset(165.0, 55.0),
      radius: 180.0,
    );

    // a fancy rainbow gradient
    final Gradient gradient = new LinearGradient(
      begin: Alignment.topCenter,
      end:Alignment.bottomRight,
      colors: <Color>[
        MyColors.primaryColor,
        Colors.white
      ],
      stops: [
        0.5,
        0.5,
      ],
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = new Paint()..shader = gradient.createShader(rect);*/
    Paint paint=Paint();

    Path mainBackground=Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color= Colors.white54;
    canvas.drawPath(mainBackground, paint);

    Path ovalPath=Path();
    ovalPath.moveTo(0, 0);
    ovalPath.lineTo(0, height*0.2);
    ovalPath.quadraticBezierTo(width*0.2, height*0.15, width*0.3, height*0.15);
    ovalPath.quadraticBezierTo(width*0.5, height*0.15, width*0.7, height*0.1);
    ovalPath.quadraticBezierTo(width*0.8, height*0.05, width, height*0.05);
    /*
    ovalPath.quadraticBezierTo(width*0.2, 142.0, width*0.3, 142.0);
    ovalPath.quadraticBezierTo(width*0.5, 159.75, width*0.7, 88.75);
    ovalPath.quadraticBezierTo(width*0.8, 53.25, width, 53.25);
     */
    ovalPath.lineTo(width, 0);
    ovalPath.close();
    paint.color=Colors.deepPurple;
    canvas.drawPath(ovalPath, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate!=this;
  }

}


class CustomScrollPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final height=size.height;
    final width=size.width;

    Paint paint=Paint();

    Path mainBackground=Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color= Colors.white;
    canvas.drawPath(mainBackground, paint);

    Path ovalPath=Path();
    ovalPath.moveTo(0, 0);
    ovalPath.lineTo(0, height);
    ovalPath.lineTo(width*0.8, height);
    ovalPath.quadraticBezierTo(width*0.9, height, width, height*0.9);
    ovalPath.lineTo(width, height*0.8);
    ovalPath.lineTo(width, 0);
    ovalPath.close();
    paint.color=Colors.deepPurple;
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate!=this;
  }

}


class ProfilePainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final height=size.height;
    final width=size.width;

    Paint paint=Paint();

    Path mainBackground=Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color= Colors.white;
    canvas.drawPath(mainBackground, paint);

    Path ovalPath=Path();
    ovalPath.moveTo(0, 0);
    ovalPath.lineTo(0, height*0.9);
    ovalPath.quadraticBezierTo(width*0.25, height, width*0.5, height);
    ovalPath.quadraticBezierTo(width*0.75, height, width, height*0.9);
    ovalPath.lineTo(width, height*0.8);
    ovalPath.lineTo(width, 0);
    ovalPath.close();
    paint.color=Colors.deepPurple;
    canvas.drawPath(ovalPath, paint);

    //Drawing shapes here
    paint.color=Colors.white10;
    //Drawing shapes here
    canvas.drawCircle(Offset(0, height*0.2), 25.0, paint);
    canvas.drawCircle(Offset(width*0.2, height), 25.0, paint);
    canvas.drawCircle(Offset(0, height*0.7), 25.0, paint);
    canvas.drawCircle(Offset(width*0.5, height*0.5), 25.0, paint);
    canvas.drawCircle(Offset(width*0.8, height*0.2), 25.0, paint);
    canvas.drawCircle(Offset(width, height*0.5), 25.0, paint);
    canvas.drawCircle(Offset(width*0.7, height), 25.0, paint);
    canvas.drawCircle(Offset(width*0.7, height*0.7), 25.0, paint);
    canvas.drawCircle(Offset(width*0.3, height*0.3), 25.0, paint);
    canvas.drawCircle(Offset(width, height), 25.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate!=this;
  }

}


