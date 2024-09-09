import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/language.dart';
import 'package:frontend/services/language_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class LanguageSelectionPage extends StatefulWidget {
  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final FlutterSecureStorage secureStorage = GetIt.I<FlutterSecureStorage>();
  final LanguageService languageService = GetIt.I<LanguageService>();
  List<Language> languages = [];
  String? selectedLanguageCode;
  String? initialLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      final fetchedLanguages = await languageService.getAllLanguages();
      setState(() {
        languages = fetchedLanguages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failed_to_load_languages)),
      );
    }
  }

@override
Widget build(BuildContext context) {
  // Fetch current language from localization within the build method
  initialLanguageCode = Localizations.localeOf(context).languageCode;
  selectedLanguageCode = selectedLanguageCode ?? initialLanguageCode;

  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
            GoRouter.of(context).go('/');
          }
        },
      ),
      title: Text(AppLocalizations.of(context)!.select_language),
    ),
    body: languages.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              return RadioListTile<String>(
                title: Text(_getLocalizedLanguageName(language.code)),
                value: language.code,
                groupValue: selectedLanguageCode,
                onChanged: (String? value) async {
                  setState(() {
                    selectedLanguageCode = value;
                  });
                  await _updateLanguage(language);
                },
                secondary: _buildFlagIcon(language.code),
              );
            },
          ),
  );
}


  Widget _buildFlagIcon(String languageCode) {
    final countryCode = languageCode.split('_').last; // Get the country code
    final flagAssetPath = 'flags/$countryCode.png'; // Example flag asset path

    return Image.asset(
      flagAssetPath,
      width: 30,
      height: 30,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.flag); // Fallback icon if flag asset is not found
      },
    );
  }

Future<void> _updateLanguage(Language language) async {
    try {
      await languageService.updatePreferedLanguage(language.id);

      // Extract the language code from the Language model
      Locale newLocale = Locale(language.code.split('_').first); // Get language part only
      MyApp.setLocale(context, newLocale); // Update the locale dynamically

      await secureStorage.write(key: 'language_code', value: language.code);

      // Refresh the page to reflect the updated language
      GoRouter.of(context).refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.language_update_failed)),
      );
    }
  }

String _getLocalizedLanguageName(String languageCode) {
  switch (languageCode.split('_').first) {
    case 'en':
      return AppLocalizations.of(context)!.english;
    case 'es':
      return AppLocalizations.of(context)!.spanish;
    case 'fr':
      return AppLocalizations.of(context)!.french;
    case 'bs':
      return AppLocalizations.of(context)!.bosnian;
    case 'de':
      return AppLocalizations.of(context)!.german;
    // Add more languages as needed
    default:
      return "";
  }
}



}
