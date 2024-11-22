import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart'; // Importando a biblioteca de áudio

void main() {
  runApp(VisionApp());
}

class VisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  FlutterTts _flutterTts = FlutterTts();
  Database? _database;
  List<Map> _historico = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  _initializeDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/vision_history.db';
    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE IF NOT EXISTS history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT,
          imagePath TEXT,
          audioPath TEXT
        )
      ''');
    });
  }

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      String imagePath = image.path;
      String description = await _getImageDescription(imagePath);
      String audioPath = await _generateAudio(description);
      print("========_captureImage======");
      print(description);
      print(imagePath);
      print(audioPath);
      print("==============");
      _saveToHistory(description, imagePath, audioPath);
    }
  }

  Future<String> _getImageDescription(String imagePath) async {
    final apiKey = 'AIzaSyAZ4YBfvklEuNYJyfFMnLaOUKtLFAH36SQ';
    final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

    final imageBytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'LABEL_DETECTION'}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<String> descriptions = [];
      for (var item in data['responses'][0]['labelAnnotations']) {
        descriptions.add(item['description'].toString());
      }

      return descriptions.join(', ');
    } else {
      throw Exception('Falha na API Vision');
    }
  }

  Future<String> _generateAudio(String description) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioFile = File('${directory.path}/audio.mp3');

    await _flutterTts.speak(description);
    return audioFile.path;
  }

  _saveToHistory(String description, String imagePath, String audioPath) async {
    await _database?.insert('history', {
      'description': description,
      'imagePath': imagePath,
      'audioPath': audioPath
    });
    _loadHistory();
  }

  _loadHistory() async {
    final List<Map> history = await _database?.query('history') ?? [];
    setState(() {
      _historico = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vision App')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _captureImage,
            child: Text('Capturar Imagem'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(_historico),
                ),
              );
            },
            child: Text('Ver Histórico'),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map> historico;
  HistoryPage(this.historico);

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Histórico')),
      body: ListView.builder(
        itemCount: historico.length,
        itemBuilder: (context, index) {
          var item = historico[index];
          return ListTile(
            title: Text(item['description']),
            subtitle: Text(item['imagePath']),
            onTap: () {
              _showImageDialog(context, item['imagePath']);

              _playAudio(item['audioPath']);
            },
          );
        },
      ),
    );
  }

  _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.file(File(imagePath)),
        );
      },
    );
  }

  _playAudio(String audioPath) async {
    if (audioPath.isNotEmpty) {
      await _audioPlayer.play(DeviceFileSource(audioPath));
    }
  }
}
