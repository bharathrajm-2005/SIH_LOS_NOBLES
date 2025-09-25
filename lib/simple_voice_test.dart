import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Simple voice input test without complex fallback logic
class SimpleVoiceTest extends StatefulWidget {
  const SimpleVoiceTest({super.key});

  @override
  State<SimpleVoiceTest> createState() => _SimpleVoiceTestState();
}

class _SimpleVoiceTestState extends State<SimpleVoiceTest> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  String _status = 'Not started';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          setState(() {
            _status = status;
          });
          print('Speech status: $status');
        },
        onError: (error) {
          setState(() {
            _status = 'Error: ${error.errorMsg}';
          });
          print('Speech error: $error');
        },
      );
      
      setState(() {
        _status = available ? 'Available' : 'Not available';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        _isListening = false;
        _recognizedText = '';
        _status = 'Starting...';
      });

      // Clean up any existing recognition
      try {
        await _speech.stop();
        await _speech.cancel();
        print('🔄 Cleaned up previous recognition');
      } catch (e) {
        print('🔄 Cleanup warning: $e');
      }

      await Future.delayed(const Duration(milliseconds: 200));

      print('🎤 Starting speech recognition...');
      final started = await _speech.listen(
        onResult: (result) {
          print('🎯 Speech result: ${result.recognizedWords}');
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
        localeId: 'en_US',
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );

      print('🎤 Speech listen result: $started (type: ${started.runtimeType})');

      setState(() {
        _isListening = started == true;
        _status = (started == true) ? 'Listening...' : 'Failed to start (result: $started)';
      });
    } catch (e) {
      print('❌ Error starting speech recognition: $e');
      setState(() {
        _isListening = false;
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _status = 'Stopped';
      });
    } catch (e) {
      setState(() {
        _status = 'Error stopping: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Voice Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Recognized Text: $_recognizedText', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isListening ? _stopListening : _startListening,
                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _recognizedText = '';
                    _status = 'Reset';
                  });
                },
                child: const Text('Clear Text'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
