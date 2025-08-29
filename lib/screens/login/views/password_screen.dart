// lib/screens/login/views/password_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/entry_point.dart'; // ** THE FIX IS HERE **
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:green_gold/screens/login/views/admin_auth_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  final String _adminAuthCode = "NUTTER1234";
  final String _customerAuthCode = "heal";

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final userDataService = Provider.of<UserDataService>(context, listen: false);
      final enteredAuthCode = _passwordController.text;

      if (enteredAuthCode == _adminAuthCode) {
        if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAuthScreen()));
      } else if (enteredAuthCode == _customerAuthCode) {
        try {
          await userDataService.login(role: 'customer');
          // ** THE FIX IS HERE: Navigate to the Shop Portal (EntryPoint) **
          if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EntryPoint(showReturnBanner: true)));
        } on AuthException catch (e) {
          if (mounted) showErrorSnackBar(context, "Customer login failed: ${e.message}");
        } catch (e) {
          if (mounted) showErrorSnackBar(context, "An unexpected error occurred: ${e.toString()}");
        }
      } else {
        if (mounted) showErrorSnackBar(context, "Invalid Authorization Code entered.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains the same, no changes needed here.
    return Scaffold(
      // Added an AppBar for better UX so the user can go back.
      appBar: AppBar(
        title: const Text("Authorization"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Authorization Required", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: defaultPadding * 2),
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter an authorization code' : null,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: "Authorization Code",
                        suffixIcon: IconButton(
                          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscured = !_isObscured),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Proceed"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}