import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'secrets.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Photo_Reader_AI/helpers/connectivity_helper.dart';

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
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  String? _prompt;
  String? _description;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isCameraPreviewVisible = false;
  bool _isFlashOn = true;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _clearAnalise() async {
    _flutterTts.stop();
    _description = null;
    _selectedImage = null;
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    } else {
      _showErrorNotification('Permissão de câmera não concedida');
      await _speak('Permissão de câmera não concedida');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
      );
      await _cameraController?.initialize();
      setState(() {});
    } catch (e) {
      _showErrorNotification("Erro ao inicializar câmera: $e");
      await _speak("Erro ao inicializar câmera: $e");
    }
  }

  Future<void> _captureImage() async {
    _clearAnalise();
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      await _processImage(File(imageFile.path));
    }
    _hideCameraPreview();
  }

  Future<void> _captureImageAuto() async {
    _clearAnalise();
    if (!(_cameraController?.value.isInitialized ?? false)) {
      _hideCameraPreview();
      _showErrorNotification("Câmera não está inicializada.");
      await _speak("Câmera não está inicializada, verifique as permissões de camera do app.");
      return;
    }
    try {
      if(!_isCameraPreviewVisible){
      _toggleCameraPreview();
      }
      if(_isFlashOn){
        _toggleFlash();
      }
      await Future.delayed(Duration(milliseconds: 1200));
      final XFile imageFile = await _cameraController!.takePicture();
      await _cameraController?.setFlashMode(FlashMode.off);
      _hideCameraPreview();
      setState(() {
        _isLoading = true;
      });
      await _processImage(File(imageFile.path));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _hideCameraPreview();
      _showErrorNotification("Erro ao capturar imagem: $e");
      await _speak("Erro ao capturar imagem: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    _clearAnalise();
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      await _processImage(File(imageFile.path));
    }
    _hideCameraPreview();
  }

  Future<void> _processImage(File imageFile) async {
    bool isConnected = await ConnectivityHelper.checkConnection(context);
    if (!isConnected) {
      _showErrorNotification('Verifique sua conexão com a internet.');
      await _speak('Verifique sua conexão com a internet.');
      _isLoading = false;
      return;
    }

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
    } else {
      _showErrorNotification('Não foi possível obter a descrição');
      await _speak('Não foi possível obter a descrição');
    }
  }

  Future<String?> _getDescription(File imageFile) async {
    setState(() {
      _prompt = _prompt ?? "O que é essa foto";
    });
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
              {"text": "$_prompt ? Favor responda em Português-BR"},
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
    setState(() {
      _prompt = null;
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]['content']?['parts']
          ?.map((part) => part['text'])
          .join(" ")
          .replaceAll(RegExp(r'[`*]'), '');
    } else {
      _showErrorNotification("Erro na API: ${response.body}");
      await _speak("Erro na API");
      return null;
    }
  }

  void _showErrorNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.speak(text);
  }

  void _toggleCameraPreview() {
    setState(() {
      if (!_isCameraPreviewVisible) {
      _clearAnalise();
      }
      _isCameraPreviewVisible = !_isCameraPreviewVisible;
    });
  }

  void _hideCameraPreview() {
    setState(() {
      _isCameraPreviewVisible = false;
    });
  }

  Future<void> _toggleIconFlash() async {
    if (_cameraController?.value.isInitialized ?? false) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }
  
  Future<void> _toggleFlash() async {
     if (_cameraController?.value.isInitialized ?? false) {
      if (_isFlashOn) {
        await _cameraController?.setFlashMode(FlashMode.torch);
      } else {
        await _cameraController?.setFlashMode(FlashMode.off);
      }
    }
  }

  Future<void> _editPrompt() async {
    String? newPrompt = '';
    String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Prompt"),
        content: TextField(
          onChanged: (value) {
            newPrompt = value; 
          },
          decoration: InputDecoration(
            hintText: "Digite um novo prompt...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(newPrompt);
            },
            child: Text("Salvar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _prompt = result;
      });
    }
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          child: AppBar(
            title: Text(
              "Photo Reader AI",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFFFF6D00),
            leading: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () async {
                 _editPrompt();
              },
              tooltip: 'Editar',
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isCameraPreviewVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if(!_isLoading)
                    _toggleCameraPreview();
                },
                tooltip: _isCameraPreviewVisible ? 'Ocultar Preview' : 'Visualizar Preview',
              ),
             IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: _toggleIconFlash,
                tooltip: _isFlashOn ? 'Desligar Flash' : 'Ligar Flash',
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF202020),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isCameraPreviewVisible && (_cameraController?.value.isInitialized ?? false))
            Expanded(
              child: CameraPreview(_cameraController!),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_selectedImage != null || _description != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    if (_description != null)
                    Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only( top: 10.0, left: 10.0, right: 10.0, bottom: 24.0, ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFD14000),
                              blurRadius: 12.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _description!,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        child: BottomAppBar(
          color: const Color(0xFFFF6D00),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () async {
                  if(!_isLoading)
                  _hideCameraPreview();
                  await _pickFromGallery();
                },
                icon: const Icon(
                  Icons.photo_library,
                  size: 48,
                  color: Colors.white,
                ),
                tooltip: "Selecionar da Galeria",
              ),
              IconButton(
                onPressed: () async {
                  if(!_isLoading)
                  await _captureImageAuto();
                },
                icon: const Icon(
                  Icons.camera,
                  size: 48,
                  color: Colors.white,
                ),
                tooltip: "Captura Automática",
              ),
              IconButton(
                onPressed: () async{
                  if(!_isLoading)
                  await _captureImage();
                },
                icon: const Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: Colors.white,
                ),
                tooltip: "Tirar Foto",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
