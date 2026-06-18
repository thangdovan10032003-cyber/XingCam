# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Isar Database Rules (prevent stripping JNI bindings)
-keep class dev.isar.** { *; }

# Google ML Kit (prepared for upcoming Phase 4)
-keep class com.google.mlkit.** { *; }

# Google Play Core / Deferred Components Exceptions (fixes R8 crash)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
