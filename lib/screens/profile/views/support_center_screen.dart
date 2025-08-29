// lib/screens/profile/views/support_center_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty || urlString.toLowerCase().contains('not set')) {
      showErrorSnackBar(context, "This link is not yet available.");
      return;
    }

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showErrorSnackBar(context, "Could not open the link.");
      }
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber.toLowerCase().contains('not set')) {
      showErrorSnackBar(context, "Contact number is not available.");
      return;
    }
    final String formattedNumber = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
    await _launchUrl("https://wa.me/$formattedNumber");
  }

  Future<void> _launchEmail(String email) async {
    if (email.isEmpty || email.toLowerCase().contains('not set')) {
      showErrorSnackBar(context, "Email is not available.");
      return;
    }
    await _launchUrl("mailto:$email");
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>().settings;
    final headOfficeNumber = settings['head_office_whatsapp'] ?? 'Not set';
    final supportEmail = settings['support_email'] ?? 'Not set';
    final tiktokLink = settings['tiktok_link'] ?? 'Not set';
    final instagramLink = settings['instagram_link'] ?? 'Not set';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support & Marketing"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contact Support",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding / 2),
            ContactCard(
              title: "Customer Care (WhatsApp)",
              contact: headOfficeNumber,
              icon: Icons.support_agent_outlined,
              onTap: () => _launchWhatsApp(headOfficeNumber),
            ),
            ContactCard(
              title: "Support Email",
              contact: supportEmail,
              icon: Icons.email_outlined,
              onTap: () => _launchEmail(supportEmail),
            ),
            const SizedBox(height: defaultPadding * 2),

            Text(
              "Follow Us",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding / 2),
            ContactCard(
              title: "TikTok",
              contact: "Follow for updates and offers",
              icon: Icons.music_note_outlined,
              onTap: () => _launchUrl(tiktokLink),
            ),
            ContactCard(
              title: "Instagram",
              contact: "Join our community",
              icon: Icons.camera_alt_outlined,
              onTap: () => _launchUrl(instagramLink),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.title,
    required this.contact,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String contact;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: defaultPadding / 2),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
