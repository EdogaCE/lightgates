import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatelessWidget {
  final List<String> imageUrl;
  final String heroTag;
  final String placeholder;
  final int position;
  ViewImage({this.imageUrl, this.heroTag, this.placeholder, this.position});

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController(
        initialPage: position,
        viewportFraction: 1.0
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
        body:Container(
          height: double.infinity,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: imageUrl.length,
            itemBuilder: (context, position) {
              return _displayImage(imageUrl[position]);
            },
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            physics: BouncingScrollPhysics(),
            onPageChanged: _onPageViewChange,
          ),
        )
    );
  }
  Widget _displayImage(String imageUrl){
    return Center(
      child: Hero(
        tag: heroTag,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: PhotoView.customChild(
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2.1,
            initialScale: PhotoViewComputedScale.contained * 1.1,
            basePosition: Alignment.center,
            child: FadeInImage.assetNetwork(
              fadeInDuration: const Duration(seconds: 1),
              fadeInCurve: Curves.easeInCirc,
              placeholder: placeholder,
              image:imageUrl,
            ),
          ),
        ),
      ),
    );
  }

  _onPageViewChange(int page) {
    print(imageUrl[page].split('/').last);
  }

}
