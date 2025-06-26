import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StepChat Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: data['profilePicUrl'] != ''
                            ? NetworkImage(data['profilePicUrl'])
                            : null,
                        child: data['profilePicUrl'] == '' ? Icon(Icons.person) : null,
                      ),
                      title: Text(data['username'] ?? 'Unknown'),
                      subtitle: Text(
                        DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
                            .toLocal()
                            .toString()
                            .split('.')[0],
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    if (data['imageUrl'] != null && data['imageUrl'] != '')
                      Image.network(data['imageUrl']),
                    if (data['caption'] != null)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(data['caption']),
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
