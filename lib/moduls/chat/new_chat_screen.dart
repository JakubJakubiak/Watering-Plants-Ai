import 'dart:ffi';
import 'dart:io';

// import 'package:PlantsAI/moduls/chat/CameraButton.dart';
import 'package:PlantsAI/moduls/chat/chat_screen.dart';
import 'package:PlantsAI/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:PlantsAI/moduls/game_over_dialog.dart';

class NewChatScreen extends StatefulWidget {
  final bool isProlocal;
  const NewChatScreen({super.key, this.isProlocal = false});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final imagePicker = ImagePicker();
  get isPro => widget.isProlocal;
  final timeMilliseconds = const Duration(milliseconds: 250);

  // final InAppReview inAppReview = InAppReview.instance;

  // openRatingDialog() async {
  //   print("Rozpoczęcie funkcji openRatingDialog");

  //   try {
  //     bool isAvailable = await inAppReview.isAvailable();
  //     print("isAvailable: $isAvailable");
  //     await inAppReview.openStoreListing(
  //       appStoreId: 'com.inu.plantsai',
  //     );

  //     if (isAvailable) {
  //       print("InAppReview jest dostępne");
  //       await inAppReview.requestReview();
  //       print("Wywołano requestReview");
  //     } else {
  //       print("InAppReview nie jest dostępne, otwieram stronę w sklepie");
  //       await inAppReview.openStoreListing(
  //         appStoreId: 'com.inu.plantsai',
  //       );
  //     }
  //   } catch (e) {
  //     print("Wystąpił błąd: $e");
  //   }

  //   print("Zakończenie funkcji openRatingDialog");
  // }

  @override
  Widget build(BuildContext context) {
    final int tokens = Provider.of<int>(context);
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
            child: (tokens > 0 || isPro)
                ? Row(
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
                                  files = capturedFile;
                                  Navigator.of(context).pop();
                                  return true;
                                },
                              ),
                            );

                            if (files == null) {
                              debugPrint("cted.");
                              return;
                            }

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
                  )
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        size: 200,
                        color: Color.fromARGB(179, 213, 36, 36),
                      ),
                      onPressed: () {
                        //   Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => const GameOverDialog(
                        //       isPro: false,
                        //       score: 0,
                        //       onContinuePlaying: null,
                        //     ),
                        //   ));

                        // showGameOverDialog();
                      },
                    ),
                    const Text(
                      "You have 0 usage, watch an ad or subscribe",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    )
                  ]),
          ),
        ],
      )),
    );
  }
}
