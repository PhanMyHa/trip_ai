import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


// Mock Chat Models
class ChatUser {
  final String id;
  final String name;
  final String avatarUrl;

  ChatUser({required this.id, required this.name, required this.avatarUrl});
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

final mockChatUsers = [
  ChatUser(
      id: 'P1',
      name: 'Resort Đồi Thông',
      avatarUrl: 'https://placehold.co/50x50/81B622/FFFFFF?text=RDT'),
  ChatUser(
      id: 'P2',
      name: 'Agent Booking Vé',
      avatarUrl: 'https://placehold.co/50x50/96CEB4/3C3C3C?text=ABV'),
  ChatUser(
      id: 'P3',
      name: 'Hỗ trợ Khách hàng',
      avatarUrl: 'https://placehold.co/50x50/F7B733/3C3C3C?text=HT'),
];

final mockMessages = [
  ChatMessage(
      text: 'Chào bạn, tôi muốn hỏi về phòng view biển vào cuối tuần này.',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 5))),
  ChatMessage(
      text: 'Chào quý khách, chúng tôi còn trống loại phòng Deluxe. Quý khách có thể xem ưu đãi tại đây.',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 3))),
  ChatMessage(
      text: 'Tuyệt vời! Tôi sẽ xem xét và đặt ngay. Cảm ơn.',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 1))),
];

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin Nhắn (Chat)'),
      ),
      body: ListView.builder(
        itemCount: mockChatUsers.length,
        itemBuilder: (context, index) {
          final chatUser = mockChatUsers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chatUser.avatarUrl),
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            ),
            title: Text(
              chatUser.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${chatUser.name == 'Resort Đồi Thông' ? 'Tuyệt vời! Tôi sẽ xem xét...' : 'Bạn có cần hỗ trợ gì không?'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              '${index + 1}p',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(user: chatUser),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final ChatUser user;

  const ChatDetailScreen({super.key, required this.user});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.user.avatarUrl),
              radius: 18,
            ),
            const SizedBox(width: 8),
            Text(widget.user.name),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.phone_rounded), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Hiển thị tin nhắn mới nhất ở dưới cùng
              itemCount: mockMessages.length,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemBuilder: (context, index) {
                final message = mockMessages[mockMessages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  // Bubble tin nhắn
  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final color = message.isMe ? AppColors.primaryBlue : Colors.grey.shade200;
    final textColor = message.isMe ? AppColors.textLight : AppColors.textDark;
    final alignment =
        message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.circular(20);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: message.isMe
              ? borderRadius.copyWith(bottomRight: const Radius.circular(4))
              : borderRadius.copyWith(bottomLeft: const Radius.circular(4)),
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          message.text,
          style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
        ),
      ),
    );
  }

  // Thanh nhập tin nhắn
  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_rounded, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primaryBlue),
            onPressed: () {
              // Mock send message
              if (_controller.text.isNotEmpty) {
                _controller.clear();
                // Logic send message...
              }
            },
          ),
        ],
      ),
    );
  }
}