import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // Ensure this is properly initialized for your platform
  );
  runApp(DegreeManagementApp());
}

class DegreeManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Degree Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: DegreeListPage(),
    );
  }
}

class Degree {
  String id;
  String name;
  String faculty;
  String duration;
  String startYear;
  String endYear;

  Degree({
    required this.id,
    required this.name,
    required this.faculty,
    required this.duration,
    required this.startYear,
    required this.endYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'faculty': faculty,
      'duration': duration,
      'startYear': startYear,
      'endYear': endYear,
    };
  }

  static Degree fromMap(String id, Map<String, dynamic> map) {
    return Degree(
      id: id,
      name: map['name'],
      faculty: map['faculty'],
      duration: map['duration'],
      startYear: map['startYear'],
      endYear: map['endYear'],
    );
  }
}

class DegreeListPage extends StatefulWidget {
  @override
  _DegreeListPageState createState() => _DegreeListPageState();
}

class _DegreeListPageState extends State<DegreeListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _deleteDegree(String id) async {
    try {
      await _firestore.collection('degrees').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Degree deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete degree'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Degree Management')),
      body: StreamBuilder(
        stream: _firestore.collection('degrees').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var degrees =
              snapshot.data!.docs
                  .map(
                    (doc) => Degree.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList();

          return degrees.isEmpty
              ? Center(child: Text('No degrees available'))
              : ListView.builder(
                itemCount: degrees.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    child: ListTile(
                      title: Text(degrees[index].name),
                      subtitle: Text(
                        "Faculty: ${degrees[index].faculty}\nDuration: ${degrees[index].duration} years\nStart Year: ${degrees[index].startYear}\nEnd Year: ${degrees[index].endYear}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDegree(degrees[index].id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddDegreePage()),
            ),
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddDegreePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController startYearController = TextEditingController();
  final TextEditingController endYearController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addDegree(BuildContext context) async {
    if (nameController.text.isNotEmpty &&
        facultyController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        startYearController.text.isNotEmpty &&
        endYearController.text.isNotEmpty) {
      try {
        await _firestore.collection('degrees').add({
          'name': nameController.text,
          'faculty': facultyController.text,
          'duration': durationController.text,
          'startYear': startYearController.text,
          'endYear': endYearController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Degree added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add degree'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Degree')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Degree Name'),
            ),
            TextField(
              controller: facultyController,
              decoration: InputDecoration(labelText: 'Faculty Name'),
            ),
            TextField(
              controller: durationController,
              decoration: InputDecoration(labelText: 'Duration (Years)'),
            ),
            TextField(
              controller: startYearController,
              decoration: InputDecoration(labelText: 'Start Year'),
            ),
            TextField(
              controller: endYearController,
              decoration: InputDecoration(labelText: 'End Year'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addDegree(context),
              child: Text('Add Degree'),
            ),
          ],
        ),
      ),
    );
  }
}
