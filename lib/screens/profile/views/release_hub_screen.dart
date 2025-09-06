// lib/screens/profile/views/release_hub_screen.dart

import 'dart:io'; // This is safe as long as it's only called in the native path
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // IMPORTED FOR WEB CHECK
import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/settings_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // IMPORTED FOR WEB DOWNLOADS

// Enum remains the same
enum DownloadStatus { idle, fetching, downloading, downloaded, error }

class ReleaseHubScreen extends StatefulWidget {
  const ReleaseHubScreen({super.key});

  @override
  State<ReleaseHubScreen> createState() => _ReleaseHubScreenState();
}

class _ReleaseHubScreenState extends State<ReleaseHubScreen> {
  // All state variables remain the same
  bool _isLoading = true;
  String _currentVersion = '0.0.0';
  String _latestVersion = '0.0.0';
  String _apkUrl = '';
  String _releaseNotes = '';
  bool _isUpdateAvailable = false;

  final Dio _dio = Dio();
  DownloadStatus _status = DownloadStatus.idle;
  double _progress = 0.0;
  String _filePath = '';
  CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _loadUpdateInfo();
  }

  Future<void> _loadUpdateInfo() async {
    try {
      // --- THIS IS THE REFRESH FUNCTIONALITY FIX ---
      // Force the settings service to refetch the latest data from Supabase NOW.
      await Provider.of<SettingsService>(context, listen: false).initializeSettings();
      // --- END OF FIX ---

      PackageInfo? info;
      // PackageInfo only works on native. On web, we'll just skip this
      if (!kIsWeb) {
        info = await PackageInfo.fromPlatform();
        _currentVersion = info.version;
      }
      
      // Now this will get the newly fetched settings, not the old cached ones.
      final settings = Provider.of<SettingsService>(context, listen: false).settings;
      final latestVersion = settings['latest_app_version'] ?? '0.0.0';

      setState(() {
        _latestVersion = latestVersion;
        _apkUrl = settings['android_apk_link'] ?? '';
        _releaseNotes = settings['latest_release_notes'] ?? 'No release notes available.';
        _isUpdateAvailable = _currentVersion != _latestVersion;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Failed to load update info: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  // --- NATIVE DOWNLOAD/INSTALL FUNCTIONS (Unchanged) ---
  // These will ONLY be called by the native Android UI path.
  Future<void> _startDownload() async {
    if (_apkUrl.isEmpty) {
      showErrorSnackBar(context, "Download link is not available.");
      return;
    }
    setState(() { _status = DownloadStatus.downloading; _progress = 0.0; _cancelToken = CancelToken(); });
    try {
      final dir = await getExternalStorageDirectory();
      final savePath = '${dir?.path}/greengold-$_latestVersion.apk';
      await _dio.download(
        _apkUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) setState(() => _progress = received / total);
        },
      );
      if (!_cancelToken.isCancelled) {
        setState(() { _status = DownloadStatus.downloaded; _filePath = savePath; });
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        setState(() { _status = DownloadStatus.idle; _progress = 0.0; });
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download cancelled.")));
      } else {
        setState(() => _status = DownloadStatus.error);
        if (mounted) showErrorSnackBar(context, "Download failed: $e");
      }
    }
  }

  void _cancelDownload() {
    _cancelToken.cancel("Download cancelled by user.");
  }

  Future<void> _installUpdate() async {
    if (_filePath.isEmpty) return;
    final result = await OpenFilex.open(_filePath);
    if (result.type != ResultType.done && mounted) {
       showErrorSnackBar(context, "Could not open installer: ${result.message}");
    }
  }
  // --- END OF NATIVE FUNCTIONS ---


  // --- WEB DOWNLOAD FUNCTION ---
  Future<void> _launchApkUrl() async {
    if (_apkUrl.isEmpty) {
      showErrorSnackBar(context, "Download link is not yet available.");
      return;
    }
    final Uri url = Uri.parse(_apkUrl);
    if (await canLaunchUrl(url)) {
      // This will trigger a standard browser download
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) showErrorSnackBar(context, "Could not launch download link.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Updates"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(defaultPadding),
              children: [
                _buildHeader(),
                const SizedBox(height: defaultPadding * 2),
                Text("What's New in v$_latestVersion", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: defaultPadding / 2),
                Text(_releaseNotes),
                const Divider(height: defaultPadding * 2),

                // This WidgetBuilder dynamically decides what to show based on platform.
                Builder(
                  builder: (context) {
                    if (kIsWeb) {
                      // If we are in a browser, show the Web Download Portal UI
                      return _buildWebUI();
                    } else {
                      // If we are native, run the native platform logic
                      if (Platform.isAndroid) {
                        return _buildAndroidUI();
                      } else if (Platform.isIOS) {
                        // For a native iOS app (if we ever build one)
                        return _buildIosUI();
                      }
                      return const Text("App updates are not supported on this platform.");
                    }
                  }
                )
              ],
            ),
    );
  }

  /// Header widget (Now web-aware)
  Widget _buildHeader() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Image.asset("assets/logo/logo.png", height: 80, width: 80),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Green Gold", style: Theme.of(context).textTheme.headlineSmall),
                  if (!kIsWeb) // Only show current version if we are native
                    Text("Current Version: $_currentVersion", style: Theme.of(context).textTheme.bodySmall),
                  if (_isUpdateAvailable && !kIsWeb)
                    Text("Latest Version: $_latestVersion", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: successColor)),
                  if (kIsWeb) // On web, just show the latest version
                     Text("Latest Version: $_latestVersion", style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Native Android UI (unchanged, this is the "App Store" flow)
  Widget _buildAndroidUI() {
    if (!_isUpdateAvailable) {
      return const ListTile(
        leading: Icon(Icons.check_circle, color: successColor),
        title: Text("You are up to date"),
        subtitle: Text("You have the latest version installed."),
      );
    }
    switch (_status) {
      case DownloadStatus.idle:
        return ElevatedButton.icon(
          icon: const Icon(Icons.download_for_offline),
          label: Text("Download Update (v$_latestVersion)"),
          onPressed: _startDownload,
        );
      case DownloadStatus.downloading:
        return Column(
          children: [
            LinearProgressIndicator(value: _progress, minHeight: 10, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: defaultPadding),
            Text("Downloading... ${(_progress * 100).toStringAsFixed(0)}%"),
             const SizedBox(height: defaultPadding),
            TextButton.icon(
              icon: const Icon(Icons.cancel, color: errorColor),
              label: const Text("Cancel Download", style: TextStyle(color: errorColor)),
              onPressed: _cancelDownload,
            )
          ],
        );
      case DownloadStatus.downloaded:
        return Column(
          children: [
             ElevatedButton.icon(
              icon: const Icon(Icons.install_mobile),
              label: const Text("Install Now"),
              onPressed: _installUpdate,
            ),
             const SizedBox(height: defaultPadding),
             const Text(
              "Note: You may need to 'Allow installs from this source' in your phone's settings when prompted.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        );
      case DownloadStatus.error:
         return ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Retry Download"),
          onPressed: _startDownload,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// iOS PWA Instructions UI (Corrected)
  Widget _buildIosUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // <-- SYNTAX FIX IS HERE
      children: [
        Text("How to Install on iOS", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: defaultPadding),
        const ListTile( // Added 'const'
          leading: Icon(Icons.launch),
          title: Text("Open in Safari"),
          subtitle: Text("This app must be open in the Safari browser."),
        ),
        const ListTile( // Added 'const'
          leading: Icon(Icons.ios_share),
          title: Text("Tap the 'Share' Icon"),
          subtitle: Text("It's the square icon with an arrow pointing up at the bottom of the screen."),
        ),
        const ListTile( // Added 'const'
          leading: Icon(Icons.add_to_home_screen),
          title: Text("Add to Home Screen"),
          subtitle: Text("Scroll down the list and tap 'Add to Home Screen' to install the app."),
        ),
      ],
    );
  }

  /// --- WEB UI ---
  /// This is the "Download Portal" shown to all browser users.
  Widget _buildWebUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Get Our App", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: defaultPadding),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          child: ListTile(
            leading: const Icon(Icons.android, color: successColor, size: 40),
            title: const Text("Download for Android"),
            subtitle: Text("Get the native .apk installer (v$_latestVersion)"),
            trailing: const Icon(Icons.download),
            onTap: _launchApkUrl, // This calls our web download function
          ),
        ),
        const Divider(height: defaultPadding * 2),
        // We reuse the iOS PWA instructions, as a web user might be on an iPhone.
        _buildIosUI(),
      ],
    );
  }
}