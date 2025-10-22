import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();
  String? extractedText;

  Future<void> uploadImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.10:8000/extract-text/'), // GANTI IP kamu
    );
    request.files.add(await http.MultipartFile.fromPath('image', picked.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var data = jsonDecode(result);
      setState(() => extractedText = data['extracted_text']);
    } else {
      setState(() => extractedText = 'Gagal upload: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('OCR Dummy App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: uploadImage,
                child: const Text('Upload Struk'),
              ),
              const SizedBox(height: 20),
              if (extractedText != null)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(extractedText!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
