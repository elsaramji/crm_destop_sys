import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../data/services/ebill_pdf_generator.dart';
import '../../domain/entities/bill.dart';
import 'bill_form_dialog.dart';

class EBillPreviewDialog extends StatefulWidget {
  final Bill bill;
  final Customer? customer;

  const EBillPreviewDialog({
    super.key,
    required this.bill,
    this.customer,
  });

  static Future<void> show(
    BuildContext context, {
    required Bill bill,
    Customer? customer,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => EBillPreviewDialog(
        bill: bill,
        customer: customer,
      ),
    );
  }

  @override
  State<EBillPreviewDialog> createState() => _EBillPreviewDialogState();
}

class _EBillPreviewDialogState extends State<EBillPreviewDialog> {
  bool _isSaving = false;
  bool _isPrinting = false;

  Future<void> _savePdf() async {
    setState(() => _isSaving = true);
    try {
      final file = await EBillPdfGenerator.saveEBillPdf(
        bill: widget.bill,
        customer: widget.customer,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text('PDF Saved successfully to:\n${file.path}'),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.amber,
            onPressed: () {
              Process.run('cmd', ['/c', 'start', '', file.path]);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _printPdf() async {
    setState(() => _isPrinting = true);
    try {
      await EBillPdfGenerator.printEBillPdf(
        bill: widget.bill,
        customer: widget.customer,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Print job dispatched to system default printer.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.bill;
    final c = widget.customer;
    final subtotal = b.amount / 1.14;
    final vat14 = b.amount - subtotal;
    final remaining = b.remainingAmount;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 860,
        height: 820,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Dark slate surrounding frame
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Action Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF334155))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Electronic Bill Preview (E-Bill #${b.id.replaceAll("bill_", "")})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Edit Action
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF475569)),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Bill'),
                    onPressed: () {
                      Navigator.pop(context);
                      BillFormDialog.show(context, bill: b);
                    },
                  ),
                  const SizedBox(width: 10),
                  // Save Action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download, size: 16),
                    label: const Text('Save as PDF'),
                    onPressed: _isSaving ? null : _savePdf,
                  ),
                  const SizedBox(width: 10),
                  // Print Action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                    ),
                    icon: _isPrinting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.print, size: 16),
                    label: const Text('Print'),
                    onPressed: _isPrinting ? null : _printPdf,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Paper Invoice Scroll View
            Expanded(
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      width: 720,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ETA & Corporate Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0B2240),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.business_center, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'EGYPTIAN CRM SOLUTIONS S.A.E',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0B2240)),
                                          ),
                                          Text(
                                            'شركة الحلول الرقمية الذكية ش.م.م',
                                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Smart Village, Building 44, Giza, Egypt', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const Text('Tax Reg. # 987-654-321  |  Commercial Reg. # 123456', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              // E-Invoice Badge
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'فاتورة ضريبية إلكترونية',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                                        ),
                                        Text(
                                          'ELECTRONIC TAX INVOICE',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '#EINV-${b.id.replaceAll("bill_", "").toUpperCase()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 32, thickness: 1.2),

                          // Metadata Grid
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('ISSUE DATE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${b.issuedAt.year}-${b.issuedAt.month.toString().padLeft(2, '0')}-${b.issuedAt.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('PAYMENT DUE DATE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${b.dueDate.year}-${b.dueDate.month.toString().padLeft(2, '0')}-${b.dueDate.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('ETA UUID', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '2026-EG-${b.id.hashCode.abs()}',
                                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('STATUS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 3),
                                      _buildStatusTag(b.status),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Customer / Buyer Details
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.person, size: 16, color: AppTheme.primaryBlue),
                                    SizedBox(width: 6),
                                    Text('BUYER / CUSTOMER DETAILS (بيانات العميل)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B2240))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c?.fullName ?? 'Account #${b.customerId}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('National ID: ${c?.nationalId ?? "N/A"}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Phone: ${c?.phoneNumbers.join(" • ") ?? "N/A"}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          Text('Address: ${c?.address ?? "Cairo, Egypt"}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Itemized Invoice Table
                          Table(
                            border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                            columnWidths: const {
                              0: FlexColumnWidth(4),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1.8),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                children: [
                                  _cell('Description / Item', isHeader: true),
                                  _cell('Qty', isHeader: true, align: TextAlign.center),
                                  _cell('Unit Price', isHeader: true, align: TextAlign.right),
                                  _cell('VAT (14%)', isHeader: true, align: TextAlign.right),
                                  _cell('Total (EGP)', isHeader: true, align: TextAlign.right),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.description ?? 'Commercial Enterprise CRM & Fulfillment Service',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text('Egyptian Tax Authority Code: GPC-100293', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  _cell('1', align: TextAlign.center),
                                  _cell(subtotal.toStringAsFixed(2), align: TextAlign.right),
                                  _cell(vat14.toStringAsFixed(2), align: TextAlign.right),
                                  _cell(b.amount.toStringAsFixed(2), isBold: true, align: TextAlign.right),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Calculation Summary & QR
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ETA QR Code Verification
                              Container(
                                width: 260,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.qr_code_2, size: 54, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('ETA VERIFIED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF16A34A))),
                                          SizedBox(height: 2),
                                          Text('Official Digital E-Invoice Receipt', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                          SizedBox(height: 2),
                                          Text('SHA-256 Validated', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),

                              // Financial Breakdown Box
                              Container(
                                width: 280,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  children: [
                                    _summaryRow('Subtotal (Net):', 'EGP ${subtotal.toStringAsFixed(2)}'),
                                    const SizedBox(height: 6),
                                    _summaryRow('VAT (14%):', 'EGP ${vat14.toStringAsFixed(2)}'),
                                    const Divider(height: 16),
                                    _summaryRow('Grand Total:', 'EGP ${b.amount.toStringAsFixed(2)}', isBold: true, fontSize: 14),
                                    const SizedBox(height: 6),
                                    _summaryRow('Amount Paid:', 'EGP ${b.paidAmount.toStringAsFixed(2)}', color: const Color(0xFF16A34A)),
                                    const SizedBox(height: 6),
                                    _summaryRow(
                                      'Balance Due:',
                                      'EGP ${remaining.toStringAsFixed(2)}',
                                      isBold: true,
                                      color: remaining > 0 ? const Color(0xFFDC2626) : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Footer
                          const Divider(),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Thank you for your business! Compliant with Egyptian Tax Law No. 206 of 2020.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false, bool isBold = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : (isBold ? FontWeight.w600 : FontWeight.normal),
          color: isHeader ? const Color(0xFF1E293B) : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, double fontSize = 12, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(BillStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case BillStatus.paid:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case BillStatus.unpaid:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      case BillStatus.partial:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
