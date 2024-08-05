// import 'package:PlantsAI/moduls/chat/CameraButton.dart';
import 'package:PlantsAI/moduls/chat/chat_screen.dart';
import 'package:PlantsAI/moduls/payment/paymentrevenuecat.dart';
import 'package:PlantsAI/moduls/payment/subscribe_Button%20.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      MaterialPageRoute(builder: (context) => PaywallView(offering: offering)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int tokens = Provider.of<int>(context);

    return Scaffold(
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          if (isPro)
            const Spacer(flex: 1)
          else ...[
            const Spacer(flex: 1),
            SizedBox(
              width: 300,
              child: SubscribeButton(
                isPro: isPro,
                onContinuePlaying: onContinuePlaying,
              ),
            ),
            const SizedBox(height: 50),
          ],
          Container(
            width: 300,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(width: 2, color: Theme.of(context).dividerColor),
              // color: Theme.of(context).cardColor,
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
            child: (tokens > 0 || widget.isProlocal)
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
                        onTap: () async {
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
                              debugPrint("Cancelled.");
                              return;
                            }

                            final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
                            final chat = await chatNotifier.createChat('${files?.path}', "What do you see in the picture?");

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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.camera,
                              size: 60,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).camera,
                            ),
                          ],
                        ),
                      )),
                      // Text(AppLocalizations.of(context).title),
                      // Text(AppLocalizations.of(context).camera),
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
                        size: 100,
                        color: Color.fromARGB(179, 213, 36, 36),
                      ),
                      onPressed: () {
                        _showPaywallIfNeeded();
                      },
                    ),
                    const Text(
                      "You have 0 usage, watch an ad or subscribe",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    )
                  ]),
          ),
          const Spacer()
        ]),
      ),
    );
  }
}
