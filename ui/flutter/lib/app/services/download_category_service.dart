import 'dart:convert';

import 'package:path/path.dart' as path;

import '../../api/model/downloader_config.dart';

class DownloadCategoryService {
  static List<DownloadCategory> buildDefaultCategories(String downloadDir) {
    return [
      DownloadCategory(
        name: '',
        path: path.join(downloadDir, 'Music'),
        isBuiltIn: true,
        nameKey: 'categoryMusic',
        extensions: const ['mp3', 'flac', 'wav', 'aac', 'm4a', 'ogg', 'wma'],
      ),
      DownloadCategory(
        name: '',
        path: path.join(downloadDir, 'Video'),
        isBuiltIn: true,
        nameKey: 'categoryVideo',
        extensions: const [
          'mp4',
          'mkv',
          'avi',
          'mov',
          'wmv',
          'flv',
          'webm',
          'm4v',
        ],
      ),
      DownloadCategory(
        name: '',
        path: path.join(downloadDir, 'Document'),
        isBuiltIn: true,
        nameKey: 'categoryDocument',
        extensions: const [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'md',
          'rtf',
        ],
      ),
      DownloadCategory(
        name: '',
        path: path.join(downloadDir, 'Program'),
        isBuiltIn: true,
        nameKey: 'categoryProgram',
        extensions: const [
          'exe',
          'msi',
          'apk',
          'ipa',
          'dmg',
          'pkg',
          'deb',
          'rpm',
          'appimage',
        ],
      ),
      DownloadCategory(
        name: '',
        path: path.join(downloadDir, 'Archive'),
        isBuiltIn: true,
        nameKey: 'categoryArchive',
        extensions: const [
          '7z',
          'zip',
          'rar',
          'tar',
          'gz',
          'bz2',
          'xz',
          'tgz',
        ],
      ),
    ];
  }

  static List<DownloadCategory> activeCategories(ExtraConfig extra) {
    return extra.downloadCategories.where((e) => !e.isDeleted).toList();
  }

  static String extensionsToText(List<String> extensions) {
    return extensions.map((e) => e.toLowerCase()).join(', ');
  }

  static List<String> parseExtensionsText(String text) {
    return text
        .split(RegExp(r'[\s,;\n\r\uFF0C\uFF1B]+'))
        .map((e) => e.trim().toLowerCase().replaceFirst(RegExp(r'^\.+'), ''))
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  static String? inferFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isEmpty) {
        return null;
      }
      final last = uri.pathSegments.last.trim();
      if (last.isEmpty) {
        return null;
      }
      return Uri.decodeComponent(last);
    } catch (_) {
      return null;
    }
  }

  static DownloadCategory? matchCategory(
      ExtraConfig extra, String? fileNameOrUrl) {
    if (!extra.downloadCategoriesEnabled || fileNameOrUrl == null) {
      return null;
    }
    final fileName = fileNameOrUrl.contains('://')
        ? inferFileNameFromUrl(fileNameOrUrl)
        : fileNameOrUrl;
    if (fileName == null || fileName.trim().isEmpty) {
      return null;
    }
    final ext = path.extension(fileName).toLowerCase().replaceFirst('.', '');
    if (ext.isEmpty) {
      return null;
    }
    for (final category in activeCategories(extra)) {
      if (category.extensions.map((e) => e.toLowerCase()).contains(ext)) {
        return category;
      }
    }
    return null;
  }

  static bool shouldApplyAutoCategory(
      DownloaderConfig config, String? currentPath) {
    if (!config.extra.downloadCategoriesEnabled) {
      return false;
    }
    if (currentPath == null || currentPath.trim().isEmpty) {
      return true;
    }
    if (currentPath == config.downloadDir) {
      return true;
    }
    return activeCategories(config.extra).any((e) => e.path == currentPath);
  }

  static String resolveDownloadPath(
    DownloaderConfig config, {
    required String currentPath,
    String? fileName,
    String? url,
  }) {
    if (!shouldApplyAutoCategory(config, currentPath)) {
      return currentPath;
    }
    final category =
        matchCategory(config.extra, fileName) ?? matchCategory(config.extra, url);
    return category?.path ?? currentPath;
  }

  static String normalizePathValue(String text) {
    final value = text.trim();
    if (value.startsWith('"') && value.endsWith('"') && value.length > 1) {
      return jsonDecode(value) as String;
    }
    return value;
  }
}
