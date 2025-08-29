# Flutter's main rules. This is the official set that prevents release-mode crashes.
-dontwarn io.flutter.embedding.**
-keep class io.flutter.embedding.android.FlutterActivityAndFragmentDelegate { *; }
-keep class io.flutter.embedding.android.FlutterFragment { *; }
-keep class io.flutter.embedding.android.FlutterView { *; }
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.engine.dart.DartExecutor { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.embedding.engine.plugins.shim.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# This rule is for the specific text input/stylus crash you are seeing.
-keep class androidx.core.view.inputmethod.EditorInfoCompat.** { *; }

# Keep Supabase classes (as you are using it)
-keep class io.supabase.** { *; }
-keepnames class io.supabase.** { *; }
-keepclassmembers class io.supabase.** { *; }