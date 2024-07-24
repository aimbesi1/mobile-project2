import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'database_helper.dart';

class ConversationsListScreen extends StatefulWidget {
  final String currentUserId;

  ConversationsListScreen({required this.currentUserId});

  @override
  _ConversationsListScreenState createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          searchQuery.isNotEmpty
              ? Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: dbHelper.searchUsers(searchQuery),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return Center(child: Text('No users found'));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final userName = userData.containsKey('username') ? userData['username'] : 'No Username';
                    return ListTile(
                      title: Text(userName),
                      onTap: () async {
                        await dbHelper.createConversation(user.id, userName);
                        setState(() {
                          searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    );
                  },
                );
              },
            ),
          )
              : Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: dbHelper.getConversations(widget.currentUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final conversations = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final conversationData = conversation.data() as Map<String, dynamic>;
                    final senderId = conversationData.containsKey('senderId') ? conversationData['senderId'] : '';
                    final recipientId = conversationData.containsKey('recipientId') ? conversationData['recipientId'] : '';
                    final senderName = conversationData.containsKey('senderName') ? conversationData['senderName'] : 'Unknown';
                    final recipientName = conversationData.containsKey('recipientName') ? conversationData['recipientName'] : 'Unknown';

                    final otherUserName = senderId == widget.currentUserId
                        ? recipientName
                        : senderName;

                    return Dismissible(
                      key: Key(conversation.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await dbHelper.deleteConversation(conversation.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Conversation deleted')),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: ListTile(
                        title: Text(otherUserName),
                        subtitle: Text(conversationData.containsKey('lastMessage') ? conversationData['lastMessage'] : ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(conversationId: conversation.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}