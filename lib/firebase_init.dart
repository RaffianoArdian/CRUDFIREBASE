import 'package:firebase_core/firebase_core.dart';
import 'package:crud_firebasereal/firebase_options.dart';

Future<FirebaseApp> initializeFirebase() async {

  FirebaseApp firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
    );

  return firebaseApp;
}
