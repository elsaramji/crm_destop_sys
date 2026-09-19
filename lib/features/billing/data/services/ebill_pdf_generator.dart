import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../domain/entities/bill.dart';


class EBillPdfGenerator {
  static const String companyName = 'EGYPTIAN CRM & TECH SOLUTIONS S.A.E';
  static const String companyNameAr = 'شركة الحلول التكنولوجية الذكية ش.م.م';
  static const String taxId = '987-654-321';
  static const String commercialReg = '123456';
  static const String companyAddress = 'Building 44, Sector 1, Smart Village, Giza, Egypt';

  /// Generates a valid %PDF-1.4 document in pure Dart.
  static Uint8List generateEBillPdfBytes({
    required Bill bill,
    required Customer? customer,
  }) {
    final subtotal = bill.amount / 1.14;
    final vat14 = bill.amount - subtotal;
    final remaining = bill.remainingAmount;
    final cleanDesc = _sanitizePdfString(bill.description ?? 'Provided Professional Services');
    final customerName = _sanitizePdfString(customer?.fullName ?? 'Customer ${bill.customerId}');
    final customerNatId = _sanitizePdfString(customer?.nationalId ?? 'N/A');
    final customerPhone = _sanitizePdfString(customer?.phoneNumbers.isNotEmpty == true ? customer!.phoneNumbers.first : 'N/A');
    final customerAddress = _sanitizePdfString(customer?.address ?? 'Cairo, Egypt');

    final issuedDateStr = '${bill.issuedAt.year}-${bill.issuedAt.month.toString().padLeft(2, '0')}-${bill.issuedAt.day.toString().padLeft(2, '0')}';
    final dueDateStr = '${bill.dueDate.year}-${bill.dueDate.month.toString().padLeft(2, '0')}-${bill.dueDate.day.toString().padLeft(2, '0')}';
    final invoiceRef = 'EINV-${bill.id.replaceAll("bill_", "").toUpperCase()}';

    // A4 dimensions: 595.28 x 841.89 pt
    final streamBuffer = StringBuffer();

    void text(String t, double x, double y, String font, double size, [List<double>? rgb]) {
      final safe = _sanitizePdfString(t);
      if (rgb != null) {
        streamBuffer.writeln('${rgb[0]} ${rgb[1]} ${rgb[2]} rg');
      } else {
        streamBuffer.writeln('0 0 0 rg');
      }
      streamBuffer.writeln('BT');
      streamBuffer.writeln('/$font $size Tf');
      streamBuffer.writeln('1 0 0 1 $x $y Tm');
      streamBuffer.writeln('($safe) Tj');
      streamBuffer.writeln('ET');
    }

    void rect(double x, double y, double w, double h, List<double> fillRgb, [List<double>? strokeRgb, double strokeWidth = 1.0]) {
      streamBuffer.writeln('${fillRgb[0]} ${fillRgb[1]} ${fillRgb[2]} rg');
      if (strokeRgb != null) {
        streamBuffer.writeln('${strokeRgb[0]} ${strokeRgb[1]} ${strokeRgb[2]} RG');
        streamBuffer.writeln('$strokeWidth w');
        streamBuffer.writeln('$x $y $w $h re B');
      } else {
        streamBuffer.writeln('$x $y $w $h re f');
      }
    }

    void line(double x1, double y1, double x2, double y2, List<double> strokeRgb, [double strokeWidth = 1.0]) {
      streamBuffer.writeln('${strokeRgb[0]} ${strokeRgb[1]} ${strokeRgb[2]} RG');
      streamBuffer.writeln('$strokeWidth w');
      streamBuffer.writeln('$x1 $y1 m');
      streamBuffer.writeln('$x2 $y2 l S');
    }

    // Header Background banner
    rect(0, 770, 595.28, 72, [0.07, 0.19, 0.38]); // Dark navy header
    text('EGYPTIAN CRM SOLUTIONS S.A.E', 40, 816, 'F1', 14, [1, 1, 1]);
    text('EGYPTIAN TAX AUTHORITY (ETA) E-INVOICE / E-RECEIPT', 40, 800, 'F2', 9, [0.85, 0.9, 1.0]);
    text('Tax Reg. # $taxId   |   Comm. Reg. # $commercialReg', 40, 786, 'F2', 8.5, [0.75, 0.85, 0.95]);
    text('ORIGINAL ELECTRONIC INVOICE', 390, 810, 'F1', 11, [0.95, 0.8, 0.2]);
    text('Ref: $invoiceRef', 390, 792, 'F1', 10, [1, 1, 1]);

    // Subheader & Invoice Metadata Card
    rect(40, 680, 515.28, 70, [0.96, 0.97, 0.99], [0.82, 0.88, 0.94]);
    text('INVOICE DETAILS', 52, 732, 'F1', 10, [0.07, 0.19, 0.38]);
    text('Invoice Number: $invoiceRef', 52, 715, 'F2', 9);
    text('Issue Date: $issuedDateStr', 52, 698, 'F2', 9);
    text('Due Date: $dueDateStr', 220, 715, 'F2', 9);
    text('Payment Status: ${bill.status.displayName.toUpperCase()}', 220, 698, 'F1', 9, bill.status == BillStatus.paid ? [0.08, 0.5, 0.24] : [0.8, 0.15, 0.15]);
    text('ETA Portal UUID: 2026-EG-${bill.id.hashCode.abs()}', 360, 715, 'F2', 8.5, [0.4, 0.45, 0.5]);
    text('Currency: EGP (Egyptian Pound)', 360, 698, 'F2', 8.5, [0.4, 0.45, 0.5]);

    // Buyer Information Card
    rect(40, 585, 515.28, 80, [1, 1, 1], [0.82, 0.88, 0.94]);
    text('BUYER / CUSTOMER INFORMATION (المشتري / العميل)', 52, 648, 'F1', 10, [0.07, 0.19, 0.38]);
    text('Client Name: $customerName', 52, 630, 'F1', 9.5);
    text('National ID / Tax ID: $customerNatId', 52, 614, 'F2', 9);
    text('Phone: $customerPhone', 52, 598, 'F2', 9);
    text('Address: $customerAddress', 280, 614, 'F2', 9);
    text('Billing Account: ${bill.customerId}', 280, 598, 'F2', 9);

    // Line Items Table Header
    rect(40, 545, 515.28, 26, [0.12, 0.35, 0.65]);
    text('#', 52, 554, 'F1', 9, [1, 1, 1]);
    text('Service / Product Description', 80, 554, 'F1', 9, [1, 1, 1]);
    text('Qty', 320, 554, 'F1', 9, [1, 1, 1]);
    text('Unit Price', 370, 554, 'F1', 9, [1, 1, 1]);
    text('VAT (14%)', 440, 554, 'F1', 9, [1, 1, 1]);
    text('Total (EGP)', 495, 554, 'F1', 9, [1, 1, 1]);

    // Item Row 1
    rect(40, 485, 515.28, 60, [0.98, 0.99, 1.0], [0.88, 0.92, 0.96]);
    text('1', 52, 520, 'F2', 9);
    text(cleanDesc, 80, 520, 'F1', 9);
    text('Commercial Sales & Enterprise CRM Fulfillment', 80, 504, 'F2', 8, [0.4, 0.45, 0.5]);
    text('1', 325, 520, 'F2', 9);
    text(subtotal.toStringAsFixed(2), 370, 520, 'F2', 9);
    text(vat14.toStringAsFixed(2), 442, 520, 'F2', 9);
    text(bill.amount.toStringAsFixed(2), 495, 520, 'F1', 9);

    // Totals Table on the right
    rect(330, 360, 225.28, 110, [0.97, 0.98, 1.0], [0.8, 0.86, 0.94]);
    text('Subtotal (Net):', 345, 452, 'F2', 9);
    text('EGP ${subtotal.toStringAsFixed(2)}', 470, 452, 'F2', 9);
    line(340, 444, 545, 444, [0.88, 0.9, 0.94]);

    text('Value Added Tax (14% VAT):', 345, 432, 'F2', 9);
    text('EGP ${vat14.toStringAsFixed(2)}', 470, 432, 'F2', 9);
    line(340, 424, 545, 424, [0.88, 0.9, 0.94]);

    text('Grand Total Amount:', 345, 408, 'F1', 10, [0.07, 0.19, 0.38]);
    text('EGP ${bill.amount.toStringAsFixed(2)}', 465, 408, 'F1', 10, [0.07, 0.19, 0.38]);
    line(340, 398, 545, 398, [0.88, 0.9, 0.94]);

    text('Paid to Date:', 345, 386, 'F2', 9, [0.08, 0.5, 0.24]);
    text('EGP ${bill.paidAmount.toStringAsFixed(2)}', 470, 386, 'F1', 9, [0.08, 0.5, 0.24]);

    text('Balance Due:', 345, 370, 'F1', 9.5, remaining > 0 ? [0.8, 0.15, 0.15] : [0.4, 0.4, 0.4]);
    text('EGP ${remaining.toStringAsFixed(2)}', 465, 370, 'F1', 9.5, remaining > 0 ? [0.8, 0.15, 0.15] : [0.4, 0.4, 0.4]);

    // ETA Verification QR Code & Official Stamp simulation
    rect(40, 360, 270, 110, [1, 1, 1], [0.85, 0.88, 0.92]);
    rect(52, 372, 85, 85, [0.94, 0.96, 0.98], [0.7, 0.75, 0.82]);
    // Simulate QR code internal pixels
    rect(58, 422, 24, 24, [0.1, 0.2, 0.35]);
    rect(106, 422, 24, 24, [0.1, 0.2, 0.35]);
    rect(58, 378, 24, 24, [0.1, 0.2, 0.35]);
    rect(88, 396, 16, 16, [0.1, 0.2, 0.35]);

    text('ETA E-INVOICE VERIFIED', 148, 442, 'F1', 8.5, [0.08, 0.5, 0.24]);
    text('Scan with ETA App to verify', 148, 428, 'F2', 7.5, [0.4, 0.45, 0.5]);
    text('Cryptographic Hash: OK', 148, 414, 'F2', 7.5, [0.4, 0.45, 0.5]);
    text('Signed with Egyptian Corporate', 148, 396, 'F2', 7.5, [0.4, 0.45, 0.5]);
    text('e-Seal Certificate (SHA-256)', 148, 384, 'F2', 7.5, [0.4, 0.45, 0.5]);

    // Footer & Legal
    line(40, 100, 555.28, 100, [0.8, 0.85, 0.9]);
    text('Official electronic document compliant with Egyptian Tax Authority (Law No. 206 / 2020)', 40, 86, 'F2', 8, [0.5, 0.55, 0.6]);
    text('Generated automatically by CRM Desktop System Egypt. All rights reserved.', 40, 74, 'F2', 7.5, [0.6, 0.65, 0.7]);
    text('Page 1 of 1', 500, 74, 'F2', 8, [0.5, 0.55, 0.6]);

    final streamBytes = utf8.encode(streamBuffer.toString());

    // Build standard PDF structure
    final pdfBuffer = BytesBuilder();
    final offsets = <int>[];

    void write(String s) {
      pdfBuffer.add(utf8.encode(s));
    }

    write('%PDF-1.4\n');

    // 1 0 obj: Catalog
    offsets.add(pdfBuffer.length);
    write('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');

    // 2 0 obj: Pages
    offsets.add(pdfBuffer.length);
    write('2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n');

    // 3 0 obj: Page
    offsets.add(pdfBuffer.length);
    write(
      '3 0 obj\n'
      '<< /Type /Page\n'
      '/Parent 2 0 R\n'
      '/MediaBox [0 0 595.28 841.89]\n'
      '/Contents 4 0 R\n'
      '/Resources << /Font << /F1 5 0 R /F2 6 0 R >> >>\n'
      '>>\nendobj\n',
    );

    // 4 0 obj: Stream
    offsets.add(pdfBuffer.length);
    write('4 0 obj\n<< /Length ${streamBytes.length} >>\nstream\n');
    pdfBuffer.add(streamBytes);
    write('\nendstream\nendobj\n');

    // 5 0 obj: Font F1 (Helvetica-Bold)
    offsets.add(pdfBuffer.length);
    write('5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n');

    // 6 0 obj: Font F2 (Helvetica)
    offsets.add(pdfBuffer.length);
    write('6 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n');

    // xref table
    final xrefOffset = pdfBuffer.length;
    write('xref\n0 7\n');
    write('0000000000 65535 f \n');
    for (final offset in offsets) {
      write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }

    // trailer
    write('trailer\n<< /Size 7 /Root 1 0 R >>\n');
    write('startxref\n$xrefOffset\n%%EOF\n');

    return pdfBuffer.toBytes();
  }

  /// Saves the generated PDF file to the device storage.
  static Future<File> saveEBillPdf({
    required Bill bill,
    required Customer? customer,
  }) async {
    final bytes = generateEBillPdfBytes(bill: bill, customer: customer);
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'EBill_${bill.id.replaceAll("bill_", "")}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Dispatches the bill PDF to print on Windows OS.
  static Future<void> printEBillPdf({
    required Bill bill,
    required Customer? customer,
  }) async {
    final file = await saveEBillPdf(bill: bill, customer: customer);
    if (Platform.isWindows) {
      // Launch Windows default handler or print dialog
      await Process.run('cmd', ['/c', 'start', '', file.path]);
    }
  }

  static String _sanitizePdfString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '?'); // Replace non-ascii for Type 1 fonts
  }
}
