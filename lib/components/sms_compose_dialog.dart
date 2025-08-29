// lib/components/sms_compose_dialog.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsComposeDialog extends StatefulWidget {
  final String recipientNumber;
  final String initialMessage;

  const SmsComposeDialog({
    super.key,
    required this.recipientNumber,
    required this.initialMessage,
  });

  @override
  State<SmsComposeDialog> createState() => _SmsComposeDialogState();
}

class _SmsComposeDialogState extends State<SmsComposeDialog> {
  late TextEditingController _messageController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    // Prevent multiple clicks while processing
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: widget.recipientNumber,
      queryParameters: <String, String>{'body': _messageController.text},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        // If it launches, close the dialog. The user will handle sending in their native SMS app.
        if (mounted) Navigator.pop(context);
      } else {
        throw 'Could not launch SMS app.';
      }
    } catch (e) {
      // If there's an error, show a snackbar and then update the state.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Could not open messaging app. Please check device settings.'),
            backgroundColor: errorColor,
          ),
        );
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Compose SMS"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recipient: ${widget.recipientNumber}"),
            const SizedBox(height: defaultPadding),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _sendSms,
          icon: _isSending
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send),
          label: Text(_isSending ? "Opening..." : "Send SMS"),
        ),
      ],
    );
  }
}