import 'package:PlantsAI/moduls/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Plant Identification')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Select Plant Image'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final imagePicker = ImagePicker();
            final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null && context.mounted) {
              final chat = await context.read<ChatNotifier>().createChat(
                pickedFile.path,
                "What plant is in the photo?"
              );
               navigator.push(MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chat.id,
                  isNewChat: true,
                  imagePath: pickedFile.path,
                ),
              ));
            }
          },
        ),
      ),
    );
  }
}