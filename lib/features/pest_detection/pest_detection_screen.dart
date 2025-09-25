import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/mistral_service.dart';
import '../../core/utils/app_colors.dart';

class PestDetectionScreen extends StatefulWidget {
  const PestDetectionScreen({super.key});

  @override
  State<PestDetectionScreen> createState() => _PestDetectionScreenState();
}

class _PestDetectionScreenState extends State<PestDetectionScreen> {
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  bool _isDescribing = false;
  Map<String, dynamic>? _analysisResult;
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imagePath = image.path;
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showErrorDialog('Error accessing camera: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imagePath = image.path;
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showErrorDialog('Error accessing gallery: $e');
    }
  }

  Future<void> _analyzePest() async {
    if (_selectedImage == null) {
      _showErrorDialog('Please select an image first');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final prompt = '''
Analyze this agricultural image and identify any pests, diseases, or plant health issues.

Please provide a detailed response including:
1. Pest/Disease Identification (if any)
2. Confidence Level (High/Medium/Low)
3. Description of the issue
4. Impact on the plant
5. Recommended treatment options
6. Prevention methods
7. Any additional notes

Format your response in a clear, structured way that can be easily parsed.
      ''';

      final response = await MistralService.generateResponseWithImage(
        prompt: prompt,
        imageBase64: base64Image,
        context: 'Pest detection analysis',
      );
      
      _parsePestResponse(response);
    } catch (e) {
      _showErrorDialog('Failed to analyze image: $e');
      debugPrint('Error analyzing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _parsePestResponse(String response) {
    try {
      final lines = response.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      String name = 'Unknown Pest';
      String confidence = 'Medium';
      String description = 'No description available';
      String damage = 'Not specified';
      List<String> prevention = [];
      List<String> treatment = [];
      
      for (var line in lines) {
        if (line.toLowerCase().contains('name:') || line.toLowerCase().contains('pest:')) {
          name = line.split(':').length > 1 ? line.split(':')[1].trim() : line.trim();
        } else if (line.toLowerCase().contains('confidence:')) {
          confidence = line.split(':').length > 1 ? line.split(':')[1].trim() : 'Medium';
        } else if (line.toLowerCase().contains('description:')) {
          description = line.split(':').length > 1 ? line.split(':')[1].trim() : line.trim();
        } else if (line.toLowerCase().contains('damage:')) {
          damage = line.split(':').length > 1 ? line.split(':')[1].trim() : line.trim();
        } else if (line.toLowerCase().contains('prevention:') || line.toLowerCase().contains('prevent:')) {
          final startIndex = lines.indexOf(line) + 1;
          for (var i = startIndex; i < lines.length; i++) {
            if (lines[i].trim().startsWith('-') || lines[i].trim().startsWith('•')) {
              prevention.add(lines[i].trim().substring(1).trim());
            } else if (!lines[i].toLowerCase().contains('treatment:')) {
              break;
            }
          }
        } else if (line.toLowerCase().contains('treatment:')) {
          final startIndex = lines.indexOf(line) + 1;
          for (var i = startIndex; i < lines.length; i++) {
            if (lines[i].trim().startsWith('-') || lines[i].trim().startsWith('•')) {
              treatment.add(lines[i].trim().substring(1).trim());
            } else {
              break;
            }
          }
        }
      }
      
      if (prevention.isEmpty) prevention = ['No specific prevention methods provided.'];
      if (treatment.isEmpty) treatment = ['No specific treatment methods provided.'];

      setState(() {
        _analysisResult = {
          'pestName': name,
          'confidence': _parseConfidence(confidence),
          'description': description,
          'damage': damage,
          'prevention': prevention,
          'treatment': treatment,
          'rawResponse': response,
        };
      });
    } catch (e) {
      setState(() {
        _analysisResult = {
          'pestName': 'Analysis Result',
          'confidence': 0.0,
          'description': response,
          'damage': 'Could not parse response',
          'prevention': ['Please see description for details'],
          'treatment': ['Please see description for details'],
          'rawResponse': response,
        };
      });
    }
  }
  
  double _parseConfidence(String confidence) {
    confidence = confidence.toLowerCase();
    if (confidence.contains('high')) return 0.9;
    if (confidence.contains('medium')) return 0.6;
    if (confidence.contains('low')) return 0.3;
    return 0.5;
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt, size: 30),
                      SizedBox(width: 16),
                      Text('Take a Photo'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromCamera();
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(Icons.photo_library, size: 30),
                      SizedBox(width: 16),
                      Text('Choose from Gallery'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _selectedImage = null;
    _imagePath = null;
    super.dispose();
  }

  List<Widget> _buildAnalysisResult() {
    if (_analysisResult == null) return [];
    
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _analysisResult!['pestName'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${(_analysisResult!['confidence'] * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  _analysisResult!['description'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Impact:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(_analysisResult!['damage']),
                const SizedBox(height: 16),
                const Text(
                  'Recommended Treatments:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ..._analysisResult!['treatment'].map<Widget>((t) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('• $t'),
                )).toList(),
                const SizedBox(height: 16),
                const Text(
                  'Prevention:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ..._analysisResult!['prevention'].map<Widget>((p) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('• $p'),
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _showImageSourceDialog,
              icon: const Icon(Icons.camera_alt),
              label: Text(_isAnalyzing ? 'Analyzing...' : 'Take Photo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing || _selectedImage == null ? null : _analyzePest,
              icon: const Icon(Icons.search),
              label: const Text('Analyze'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDescriptionMode() {
    setState(() {
      _isDescribing = !_isDescribing;
      _selectedImage = null;
      _analysisResult = null;
    });
  }

  Widget _buildBody() {
    if (_isDescribing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter pest description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe the pest or plant issue in detail...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement text-based analysis
                  _showErrorDialog('Text-based analysis coming soon!');
                },
                child: const Text('Analyze Description'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _selectedImage == null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _showImageSourceDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to add image',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: kIsWeb
                          ? Image.network(
                              _imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Center(child: Icon(Icons.error)),
                            )
                          : Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Center(child: Icon(Icons.error)),
                            ),
                    ),
                    if (_isAnalyzing)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
        ),
        if (_analysisResult != null) ..._buildAnalysisResult(),
        _buildActionButtons(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Detection'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isDescribing ? Icons.camera_alt : Icons.text_fields),
            onPressed: _toggleDescriptionMode,
            tooltip: _isDescribing ? 'Switch to camera' : 'Switch to text description',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: !_isDescribing && _selectedImage == null && !_isAnalyzing
          ? FloatingActionButton(
              onPressed: _showImageSourceDialog,
              child: const Icon(Icons.add_a_photo),
            )
          : null,
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pest Detection Help'),
          content: const SingleChildScrollView(
            child: Text(
              '1. Take a clear photo of the affected plant or pest\n\n'
              '2. Ensure good lighting and focus\n\n'
              '3. Capture the entire plant and close-up of the issue\n\n'
              '4. The AI will analyze the image and provide information about any detected pests or diseases\n\n'
              '5. Follow the recommended treatments and prevention methods',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}