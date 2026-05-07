import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TryOn AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({ super.key });

  @override
  State<HomeScreen> createState () => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isReady = false;

  void _toggleMessage() {
    setState(() {
      _isReady = !_isReady;
    });
  }

  @override 
  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TryOn AI'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checkroom,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'Virtual Try-On',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a dress + your photo\nto see how it looks on you',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _isReady
                  ? "Let's go!"
                  : 'Upload your images to begin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _isReady ? Colors.deepPurple : Colors.grey,
                fontWeight: _isReady
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
              ElevatedButton.icon(
              onPressed: _toggleMessage,
              icon: Icon(_isReady ? Icons.refresh : Icons.arrow_forward),
              label: Text(_isReady ? 'Reset' : 'Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const TryOnCounter(),
          ],
        )
      ),
    );
  }
}

class TryOnCounter extends StatefulWidget {
  const TryOnCounter({ super.key });

  @override
  State<TryOnCounter> createState() => _TryOnCounterState();
}

class _TryOnCounterState extends State<TryOnCounter> {
  int _uploadCount = 0;

  void _increment() {
    setState(() {
      _uploadCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Uploads attempted: $_uploadCount',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Simulate Upload'),
        ),
      ],
    );
  }
}
