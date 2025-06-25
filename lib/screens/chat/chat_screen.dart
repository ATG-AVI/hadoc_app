import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash_chat_2/dash_chat_2.dart' as dash;
import '../../providers/user_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/user_model.dart';
import '../../models/chat_message.dart' as app;
import '../../models/analysis_result.dart';
import '../../utils/theme.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  List<app.ChatMessage> _messages = [];
  List<AnalysisResult> _recentAnalyses = [];
  bool _isLoading = false;
  bool _isDashboardExpanded = true;
  late AnimationController _dashboardAnimationController;
  late Animation<double> _dashboardAnimation;

  @override
  void initState() {
    super.initState();
    _dashboardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dashboardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dashboardAnimationController, curve: Curves.easeInOut),
    );
    _dashboardAnimationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _dashboardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        // Load messages and recent analyses in parallel
        final futures = await Future.wait([
          SupabaseService.instance.getChatMessages(
            userId: user.id,
            otherUserId: widget.otherUser.id,
          ),
          SupabaseService.instance.getUserAnalyses(user.id),
        ]);
        
        setState(() {
          _messages = futures[0] as List<app.ChatMessage>;
          _recentAnalyses = (futures[1] as List<AnalysisResult>).take(3).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading data: $e', Colors.red);
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
        _showSnackBar('Error sending message: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _dashboardAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryTeal, AppTheme.primaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Doctor and Patient Info Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    // Patient Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Consultation Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    
                    // Doctor Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Consulting Doctor',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  'Dr. ${widget.otherUser.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : 'D',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dashboard Toggle and Content
              if (_isDashboardExpanded) ...[
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      // Quick Health Stats
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            // Narrow layout: 2x2 grid
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildQuickStat('Analyses', '${_recentAnalyses.length}', Icons.analytics, Colors.white)),
                                    const SizedBox(width: 8),
                                    Expanded(child: _buildQuickStat('Status', 'Good', Icons.favorite, Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: _buildQuickStat('Last Check', _recentAnalyses.isNotEmpty ? _formatDate(_recentAnalyses.first.createdAt) : 'Never', Icons.schedule, Colors.white)),
                                    const SizedBox(width: 8),
                                    Expanded(child: _buildQuickStat('Risk', 'Low', Icons.security, Colors.white)),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // Wide layout: Single row
                            return Row(
                              children: [
                                Expanded(child: _buildQuickStat('Total Analyses', '${_recentAnalyses.length}', Icons.analytics, Colors.white)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildQuickStat('Health Status', 'Good', Icons.favorite, Colors.white)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildQuickStat('Last Check', _recentAnalyses.isNotEmpty ? _formatDate(_recentAnalyses.first.createdAt) : 'Never', Icons.schedule, Colors.white)),
                              ],
                            );
                          }
                        },
                      ),
                      
                      if (_recentAnalyses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Recent Analysis Summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.analytics, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Latest ECG Analysis',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getConfidenceColor(_recentAnalyses.first.confidenceScore).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(_recentAnalyses.first.confidenceScore * 100).toInt()}%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _recentAnalyses.first.analysisResult.length > 80 
                                    ? '${_recentAnalyses.first.analysisResult.substring(0, 80)}...'
                                    : _recentAnalyses.first.analysisResult,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              // Toggle Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDashboardExpanded = !_isDashboardExpanded;
                  });
                  if (_isDashboardExpanded) {
                    _dashboardAnimationController.forward();
                  } else {
                    _dashboardAnimationController.reverse();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isDashboardExpanded ? 'Hide Details' : 'Show Health Summary',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isDashboardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.9), size: 16),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Now';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. ${widget.otherUser.name}'),
            Text(
              widget.otherUser.specialization ?? 'General Practice',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              _showSnackBar('Video call feature coming soon!', Colors.blue);
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              _showSnackBar('Voice call feature coming soon!', Colors.blue);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard Header
          _buildDashboardHeader(),
          
          // Chat Interface
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading conversation...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey[50]!,
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Chat Messages Area
                        Expanded(
                          child: _messages.isEmpty
                              ? _buildEmptyState()
                              : Column(
                                  children: [
                                    Expanded(
                                      child: dash.DashChat(
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
                                  messageOptions: dash.MessageOptions(
                                    showTime: true,
                                    timeTextColor: Colors.grey[500]!,
                                    containerColor: Colors.white,
                                    textColor: Colors.grey[800]!,
                                    currentUserContainerColor: AppTheme.primaryTeal,
                                    currentUserTextColor: Colors.white,
                                    messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    borderRadius: 16,
                                    spaceWhenAvatarIsHidden: 12,
                                    showOtherUsersAvatar: true,
                                    showCurrentUserAvatar: false,
                                    avatarBuilder: (user, onPressAvatar, onLongPressAvatar) {
                                      return Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.local_hospital,
                                          color: AppTheme.primaryTeal,
                                          size: 16,
                                        ),
                                      );
                                    },
                                  ),
                                        inputOptions: dash.InputOptions(
                                          inputDecoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '',
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          sendButtonBuilder: (onSend) => const SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                    // Typing Indicator
                                    _buildTypingIndicator(),
                                  ],
                                ),
                        ),
                        
                        // Enhanced Input Area
                        _buildChatInput(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Your Consultation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask Dr. ${widget.otherUser.name} about your ECG results\nor any health concerns you may have.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Secure & Confidential',
                  style: TextStyle(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quick Actions
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  // Add attachment functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attachment feature coming soon')),
                  );
                },
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Text Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ask about your ECG results...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (text) => _sendTextMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Send Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.primaryBlue],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _sendTextMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = Provider.of<UserProvider>(context, listen: false).user!;
    final chatMsg = app.ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: user.id,
      receiverId: widget.otherUser.id,
      message: text,
      createdAt: DateTime.now(),
      senderName: user.name,
      senderRole: user.role,
    );

    _messageController.clear();
    _sendMessage(chatMsg);
    
    // Simulate doctor typing response
    _simulateTypingResponse();
  }

  void _simulateTypingResponse() {
    if (_messages.length == 1) { // First message from patient
      setState(() {
        _isTyping = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          
          // Add welcome response
          final welcomeMsg = app.ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: widget.otherUser.id,
            receiverId: Provider.of<UserProvider>(context, listen: false).user!.id,
            message: "Hello! I've reviewed your recent ECG analysis. I'm here to help explain your results and answer any questions you might have about your heart health. What would you like to know?",
            createdAt: DateTime.now(),
            senderName: widget.otherUser.name,
            senderRole: widget.otherUser.role,
          );
          
          setState(() {
            _messages.insert(0, welcomeMsg);
          });
        }
      });
    }
  }

  Widget _buildTypingIndicator() {
    if (!_isTyping) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.local_hospital,
              color: AppTheme.primaryTeal,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dr. ${widget.otherUser.name} is typing',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 