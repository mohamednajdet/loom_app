import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackButtonCustom extends StatelessWidget {
  final String? title;

  const BackButtonCustom({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF546E7A);
    const Color textColor = Color(0xFF546E7A); // أو استعمل لون آخر للنص لو تريد غيره

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: primary,
                  size: 24,
                ),
                onPressed: () => context.pop(),
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
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
