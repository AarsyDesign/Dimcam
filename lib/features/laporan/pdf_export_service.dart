import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/format.dart';
import '../../data/database/database_helper.dart';
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

  static Future<void> generateStokPdf() async {
    final bahans = await DatabaseHelper.instance.getBahans();
    if (bahans.isEmpty) return;

    final pdf = pw.Document();
    final ttf = pw.Font.helvetica();
    final ttfBold = pw.Font.helveticaBold();

    const cPink = PdfColor.fromInt(0xFFF472A8);
    const cPinkDeep = PdfColor.fromInt(0xFFE8557E);
    const cText = PdfColor.fromInt(0xFF4A2F36);
    const cMuted = PdfColor.fromInt(0xFFB89AA0);
    const cMint = PdfColor.fromInt(0xFF6BAE84);
    const cWhite = PdfColor.fromInt(0xFFFFFEFD);
    const cLavender = PdfColor.fromInt(0xFFE6D7F5);

    final totalItems = bahans.length;
    final totalValue = bahans.fold<int>(0, (s, b) => s + (b.buyPrice * b.stock).round());
    final lowCount = bahans.where((b) => b.isLow || b.isOut).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _buildPdfHeader(ttf, ttfBold, 'Laporan Stok Bahan', 'Daftar stok bahan baku', cPink, cPinkDeep, cWhite),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: cPinkDeep),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ringkasan Stok', style: pw.TextStyle(font: ttfBold, fontSize: 16, color: cPinkDeep)),
                pw.SizedBox(height: 12),
                _row(ttf, ttfBold, 'Total Bahan', '$totalItems item', cPinkDeep),
                _row(ttf, ttfBold, 'Total Nilai Stok', Format.rupiah(totalValue), cPinkDeep),
                _row(ttf, ttfBold, 'Stok Menipis/Habis', '$lowCount bahan', cMint),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text('Daftar Bahan', style: pw.TextStyle(font: ttfBold, fontSize: 16, color: cPinkDeep)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: cPinkDeep),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: cPinkDeep),
                children: [
                  _cell(ttfBold, 'No', cPinkDeep),
                  _cell(ttfBold, 'Bahan', cPinkDeep),
                  _cell(ttfBold, 'Kategori', cPinkDeep),
                  _cell(ttfBold, 'Stok', cPinkDeep),
                  _cell(ttfBold, 'Min', cPinkDeep),
                  _cell(ttfBold, 'Status', cPinkDeep),
                  _cell(ttfBold, 'Harga', cPinkDeep),
                ],
              ),
              ...bahans.asMap().entries.map((entry) {
                final i = entry.key;
                final b = entry.value;
                final status = b.isOut ? 'Habis' : b.isLow ? 'Menipis' : 'Aman';
                return pw.TableRow(
                  decoration: i.isEven ? const pw.BoxDecoration() : const pw.BoxDecoration(color: cLavender),
                  children: [
                    _cell(ttf, '${i + 1}', cText),
                    _cell(ttf, '${b.emoji ?? ""} ${b.name}', cText),
                    _cell(ttf, b.category, cText),
                    _cell(ttf, '${b.stock.toStringAsFixed(b.stock % 1 == 0 ? 0 : 1)} ${b.unit}', cText),
                    _cell(ttf, '${b.minStock.toStringAsFixed(0)} ${b.unit}', cText),
                    _cell(ttf, status, cText),
                    _cell(ttf, Format.rupiah(b.buyPrice), cText),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 32),
          pw.Center(
            child: pw.Text(
              'Dicetak: ${_dateFormat(DateTime.now())}',
              style: pw.TextStyle(font: ttf, fontSize: 10, color: cMuted),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Laporan_Stok.pdf');
  }

  static Future<void> generateHutangPdf() async {
    final debts = await DatabaseHelper.instance.getDebts();
    if (debts.isEmpty) return;

    final pdf = pw.Document();
    final ttf = pw.Font.helvetica();
    final ttfBold = pw.Font.helveticaBold();

    const cPink = PdfColor.fromInt(0xFFF472A8);
    const cPinkDeep = PdfColor.fromInt(0xFFE8557E);
    const cText = PdfColor.fromInt(0xFF4A2F36);
    const cMuted = PdfColor.fromInt(0xFFB89AA0);
    const cMint = PdfColor.fromInt(0xFF6BAE84);
    const cWhite = PdfColor.fromInt(0xFFFFFEFD);
    const cLavender = PdfColor.fromInt(0xFFE6D7F5);

    String dateFormat(DateTime d) => Format.dateMedium(d);

    final totalPiutang = debts.where((d) => d.isUnpaid).fold<int>(0, (s, d) => s + d.amount);
    final totalLunas = debts.where((d) => d.isPaid).fold<int>(0, (s, d) => s + d.amount);
    final overdueCount = debts.where((d) => d.isOverdue).length;
    final unpaidCount = debts.where((d) => d.isUnpaid).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _buildPdfHeader(ttf, ttfBold, 'Laporan Hutang', 'Piutang pelanggan', cPink, cPinkDeep, cWhite),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: cPinkDeep),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ringkasan Hutang', style: pw.TextStyle(font: ttfBold, fontSize: 16, color: cPinkDeep)),
                pw.SizedBox(height: 12),
                _row(ttf, ttfBold, 'Piutang', Format.rupiah(totalPiutang), cPinkDeep),
                _row(ttf, ttfBold, 'Sudah Lunas', Format.rupiah(totalLunas), cMint),
                _row(ttf, ttfBold, 'Belum Lunas', '$unpaidCount pelanggan', cPinkDeep),
                _row(ttf, ttfBold, 'Jatuh Tempo', '$overdueCount pelanggan', cPinkDeep),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text('Daftar Hutang', style: pw.TextStyle(font: ttfBold, fontSize: 16, color: cPinkDeep)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: cPinkDeep),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: cLavender),
                children: [
                  _cell(ttfBold, 'No', cPinkDeep),
                  _cell(ttfBold, 'Pelanggan', cPinkDeep),
                  _cell(ttfBold, 'Nominal', cPinkDeep),
                  _cell(ttfBold, 'Tanggal', cPinkDeep),
                  _cell(ttfBold, 'Status', cPinkDeep),
                ],
              ),
              ...debts.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                final status = d.isPaid ? 'Lunas' : d.isOverdue ? 'Jatuh Tempo' : 'Belum Lunas';
                return pw.TableRow(
                  decoration: i.isEven ? const pw.BoxDecoration() : const pw.BoxDecoration(color: cLavender),
                  children: [
                    _cell(ttf, '${i + 1}', cText),
                    _cell(ttf, '${d.customerName}${d.whatsapp != null ? " (${d.whatsapp})" : ""}', cText),
                    _cell(ttf, Format.rupiah(d.amount), cText),
                    _cell(ttf, dateFormat(d.dateTime), cText),
                    _cell(ttf, status, cText),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 32),
          pw.Center(
            child: pw.Text(
              'Dicetak: ${_dateFormat(DateTime.now())}',
              style: pw.TextStyle(font: ttf, fontSize: 10, color: cMuted),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Laporan_Hutang.pdf');
  }

  static pw.Widget _buildPdfHeader(pw.Font font, pw.Font fontBold, String title, String subtitle,
      PdfColor pink, PdfColor pinkDeep, PdfColor white) {
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
          pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 20, color: white)),
          pw.SizedBox(height: 4),
          pw.Text(subtitle, style: pw.TextStyle(font: font, fontSize: 12, color: white)),
        ],
      ),
    );
  }

  static String _dateFormat(DateTime d) => Format.dateMedium(d);

  static Future<pw.Document> _generatePdf(ReportData report) async {
    final pdf = pw.Document();

    final ttf = pw.Font.helvetica();
    final ttfBold = pw.Font.helveticaBold();

    const cPink = PdfColor.fromInt(0xFFF472A8);
    const cPinkDeep = PdfColor.fromInt(0xFFE8557E);
    const cText = PdfColor.fromInt(0xFF4A2F36);
    const cMuted = PdfColor.fromInt(0xFFB89AA0);
    const cMint = PdfColor.fromInt(0xFF6BAE84);
    const cWhite = PdfColor.fromInt(0xFFFFFEFD);
    const cLavender = PdfColor.fromInt(0xFFE6D7F5);

    String dateFormat(DateTime d) => Format.dateLongNoDay(d);

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
              'Dicetak: ${dateFormat(DateTime.now())}',
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
    String Function(DateTime) df,
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
                  _cell(font, df(day.date), text),
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
    String f(DateTime d) => Format.dateLongNoDay(d);
    final end = report.endDate.subtract(const Duration(days: 1));
    return '${f(report.startDate)} - ${f(end)}';
  }
}
