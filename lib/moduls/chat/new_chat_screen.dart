// import 'package:plantsai/moduls/chat/CameraButton.dart';
import 'package:plantsai/moduls/chat/chat_screen.dart';
import 'package:plantsai/moduls/data_jeson/data_Visulisation%20.dart';
import 'package:plantsai/moduls/payment/paymentrevenuecat.dart';
import 'package:plantsai/moduls/payment/subscribe_Button%20.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:plantsai/providers/chat_notifier.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:plantsai/languages/i10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NewChatScreen extends StatefulWidget {
  final bool isProlocal;
  final void Function(BuildContext dialogContext) onContinuePlaying;
  const NewChatScreen({super.key, this.isProlocal = false, required this.onContinuePlaying});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final imagePicker = ImagePicker();
  get isPro => widget.isProlocal;
  get onContinuePlaying => widget.onContinuePlaying;

  final timeMilliseconds = const Duration(milliseconds: 250);

  _showPaywallIfNeeded() async {
    final navigator = Navigator.of(context);
    Offerings offerings = await Purchases.getOfferings();
    final offering = offerings.current;

    if (offering == null) return;

    navigator.push(
      MaterialPageRoute(builder: (context) => PaywallView(offering: offering, loadingX: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int tokens = Provider.of<int>(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 🌄 Gradientowe tło
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1a1a2e),
                      Color(0xFF16213e),
                      Color(0xFF0f3460),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // if (!isPro) ...[
                        //   const SizedBox(height: 10),
                        //   GestureDetector(
                        //     onTap: () => _showPaywallIfNeeded(),
                        //     child: SizedBox(
                        //       width: 150,
                        //       child: Card(
                        //         color: const Color(0xFFFFD700),
                        //         clipBehavior: Clip.antiAlias,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(12.0),
                        //         ),
                        //         elevation: 6.0,
                        //         shadowColor: Colors.black54,
                        //         child: Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             Padding(
                        //               padding: EdgeInsets.all(8.0),
                        //               child: Text(
                        //                 AppLocalizations.of(context).subscribe ?? "",
                        //                 style: const TextStyle(
                        //                   color: Colors.black,
                        //                   fontSize: 18.0,
                        //                   fontWeight: FontWeight.bold,
                        //                 ),
                        //                 textAlign: TextAlign.center,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        //   const SizedBox(height: 10),
                        // ],
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 300,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  width: 2,
                                  color: Theme.of(context).dividerColor,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.withOpacity(0.2),
                                    Colors.purpleAccent.withOpacity(0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: (tokens > 0 || isPro)
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              try {
                                                final navigator = Navigator.of(context);
                                                final pickedFile = await imagePicker.pickImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 90,
                                                  maxWidth: 1024,
                                                  maxHeight: 1024,
                                                );

                                                final imagescrypt = await _imageTrimming(pickedFile);
                                                if (imagescrypt != null && context.mounted) {
                                                  final chat = await context.read<ChatNotifier>().createChat(imagescrypt.path, "What plant is in the photo?");

                                                  navigator.push(MaterialPageRoute(
                                                    builder: (context) => ChatScreen(
                                                      chatId: chat.id,
                                                      isNewChat: true,
                                                      imagePath: imagescrypt.path,
                                                      onContinuePlaying: onContinuePlaying,
                                                    ),
                                                  ));
                                                }
                                              } catch (e, stackTrace) {
                                                print('Error in onPressed: $e');
                                                print('Stack trace: $stackTrace');
                                              }
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  LucideIcons.imagePlus,
                                                  size: 60,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  AppLocalizations.of(context).gallery,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 2,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _handleCameraCapture(context, onContinuePlaying),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(LucideIcons.camera, size: 60),
                                                const SizedBox(height: 8),
                                                Text(AppLocalizations.of(context).camera),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                          ),
                                          child: const Icon(
                                            Icons.cancel_outlined,
                                            size: 100,
                                            color: Color.fromARGB(179, 213, 36, 36),
                                          ),
                                          onPressed: _showPaywallIfNeeded,
                                        ),
                                        const Text(
                                          "You have 0 usage, watch an ad or subscribe",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          height: 320,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF0f3460),
                                width: 2,
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1a1a2e), Color(0xFF0f3460)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: DataVisulisation(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _handleCameraCapture(BuildContext context, onContinuePlaying) async {
  try {
    final XFile? capturedFile = await _captureImage(context);
    if (capturedFile != null) {
      await _processCapture(context, capturedFile, onContinuePlaying);
    } else {
      _showSnackBar(context, 'Image capture cancelled.');
    }
  } catch (e) {
    _handleError(context, e);
  }
}

Future<XFile?> _captureImage(BuildContext context) async {
  XFile? capturedFile;
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
      onXFileCaptured: (XFile file, CameraPickerViewType _) {
        capturedFile = file;
        Navigator.of(context).pop();
        return true;
      },
    ),
  );
  final imagescrypt = await _imageTrimming(capturedFile);
  return imagescrypt;
}

Future<XFile?> _imageTrimming(XFile? capturedFile) async {
  if (capturedFile != null) {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: capturedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxWidth: 500,
      maxHeight: 500,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );
    if (croppedFile != null) {
      return XFile(croppedFile.path);
    }
  }
  return null;
}

Future<void> _processCapture(BuildContext context, XFile capturedFile, onContinuePlaying) async {
  final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
  final chat = await chatNotifier.createChat(capturedFile.path, "What do you see in the picture?");

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatId: chat.id,
        isNewChat: true,
        imagePath: capturedFile.path,
        onContinuePlaying: onContinuePlaying,
      ),
    ),
  );
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void _handleError(BuildContext context, dynamic error) {
  debugPrint('Error in image capture: $error');
  _showSnackBar(context, 'An error occurred while capturing the image.');
}
