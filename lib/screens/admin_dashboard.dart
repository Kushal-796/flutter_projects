
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _updateRequest(String requestId, String bookId, String status) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('lending_requests').doc(requestId).update({
      'status': status,
    });

    if (status == 'approved') {
      await firestore.collection('books').doc(bookId).update({
        'isAvailable': false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('lending_requests').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data();
              return ListTile(
                title: Text("Book ID: ${data['bookId']}"),
                subtitle: Text("User ID: ${data['userId']}
Status: ${data['status']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateRequest(request.id, data['bookId'], 'approved'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateRequest(request.id, data['bookId'], 'rejected'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
