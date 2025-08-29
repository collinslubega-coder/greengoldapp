// lib/screens/admin/views/admin_confirm_order_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/services/settings_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AdminConfirmOrderScreen extends StatefulWidget {
  final Order order;
  const AdminConfirmOrderScreen({super.key, required this.order});

  @override
  State<AdminConfirmOrderScreen> createState() => _AdminConfirmOrderScreenState();
}

class _AdminConfirmOrderScreenState extends State<AdminConfirmOrderScreen> {
  final _deliveryFeeController = TextEditingController();
  late TextEditingController _paymentNameController;
  late TextEditingController _paymentNumberController;
  
  String _fullPhoneNumber = '';
  String _messagePreview = '';

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsService>(context, listen: false).settings;
    _paymentNameController = TextEditingController(text: settings['momo_name'] ?? 'Your Business Name');
    _paymentNumberController = TextEditingController(text: settings['momo_number'] ?? 'Your MoMo Number');
    
    _fullPhoneNumber = widget.order.customerContact ?? '';

    _deliveryFeeController.addListener(_updateMessagePreview);
    _paymentNameController.addListener(_updateMessagePreview);
    _paymentNumberController.addListener(_updateMessagePreview);

    _updateMessagePreview();
  }

  @override
  void dispose() {
    _deliveryFeeController.dispose();
    _paymentNameController.dispose();
    _paymentNumberController.dispose();
    super.dispose();
  }

  void _updateMessagePreview() {
    final currencyFormatter = NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');
    final customerName = widget.order.customerName ?? 'Valued Customer';
    final orderId = widget.order.id;
    final items = widget.order.items.map((item) {
      final productName = item.product?.strainName ?? 'Item';
      return "- $productName (x${item.quantity})";
    }).join('\n');
    
    final subtotal = widget.order.total ?? 0;
    final deliveryFee = double.tryParse(_deliveryFeeController.text) ?? 0;
    final total = subtotal + deliveryFee;

    final paymentName = _paymentNameController.text;
    final paymentNumber = _paymentNumberController.text;

    setState(() {
      _messagePreview = """
Hello $customerName, this is Green Gold.

Thank you for your order! We've received it and have the following items ready for you:
Order ID: #$orderId

$items

Here is the final price breakdown for your delivery to ${widget.order.deliveryAddress ?? 'your location'}:

Subtotal (Items): ${currencyFormatter.format(subtotal)}
Delivery Fee: ${currencyFormatter.format(deliveryFee)}
--------------------
TOTAL: ${currencyFormatter.format(total)}

To complete your order, please send the total amount via Mobile Money to:
Name: $paymentName
Number: $paymentNumber

Please reply to this message to confirm you agree with the total, and let us know once you have sent the payment. We will dispatch your order immediately after we receive it.

Thank you for choosing Green Gold!
""";
    });
  }

  Future<void> _launchUrl(Uri uri, String platformName) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open $platformName. Please make sure it is installed."))
        );
      }
    }
  }

  void _copyToClipboard(String text, String platformName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Message copied! Please paste it into your $platformName message."))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Order #${widget.order.id}"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Text("Customer Details", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: defaultPadding),
          IntlPhoneField(
            decoration: const InputDecoration(
                labelText: 'Customer Contact Number',
                border: OutlineInputBorder(),
            ),
            initialCountryCode: 'UG',
            initialValue: widget.order.customerContact,
            onChanged: (phone) {
              setState(() {
                _fullPhoneNumber = phone.completeNumber;
              });
            },
          ),
          const SizedBox(height: defaultPadding),

          Text("Order Details", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _deliveryFeeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter Delivery Fee",
              prefixText: "UGX ",
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _paymentNameController,
            decoration: const InputDecoration(labelText: "Payment Name"),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _paymentNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Payment Number"),
          ),
          const SizedBox(height: defaultPadding * 2),

          Text("Message Preview", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: defaultPadding),
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              // --- FIX IS HERE: Replaced deprecated .withOpacity() ---
              color: Theme.of(context).colorScheme.surface.withAlpha(128),
              borderRadius: BorderRadius.circular(defaultBorderRadious),
            ),
            child: Text(_messagePreview),
          ),
          const SizedBox(height: defaultPadding * 2),

          Text("Send Confirmation via", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.sms, size: 30),
                tooltip: "Send via SMS",
                onPressed: () => _launchUrl(Uri.parse('sms:$_fullPhoneNumber?body=${Uri.encodeComponent(_messagePreview)}'), "SMS"),
              ),
              // --- FIX IS HERE: Replaced non-existent Icons.whatsapp ---
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.green, size: 30),
                tooltip: "Send via WhatsApp",
                onPressed: () => _launchUrl(Uri.parse('https://wa.me/$_fullPhoneNumber?text=${Uri.encodeComponent(_messagePreview)}'), "WhatsApp"),
              ),
              IconButton(
                icon: const Icon(Icons.email, size: 30),
                tooltip: "Send via Email",
                onPressed: () => _launchUrl(Uri.parse('mailto:?subject=Your Green Gold Order Confirmation&body=${Uri.encodeComponent(_messagePreview)}'), "Email"),
              ),
              IconButton(
                icon: const Icon(Icons.snapchat, color: Colors.yellow, size: 30),
                tooltip: "Copy for Snapchat",
                onPressed: () => _copyToClipboard(_messagePreview, "Snapchat"),
              ),
               IconButton(
                icon: const Icon(Icons.camera_alt, size: 30),
                tooltip: "Copy for Instagram",
                onPressed: () => _copyToClipboard(_messagePreview, "Instagram"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}