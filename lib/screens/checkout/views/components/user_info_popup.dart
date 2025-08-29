// lib/screens/checkout/views/components/user_info_popup.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
// NEW: Import for the phone number field
import 'package:intl_phone_field/intl_phone_field.dart';

class UserInfoPopup extends StatefulWidget {
  final Function(String name, String phone, String address) onSave;

  const UserInfoPopup({super.key, required this.onSave});

  @override
  State<UserInfoPopup> createState() => _UserInfoPopupState();
}

class _UserInfoPopupState extends State<UserInfoPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  
  // NEW: A new string to hold the complete phone number from the picker
  String _fullPhoneNumber = '';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    _nameController = TextEditingController(text: userDataService.userName ?? '');
    
    // Set the initial phone number state
    _fullPhoneNumber = (userDataService.userContacts?.isNotEmpty ?? false) 
            ? userDataService.userContacts!.first 
            : '';
            
    _addressController = TextEditingController(
      text: (userDataService.addresses.isNotEmpty) 
            ? userDataService.addresses.last 
            : ''
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        final userDataService = Provider.of<UserDataService>(context, listen: false);

        final userName = _nameController.text;
        final userAddress = _addressController.text;

        await userDataService.updateUserInfoAndAddress(
          name: userName,
          // --- FIX IS HERE: Pass the complete phone number ---
          contact: _fullPhoneNumber, 
          address: userAddress,
        );
        
        // The onSave callback now passes the full international number
        widget.onSave(userName, _fullPhoneNumber, userAddress);

      } catch (e) {
        if (mounted) { 
          showErrorSnackBar(scaffoldMessenger.context, "Failed to place order: ${e.toString()}");
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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: defaultPadding,
          right: defaultPadding,
          top: defaultPadding
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Confirm Your Details", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: defaultPadding / 2),
              const Text("Please confirm your information below before placing your order."),
              const SizedBox(height: defaultPadding * 1.5),
              
              TextFormField(
                controller: _nameController,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
                decoration: const InputDecoration(labelText: "Your Name"),
              ),
              const SizedBox(height: defaultPadding),

              // --- FIX IS HERE: Replaced TextFormField with IntlPhoneField ---
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Your Contact Number',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'UG', // Default to Uganda
                initialValue: _fullPhoneNumber, // Set initial value from user data
                onChanged: (phone) {
                  setState(() {
                    _fullPhoneNumber = phone.completeNumber; // e.g., +256771234567
                  });
                },
              ),
              const SizedBox(height: defaultPadding),

              TextFormField(
                controller: _addressController,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your delivery address' : null,
                decoration: const InputDecoration(labelText: "Your Delivery Address"),
              ),
              const SizedBox(height: defaultPadding * 2),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Proceed & Place Order"),
                ),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}