class AppInfo {
  // ============================================================
  // FRAMES RELEASE IDENTITY
  // ============================================================

  static const String appName = "Frames";

  static const String versionName = "3.1.0";

  static const String buildNumber = "302";

  static const String buildCodename =
      "Still";

  static const String releaseType =
      "Stable";

  // Short UI label
  static String get display =>
      "$appName $versionName · Build $buildNumber";

  // Detailed release information
  static String get fullInfo =>
      "$appName $versionName+$buildNumber · "
          "$buildCodename · $releaseType";

  // Version shown in What's New
  static String get releaseLabel =>
      "BUILD $buildNumber";

  // Human-friendly release title
  static String get releaseTitle =>
      "Frames · $buildCodename";

  // Compact version for settings/footer
  static String get compact =>
      "v$versionName";

  // Complete developer/build identifier
  static String get buildIdentity =>
      "$appName/$versionName+$buildNumber "
          "($buildCodename)";

  // Used for the What's New section
  static String get whatsNewTitle =>
      "What's New in $buildCodename";

  static String get whatsNewSubtitle =>
      "A refined Frames experience.";
}