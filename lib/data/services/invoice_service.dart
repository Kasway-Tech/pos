import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../../app/helpers/format_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../app/invoice/invoice_state.dart';
import '../models/cart_item.dart';

/// Pre-captured localised strings passed to [InvoiceService] to avoid
/// needing a BuildContext inside a pure-Dart service.
class InvoiceStrings {
  const InvoiceStrings({
    required this.date,
    required this.table,
    required this.txId,
    required this.item,
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.grandTotal,
    required this.kasPaid,
    required this.verify,
    required this.invoiceLabel,
  });

  final String date;
  final String table;
  final String txId;
  final String item;
  final String qty;
  final String unitPrice;
  final String total;
  final String grandTotal;
  final String kasPaid;
  final String verify;
  final String invoiceLabel;

  /// Formats the exchange-rate line: "1 KAS = USD 1.36"
  String rateLabel(String kasSymbol, String amount) =>
      '1 $kasSymbol = $amount';
}

class InvoiceService {
  /// Builds a PDF invoice and opens the system print dialog.
  ///
  /// This method is intentionally fire-and-forget: callers should call it with
  /// [unawaited] and attach a [Future.catchError] to suppress print-dialog
  /// cancellations without crashing the app.
  Future<void> printInvoice({
    required InvoiceState settings,
    required List<CartItem> cartItems,
    required double totalIdr,
    required String txId,
    required double kasAmount,
    required double kasIdrRate,
    required String kasSymbol,
    required bool isCryptoMode,
    required String Function(double idrPrice) formatPrice,
    required String explorerUrl,
    required InvoiceStrings strings,
    String? tableLabel,
  }) async {
    final doc = pw.Document();

    final now = DateTime.now();
    final dateStr =
        DateFormat('dd MMM yyyy, HH:mm').format(now);

    // ── Build line items ──────────────────────────────────────────────────
    final List<pw.TableRow> itemRows = [];

    // Header row
    itemRows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
        ),
      ),
      children: [
        _headerCell(strings.item),
        _headerCell(strings.qty, align: pw.TextAlign.center),
        _headerCell(strings.unitPrice, align: pw.TextAlign.right),
        _headerCell(strings.total, align: pw.TextAlign.right),
      ],
    ));

    for (final item in cartItems) {
      final unitPrice = item.product.price +
          item.selectedAdditions.fold(0.0, (s, a) => s + a.price);
      final lineTotal = unitPrice * item.quantity;

      itemRows.add(pw.TableRow(children: [
        _cell(item.product.name),
        _cell(item.quantity.toString(), align: pw.TextAlign.center),
        _cell(formatPrice(unitPrice), align: pw.TextAlign.right),
        _cell(formatPrice(lineTotal), align: pw.TextAlign.right),
      ]));

      // Addition sub-rows
      for (final addition in item.selectedAdditions) {
        itemRows.add(pw.TableRow(children: [
          _cell('  + ${addition.name}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              )),
          _cell('', align: pw.TextAlign.center),
          _cell('+${formatPrice(addition.price)}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
              align: pw.TextAlign.right),
          _cell('', align: pw.TextAlign.right),
        ]));
      }
    }

    // ── KAS rate formatting ───────────────────────────────────────────────
    final kasAmountStr =
        kasAmount > 0 ? '$kasSymbol ${formatKas(kasAmount)}' : '-- $kasSymbol';

    String rateStr = '--';
    if (!isCryptoMode && kasIdrRate > 0) {
      // Format 1 KAS in the display currency
      // We pass formatPrice which converts IDR → display currency,
      // so pass kasIdrRate (the IDR value of 1 KAS).
      rateStr = formatPrice(kasIdrRate);
    }

    // ── QR code ──────────────────────────────────────────────────────────
    final qrWidget = pw.BarcodeWidget(
      barcode: pw.Barcode.qrCode(),
      data: explorerUrl,
      width: 80,
      height: 80,
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Header: business info ─────────────────────────────────
            pw.Text(
              settings.businessName,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(settings.businessAddress,
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text(settings.businessPhone,
                style: const pw.TextStyle(fontSize: 10)),
            pw.Divider(color: PdfColors.grey400, height: 16),

            // ── Invoice meta ─────────────────────────────────────────
            pw.Text(
              strings.invoiceLabel.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 6),
            _metaRow(strings.date, dateStr),
            if (tableLabel != null && tableLabel.isNotEmpty)
              _metaRow(strings.table, tableLabel),
            _metaRow(strings.txId, _truncateTxId(txId)),
            pw.Divider(color: PdfColors.grey400, height: 16),

            // ── Line items ───────────────────────────────────────────
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FixedColumnWidth(32),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(2.5),
              },
              children: itemRows,
            ),
            pw.Divider(color: PdfColors.grey400, height: 16),

            // ── Totals ───────────────────────────────────────────────
            _totalRow(strings.grandTotal, formatPrice(totalIdr), bold: true),
            pw.SizedBox(height: 4),
            if (!isCryptoMode || kasAmount > 0) ...[
              _totalRow(strings.kasPaid, kasAmountStr),
              if (!isCryptoMode && kasIdrRate > 0)
                _totalRow(
                  strings.rateLabel(kasSymbol, rateStr),
                  '',
                ),
            ],
            pw.Divider(color: PdfColors.grey400, height: 16),

            // ── QR code ──────────────────────────────────────────────
            pw.Center(child: qrWidget),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                strings.verify,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────
            if (settings.footerText.trim().isNotEmpty) ...[
              pw.Divider(color: PdfColors.grey400, height: 16),
              pw.Center(
                child: pw.Text(
                  settings.footerText.trim(),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final filename = 'invoice_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
    final bytes = await doc.save();

    // On macOS, Printing.layoutPdf opens a native NSPrintOperation modal that
    // causes Flutter's keyboard handler to receive duplicate modifier-key events
    // on dismiss, flooding the message queue and freezing the UI. Workaround:
    // write the PDF to a temp file and open it in Preview, which handles focus
    // transitions correctly. All other platforms use the standard print dialog.
    if (!kIsWeb && Platform.isMacOS) {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}/Kasway/Invoices');
      await dir.create(recursive: true);
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      await Process.run('open', [file.path]);
    } else {
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: filename,
      );
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  pw.Widget _headerCell(String text,
      {pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: align,
        ),
      );

  pw.Widget _cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    pw.TextStyle? style,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Text(
          text,
          style: style ?? const pw.TextStyle(fontSize: 9),
          textAlign: align,
          maxLines: 3,
        ),
      );

  pw.Widget _metaRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600)),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: const pw.TextStyle(fontSize: 9)),
          ),
        ]),
      );

  pw.Widget _totalRow(String label, String value,
      {bool bold = false}) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: bold
                ? pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)
                : const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            value,
            style: bold
                ? pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)
                : const pw.TextStyle(fontSize: 9),
          ),
        ],
      );

  String _truncateTxId(String txId) {
    if (txId.length <= 20) return txId;
    return '${txId.substring(0, 10)}...${txId.substring(txId.length - 10)}';
  }
}
