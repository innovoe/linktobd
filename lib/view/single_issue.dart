import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:linktobd/model/image_fullscreen.dart';
import '../model/memory.dart';

class SingleIssue extends StatefulWidget {
  const SingleIssue({super.key});

  @override
  State<SingleIssue> createState() => _SingleIssueState();
}

class _SingleIssueState extends State<SingleIssue> {
  var primaryColor = const Color(0xFFB533F1);
  var secondaryColor = const Color(0xFF24CF81);
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;
  Timer? _chatRefreshTimer;
  int lastMessageCount = 0;
  Future<List<Map<String, dynamic>>>? chatFuture;
  Future<Map<String, dynamic>>? issueFuture;

  Map<String, String> statusList = {
    '0': 'Pending',
    '1': 'Processing',
    '2': 'Cancelled',
    '3': 'Resolved'
  };

  @override
  void initState() {
    super.initState();
    issueFuture = getIssue();
    chatFuture = getChatHistory();
    _chatRefreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      checkNewMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> checkNewMessages() async {
    try {
      final response = await Dio().post(
        'https://linktobd.com/appapi/issue_chat',
        data: FormData.fromMap({
          'token': memory.token,
          'issue_id': memory.issueId
        }),
      );

      List<Map<String, dynamic>> newChat = [];
      if (response.data is List) {
        newChat = List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data['messages'] is List) {
        newChat = List<Map<String, dynamic>>.from(response.data['messages']);
      }

      if (newChat.length != lastMessageCount) {
        print('New messages detected: ${newChat.length} vs $lastMessageCount');
        setState(() {
          lastMessageCount = newChat.length;
          chatFuture = Future.value(newChat);
        });
      }
    } catch (e) {
      print('Error checking messages: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final response = await Dio().post(
        'https://linktobd.com/appapi/issue_chat',
        data: FormData.fromMap({
          'token': memory.token,
          'issue_id': memory.issueId
        }),
      );

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data['messages'] is List) {
        return List<Map<String, dynamic>>.from(response.data['messages']);
      }
      return [];
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      await Dio().post(
        'https://linktobd.com/appapi/issue_chat_send',
        data: FormData.fromMap({
          'token': memory.token,
          'issue_id': memory.issueId,
          'message': _messageController.text.trim(),
        }),
      );

      _messageController.clear();

      // Force refresh chat after sending
      final newChat = await getChatHistory();
      setState(() {
        lastMessageCount = newChat.length;
        chatFuture = Future.value(newChat);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildIssueDetails(Map<String, dynamic> issueData) {
    DateTime parsedTime = DateTime.parse(issueData['created'].toString());
    String formattedTime = DateFormat('hh:mm a, d/m/y').format(parsedTime);
    String statusString = statusList[issueData['status']] ?? 'Unknown Status';
    List<String> imageUrls = List<String>.from(issueData['photo_urls'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Created on: $formattedTime',
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        Text(
          'Description:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        const SizedBox(height: 5),
        Text(
          issueData['description'] ?? '',
          style: const TextStyle(fontSize: 16),
        ),
        if (imageUrls.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Uploaded Photos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: imageUrls
                .asMap()
                .map((index, photoUrl) => MapEntry(
              index,
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageFullScreen(
                        imageUrls: imageUrls,
                        initialPage: index,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  photoUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ))
                .values
                .toList(),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Status: $statusString',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ],
    );
  }

  Widget buildChatSection(List<Map<String, dynamic>> chat) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chat.length,
              itemBuilder: (context, index) {
                final message = chat[index];
                final isUser = message['sender'] == 'You';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? primaryColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message['sender'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isUser ? Colors.white : Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('hh:mm a').format(DateTime.parse(message['created'])),
                              style: TextStyle(
                                fontSize: 10,
                                color: isUser ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['message'],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(Icons.send, color: primaryColor),
                  onPressed: isLoading ? null : sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issue Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Issue Details Section
            FutureBuilder<Map<String, dynamic>>(
              future: issueFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return buildIssueDetails(snapshot.data!);
                }
                return const Center(child: Text('No issue data found'));
              },
            ),
            const SizedBox(height: 20),
            // Chat Section
            FutureBuilder<List<Map<String, dynamic>>>(
              future: chatFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return buildChatSection(snapshot.data!);
                }
                return const Center(child: Text('No chat history found'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getIssue() async {
    try {
      var response = await Dio().post(
        'https://linktobd.com/appapi/single_issue',
        data: FormData.fromMap({
          'token': memory.token,
          'issue_id': memory.issueId
        }),
      );
      return response.data;
    } catch (e) {
      print(e);
      return Future.error(e.toString());
    }
  }
}