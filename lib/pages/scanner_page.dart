import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _captured;
  bool _isUploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Открываем камеру сразу после захода на страницу
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (!mounted) return;
      // Если фото сделано — сохраняем и переходим на страницу валидации
      if (photo != null) {
        setState(() => _captured = photo);
        // Загружаем фото на бекенд и переходим на страницу проверки с результатами
        await _uploadAndNavigate(photo);
        return;
      }
      // Если пользователь отменил — просто остаёмся на странице
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть камеру: $e')),
      );
    }
  }

  Future<void> _uploadAndNavigate(XFile photo) async {
    try {
      setState(() {
        _isUploading = true;
        _error = null;
      });

      final uri = Uri.parse('http://121.127.37.220:8000/upload-photo/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['accept'] = 'application/json';

      final bytes = await photo.readAsBytes();
      final fileName = photo.name.isNotEmpty ? photo.name : 'captured.png';
      final multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: fileName);
      request.files.add(multipartFile);

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> payload = jsonDecode(response.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() => _isUploading = false);
        // Передаём ответ на /validation
        context.go('/validation', extra: payload);
      } else {
        throw Exception('Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки фото: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Сканер'),
        actions: [
          IconButton(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Открыть камеру',
          )
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _captured == null
                ? const Text(
                    'Камера откроется автоматически.\nНажмите на иконку камеры, чтобы открыть вручную.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                : _buildPreview(),
          ),
          if (_isUploading) ...[
            const ModalBarrier(dismissible: false, color: Color(0x80000000)),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFB3F800)),
            ),
          ],
        ],
      ),
      bottomNavigationBar: NavPanel(
        selectedIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go('/fridge');
          } else if (index == 1) {
            context.go('/recipes');
          } else if (index == 2) {
            // остаёмся на сканере, камера уже открывается автоматически
            _openCamera();
          }
        },
      ),
    );
  }

  Widget _buildPreview() {
    // Для Web File(path) недоступен — используем Image.network с blob URL, но
    // image_picker на Web возвращает XFile с bytes; здесь для простоты для
    // мобильных платформ используем File, для Web показываем через Image.memory.
    if (_captured == null) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<Uint8List>(
      future: _captured!.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(snapshot.data!, width: 300, fit: BoxFit.cover),
        );
      },
    );
  }
}