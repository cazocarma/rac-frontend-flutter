import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../documents/ui/document_text.dart';
import 'editorial_api.dart';
import 'editorial_decision.dart';

EditorialCommand draftDocument({
  required String kind,
  required String version,
  required String locale,
  required String content,
  required bool materialChange,
}) {
  if (!{
        'terms_client',
        'terms_compa',
        'community_rules',
        'privacy',
        'safety_rules',
      }.contains(kind) ||
      !RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$').hasMatch(version) ||
      !{'es', 'en'}.contains(locale) ||
      content.trim().isEmpty ||
      content.contains('\u0000') ||
      utf8.encode(content).length > 131072) {
    throw const FormatException('Invalid editorial draft');
  }
  return EditorialCommand('documents/drafts', {
    'event_id': newEditorialReference(),
    'document_id': newEditorialReference(),
    'kind': kind,
    'version': version,
    'locale': locale,
    'content': content,
    'material_change': materialChange,
    'sha256': sha256.convert(utf8.encode(content)).toString(),
  });
}

class EditorialDraft extends StatefulWidget {
  const EditorialDraft({super.key, required this.onSubmit});
  final Future<void> Function(EditorialCommand) onSubmit;
  @override
  State<EditorialDraft> createState() => _EditorialDraftState();
}

class _EditorialDraftState extends State<EditorialDraft> {
  final version = TextEditingController();
  final content = TextEditingController();
  String? kind;
  String? locale;
  bool? material;
  bool failed = false;
  bool busy = false;

  Future<void> prepare() async {
    final t = AppLocalizations.of(context)!;
    EditorialCommand command;
    try {
      if (material == null) {
        throw const FormatException('Explicit selection required');
      }
      command = draftDocument(
        kind: kind ?? '',
        version: version.text,
        locale: locale ?? '',
        content: content.text,
        materialChange: material!,
      );
    } catch (_) {
      setState(() => failed = true);
      return;
    }
    setState(() {
      failed = false;
      busy = true;
    });
    final body = jsonDecode(command.encodedBody) as Map<String, dynamic>;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.staffConfirmDraft),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${body['document_id']}\n${body['version']} · ${body['locale']}',
                ),
                SelectableText('SHA-256: ${body['sha256']}'),
                const SizedBox(height: 16),
                DocumentText(body['content'] as String),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.staffCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.staffConfirmDraft),
          ),
        ],
      ),
    );
    if (!mounted) return;
    try {
      if (confirmed == true) await widget.onSubmit(command);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    version.dispose();
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ExpansionTile(
      title: Text(t.staffCreateDraft),
      children: [
        Text(t.staffDraftHelp),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: t.staffDocumentKind),
          items: [
            DropdownMenuItem(
              value: 'terms_client',
              child: Text(t.staffClientTerms),
            ),
            DropdownMenuItem(
              value: 'terms_compa',
              child: Text(t.staffCompaTerms),
            ),
            DropdownMenuItem(
              value: 'community_rules',
              child: Text(t.staffCommunityRules),
            ),
            DropdownMenuItem(value: 'privacy', child: Text(t.staffPrivacy)),
            DropdownMenuItem(
              value: 'safety_rules',
              child: Text(t.staffSafetyRules),
            ),
          ],
          onChanged: busy ? null : (v) => setState(() => kind = v),
        ),
        TextField(
          controller: version,
          enabled: !busy,
          decoration: InputDecoration(labelText: t.staffVersion),
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: t.staffLocale),
          items: const [
            DropdownMenuItem(value: 'es', child: Text('Español')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: busy ? null : (v) => setState(() => locale = v),
        ),
        DropdownButtonFormField<bool>(
          decoration: InputDecoration(labelText: t.staffMaterialChange),
          items: [
            DropdownMenuItem(value: true, child: Text(t.staffMaterialYes)),
            DropdownMenuItem(value: false, child: Text(t.staffMaterialNo)),
          ],
          onChanged: busy ? null : (v) => setState(() => material = v),
        ),
        TextField(
          controller: content,
          enabled: !busy,
          minLines: 8,
          maxLines: 18,
          decoration: InputDecoration(labelText: t.staffDocumentContent),
        ),
        if (failed) Text(t.staffDraftInvalid),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: busy ? null : prepare,
          child: Text(t.staffCreateDraft),
        ),
      ],
    );
  }
}
