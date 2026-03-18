import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;

class ImportResult {
  final int imported;
  final int skipped;
  final String? error;

  const ImportResult({
    required this.imported,
    required this.skipped,
    this.error,
  });
}

class DataService {
  final ProductRepository _repo;

  DataService(this._repo);

  Future<void> exportData(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareRect =
        box != null ? box.localToGlobal(Offset.zero) & box.size : Rect.zero;
    final entries = await _repo.getAllProducts();
    final csv = _buildCsv(entries);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/kasway_data.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Kasway Catalog Export',
      sharePositionOrigin: shareRect,
    );
  }

  Future<ImportResult> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) return const ImportResult(imported: 0, skipped: 0);

    final path = result.files.single.path;
    if (path == null) {
      return const ImportResult(
        imported: 0,
        skipped: 0,
        error: 'Could not read selected file',
      );
    }

    final contents = await File(path).readAsString();
    final products = _parseCsv(contents);
    if (products.isEmpty) return const ImportResult(imported: 0, skipped: 0);

    await _repo.importProducts(products);
    return ImportResult(imported: products.length, skipped: 0);
  }

  String _buildCsv(List<ProductWithCategory> entries) {
    final buf = StringBuffer();
    buf.writeln('id,category,name,price,description,additions');
    for (final entry in entries) {
      final p = entry.product;
      final additionsStr = p.additions.isEmpty
          ? ''
          : p.additions
              .map((a) => '${a.name}:${_formatPrice(a.price)}')
              .join('|');
      buf.write(_csvField(p.id));
      buf.write(',');
      buf.write(_csvField(entry.category));
      buf.write(',');
      buf.write(_csvField(p.name));
      buf.write(',');
      buf.write(_formatPrice(p.price));
      buf.write(',');
      buf.write(_csvField(p.description));
      buf.write(',');
      buf.write(additionsStr.isEmpty ? '' : '"$additionsStr"');
      buf.writeln();
    }
    return buf.toString();
  }

  List<Map<String, dynamic>> _parseCsv(String csv) {
    final lines = csv.split('\n');
    if (lines.length < 2) return [];

    final products = <Map<String, dynamic>>[];
    // Skip header row (index 0)
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = _parseCsvLine(line);
      if (fields.length < 6) continue;

      final id = fields[0].trim();
      final category = fields[1].trim();
      final name = fields[2].trim();
      final price = double.tryParse(fields[3].trim()) ?? 0.0;
      final description = fields[4].trim();
      final additionsStr = fields[5].trim();

      if (id.isEmpty || category.isEmpty || name.isEmpty) continue;

      final additions = _parseAdditions(additionsStr);

      products.add({
        'id': id,
        'category': category,
        'name': name,
        'price': price,
        'description': description,
        'additions': additions,
      });
    }
    return products;
  }

  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final c = line[i];
      if (inQuotes) {
        if (c == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buf.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buf.write(c);
        }
      } else {
        if (c == '"') {
          inQuotes = true;
        } else if (c == ',') {
          fields.add(buf.toString());
          buf.clear();
        } else {
          buf.write(c);
        }
      }
    }
    fields.add(buf.toString()); // last field

    return fields;
  }

  List<Map<String, dynamic>> _parseAdditions(String additionsStr) {
    if (additionsStr.isEmpty) return [];
    return additionsStr.split('|').map((a) {
      final colonIdx = a.lastIndexOf(':');
      if (colonIdx < 0) return <String, dynamic>{'name': a, 'price': 0.0};
      return <String, dynamic>{
        'name': a.substring(0, colonIdx),
        'price': double.tryParse(a.substring(colonIdx + 1)) ?? 0.0,
      };
    }).toList();
  }

  String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) return price.toInt().toString();
    return price.toString();
  }
}
