import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/format.dart';
import '../../data/models/report.dart';

class PdfExportService {
  PdfExportService._();

  static Future<void> generateAndShareReport(ReportData report) async {
    final pdf = await _generatePdf(report);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Laporan_${report.periodLabel}.pdf',
    );
  }

  static Future<pw.Document> _generatePdf(ReportData report) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('assets/fonts/Quicksand-Regular.ttf');
    final fontBoldData = await rootBundle.load('assets/fonts/Quicksand-Bold.ttf');

    final ttf = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(fontBoldData);

    const cPink = PdfColor.fromInt(0xFFF472A8);
    const cPinkDeep = PdfColor.fromInt(0xFFE8557E);
    const cText = PdfColor.fromInt(0xFF4A2F36);
    const cMuted = PdfColor.fromInt(0xFFB89AA0);
    const cMint = PdfColor.fromInt(0xFF6BAE84);
    const cWhite = PdfColor.fromInt(0xFFFFFEFD);
    const cLavender = PdfColor.fromInt(0xFFE6D7F5);

    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _buildHeader(ctx, ttf, ttfBold, report, cPink, cPinkDeep, cWhite),
          pw.SizedBox(height: 24),
          _buildSummary(ttf, ttfBold, report, cPinkDeep, cMint),
          pw.SizedBox(height: 24),
          if (report.bestSellers.isNotEmpty) ..._buildBestSellers(ttf, ttfBold, report, cPinkDeep, cText, cLavender),
          pw.SizedBox(height: 24),
          _buildTable(ttf, ttfBold, report, cPinkDeep, cText, cLavender, dateFormat),
          pw.SizedBox(height: 32),
          pw.Center(
            child: pw.Text(
              'Dicetak: ${dateFormat.format(DateTime.now())}',
              style: pw.TextStyle(font: ttf, fontSize: 10, color: cMuted),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(
    pw.Context ctx,
    pw.Font font,
    pw.Font fontBold,
    ReportData report,
    PdfColor pink,
    PdfColor pinkDeep,
    PdfColor white,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [pink, pinkDeep],
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Laporan ${report.periodLabel}',
            style: pw.TextStyle(font: fontBold, fontSize: 20, color: white),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _getDateRangeText(report),
            style: pw.TextStyle(font: font, fontSize: 12, color: white),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummary(
    pw.Font font,
    pw.Font fontBold,
    ReportData report,
    PdfColor pinkDeep,
    PdfColor mint,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pinkDeep),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ringkasan Keuangan',
            style: pw.TextStyle(font: fontBold, fontSize: 16, color: pinkDeep),
          ),
          pw.SizedBox(height: 12),
          _row(font, fontBold, 'Omset', Format.rupiah(report.totalSales), pinkDeep),
          _row(font, fontBold, 'HPP', Format.rupiah(report.totalCost), pinkDeep),
          _row(font, fontBold, 'Laba Bersih', Format.rupiah(report.totalProfit), mint),
          _row(font, fontBold, 'Margin', '${report.profitMargin.toStringAsFixed(1)}%', mint),
          _row(font, fontBold, 'Transaksi', '${report.transactionCount}', pinkDeep),
        ],
      ),
    );
  }

  static pw.Widget _row(pw.Font font, pw.Font fontBold, String label, String value, PdfColor vc) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12, color: const PdfColor.fromInt(0xFF6B4A50))),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 14, color: vc)),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildBestSellers(
    pw.Font font,
    pw.Font fontBold,
    ReportData report,
    PdfColor pinkDeep,
    PdfColor text,
    PdfColor bg,
  ) {
    return [
      pw.Text('Produk Terlaris', style: pw.TextStyle(font: fontBold, fontSize: 16, color: pinkDeep)),
      pw.SizedBox(height: 12),
      pw.Table(
        border: pw.TableBorder.all(color: pinkDeep),
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              _cell(fontBold, 'No', pinkDeep),
              _cell(fontBold, 'Produk', pinkDeep),
              _cell(fontBold, 'Terjual', pinkDeep),
              _cell(fontBold, 'Omzet', pinkDeep),
              _cell(fontBold, 'Laba', pinkDeep),
            ],
          ),
          ...report.bestSellers.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return pw.TableRow(
              decoration: i.isEven ? const pw.BoxDecoration() : pw.BoxDecoration(color: bg),
              children: [
                _cell(font, '${i + 1}', text),
                _cell(font, '${item.productEmoji} ${item.productName}', text),
                _cell(font, '${item.quantity}', text),
                _cell(font, Format.rupiah(item.revenue), text),
                _cell(font, Format.rupiah(item.profit), text),
              ],
            );
          }),
        ],
      ),
    ];
  }

  static pw.Widget _buildTable(
    pw.Font font,
    pw.Font fontBold,
    ReportData report,
    PdfColor pinkDeep,
    PdfColor text,
    PdfColor bg,
    DateFormat df,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Data Per-Hari', style: pw.TextStyle(font: fontBold, fontSize: 16, color: pinkDeep)),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: pinkDeep),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: bg),
              children: [
                _cell(fontBold, 'Tanggal', pinkDeep),
                _cell(fontBold, 'Penjualan', pinkDeep),
                _cell(fontBold, 'HPP', pinkDeep),
                _cell(fontBold, 'Laba', pinkDeep),
                _cell(fontBold, 'Transaksi', pinkDeep),
              ],
            ),
            ...report.dailyData.map((day) {
              return pw.TableRow(
                decoration: const pw.BoxDecoration(),
                children: [
                  _cell(font, df.format(day.date), text),
                  _cell(font, Format.rupiah(day.sales), text),
                  _cell(font, Format.rupiah(day.cost), text),
                  _cell(font, Format.rupiah(day.profit), text),
                  _cell(font, '${day.transactionCount}', text),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(pw.Font font, String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10, color: color)),
    );
  }

  static String _getDateRangeText(ReportData report) {
    final f = DateFormat('d MMMM yyyy', 'id_ID');
    final end = report.endDate.subtract(const Duration(days: 1));
    return '${f.format(report.startDate)} - ${f.format(end)}';
  }
}
