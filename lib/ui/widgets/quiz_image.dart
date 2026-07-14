import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:flutter/cupertino.dart';

class QuizImage extends StatelessWidget {
  final String imagePath;
  const QuizImage(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: GestureDetector(
            // child: Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: imageHeight + 60.0,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       alignment: Alignment.topLeft,
            //       image: NetworkImage(imagePath),
            //     ),
            //   ),
            // ),
            child: FittedBox(fit: BoxFit.fill, child: Image.network(imagePath)),
            onTap: () => launchURL(imagePath)));
  }
}
