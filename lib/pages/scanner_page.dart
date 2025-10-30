import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
    // Предлагаем выбрать источник сразу после захода на страницу
    WidgetsBinding.instance.addPostFrameCallback((_) => _chooseSource());
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

  Future<void> _openGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (photo != null) {
        setState(() => _captured = photo);
        await _uploadAndNavigate(photo);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть галерею: $e')),
      );
    }
  }

  Future<void> _chooseSource() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF2D2D2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Сделать фото', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Выбрать из галереи', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (choice == 'camera') {
      await _openCamera();
    } else if (choice == 'gallery') {
      await _openGallery();
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
      final fileName = photo.name.isNotEmpty ? photo.name : 'captured.jpg';
      // Определяем MIME-тип по расширению/имени (по умолчанию jpeg)
      final lower = fileName.toLowerCase();
      MediaType contentType;
      if (lower.endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (lower.endsWith('.gif')) {
        contentType = MediaType('image', 'gif');
      } else {
        contentType = MediaType('image', 'jpeg');
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: contentType,
      );
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
          ),
          IconButton(
            onPressed: _openGallery,
            icon: const Icon(Icons.photo_library),
            tooltip: 'Выбрать из галереи',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _captured == null
                ? const Text(
                    'Выберите источник: камера или галерея.\nНажмите на иконки вверху, чтобы открыть.',
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
            // остаёмся на сканере: предложить выбрать источник
            _chooseSource();
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