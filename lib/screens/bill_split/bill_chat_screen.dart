// lib/screens/bill_split/bill_chat_screen.dart
// Real-time chat for bill discussions and settlement negotiations

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';

class BillChatScreen extends StatefulWidget {
  final String billId;
  final String billTitle;

  const BillChatScreen({
    super.key,
    required this.billId,
    required this.billTitle,
  });

  @override
  State<BillChatScreen> createState() => _BillChatScreenState();
}

class _BillChatScreenState extends State<BillChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'sender': 'You',
      'message': 'Hey, I\'ve created a bill for the dinner last night',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isMe': true,
    },
    {
      'id': 2,
      'sender': 'John',
      'message': 'Great! How much is my share?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 28)),
      'isMe': false,
    },
    {
      'id': 3,
      'sender': 'You',
      'message': 'The total is ₹2,500. Your share is ₹625',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
      'isMe': true,
    },
    {
      'id': 4,
      'sender': 'Sarah',
      'message': 'Can I settle this tomorrow? Low on cash right now',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 20)),
      'isMe': false,
    },
    {
      'id': 5,
      'sender': 'You',
      'message': 'Sure, no problem!',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 18)),
      'isMe': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill Discussion'),
            Text(
              widget.billTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMessageBubble(message),
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {},
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                message['sender'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryColor : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    Radius.circular(isMe ? 16 : 4),
                bottomRight:
                    Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Text(
              message['message'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('HH:mm').format(message['timestamp']),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'sender': 'You',
          'message': _messageController.text,
          'timestamp': DateTime.now(),
          'isMe': true,
        });
        _messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
