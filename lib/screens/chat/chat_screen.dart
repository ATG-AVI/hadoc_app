import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash_chat_2/dash_chat_2.dart' as dash;
import '../../providers/user_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/user_model.dart';
import '../../models/chat_message.dart' as app;
import '../../utils/theme.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<app.ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        final messages = await SupabaseService.instance.getChatMessages(
          userId: user.id,
          otherUserId: widget.otherUser.id,
        );
        setState(() {
          _messages = messages;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(app.ChatMessage message) async {
    try {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        await SupabaseService.instance.sendMessage(
          senderId: user.id,
          receiverId: widget.otherUser.id,
          message: message.message,
        );
        setState(() {
          _messages.add(message);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    final chatUser = dash.ChatUser(
      id: user.id,
      firstName: user.name,
    );

    final otherChatUser = dash.ChatUser(
      id: widget.otherUser.id,
      firstName: widget.otherUser.name,
    );

    final dashMessages = _messages.map((msg) => dash.ChatMessage(
      user: msg.senderId == user.id ? chatUser : otherChatUser,
      createdAt: msg.createdAt,
      text: msg.message,
    )).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${widget.otherUser.name}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : dash.DashChat(
              currentUser: chatUser,
              onSend: (dash.ChatMessage message) {
                final chatMsg = app.ChatMessage(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  senderId: user.id,
                  receiverId: widget.otherUser.id,
                  message: message.text,
                  createdAt: DateTime.now(),
                  senderName: user.name,
                  senderRole: user.role,
                );
                _sendMessage(chatMsg);
              },
              messages: dashMessages,
              messageOptions: const dash.MessageOptions(
                showTime: true,
                timeTextColor: Colors.grey,
              ),
              inputOptions: dash.InputOptions(
                inputDecoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                sendButtonBuilder: (onSend) => IconButton(
                  onPressed: onSend,
                  icon: Icon(
                    Icons.send,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
    );
  }
} 