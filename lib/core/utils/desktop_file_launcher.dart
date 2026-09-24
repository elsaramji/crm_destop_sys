import 'dart:io';

class DesktopFileLauncher {
  /// Opens the file using the default associated OS application (e.g. Microsoft Excel)
  static Future<void> openFile(String filePath) async {
    if (filePath.isEmpty) return;

    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '""', filePath], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [filePath]);
      }
    } catch (_) {
      // Fallback on Windows to explorer.exe if cmd start fails
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [filePath]);
      }
    }
  }

  /// Opens the folder in Windows Explorer and selects/highlights the file
  static Future<void> revealInFolder(String filePath) async {
    if (filePath.isEmpty) return;

    try {
      if (Platform.isWindows) {
        await Process.run('explorer.exe', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        final dir = File(filePath).parent.path;
        await Process.run('xdg-open', [dir]);
      }
    } catch (_) {}
  }
}
