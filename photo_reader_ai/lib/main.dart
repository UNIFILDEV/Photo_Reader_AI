import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageDescriptionPage(),
    );
  }
}

class ImageDescriptionPage extends StatefulWidget {
  @override
  _ImageDescriptionPageState createState() => _ImageDescriptionPageState();
}

class _ImageDescriptionPageState extends State<ImageDescriptionPage> {
  final ImagePicker _picker = ImagePicker();
  late FlutterTts _flutterTts;
  String? _description;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _captureOrPickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tirar Foto"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
                  if (imageFile != null) {
                    await _processImage(File(imageFile.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Selecionar da Galeria"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (imageFile != null) {
                    await _processImage(File(imageFile.path));
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    final description = await _getDescription(imageFile);

    setState(() {
      _isLoading = false;
      if (description != null) {
        _selectedImage = imageFile;
        _description = description;
      }
    });

    if (description != null) {
      await _speak(description);
    }
  }

  Future<String?> _getDescription(File imageFile) async {
    final apiKey = "AIzaSyAZ4YBfvklEuNYJyfFMnLaOUKtLFAH36SQ";
    final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "O que é essa foto?"},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image,
                },
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]['content']?['parts']
          ?.map((part) => part['text'])
          .join(" ");
    } else {
      print("Erro na API: ${response.body}");
      return null;
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Reader AI"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _captureOrPickImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Adicionar Foto"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 16.0),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
              if (_selectedImage != null)
                Column(
                  children: [
                    Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              if (_description != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
