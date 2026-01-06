import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../services/openai_service.dart';
import '../../../services/openai_client.dart';

/// AI Chatbot Widget - Floating action button with expandable chat interface
/// Context-aware assistant for Rungroj Car Rental customer support
class AIChatbotWidget extends StatefulWidget {
  const AIChatbotWidget({super.key});

  @override
  State<AIChatbotWidget> createState() => _AIChatbotWidgetState();
}

class _AIChatbotWidgetState extends State<AIChatbotWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatBubble> _messages = [];
  bool _isTyping = false;
  late OpenAIClient _aiClient;

  // System prompt with business context
  static const String _systemPrompt =
      '''คุณคือผู้ช่วยลูกค้าอัจฉริยะของรถเช่าอุดรธานี รุ่งโรจน์คาร์เร้นท์ ให้ตอบคำถามเป็นภาษาไทยที่เป็นมิตรและเป็นประโยชน์

ข้อมูลธุรกิจ:
- ชื่อ: รถเช่าอุดรธานี รุ่งโรจน์คาร์เร้นท์
- ที่อยู่: 79QPF+QQM Chiang Phin, Mueang Udon Thani, Udon Thani 41000
- เบอร์โทร: 086-634-8619, 096-363-8519
- Line ID: @rungroj
- เปิดบริการ: 24 ชั่วโมง

จุดเด่น:
- ไม่ต้องใช้บัตรเครดิต
- บริการรับ-ส่งฟรีทั้งสนามบินและในตัวเมือง
- รถใหม่ สะอาด ตรวจเช็คคุณภาพก่อนส่งมอบ
- แอดมินใจดี คุยง่าย

ราคาเช่า:
- ราคาพื้นฐาน: 800 บาท/วัน
- ส่วนลด 25% สำหรับการเช่า 7 วันขึ้นไป
- มีโปรโมชั่นพิเศษตามช่วงเวลา

รถที่มีให้บริการ:
- รถเก๋ง (Sedan): สำหรับเดินทางในเมือง
- รถ SUV: สำหรับครอบครัวและเดินทางไกล
- รถตู้: สำหรับกลุ่มใหญ่ 10-12 ที่นั่ง
- รถกระบะ: สำหรับขนของหรือเดินทางทุรกันดาร

คุณสามารถช่วยเรื่อง:
1. ตอบคำถามเกี่ยวกับราคา รุ่นรถ และความพร้อม
2. แนะนำรถที่เหมาะสมตามความต้องการ
3. อธิบายเงื่อนไขการเช่าและการชำระเงิน
4. ให้ข้อมูลการติดต่อและสถานที่รับรถ
5. ช่วยเหลือทั่วไปเกี่ยวกับบริการ

สำคัญ: หากลูกค้าต้องการจองรถจริง ให้แนะนำให้ติดต่อโดยตรงผ่าน:
- โทร: 086-634-8619 หรือ 096-363-8519
- Messenger: m.me/553199731216723
- LINE: @rungroj
''';

  @override
  void initState() {
    super.initState();
    try {
      _aiClient = OpenAIClient(OpenAIService().dio);
      _addWelcomeMessage();
    } catch (e) {
      debugPrint('Error initializing AI client: $e');
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatBubble(
          message:
              'สวัสดีครับ! 👋\n\nผมคือผู้ช่วยอัจฉริยะของรถเช่าอุดรธานี\n\nมีอะไรให้ช่วยเหลือไหมครับ? เช่น:\n• สอบถามราคาและรุ่นรถ\n• แนะนำรถที่เหมาะสม\n• ข้อมูลการจองและชำระเงิน\n• สถานที่รับรถและเวลาทำการ',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    HapticFeedback.selectionClick();

    setState(() {
      _messages.add(ChatBubble(
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      // Build conversation history
      final messages = [
        ChatMessage(role: 'system', content: _systemPrompt),
        ..._messages.where((m) => m.message.isNotEmpty).map((m) => ChatMessage(
              role: m.isUser ? 'user' : 'assistant',
              content: m.message,
            )),
      ];

      // Stream response
      final responseBuffer = StringBuffer();
      ChatBubble? currentBubble;

      await for (final chunk in _aiClient.streamContentOnly(
        messages: messages,
        model: 'gpt-3.5-turbo',
      )) {
        responseBuffer.write(chunk);

        setState(() {
          if (currentBubble == null) {
            currentBubble = ChatBubble(
              message: responseBuffer.toString(),
              isUser: false,
              timestamp: DateTime.now(),
            );
            _messages.add(currentBubble!);
          } else {
            final index = _messages.indexOf(currentBubble!);
            if (index != -1) {
              _messages[index] = ChatBubble(
                message: responseBuffer.toString(),
                isUser: false,
                timestamp: currentBubble!.timestamp,
              );
            }
          }
        });

        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatBubble(
          message:
              'ขออภัยครับ เกิดข้อผิดพลาดในการตอบกลับ\n\nกรุณาลองใหม่อีกครั้ง หรือติดต่อโดยตรงที่:\n📞 086-634-8619\n💬 LINE: @rungroj',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      debugPrint('Error sending message: $e');
    } finally {
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child:
          _isExpanded ? _buildExpandedChat(theme) : _buildFloatingButton(theme),
    );
  }

  Widget _buildFloatingButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _toggleChat,
      backgroundColor: theme.colorScheme.primary,
      icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      label: const Text(
        'AI ผู้ช่วย',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExpandedChat(ThemeData theme) {
    return Container(
      width: 90.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI ผู้ช่วย',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'รถเช่าอุดรธานี',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _toggleChat,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(theme);
                }
                return _messages[index].build(theme);
              },
            ),
          ),

          // Input
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 2.w),
                Material(
                  color: _messageController.text.trim().isNotEmpty && !_isTyping
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(25),
                  child: InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      child: Icon(
                        Icons.send,
                        color: _messageController.text.trim().isNotEmpty &&
                                !_isTyping
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
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

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(theme),
                SizedBox(width: 1.w),
                _buildDot(theme, delay: 200),
                SizedBox(width: 1.w),
                _buildDot(theme, delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(ThemeData theme, {int delay = 0}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () => Future.delayed(Duration(milliseconds: delay)),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Chat bubble model for messages
class ChatBubble {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatBubble({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  Widget build(ThemeData theme) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        constraints: BoxConstraints(maxWidth: 70.w),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser ? Colors.white : theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
