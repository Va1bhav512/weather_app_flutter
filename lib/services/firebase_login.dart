import 'package:flutter/material.dart';
import 'package:weather_app_flutter/auth.dart';

class FirebaseLogin extends StatelessWidget {
  final AuthService _auth = AuthService();

  FirebaseLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                height: 150,
                // decoration: BoxDecoration(color: Colors.lightBlue[700], borderRadius: BorderRadius.circular(20)),
                color: Colors.transparent,
                child: Text(
                  "Flutter Weather App",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue[700],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  color: Colors.white,
                ),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 40, 0, 40),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.78,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _auth.signInAnonymously();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[700],
                            minimumSize: const Size(200, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Anonymous sign in",
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 0.7,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.78,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _auth.signInWithGoogle();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[700],
                            minimumSize: const Size(200, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Google Sign IN",
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 0.7,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
