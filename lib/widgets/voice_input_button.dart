import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/whisper_service.dart';
import '../core/utils/app_colors.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onTextRecognized;
  final VoidCallback? onListeningStarted;
  final VoidCallback? onListeningStopped;
  final String? initialLanguage;

  const VoiceInputButton({
    super.key,
    required this.onTextRecognized,
    this.onListeningStarted,
    this.onListeningStopped,
    this.initialLanguage,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showLanguageDropdown = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize with the provided language if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLanguage != null) {
        final whisperService =
            Provider.of<WhisperService>(context, listen: false);
        whisperService.setLanguage(widget.initialLanguage!);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    final whisperService = Provider.of<WhisperService>(context, listen: false);

    if (whisperService.isRecording) {
      // Stop recording
      _pulseController.stop();
      widget.onListeningStopped?.call();

      final text = await whisperService.stopRecording();
      if (text != null && text.isNotEmpty) {
        widget.onTextRecognized(text);
      }
    } else {
      // Reset speech recognition first to ensure clean state
      await whisperService.resetSpeechRecognition();

      // Check permission first
      final hasPermission = await whisperService.hasPermission();
      if (!hasPermission) {
        final granted = await whisperService.requestPermission();
        if (!granted) {
          _showPermissionDialog();
          return;
        }
      }

      // Initialize if not already done
      final initialized = await whisperService.initialize();
      if (!initialized) {
        _showErrorDialog('Speech recognition is not available on this device.');
        return;
      }

      // Start recording (with automatic fallback)
      final started = await whisperService.startRecording();
      if (started) {
        _pulseController.repeat(reverse: true);
        widget.onListeningStarted?.call();
      } else {
        _showErrorDialog(
            'Could not start speech recognition. Please check your microphone permissions and try again.');
      }
    }
  }

  void _showLanguageSelector() {
    setState(() {
      _showLanguageDropdown = !_showLanguageDropdown;
    });
  }

  void _selectLanguage(String languageCode) async {
    final whisperService = Provider.of<WhisperService>(context, listen: false);

    whisperService.setLanguage(languageCode);
    setState(() {
      _showLanguageDropdown = false;
    });

    // Show a snackbar with the selected language
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Language set to: ${whisperService.getLanguageName(languageCode)}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mic_off, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Microphone Permission'),
          ],
        ),
        content: const Text(
          'This app needs microphone permission to use voice input. Please allow microphone access to speak your farming questions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleRecording(); // Try again
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.error, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Voice Input Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WhisperService>(
      builder: (context, whisperService, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language selector dropdown
            if (_showLanguageDropdown)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Select Voice Language',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...whisperService.availableLanguages.map((languageCode) {
                      final languageName =
                          whisperService.getLanguageName(languageCode);
                      final isSelected = whisperService.currentLanguage ==
                              languageCode ||
                          (languageCode.startsWith(whisperService
                                  .currentLanguage
                                  .split('_')[0]) &&
                              !whisperService.availableLanguages
                                  .contains(whisperService.currentLanguage));

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            languageName,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () => _selectLanguage(languageCode),
                          trailing: isSelected
                              ? const Icon(Icons.check,
                                  color: AppColors.primaryColor)
                              : null,
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            // Voice input buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language selector button
                GestureDetector(
                  onTap: _showLanguageSelector,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.language,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Main voice button
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: whisperService.isRecording
                          ? _pulseAnimation.value
                          : 1.0,
                      child: GestureDetector(
                        onTap: whisperService.isProcessing
                            ? null
                            : _toggleRecording,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: whisperService.isRecording
                                ? LinearGradient(
                                    colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade600
                                    ],
                                  )
                                : whisperService.isProcessing
                                    ? LinearGradient(
                                        colors: [
                                          Colors.orange.shade400,
                                          Colors.orange.shade600
                                        ],
                                      )
                                    : AppColors.farmGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: whisperService.isRecording
                                    ? Colors.red.withOpacity(0.4)
                                    : whisperService.isProcessing
                                        ? Colors.orange.withOpacity(0.4)
                                        : AppColors.primaryColor
                                            .withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: whisperService.isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Icon(
                                  whisperService.isRecording
                                      ? Icons.stop
                                      : Icons.mic,
                                  color: Colors.white,
                                  size: 28,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Status text
            if (whisperService.isRecording ||
                whisperService.isProcessing ||
                whisperService.recognizedText.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: whisperService.isRecording
                      ? Colors.red.withOpacity(0.1)
                      : whisperService.isProcessing
                          ? Colors.orange.withOpacity(0.1)
                          : AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  whisperService.isRecording
                      ? '🎤 Recording... (${whisperService.getLanguageName(whisperService.currentLanguage)})'
                      : whisperService.isProcessing
                          ? '🔄 Processing audio...'
                          : whisperService.recognizedText.isNotEmpty
                              ? '✓ "${whisperService.recognizedText}"'
                              : '',
                  style: TextStyle(
                    fontSize: 11,
                    color: whisperService.isRecording
                        ? Colors.red.shade700
                        : whisperService.isProcessing
                            ? Colors.orange.shade700
                            : AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Debug info (only in debug mode)
            if (kDebugMode)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Debug: ${whisperService.currentLanguage}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Recording: ${whisperService.isRecording}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
