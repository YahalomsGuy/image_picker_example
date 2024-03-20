import 'package:flutter/material.dart';
import 'package:image_picker_example/base/glob.dart';
import 'package:image_picker_example/widgets/open_painter.dart';

enum CursorWork { nothing, move, resizeTop, resizeBottom }

class RoiSizeWidget extends StatefulWidget {
  const RoiSizeWidget({super.key});

  @override
  State<RoiSizeWidget> createState() => _RoiSizeWidgetState();
}

class _RoiSizeWidgetState extends State<RoiSizeWidget> {
  @override
  bool expOpen = false;
  double x = 0.0;
  double y = 0.0;
  double deltaX = 0.0;
  double deltaY = 0.0;
  double heightRatio = 0.0;
  double widthRatio = 0.0;
  int downX = 0;
  int downY = 0;
  late Size size;
  CursorWork job = CursorWork.nothing;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    heightRatio = size.height / 320;
    widthRatio = size.width / 240;
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          color: Colors.transparent,
          child: Listener(
            //onPointerSignal: ,
            onPointerMove: updateLocation,
            onPointerDown: moveResize,
            child: CustomPaint(
              painter: OpenPainter(
                left: roiLeft,
                top: roiTop,
                width: roiWidth,
                height: roiHeight,
                screenSize: size,
              ),
            ),
          ),
        ),
        // Positioned(
        //   left: 40,
        //   top: 50,
        //   child: SizedBox(
        //     width: MediaQuery.of(context).size.width - 80,
        //     height: expOpen ? 250 : 80,
        //     child: ExpansionTile(
        //       backgroundColor: Colors.white.withOpacity(0.5),
        //       collapsedBackgroundColor: Colors.transparent,
        //       expansionAnimationStyle: AnimationStyle.noAnimation,
        //       iconColor: Colors.red,
        //       collapsedIconColor: Colors.white,
        //       onExpansionChanged: (open) {
        //         expOpen = open;
        //         setState(() {});
        //       },
        //       title: Text("Position and Size"),
        //       children: [
        //         Slider(
        //             min: -99999,
        //             max: 99999,
        //             value: roiTop.toDouble(),
        //             onChanged: (newTop) {
        //               roiTop = newTop;
        //               setState(() {});
        //             }),
        //         Slider(
        //             min: 0,
        //             max: (240 - roiWidth).toDouble(),
        //             value: roiLeft.toDouble(),
        //             onChanged: (newLeft) {
        //               roiLeft = newLeft;
        //               setState(() {});
        //             }),
        //         Slider(
        //             min: -99999,
        //             max: 9999,
        //             value: roiWidth.toDouble(),
        //             onChanged: (newWidth) {
        //               roiWidth = newWidth;
        //               setState(() {});
        //             }),
        //         Slider(
        //             min: 10,
        //             max: 100,
        //             value: roiHeight.toDouble(),
        //             onChanged: (newHeight) {
        //               roiHeight = newHeight;
        //               setState(() {});
        //             }),
        //       ],
        //     ),
        //   ),
        // ),
        Positioned(
          bottom: 50,
          left: 30,
          child: Column(
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      roiTop = 120;
                      roiLeft = 90;
                    });
                  },
                  icon: const Icon(Icons.recycling)),
              SizedBox(
                width: 200,
                height: 100,
                child: Text(
                  "X: ${x ~/ widthRatio}, Y: ${y ~/ heightRatio}",
                  style: TextStyle(
                      color: chkRed && chkGreen ? Colors.black : Colors.white,
                      fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
      deltaX = details.delta.dx / widthRatio;
      deltaY = details.delta.dy / heightRatio;
      switch (job) {
        case CursorWork.nothing:
          break;
        case CursorWork.move:
          roiLeft += deltaX;
          roiTop += deltaY;
          break;
        case CursorWork.resizeTop:
          roiLeft += deltaX;
          roiTop += deltaY;
          roiWidth -= deltaX;
          roiHeight -= deltaY;
          break;
        case CursorWork.resizeBottom:
          roiWidth += deltaX;
          roiHeight += deltaY;
          break;
      }
    });
  }

  moveResize(PointerEvent details) {
    x = details.position.dx;
    y = details.position.dy;
    int xPoint = x ~/ widthRatio;
    int yPoint = y ~/ heightRatio;
    downX = xPoint;
    downY = yPoint;
    if ((xPoint - roiLeft).abs() < tolerance &&
        ((yPoint - roiTop).abs()) < tolerance) {
      print("Caught TopLeft Edge, Stretching top anchor!!!");
      job = CursorWork.resizeTop;
    } else if ((xPoint - (roiLeft + roiWidth)).abs() < tolerance &&
        ((yPoint - (roiTop + roiHeight)).abs()) < tolerance) {
      print("Caught BottomRight Edge, Stretching bottom anchor!!!");
      job = CursorWork.resizeBottom;
    } else {
      print("Did not Catch Edge, Moving !!!");
      job = CursorWork.move;
    }

    setState(() {
      print("Caught X: ${xPoint.toInt()}, Y: ${yPoint.toInt()}");
    });
  }
}
