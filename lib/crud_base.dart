import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CrudBase extends StatefulWidget {
  const CrudBase({Key? key}) : super(key: key);

  @override
  State<CrudBase> createState() => _CrudBaseState();
}

class _CrudBaseState extends State<CrudBase> {
  final TextEditingController _matricNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  Future<void> create([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _matricNumberController.text = documentSnapshot['name'];
      _nameController.text = documentSnapshot['matric'].toUpperCase();
      _departmentController.text = documentSnapshot['Department'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'FullName'),
                ),
                TextField(
                  controller: _matricNumberController,
                  decoration: const InputDecoration(labelText: 'Matric Number'),
                ),
                TextField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String matric = _matricNumberController.text;
                    final String department = _departmentController.text;
                    if (matric != null) {
                      await products.add({
                        "Name": name,
                        "Matric": matric,
                        "Department": department
                      });
                      _nameController.text = '';
                      _matricNumberController.text = '';
                      _departmentController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('create'),
                )
              ],
            ),
          );
        });
  }

  Future<void> _updateOnClick([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _matricNumberController.text = documentSnapshot['Name'];
      _nameController.text =
          documentSnapshot['Matric'].toString().toUpperCase();
      _departmentController.text =
          documentSnapshot['Department'].toString().toUpperCase();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'FullName'),
                ),
                TextField(
                  controller: _matricNumberController,
                  decoration: const InputDecoration(labelText: 'Matric Number'),
                ),
                TextField(
                  controller: _departmentController,
                  decoration:
                      const InputDecoration(labelText: 'Name of Department'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String matric = _matricNumberController.text;
                    final String department = _departmentController.text;
                    if (matric != null) {
                      await products.doc(documentSnapshot!.id).update({
                        "Name": name,
                        "Matric": matric,
                        "Department": department
                      });
                      _nameController.text = '';
                      _matricNumberController.text = '';
                      _departmentController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('update'),
                )
              ],
            ),
          );
        });
  }

  Future<void> delete(String productId) async {
    await products.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Firebase Tutorial'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: products.snapshots(), //build Connection
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        documentSnapshot['Name'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        documentSnapshot['Matric'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      leading: Text(documentSnapshot['Department']
                          .toString()
                          .toUpperCase()),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateOnClick(documentSnapshot),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => delete(documentSnapshot.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        },
      ),
      // Add New Products or new account name to firebase
      floatingActionButton: FloatingActionButton(
        onPressed: () => create(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
