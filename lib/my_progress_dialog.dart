import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// import '../../misc/constants/colors.dart';

class MyProgressDialog extends StatelessWidget {
  const MyProgressDialog({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(80.0),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCircle(
                      color: Theme.of(context).colorScheme.primary,
                      size: 35,
                    ),
                    const SizedBox(height: 20),
                    Text(text ?? 'Cargando...',
                        style: Theme.of(context).textTheme.titleLarge)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
