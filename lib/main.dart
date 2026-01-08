import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

void main() {
  runApp(const GoogleSignInWasmExample());
}

class GoogleSignInWasmExample extends StatelessWidget {
  const GoogleSignInWasmExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sign in with google wasm example',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const SignInWidget(title: 'sign in with google wasm example'),
    );
  }
}

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key, required this.title});
  final String title;

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  late final GoogleSignIn googleSignIn;
  GoogleSignInAccount? account;
  late final StreamSubscription<GoogleSignInAuthenticationEvent> onAuth;

  @override
  void initState() {
    super.initState();
    googleSignIn = GoogleSignIn.instance;
    unawaited(init());
  }

  Future<void> init() async {
    await googleSignIn.initialize();
    onAuth = googleSignIn.authenticationEvents.listen((event) {
      switch (event) {
        case final GoogleSignInAuthenticationEventSignIn signIn:
          setState(() {
            account = signIn.user;
          });
        case GoogleSignInAuthenticationEventSignOut():
          setState(() {
            account = null;
          });
      }
    });
  }

  @override
  void dispose() {
    onAuth.cancel();
    unawaited(googleSignIn.disconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('is running with wasm: $kIsWasm');
    print('is in debug mode: $kDebugMode');

    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            if (account case final acc?) ...[
              Text("Signed in as ${acc.displayName} (${acc.email})"),
              ElevatedButton(
                onPressed: signOut,
                child: const Text("Sign out"),
              ),
            ] else ...[
              const Text("Not signed in"),
              if (kIsWeb)
                web.renderButton()
              else
                ElevatedButton(
                  onPressed: signInWithGoogle,
                  child: Text("Sign in with Google"),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void signOut() async {
    await googleSignIn.signOut();
    setState(() {
      account = null;
    });
  }

  Future<void> signInWithGoogle() async {
    final account = await googleSignIn.authenticate();
    setState(() {
      this.account = account;
    });
  }
}
