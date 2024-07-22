import 'dart:io';

// import 'package:PlantsAI/moduls/chat/CameraButton.dart';
import 'package:PlantsAI/moduls/chat/chat_screen.dart';
import 'package:PlantsAI/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';
// import 'package:camera/camera.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final imagePicker = ImagePicker();
  final timeMilliseconds = const Duration(milliseconds: 250);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Plant Identification')),
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   colors: [
                //     Colors.blueAccent.withOpacity(0.1),
                //     Colors.purpleAccent.withOpacity(0.1),
                //   ],
                // ),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(width: 2, color: Colors.white70),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 80,
                        color: Colors.white70,
                      ),
                      onPressed: () async {
                        try {
                          final navigator = Navigator.of(context);
                          final pickedFile = await imagePicker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                            maxWidth: 800,
                            maxHeight: 800,
                          );

                          if (pickedFile != null && context.mounted) {
                            final chat = await context.read<ChatNotifier>().createChat(pickedFile.path, "What plant is in the photo?");

                            navigator.push(MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chat.id,
                                isNewChat: true,
                                imagePath: pickedFile.path,
                              ),
                            ));
                          }
                        } catch (e, stackTrace) {
                          print('Error in onPressed: $e');
                          print('Stack trace: $stackTrace');
                        }
                      }),
                  const VerticalDivider(
                    thickness: 2,
                    color: Colors.white70,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.white70,
                    ),
                    onPressed: () async {
                      XFile? files;
                      try {
                        final AssetEntity? pickedAsset = await CameraPicker.pickFromCamera(
                          context,
                          pickerConfig: CameraPickerConfig(
                            enableRecording: false,
                            enablePinchToZoom: true,
                            resolutionPreset: ResolutionPreset.medium,
                            imageFormatGroup: ImageFormatGroup.jpeg,
                            preferredLensDirection: CameraLensDirection.back,
                            textDelegate: const EnglishCameraPickerTextDelegate(),
                            theme: ThemeData(
                              colorScheme: const ColorScheme.dark().copyWith(secondary: Colors.black),
                            ),
                            onXFileCaptured: (XFile capturedFile, CameraPickerViewType viewType) {
                              print('XFile captured: ${capturedFile.path}');
                              files = capturedFile;
                              Navigator.of(context).pop();
                              return true;
                            },
                          ),
                        );
                        // if (pickedAsset == null) {
                        //   debugPrint("cted.");
                        //   return;
                        // }

                        if (files == null) {
                          debugPrint("cted.");
                          return;
                        }

                        // final file = await pickedAsset.file;
                        // final String file = '${files?.path}';

                        // if (file == null) {
                        //   debugPrint("Failed to get file from asset.");
                        //   return;
                        // }

                        // debugPrint('Image selected: ${files?.path}');

                        final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
                        final chat = await chatNotifier.createChat('${files?.path}', "What plant is in the photo?");

                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: chat.id,
                              isNewChat: true,
                              imagePath: files?.path,
                            ),
                          ),
                        );
                      } catch (e, stackTrace) {
                        debugPrint('Error in image picking: $e');
                        debugPrint('Stack trace: $stackTrace');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('An error occurred while picking the image.')),
                        );
                      }
                    },
                  )
                ],
              )),
        ],
      )),
    );
  }
}
