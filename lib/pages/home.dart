import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:kronic_desktop_tool/pages/client_home.dart';
import 'package:dart_lol/lcu/league_client_connector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animated_error.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ScaffoldSnackbar {
  // ignore: public_member_api_docs
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          width: 400,
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
enum AuthMode { login, register, phone }

extension on AuthMode {
  String get label => this == AuthMode.login
      ? 'Sign in'
      : this == AuthMode.phone
      ? 'Sign in'
      : 'Register';
}

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    if(!mounted) return;
      setState(() {
        isLoading = !isLoading;
      });

  }

  void resetError() {
    if(!mounted) return;
    if (error.isNotEmpty) {
      setState(() {
        error = '';
      });
    }
  }

  Future _resetPassword() async {
    resetError();

    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
        ScaffoldSnackbar.of(context).show('Password reset email is sent');
      } catch (e) {
        ScaffoldSnackbar.of(context).show('Error resetting');
      }
    }
  }

  Future _emailAuth() async {
    resetError();

    if (formKey.currentState?.validate() ?? false) {
      setIsLoading();

      try {
        if (mode == AuthMode.login) {
          await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        } else if (mode == AuthMode.register) {
          await _auth.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        }
      } on FirebaseAuthException catch (e) {
        setIsLoading();
        if(!mounted) return;
        setState(() {
          error = '${e.message}';
        });
      } catch (e) {
        setIsLoading();
      }
    }

  }

  Future<void> _anonymousAuth() async {
    setIsLoading();

    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if(!mounted) return;
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Client Not Running'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please make sure the League Client is Running.'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              leading: new Container(),
              title: Text("League Of Legends Tool, By Kronic",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(28, 22, 46, 1),
              elevation: 0.0,
            ),
            body: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/league_home.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(.2), BlendMode.dstATop))),
                child: Center(
                        child: Padding(
                            padding: const EdgeInsets.all(29),
                            child: Center(
                                child: SizedBox(
                                    width: 400,
                                    child: Form(
                                        key: formKey,
                                        autovalidateMode: AutovalidateMode
                                            .onUserInteraction,
                                        child: Column(
                                            children: [
                                              AnimatedError(text: error,
                                                  show: error.isNotEmpty),
                                              const SizedBox(height: 20),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: [
                                                  TextFormField(
                                                    controller: emailController,
                                                    decoration: const InputDecoration(
                                                        hintText: 'Email'),
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isNotEmpty
                                                        ? null
                                                        : 'Required',
                                                  ),
                                                  const SizedBox(height: 20),
                                                  TextFormField(
                                                    controller: passwordController,
                                                    obscureText: true,
                                                    decoration:
                                                    const InputDecoration(
                                                        hintText: 'Password'),
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isNotEmpty
                                                        ? null
                                                        : 'Required',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              TextButton(
                                                onPressed: _resetPassword,
                                                child: Text("Forgot Password?"),
                                              ),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: ElevatedButton(
                                                    onPressed: isLoading
                                                        ? null
                                                        : _emailAuth,
                                                    child: isLoading
                                                        ? const CircularProgressIndicator
                                                        .adaptive()
                                                        : Text(mode.label)
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              RichText(
                                                  text: TextSpan(
                                                      style: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                      children: [
                                                        TextSpan(
                                                          text: mode ==
                                                              AuthMode.login
                                                              ? "Don't have an account? "
                                                              : "You have an account? ",
                                                        ),
                                                        TextSpan(
                                                            text: mode ==
                                                                AuthMode.login
                                                                ? 'Register now'
                                                                : 'Click to Login',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .blue),
                                                            recognizer: TapGestureRecognizer()
                                                              ..onTap = () {
                                                                setState(() {
                                                                  mode = mode ==
                                                                      AuthMode
                                                                          .login
                                                                      ? AuthMode
                                                                      .register
                                                                      : AuthMode
                                                                      .login;
                                                                });
                                                              }
                                                        )
                                                      ]
                                                  )
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                  children: [
                                                    const TextSpan(text: 'Or '),
                                                    TextSpan(
                                                      text: 'continue as guest',
                                                      style: const TextStyle(
                                                          color: Colors.blue),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = _anonymousAuth,
                                                    )
                                                  ],
                                                ),

                                              ),
                                            ])
                                    )
                                )
                            )
                        )
                    ) )
                  );



  }
  @override
  void initState() {
    if(!mounted) return;
    FirebaseAuth.instance.authStateChanges()
        .listen((User? user) async {
      if (user == null) {
      }
      else {
        //user is signed in
        if(!mounted) return;
        Navigator.pushReplacementNamed(context, ClientHome.routeName);
      }
    });
    super.initState();
  }
  @override
  void dispose()
  {

    super.dispose();
  }



}
