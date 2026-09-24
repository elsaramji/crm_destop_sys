import 'dart:io';
import 'package:file_picker/file_picker.dart';

class DesktopFilePicker {
  /// Launches native OS file picker dialog to pick an Excel spreadsheet (.xlsx or .xls)
  static Future<String?> pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        dialogTitle: 'Select Excel Spreadsheet',
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null && path.trim().isNotEmpty && File(path).existsSync()) {
          return path.trim();
        }
      }
    } catch (_) {
      // Fallback to Windows native dialog if plugin is not available
      return _pickExcelFileWindowsFallback();
    }
    return null;
  }

  static Future<String?> _pickExcelFileWindowsFallback() async {
    if (!Platform.isWindows) return null;

    try {
      const psScript = '''
Add-Type -AssemblyName System.Windows.Forms
\$dialog = New-Object System.Windows.Forms.OpenFileDialog
\$dialog.Filter = "Excel Files (*.xlsx;*.xls)|*.xlsx;*.xls|All Files (*.*)|*.*"
\$dialog.Title = "Select Excel Spreadsheet"
\$dialog.CheckFileExists = \$true
if (\$dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output \$dialog.FileName
}
''';
      final res = await Process.run('powershell', ['-NoProfile', '-Command', psScript]);
      final path = res.stdout.toString().trim();
      if (path.isNotEmpty && File(path).existsSync()) {
        return path;
      }
    } catch (_) {}
    return null;
  }
}
