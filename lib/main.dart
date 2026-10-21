import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

void main() => runApp(const MaterialApp(home: Demo()));

int parseFile(String path) {
  final text = File(path).readAsStringSync();
  final list = jsonDecode(text) as List;
  return list.length;
}

Future<int> parseIsolate(String path) {
  return compute(parseFile, path);
}

// Future<int> parseIsolate(String path) async {
//   final text = await File(path).readAsString();
//   return compute(parseJson, text);
// }

// int parseJson(String text) {
//   final list = jsonDecode(text) as List;
//   return list.length;
// }

Future<int> parseAsync(String path) async {
  final text = await File(path).readAsString();
  final list = jsonDecode(text) as List;
  return list.length;
}

class Demo extends StatefulWidget {
  const Demo({super.key});
  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> with SingleTickerProviderStateMixin {
  late final _spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();

  final _clock = Stopwatch()..start();
  final _fps = ValueNotifier<int>(0);
  int _frames = 0, _windowStart = 0, _lastFrame = 0, _maxGap = 0;

  String? _path;
  String _result = 'Đang chuẩn bị file...';
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _spin.addListener(_onFrame);
    _prepareFile();
  }


  Future<void> _prepareFile() async {
    final data = await rootBundle.load('assets/large_test_data.json');
    final file = File('${Directory.systemTemp.path}/large_test_data.json');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    setState(() {
      _path = file.path;
      _busy = false;
      _result = 'Sẵn sàng';
    });
  }

  void _onFrame() {
    final now = _clock.elapsedMilliseconds;
    if (now - _lastFrame > _maxGap) _maxGap = now - _lastFrame;
    _lastFrame = now;
    _frames++;
    if (now - _windowStart >= 500) {
      _fps.value = (_frames * 1000 / (now - _windowStart)).round();
      _frames = 0;
      _windowStart = now;
    }
  }

  Future<void> _run(String name, Future<int> Function(String) parse) async {
    setState(() {
      _busy = true;
      _result = 'Đang chạy $name...';
    });
    await Future.delayed(const Duration(milliseconds: 300));
    _maxGap = 0;
    final sw = Stopwatch()..start();
    final count = await parse(_path!);
    sw.stop();
    await WidgetsBinding.instance.endOfFrame;
    setState(() {
      _busy = false;
      _result = '$name\n'
          'Số item: $count\n'
          'Khựng lâu nhất: $_maxGap ms';
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async vs Isolate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(turns: _spin, child: const FlutterLogo(size: 100)),
            const SizedBox(height: 24),
            ValueListenableBuilder<int>(
              valueListenable: _fps,
              builder: (_, v, __) => Text('FPS: $v',
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 16),
            Text(_result, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _busy ? null : () => _run('Async', parseAsync),
                  child: const Text('Parse Async'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _busy ? null : () => _run('Isolate', parseIsolate),
                  child: const Text('Parse Isolate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}