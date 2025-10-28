import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _captured;

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
      setState(() => _captured = photo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть камеру: $e')),
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
      body: Center(
        child: _captured == null
            ? const Text(
                'Камера откроется автоматически.\nНажмите на иконку камеры, чтобы открыть вручную.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            : _buildPreview(),
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
    if (kIsWeb) {
      // ignore: unnecessary_null_comparison
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
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(File(_captured!.path), width: 300, fit: BoxFit.cover),
      );
    }
  }
}
