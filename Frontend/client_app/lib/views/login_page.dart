import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/constants/images.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  final AuthenticationService authService = GetIt.I<AuthenticationService>();
  
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final UserLoginResponse loginResponse =
          await widget.authService.login(email, password);
      if (loginResponse.token != null) {
        // Authentication successful, navigate to home page
        GoRouter.of(context).push(Routes.home);
      } else if (loginResponse.error != null) {
        // Show error message
        final errorMessage = loginResponse.error!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.generic_error),
          duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() => _isLoading = false);
    } catch (e) {
      // Handle other exceptions (network error, etc.)
      if (kDebugMode) {
        print('Login failed: $e');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.login_error),
          duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isLoading = false;
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 70),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        Images.musewaveLogo,
                        fit: BoxFit.cover,
                        width: 200,
                      )),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.email_hint;
                        }
                        String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                            "\\@" +
                            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                            "(" +
                            "\\." +
                            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                            ")+";
                        RegExp regExp = new RegExp(p);
                        if (regExp.hasMatch(value)) {
                          return null;
                        }
                        return AppLocalizations.of(context)!.email_hint_invalid;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _toggle,
                        ),
                      ),
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.password_hint;
                        }
                        String pattern =
                            r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9]).{8,}$';
                        RegExp regExp = new RegExp(pattern);
                        if (!regExp.hasMatch(value)) {
                          return AppLocalizations.of(context)!.password_hint_invalid;
                        }
                        return null;
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                minimumSize: Size(double.infinity,
                                    50),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  await _login();
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.login),
                            ),
                          ),
                          // Container(
                          //   margin: EdgeInsets.only(top: 20),
                          //   width: double.infinity,
                          //   child: OutlinedButton(
                          //     onPressed: () {},
                          //     // remove the outline
                          //     style: OutlinedButton.styleFrom(
                          //       side: BorderSide.none,
                          //       minimumSize: Size(double.infinity,
                          //           50),
                          //     ),
                          //     child: Text('Sign up'),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ]),
    );
  }
}
