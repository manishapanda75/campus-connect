import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/gate_info_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── BOOKS ───────────────────────────────────────────────────────────────

  Stream<List<Book>> getBooksStream() {
    return _db
        .collection('books')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromFirestore(d)).toList());
  }

  Future<List<Book>> searchBooks(String query) async {
    final snap = await _db.collection('books').get();
    return snap.docs
        .map((d) => Book.fromFirestore(d))
        .where((b) =>
            b.title.toLowerCase().contains(query.toLowerCase()) ||
            b.author.toLowerCase().contains(query.toLowerCase()) ||
            b.subject.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<Book?> getBookById(String id) async {
    final doc = await _db.collection('books').doc(id).get();
    if (doc.exists) return Book.fromFirestore(doc);
    return null;
  }

  // ─── GATE INFO ────────────────────────────────────────────────────────────

  Stream<List<GateInfo>> getGateInfoStream() {
    return _db
        .collection('gate_info')
        .snapshots()
        .map((snap) => snap.docs.map((d) => GateInfo.fromFirestore(d)).toList());
  }

  Future<GateInfo?> getGateInfoByBranch(String branch) async {
    final snap = await _db
        .collection('gate_info')
        .where('branchCode', isEqualTo: branch)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) return GateInfo.fromFirestore(snap.docs.first);
    return null;
  }

  // ─── SEED DATA (Run once to populate Firestore) ─────────────────────────

  Future<void> seedBooksData() async {
    final batch = _db.batch();
    final booksRef = _db.collection('books');
    final List<Map<String, dynamic>> books = [
      {
        'title': 'Engineering Mathematics',
        'author': 'B.S. Grewal',
        'subject': 'Mathematics',
        'libraryStatus': 'available',
        'location': 'Section A, Shelf 2',
        'onlineLink': 'https://archive.org/details/highermathematics',
        'coverColor': 0xFF6C63FF,
        'edition': '44th Edition',
        'tags': ['maths', 'engineering', 'calculus'],
      },
      {
        'title': 'Introduction to Algorithms',
        'author': 'Thomas H. Cormen',
        'subject': 'Computer Science',
        'libraryStatus': 'checked_out',
        'location': 'Section B, Shelf 5',
        'onlineLink': 'https://mitpress.mit.edu/9780262046305/',
        'coverColor': 0xFF00D9A5,
        'edition': '4th Edition',
        'tags': ['algorithms', 'data structures', 'CSE'],
      },
      {
        'title': 'Signals and Systems',
        'author': 'Alan V. Oppenheim',
        'subject': 'Electronics',
        'libraryStatus': 'available',
        'location': 'Section C, Shelf 1',
        'onlineLink': 'https://ocw.mit.edu/courses/6-003-signals-and-systems/',
        'coverColor': 0xFFFF6B6B,
        'edition': '2nd Edition',
        'tags': ['signals', 'systems', 'ECE'],
      },
      {
        'title': 'Engineering Thermodynamics',
        'author': 'P.K. Nag',
        'subject': 'Mechanical',
        'libraryStatus': 'available',
        'location': 'Section D, Shelf 3',
        'onlineLink': 'https://www.nptel.ac.in/courses/112/104/112104113/',
        'coverColor': 0xFFFFD93D,
        'edition': '5th Edition',
        'tags': ['thermodynamics', 'MECH', 'heat'],
      },
      {
        'title': 'Fluid Mechanics',
        'author': 'R.K. Bansal',
        'subject': 'Civil Engineering',
        'libraryStatus': 'available',
        'location': 'Section E, Shelf 4',
        'onlineLink': 'https://www.nptel.ac.in/courses/112/101/112101265/',
        'coverColor': 0xFF4ECDC4,
        'edition': '9th Edition',
        'tags': ['fluid', 'mechanics', 'CIVIL'],
      },
      {
        'title': 'Control Systems Engineering',
        'author': 'Norman S. Nise',
        'subject': 'Electronics',
        'libraryStatus': 'checked_out',
        'location': 'Section C, Shelf 7',
        'onlineLink': 'https://archive.org/details/ControlSystemsEngineering',
        'coverColor': 0xFFA855F7,
        'edition': '7th Edition',
        'tags': ['control', 'systems', 'ECE', 'EEE'],
      },
      {
        'title': 'Database System Concepts',
        'author': 'Silberschatz & Korth',
        'subject': 'Computer Science',
        'libraryStatus': 'available',
        'location': 'Section B, Shelf 2',
        'onlineLink': 'https://www.db-book.com/',
        'coverColor': 0xFF06B6D4,
        'edition': '7th Edition',
        'tags': ['database', 'SQL', 'DBMS', 'CSE'],
      },
      {
        'title': 'Operating System Concepts',
        'author': 'Abraham Silberschatz',
        'subject': 'Computer Science',
        'libraryStatus': 'available',
        'location': 'Section B, Shelf 3',
        'onlineLink': 'https://os-book.com/',
        'coverColor': 0xFFF59E0B,
        'edition': '10th Edition',
        'tags': ['OS', 'operating systems', 'CSE'],
      },
      {
        'title': 'Strength of Materials',
        'author': 'R.K. Rajput',
        'subject': 'Mechanical',
        'libraryStatus': 'available',
        'location': 'Section D, Shelf 1',
        'onlineLink': 'https://www.nptel.ac.in/courses/112/107/112107147/',
        'coverColor': 0xFFEC4899,
        'edition': '3rd Edition',
        'tags': ['strength', 'materials', 'MECH', 'CIVIL'],
      },
      {
        'title': 'Computer Networks',
        'author': 'Andrew S. Tanenbaum',
        'subject': 'Computer Science',
        'libraryStatus': 'checked_out',
        'location': 'Section B, Shelf 8',
        'onlineLink': 'https://archive.org/details/computernetswork05tane',
        'coverColor': 0xFF84CC16,
        'edition': '5th Edition',
        'tags': ['networks', 'TCP/IP', 'CSE', 'ECE'],
      },
    ];
    for (final bookData in books) {
      batch.set(booksRef.doc(), bookData);
    }
    await batch.commit();
  }

  Future<void> seedGateData() async {
    final batch = _db.batch();
    final gateRef = _db.collection('gate_info');
    final List<Map<String, dynamic>> gates = [
      {
        'branchCode': 'CSE',
        'branchName': 'Computer Science & Engineering',
        'examName': 'GATE CS 2026',
        'eligibility': 'B.E./B.Tech in Computer Science or related discipline',
        'examDate': '2026-02-08',
        'registrationStart': '2025-08-24',
        'registrationDeadline': '2025-09-26',
        'syllabusLink': 'https://gate2026.iitr.ac.in/pages/syllabus.html',
        'officialLink': 'https://gate2026.iitr.ac.in',
        'keyTopics': ['Algorithms', 'Data Structures', 'OS', 'DBMS', 'CN', 'TOC', 'Digital Logic', 'COA'],
        'iconCode': 0xE0EF,
        'colorHex': 0xFF6C63FF,
        'avgCutoff': 28.5,
      },
      {
        'branchCode': 'ECE',
        'branchName': 'Electronics & Communication Engineering',
        'examName': 'GATE EC 2026',
        'eligibility': 'B.E./B.Tech in Electronics & Communication or related',
        'examDate': '2026-02-01',
        'registrationStart': '2025-08-24',
        'registrationDeadline': '2025-09-26',
        'syllabusLink': 'https://gate2026.iitr.ac.in/pages/syllabus.html',
        'officialLink': 'https://gate2026.iitr.ac.in',
        'keyTopics': ['Signals & Systems', 'Control Systems', 'EMT', 'Analog Circuits', 'Communication'],
        'iconCode': 0xE311,
        'colorHex': 0xFF00D9A5,
        'avgCutoff': 25.0,
      },
      {
        'branchCode': 'MECH',
        'branchName': 'Mechanical Engineering',
        'examName': 'GATE ME 2026',
        'eligibility': 'B.E./B.Tech in Mechanical Engineering or equivalent',
        'examDate': '2026-02-15',
        'registrationStart': '2025-08-24',
        'registrationDeadline': '2025-09-26',
        'syllabusLink': 'https://gate2026.iitr.ac.in/pages/syllabus.html',
        'officialLink': 'https://gate2026.iitr.ac.in',
        'keyTopics': ['Thermodynamics', 'Fluid Mechanics', 'Manufacturing', 'SOM', 'Machine Design'],
        'iconCode': 0xE1C2,
        'colorHex': 0xFFFFD93D,
        'avgCutoff': 30.0,
      },
      {
        'branchCode': 'CIVIL',
        'branchName': 'Civil Engineering',
        'examName': 'GATE CE 2026',
        'eligibility': 'B.E./B.Tech in Civil Engineering or equivalent',
        'examDate': '2026-02-08',
        'registrationStart': '2025-08-24',
        'registrationDeadline': '2025-09-26',
        'syllabusLink': 'https://gate2026.iitr.ac.in/pages/syllabus.html',
        'officialLink': 'https://gate2026.iitr.ac.in',
        'keyTopics': ['Structural Analysis', 'Concrete Structures', 'Soil Mechanics', 'Fluid Mechanics'],
        'iconCode': 0xE88A,
        'colorHex': 0xFFFF6B6B,
        'avgCutoff': 27.0,
      },
      {
        'branchCode': 'EEE',
        'branchName': 'Electrical Engineering',
        'examName': 'GATE EE 2026',
        'eligibility': 'B.E./B.Tech in Electrical Engineering or equivalent',
        'examDate': '2026-02-22',
        'registrationStart': '2025-08-24',
        'registrationDeadline': '2025-09-26',
        'syllabusLink': 'https://gate2026.iitr.ac.in/pages/syllabus.html',
        'officialLink': 'https://gate2026.iitr.ac.in',
        'keyTopics': ['Power Systems', 'Control Systems', 'Machines', 'Power Electronics', 'Circuits'],
        'iconCode': 0xE3E7,
        'colorHex': 0xFFA855F7,
        'avgCutoff': 26.5,
      },
      {
        'branchCode': 'CHEM',
        'branchName': 'Chemical Engineering',
        'examName': 'GATE CH 2026',
        'eligibility': 'B.E./B.Tech in Chemical Engineering or equivalent',
        'examDate': '2026-02-01',
        'registrationStart': '2025-08-24',
        'registrationDeadline': '2025-09-26',
        'syllabusLink': 'https://gate2026.iitr.ac.in/pages/syllabus.html',
        'officialLink': 'https://gate2026.iitr.ac.in',
        'keyTopics': ['Process Calculations', 'Thermodynamics', 'Mass Transfer', 'Reaction Engineering'],
        'iconCode': 0xE2BE,
        'colorHex': 0xFF4ECDC4,
        'avgCutoff': 22.0,
      },
    ];
    for (final gateData in gates) {
      batch.set(gateRef.doc(), gateData);
    }
    await batch.commit();
  }
}
