import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:flutter/material.dart';

class FirebaseInitializer extends StatelessWidget {
  final Widget child;
  const FirebaseInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        // Use MaterialApp to provide Directionality for loading/error screens
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: snapshot.hasError
                  ? Text('❌ Firebase init error: ${snapshot.error}')
                  : const CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
