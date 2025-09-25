import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Working voice input test with proper null handling
class WorkingVoiceTest extends StatefulWidget {
  const WorkingVoiceTest({super.key});

  @override
  State<WorkingVoiceTest> createState() => _WorkingVoiceTestState();
}

class _WorkingVoiceTestState extends State<WorkingVoiceTest> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  String _status = 'Not started';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    if (!mounted) return;
    
    setState(() {
      _status = 'Initializing...';
    });

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (mounted) {
            setState(() {
              _status = 'Status: $status';
            });
          }
        },
        onError: (error) {
          print('Speech error: $error');
          if (mounted) {
            setState(() {
              _status = 'Error: ${error.errorMsg}';
            });
          }
        },
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = available;
          _status = available ? 'Ready to listen' : 'Not available';
        });
      }
      
      print('Speech initialized: $available');
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _status = 'Init error: $e';
        });
      }
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized || !mounted) {
      if (mounted) {
        setState(() {
          _status = 'Not initialized or disposed';
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isListening = false;
          _recognizedText = '';
          _status = 'Starting...';
        });
      }

      // Ensure clean state
      try {
        await _speech.stop();
        await _speech.cancel();
        print('🔄 Cleaned up previous recognition');
      } catch (e) {
        print('🔄 Cleanup warning: $e');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      print('🎤 Starting speech recognition...');
      
      // Check if speech is available before trying to listen
      if (!_speech.isAvailable) {
        print('❌ Speech not available');
        if (mounted) {
          setState(() {
            _status = 'Speech not available';
          });
        }
        return;
      }

      // Try to start listening
      bool? result = await _speech.listen(
        onResult: (result) {
          print('🎯 Speech result: ${result.recognizedWords}');
          if (mounted) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          }
        },
        localeId: 'en_US',
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );

      print('🎤 Listen call completed. Result: $result');

      // Wait a bit and check the actual status
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        setState(() {
          _isListening = _speech.isListening;
          _status = _speech.isListening ? 'Listening...' : 'Failed to start (result: $result)';
        });
      }

      print('🎤 Final state - isListening: ${_speech.isListening}');
      
    } catch (e) {
      print('❌ Error starting speech recognition: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _status = 'Error: $e';
        });
      }
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
          _status = 'Stopped';
        });
      }
      print('🛑 Stopped listening');
    } catch (e) {
      print('❌ Error stopping: $e');
      if (mounted) {
        setState(() {
          _status = 'Error stopping: $e';
        });
      }
    }
  }

  Future<void> _reset() async {
    try {
      await _speech.cancel();
      if (mounted) {
        setState(() {
          _isListening = false;
          _recognizedText = '';
          _status = 'Reset';
        });
      }
      print('🔄 Reset complete');
    } catch (e) {
      print('❌ Error resetting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Working Voice Test'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Initialized: $_isInitialized', style: const TextStyle(fontSize: 14)),
            Text('Is Listening: $_isListening', style: const TextStyle(fontSize: 14)),
            Text('Is Available: ${_speech.isAvailable}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_recognizedText.isEmpty ? '(No text yet)' : _recognizedText),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  label: Text(_isListening ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _initializeSpeech,
                icon: const Icon(Icons.settings),
                label: const Text('Reinitialize'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
