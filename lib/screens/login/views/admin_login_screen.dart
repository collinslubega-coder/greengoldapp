// lib/screens/login/views/admin_login_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/admin_entry_point.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For AuthException (used in catch)
import 'dart:io'; // For SocketException
import 'package:green_gold/components/custom_error_snackbar.dart'; // Ensure this is imported for showErrorSnackBar

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController(); // Changed from password controller to PIN controller
  bool _isObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);
      final userDataService = Provider.of<UserDataService>(context, listen: false);
      
      try {
        await userDataService.login(
          role: 'admin', // Explicitly logging in as admin
          pin: _pinController.text, // Pass the PIN
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminEntryPoint()),
          );
        }
      } on AuthException catch (e) { // Catch Supabase Auth exceptions
        if (mounted) {
          showErrorSnackBar(context, e.message);
        }
      } on SocketException { // Catch network errors
        if (mounted) {
          showErrorSnackBar(context, "Network error. Please check your connection.");
        }
      } catch (e) { // Catch other unexpected errors
        if (mounted) {
          showErrorSnackBar(context, "An unexpected error occurred. Please try again.");
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")), // Title remains Admin Login
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
                    Text("Admin Access", style: Theme.of(context).textTheme.headlineSmall), // Text remains Admin Access
                    const SizedBox(height: defaultPadding * 2),
                    TextFormField(
                      controller: _pinController, // PIN controller
                      keyboardType: TextInputType.number, // Numeric keyboard for PIN
                      maxLength: 4, // 4-digit PIN
                      validator: (value) => (value == null || value.isEmpty || value.length != 4) ? 'Please enter a 4-digit PIN' : null,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: "4-Digit PIN", // Label changed to 4-Digit PIN
                        suffixIcon: IconButton(
                          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscured = !_isObscured),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("Login"), // Text remains Login
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