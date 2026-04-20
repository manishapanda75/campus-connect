// This script seeds Firestore with books and GATE data.
// Run it ONCE from Dart after linking Firebase:
//   dart run lib/scripts/seed_firestore.dart

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../services/firestore_service.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final service = FirestoreService();
  print('Seeding books...');
  await service.seedBooksData();
  print('Seeding GATE data...');
  await service.seedGateData();
  print('✅ Firestore seeded successfully!');
}
