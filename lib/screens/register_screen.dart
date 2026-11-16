import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscure = true;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? nameError;
  String? emailError;
  String? passError;

  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  Future<void> _onRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    final nError = name.isNotEmpty ? null : 'Enter your name';
    final eError = isValidEmail(email) ? null : 'Invalid email';
    final pError = isValidPassword(pass)
        ? null
        : 'Min 8 chars, uppercase, lowercase, number & symbol';

    setState(() {
      nameError = nError;
      emailError = eError;
      passError = pError;
    });

    FocusScope.of(context).unfocus();

    if (nError == null && eError == null && pError == null) {
      try {
        // 1. Crear usuario en Firebase Auth
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );

        // 2. Guardar datos básicos en Cloud Firestore (opcional según Fase 3)
        if (cred.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .set({
                'name': name,
                'email': email,
                'createdAt': FieldValue.serverTimestamp(),
              });
        }

        // 3. Cerrar pantalla de registro; authStateChanges() redirige al Home
        if (mounted) {
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Error al registrar usuario'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    errorText: nameError,
                    hintText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: emailError,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    errorText: passError,
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _onRegister,
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
