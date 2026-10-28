import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../documents/ui/document_text.dart';
import 'editorial_api.dart';

class EditorialReader extends StatefulWidget {
  const EditorialReader({super.key, required this.api});
  final EditorialApi api;
  @override
  State<EditorialReader> createState() => _EditorialReaderState();
}

class _EditorialReaderState extends State<EditorialReader> {
  final reference = TextEditingController();
  String resource = 'documents';
  Map<String, dynamic>? revision;
  bool busy = false;
  bool failed = false;
  int generation = 0;

  void invalidate() {
    generation++;
    setState(() {
      revision = null;
      busy = false;
      failed = false;
    });
  }

  Future<void> read() async {
    final requestGeneration = ++generation;
    final id = reference.text.trim();
    final requestedResource = resource;
    setState(() {
      busy = true;
      failed = false;
      revision = null;
    });
    try {
      final result = await widget.api.read(requestedResource, id);
      if (result['id'] != id ||
          result['content'] is! String ||
          result['sha256'] is! String ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(result['sha256'] as String)) {
        throw const FormatException('Invalid revision');
      }
      if (mounted && generation == requestGeneration) {
        setState(() => revision = result);
      }
    } catch (_) {
      if (mounted && generation == requestGeneration) {
        setState(() => failed = true);
      }
    } finally {
      if (mounted && generation == requestGeneration) {
        setState(() => busy = false);
      }
    }
  }

  @override
  void dispose() {
    generation++;
    reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.staffReadRevision,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: resource,
          decoration: InputDecoration(labelText: t.staffResource),
          items: [
            DropdownMenuItem(value: 'documents', child: Text(t.staffDocument)),
            DropdownMenuItem(
              value: 'assessments',
              child: Text(t.staffAssessment),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              resource = value;
              invalidate();
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reference,
          onChanged: (_) => invalidate(),
          decoration: InputDecoration(labelText: t.staffReference),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: busy ? null : read,
          child: Text(t.staffReadRevision),
        ),
        if (busy) const LinearProgressIndicator(),
        if (failed) Text(t.staffRevisionUnavailable),
        if (revision != null) ...[
          const SizedBox(height: 20),
          Text('${revision!['version']} · ${revision!['locale']}'),
          const SizedBox(height: 8),
          SelectableText('SHA-256: ${revision!['sha256']}'),
          const SizedBox(height: 12),
          DocumentText(revision!['content'] as String),
        ],
      ],
    );
  }
}
