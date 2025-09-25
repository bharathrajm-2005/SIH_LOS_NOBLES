import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/whisper_service.dart';

/// Simple test screen for voice input functionality
class VoiceInputTestScreen extends StatefulWidget {
  const VoiceInputTestScreen({super.key});

  @override
  State<VoiceInputTestScreen> createState() => _VoiceInputTestScreenState();
}

class _VoiceInputTestScreenState extends State<VoiceInputTestScreen> {
  final List<String> _testResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Input Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Test buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _testInitialization,
                  child: const Text('Test Init'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _testPermissions,
                  child: const Text('Test Permissions'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _testLanguageSupport,
                  child: const Text('Test Languages'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Language selector
            Consumer<WhisperService>(
              builder: (context, whisperService, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Language:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: whisperService.availableLanguages.map((lang) {
                        final isSelected = whisperService.currentLanguage == lang;
                        return FilterChip(
                          label: Text(whisperService.getLanguageName(lang)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              whisperService.setLanguage(lang);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Voice input button
            Consumer<WhisperService>(
              builder: (context, whisperService, child) {
                return Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: whisperService.isRecording ? _stopRecording : _startRecording,
                      icon: Icon(whisperService.isRecording ? Icons.stop : Icons.mic),
                      label: Text(whisperService.isRecording ? 'Stop Recording' : 'Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: whisperService.isRecording ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${whisperService.isRecording ? 'Recording' : 'Stopped'}'),
                    Text('Language: ${whisperService.getLanguageName(whisperService.currentLanguage)}'),
                    if (whisperService.recognizedText.isNotEmpty)
                      Text('Recognized: ${whisperService.recognizedText}'),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Test results
            const Text('Test Results:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _testResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_testResults[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addResult(String result) {
    setState(() {
      _testResults.insert(0, '${DateTime.now().toString().substring(11, 19)}: $result');
    });
  }

  Future<void> _testInitialization() async {
    final whisperService = Provider.of<WhisperService>(context, listen: false);
    _addResult('Testing initialization...');
    
    try {
      final initialized = await whisperService.initialize();
      _addResult('Initialization result: $initialized');
    } catch (e) {
      _addResult('Initialization error: $e');
    }
  }

  Future<void> _testPermissions() async {
    final whisperService = Provider.of<WhisperService>(context, listen: false);
    _addResult('Testing permissions...');
    
    try {
      final hasPermission = await whisperService.hasPermission();
      _addResult('Has permission: $hasPermission');
      
      if (!hasPermission) {
        final granted = await whisperService.requestPermission();
        _addResult('Permission request result: $granted');
      }
    } catch (e) {
      _addResult('Permission error: $e');
    }
  }

  Future<void> _testLanguageSupport() async {
    final whisperService = Provider.of<WhisperService>(context, listen: false);
    _addResult('Testing language support...');
    
    try {
      final availableLanguages = await whisperService.getAvailableLanguages();
      _addResult('Available languages: $availableLanguages');
      
      for (final lang in availableLanguages) {
        final isSupported = await whisperService.isLanguageSupported(lang);
        _addResult('$lang supported: $isSupported');
      }
    } catch (e) {
      _addResult('Language support error: $e');
    }
  }

  Future<void> _startRecording() async {
    final whisperService = Provider.of<WhisperService>(context, listen: false);
    _addResult('Starting recording...');
    
    try {
      final started = await whisperService.startRecording();
      _addResult('Recording started: $started');
    } catch (e) {
      _addResult('Recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    final whisperService = Provider.of<WhisperService>(context, listen: false);
    _addResult('Stopping recording...');
    
    try {
      final text = await whisperService.stopRecording();
      _addResult('Recording stopped. Text: $text');
    } catch (e) {
      _addResult('Recording stop error: $e');
    }
  }
}
