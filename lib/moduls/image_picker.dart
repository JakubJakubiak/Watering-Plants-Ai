import 'dart:convert';
import 'package:PlantsAI/main.dart';
import 'package:PlantsAI/moduls/chat_screen.dart';
import 'package:PlantsAI/moduls/modern_full_width_button.dart';
import 'package:PlantsAI/utils/gaps.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ImagePickerModule extends StatefulWidget {
  final int counter;
  const ImagePickerModule({Key? key, required this.counter}) : super(key: key);

  @override
  State<ImagePickerModule> createState() => _ImagePickerModuleState();
}

class _ImagePickerModuleState extends State<ImagePickerModule> {
  final timeMilliseconds = const Duration(milliseconds: 250);

  final ImagePicker _picker = ImagePicker();
  // XFile? _image;
  String base64Image = "";
  String? mimeType = "";

  final ScrollController _scrollController = ScrollController();

  bool _isUploading = false;
  int get counter => widget.counter;

  String generatedText = "";
  List<Map<String, dynamic>> generatedHistory = [];

  // Future<void> _pickImage() async {
  //   final pickedImage = await _picker.pickImage(source: ImageSource.camera);
  //   File file = File(pickedImage!.path);
  //   String base64ImageFuncion = base64Encode(await file.readAsBytes());
  //   String? mimeTypeFuncion = lookupMimeType(file.path);

  //   setState(() {
  //     mimeType = mimeTypeFuncion;
  //     base64Image = base64ImageFuncion;
  //   });
  // }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera, requestFullMetadata: true, imageQuality: 80, maxWidth: 800, maxHeight: 800);

    if (pickedImage == null) {
      debugPrint("No image selected.");
      return;
    }

    // String base64ImageFunction = base64Encode(await file.readAsBytes());
    // String? mimeTypeFunction = lookupMimeType(file.path);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(file: pickedImage),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadGeneratedHistory();
  }

  Future<void> _loadGeneratedHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('HistoryChat');
    if (jsonStringList != null) {
      setState(() {
        generatedHistory = jsonStringList.map((jsonString) {
          return jsonDecode(jsonString) as Map<String, dynamic>;
        }).toList();
      });
    }
  }

  Future<void> _saveGenerateHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = generatedHistory.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('HistoryChat', jsonStringList);
  }

  Future<void> _reset() async {
    setState(() {
      // _image = null;
      base64Image = "";
      generatedText = "";
    });
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showFloatingMessage('Text copied to clipboard');
  }

  void shareText(String text) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      text,
      subject: generatedText,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _showFloatingMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueAccent.withOpacity(0.7),
      ),
    );
  }

  Future<void> imagesAnaliz() async {
    if (base64Image.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });

      subtractionPoints();

      try {
        // File file = File(_image!.path);
        // String base64Image = base64Encode(await file.readAsBytes());
        // String? mimeType = lookupMimeType(base64Image);

        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('imagesMobileAnaliz');
        final response = await callable.call(<String, dynamic>{'base64Image': 'data:$mimeType;base64,$base64Image'});
        final description = response.data['descriptionImages'];

        setState(() {
          generatedText = description;

          generatedHistory.insert(0, {
            'base64Image': base64Image,
            'description': description,
          });
          _isUploading = false;
        });
        await _saveGenerateHistory();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: timeMilliseconds,
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });

        _showFloatingMessage('Failed to upload image: $e');
      }
    }
  }

  void subtractionPoints() async {
    CounterModel counterModel = Provider.of<CounterModel>(context, listen: false);
    int counter = counterModel.counter - 2;
    if (counter <= 0) counter = 0;

    counterModel.updateCounter(counter);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImageSection(),
            if (base64Image.isNotEmpty) ...[
              gapH24,
              _buildAnalyzeButton(),
            ],
            if (!_isUploading && generatedText.isNotEmpty) ...[
              gapH24,
              _buildResultSection(),
            ],
          ],
        ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
      ),
    );
  }

  Widget _buildImageSection() {
    return (base64Image.isNotEmpty) ? _buildSelectedImage() : _buildImagePickerPlaceholder();
  }

  Widget _buildSelectedImage() {
    Uint8List imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : Uint8List(0);
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                  ),
                )),
            if (!_isUploading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _reset,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
          ],
        ),
      ).animate().scale(duration: timeMilliseconds),
    );
  }

  Widget _buildImagePickerPlaceholder() {
    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueAccent.withOpacity(0.1),
                Colors.purpleAccent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white24),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 80,
                color: Colors.white70,
              ),
              gapH16,
              Text(
                "Tap to select photo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ).animate().scale(duration: timeMilliseconds),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ModernFullWidthButton(
      onPressed: (counter > 0) ? imagesAnaliz : null,
      isLoading: _isUploading,
      text: 'Analyze Image',
    ).animate().fadeIn(delay: timeMilliseconds);
  }

  Widget _buildResultSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.content_copy_outlined,
                onPressed: () => copyToClipboard(generatedText),
              ),
            ),
            gapW16,
            Expanded(
              child: _buildActionButton(
                icon: Icons.share_outlined,
                onPressed: () => shareText(generatedText),
              ),
            ),
          ],
        ),
        gapH24,
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueAccent.withOpacity(0.1),
                Colors.purpleAccent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            generatedText,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: timeMilliseconds);
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Icon(icon),
    );
  }
}
