import 'package:flutter/material.dart';

class BackButtonCustom extends StatelessWidget {
  final String? title;

  const BackButtonCustom({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF29434E)),
              onPressed: () => Navigator.pop(context),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
          ),
          if (title != null)
            Align(
              alignment: Alignment.center,
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Color(0xFF29434E),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
