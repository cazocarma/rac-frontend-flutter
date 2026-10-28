import 'dart:convert';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'editorial_api.dart';
import 'editorial_decision.dart';
import 'editorial_journal.dart';
import 'editorial_reader.dart';
import 'editorial_draft.dart';

class EditorialWorkspace extends StatefulWidget {
  const EditorialWorkspace({
    super.key,
    required this.api,
    required this.journal,
    required this.subject,
    required this.issuer,
    required this.permissions,
  });
  final EditorialApi api;
  final EditorialJournal journal;
  final String subject;
  final String issuer;
  final Set<String> permissions;
  @override
  State<EditorialWorkspace> createState() => _EditorialWorkspaceState();
}

class _EditorialWorkspaceState extends State<EditorialWorkspace> {
  final attempts = <EditorialDecisionAttempt>[];
  Map<String, dynamic>? revision;
  String resource = 'documents';
  bool ready = false;
  bool busy = false;
  bool failed = false;
  bool acknowledged = false;
  bool completed = false;
  String? receipt;

  String get origin => widget.api.origin.origin;
  @override
  void initState() {
    super.initState();
    recover();
  }

  EditorialDecisionAttempt attempt(
    EditorialCommand command, {
    bool recovered = false,
  }) => EditorialDecisionAttempt.durable(
    command,
    journal: widget.journal,
    subject: widget.subject,
    issuer: widget.issuer,
    origin: origin,
    recovered: recovered,
  );

  Future<void> recover() async {
    try {
      final commands = await widget.journal.pending(
        subject: widget.subject,
        issuer: widget.issuer,
        origin: origin,
      );
      if (!mounted) return;
      setState(() {
        attempts.addAll(commands.map((c) => attempt(c, recovered: true)));
        ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  Future<void> submit(EditorialDecisionAttempt item) async {
    setState(() {
      busy = true;
      failed = false;
      completed = false;
    });
    try {
      await item.submit(widget.api);
      if (mounted) {
        setState(() {
          attempts.remove(item);
          revision = null;
          completed = true;
          final body =
              jsonDecode(item.command.encodedBody) as Map<String, dynamic>;
          receipt =
              '${body['document_id'] ?? body['definition_id']}\nSHA-256: ${body['sha256']}';
          acknowledged = false;
        });
      }
    } on EditorialFailure catch (error) {
      if (!item.uncertain && !error.uncertain) {
        try {
          await widget.journal.resolve(
            command: item.command,
            subject: widget.subject,
            issuer: widget.issuer,
            origin: origin,
          );
          if (mounted) setState(() => attempts.remove(item));
        } catch (_) {
          // Keep recovery visible if cleanup cannot be confirmed.
        }
      }
      if (mounted) setState(() => failed = true);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  bool allowed(String action) {
    if (!ready ||
        busy ||
        attempts.isNotEmpty ||
        !acknowledged ||
        revision == null) {
      return false;
    }
    return canEditorialDecide(
      resource: resource,
      revision: revision!,
      action: action,
      permissions: widget.permissions,
      subject: widget.subject,
    );
  }

  Future<void> decide(String action) async {
    if (!allowed(action)) return;
    final command = editorialDecision(
      resource: resource,
      revision: revision!,
      action: action,
      permissions: widget.permissions,
      subject: widget.subject,
    );
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.staffConfirmDecision),
        content: SingleChildScrollView(
          child: SelectableText(
            '${revision!['id']}\nSHA-256: ${revision!['sha256']}\n${action == 'approved'
                ? t.staffApprove
                : action == 'rejected'
                ? t.staffReject
                : t.staffPublish}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.staffCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.staffConfirmDecision),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final item = attempt(command);
    setState(() => attempts.add(item));
    await submit(item);
  }

  Future<void> reauthenticate() async {
    setState(() => busy = true);
    try {
      await widget.api.session.login();
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!ready && !failed) const LinearProgressIndicator(),
        if (failed) Text(t.staffDecisionFailed),
        if (completed) ...[
          Text(t.staffDecisionCompleted),
          if (receipt != null) SelectableText(receipt!),
        ],
        if (attempts.isNotEmpty) ...[
          Text(t.staffPendingRecovery),
          for (final item in attempts)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SelectableText(
                      '${item.command.path}\n${jsonDecode(item.command.encodedBody)['event_id']}',
                    ),
                    OutlinedButton(
                      onPressed: busy ? null : () => submit(item),
                      child: Text(t.staffRetrySameCommand),
                    ),
                  ],
                ),
              ),
            ),
          TextButton(
            onPressed: busy ? null : reauthenticate,
            child: Text(t.staffSignIn),
          ),
        ],
        if (ready && attempts.isEmpty) ...[
          if (widget.permissions.contains('documents.draft'))
            EditorialDraft(
              onSubmit: (command) async {
                final item = attempt(command);
                setState(() => attempts.add(item));
                await submit(item);
              },
            ),
          EditorialReader(
            api: widget.api,
            onRevision: (kind, value) {
              setState(() {
                resource = kind;
                revision = value;
                acknowledged = false;
                completed = false;
              });
            },
          ),
          if (revision != null) ...[
            CheckboxListTile(
              value: acknowledged,
              onChanged: (v) => setState(() => acknowledged = v == true),
              title: Text(t.staffReadAcknowledgement),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: allowed('approved')
                      ? () => decide('approved')
                      : null,
                  child: Text(t.staffApprove),
                ),
                OutlinedButton(
                  onPressed: allowed('rejected')
                      ? () => decide('rejected')
                      : null,
                  child: Text(t.staffReject),
                ),
                FilledButton(
                  onPressed: allowed('publish')
                      ? () => decide('publish')
                      : null,
                  child: Text(t.staffPublish),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
