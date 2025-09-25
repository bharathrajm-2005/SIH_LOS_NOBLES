import 'package:flutter/material.dart';

import '../core/services/language_service.dart';
import '../core/utils/app_colors.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LanguageService.getCurrentLanguage();
    setState(() {
      _currentLanguage = language;
    });
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.language, color: AppColors.primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.selectLanguage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Language list
            ...LanguageService.supportedLanguages.values.map(
              (language) => _buildLanguageItem(context, language),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, LanguageModel language) {
    final isSelected = _currentLanguage == language.code;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.primaryColor) : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.2)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              language.flag,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          language.nativeName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryColor : null,
          ),
        ),
        subtitle: Text(
          language.name,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppColors.primaryColor)
            : null,
        onTap: () async {
          await _selectLanguage(language.code);
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<void> _selectLanguage(String languageCode) async {
    await LanguageService.setLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
    widget.onLanguageChanged(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguageModel =
        LanguageService.supportedLanguages[_currentLanguage]!;

    return Container(
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.2), // Semi-transparent white background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLanguageBottomSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLanguageModel.flag,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  currentLanguageModel.code.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Changed to white
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.white, // Changed to white
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
