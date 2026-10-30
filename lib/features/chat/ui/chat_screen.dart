import '../../../l10n/generated/app_localizations.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/widgets/design.dart';
import '../data/chat_api.dart';
import 'chat_safety_screen.dart';
import 'moderation_screen.dart';
import '../../../shared/services/session.dart';

String chatState(AppLocalizations t, String state) => switch (state) {
  'activa' => t.chatStateActive,
  'finalizada' => t.chatStateFinished,
  _ => t.chatStateClosed,
};

/// Localizes a chat failure; non-HTTP failures use [fallback].
String chatFailure(AppLocalizations t, Object? error, String fallback) =>
    error is! ChatException
    ? fallback
    : switch (error.status) {
        400 => t.chatErrorInvalid,
        403 => t.chatErrorForbidden,
        401 => t.chatErrorSession,
        404 => t.chatErrorGone,
        409 => t.chatErrorChanged,
        429 => t.chatErrorBusy,
        _ => t.chatErrorUnavailable,
      };

enum _Link { connecting, paused, connected, readOnly, offline, reconnecting }

/// Marks a draft rejected locally for exceeding the message limit.
class _TooLong {
  const _TooLong();
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, this.api});
  final ChatApi? api;
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final role = Session.role();
  late final api = widget.api ?? ChatApi(Env.apiBase);
  late Future<Map<String, dynamic>> data = api.conversations();
  int offset = 0;
  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  void load(int page) => setState(() {
    offset = page;
    data = api.conversations(offset: offset);
  });
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.chatTitle),
        actions: [
          FutureBuilder<String>(
            future: role,
            builder: (context, snapshot) => snapshot.data == 'admin'
                ? IconButton(
                    tooltip: t.chatModeration,
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ModerationScreen(),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: t.chatRefreshList,
            onPressed: () => load(0),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PageContent(
        width: 900,
        child: FutureBuilder<Map<String, dynamic>>(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                title: t.chatListLoadFailed,
                message: chatFailure(t, snapshot.error, t.chatCheckConnection),
                action: OutlinedButton(
                  onPressed: () => load(offset),
                  child: Text(t.chatRetry),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!['items'] as List;
            return ListView(
              children: [
                Text(
                  t.chatListHeadline,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(t.chatListIntro),
                const SizedBox(height: 24),
                if (items.isEmpty)
                  EmptyState(
                    title: t.chatListEmptyTitle,
                    message: t.chatListEmptyMessage,
                    icon: Icons.chat_bubble_outline,
                    action: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/match'),
                      child: Text(t.chatListBookings),
                    ),
                  ),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          child: Icon(Icons.chat_bubble_outline),
                        ),
                        title: Text(
                          item['nombre'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          t.chatListSubtitle(
                            chatState(t, item['estado'] as String),
                            (item['sesion_id'] as String).substring(0, 8),
                            (item['ultimo_mensaje'] as String).isEmpty
                                ? t.chatListFirstHello
                                : item['ultimo_mensaje'] as String,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => ChatConversationScreen(
                                bookingId: item['sesion_id'] as String,
                                name: item['nombre'] as String,
                              ),
                            ),
                          );
                          if (mounted) load(offset);
                        },
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (offset > 0)
                      TextButton(
                        onPressed: () => load(offset - 20),
                        child: Text(t.chatListNewer),
                      ),
                    if (snapshot.data!['has_more'] == true)
                      TextButton(
                        onPressed: () => load(offset + 20),
                        child: Text(t.chatListOlder),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.bookingId,
    this.name,
    this.apiFactory,
  });
  final String bookingId;
  final String? name;
  final ChatApi Function()? apiFactory;
  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen>
    with WidgetsBindingObserver {
  late final ChatApi api = createApi();
  ChatApi? polling;
  final text = TextEditingController();
  final scroll = ScrollController();
  final messages = <String, Map<String, dynamic>>{};
  String cursor = '0', before = '';
  _Link connection = _Link.connecting;
  // Failures keep their cause and are localized when rendered.
  Object? error, sendError;
  String? pendingId, pendingText;
  bool loading = true,
      canSend = false,
      sending = false,
      loadingOlder = false,
      hasOlder = false,
      loadedOlder = false;
  int generation = 0;
  Timer? retryTimer;
  Completer<void>? retryWait;
  ChatApi createApi() => widget.apiFactory?.call() ?? ChatApi(Env.apiBase);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(load());
  }

  void stopPolling() {
    generation++;
    polling?.close();
    polling = null;
    retryTimer?.cancel();
    if (retryWait != null && !retryWait!.isCompleted) retryWait!.complete();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopPolling();
    api.close();
    text.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!loading && error == null && canSend) {
        stopPolling();
        polling = createApi();
        unawaited(poll(generation, polling!));
      } else {
        unawaited(load());
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      stopPolling();
      if (mounted) setState(() => connection = _Link.paused);
    }
  }

  void merge(List<dynamic> items) {
    for (final raw in items) {
      final message = Map<String, dynamic>.from(raw as Map);
      messages[message['id'] as String] = message;
      if (pendingId != null &&
          message['propio'] == true &&
          message['envio_id'] == pendingId) {
        pendingId = null;
        pendingText = null;
        sendError = null;
        text.clear();
      }
    }
  }

  void bottom({bool force = false}) {
    final follow =
        force ||
        !scroll.hasClients ||
        scroll.position.maxScrollExtent - scroll.offset < 100;
    if (follow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && scroll.hasClients) {
          scroll.jumpTo(scroll.position.maxScrollExtent);
        }
      });
    }
  }

  String explain(AppLocalizations t, Object e) =>
      e is _TooLong ? t.chatTooLong : chatFailure(t, e, t.chatInterrupted);
  Future<void> load() async {
    stopPolling();
    final current = generation;
    if (mounted) {
      setState(() {
        error = null;
        connection = _Link.connecting;
      });
    }
    try {
      final result = await api.history(widget.bookingId);
      if (!mounted || current != generation) return;
      setState(() {
        messages.clear();
        loadedOlder = false;
        merge(result['items'] as List);
        cursor = result['event_cursor'] as String;
        canSend = result['can_send'] == true;
        loading = false;
        error = null;
        connection = canSend ? _Link.connected : _Link.readOnly;
        if (!loadedOlder) {
          hasOlder = result['has_more'] == true;
          before = result['before'] as String;
        }
      });
      bottom(force: messages.length <= 50);
      if (canSend) {
        polling = createApi();
        unawaited(poll(current, polling!));
      }
    } catch (e) {
      if (mounted && current == generation) {
        setState(() {
          loading = false;
          error = e;
          connection = _Link.offline;
        });
      }
    }
  }

  Future<void> poll(int current, ChatApi channel) async {
    int failures = 0;
    while (mounted && current == generation) {
      try {
        final result = await channel.events(widget.bookingId, cursor);
        if (!mounted || current != generation) return;
        setState(() {
          merge(
            (result['items'] as List).map((event) => event['mensaje']).toList(),
          );
          cursor = result['cursor'] as String;
          canSend = result['can_send'] == true;
          connection = canSend ? _Link.connected : _Link.readOnly;
          error = null;
        });
        bottom();
        failures = 0;
        if (!canSend) return;
      } catch (e) {
        if (!mounted || current != generation) return;
        if (e is ChatException && e.code == 'cursor_ahead') {
          unawaited(load());
          return;
        }
        setState(() {
          connection = _Link.reconnecting;
          error = e;
          if (e is ChatException && [401, 403, 404].contains(e.status)) {
            canSend = false;
          }
        });
        if (e is ChatException && [401, 403, 404].contains(e.status)) return;
        // A timeout must close its underlying HTTP request before another poll.
        channel.close();
        final wait = Duration(
          milliseconds:
              min(30000, 1000 * (1 << min(failures++, 5))) +
              Random().nextInt(500),
        );
        retryWait = Completer<void>();
        retryTimer = Timer(wait, () {
          if (!retryWait!.isCompleted) retryWait!.complete();
        });
        await retryWait!.future;
        if (!mounted || current != generation) return;
        channel = createApi();
        polling = channel;
      }
    }
  }

  Future<void> older() async {
    if (loadingOlder) return;
    setState(() => loadingOlder = true);
    final previousExtent = scroll.hasClients
        ? scroll.position.maxScrollExtent
        : 0.0;
    final previousOffset = scroll.hasClients ? scroll.offset : 0.0;
    try {
      final result = await api.history(widget.bookingId, before: before);
      if (!mounted) return;
      setState(() {
        merge(result['items'] as List);
        hasOlder = result['has_more'] == true;
        before = result['before'] as String;
        loadedOlder = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && scroll.hasClients) {
          scroll.jumpTo(
            (previousOffset + scroll.position.maxScrollExtent - previousExtent)
                .clamp(0, scroll.position.maxScrollExtent),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(explain(t, e))));
      }
    } finally {
      if (mounted) setState(() => loadingOlder = false);
    }
  }

  Future<void> send() async {
    if (sending ||
        !canSend ||
        (pendingId == null && text.text.trim().isEmpty)) {
      return;
    }
    if (pendingId == null && text.text.trim().runes.length > 2000) {
      setState(() => sendError = const _TooLong());
      return;
    }
    pendingId ??= ChatApi.newRequestId();
    pendingText ??= text.text.trim();
    final id = pendingId!;
    setState(() {
      sending = true;
      sendError = null;
    });
    try {
      final message = await api.send(widget.bookingId, id, pendingText!);
      if (!mounted) return;
      setState(() {
        merge([message]);
        if (pendingId == id) {
          pendingId = null;
          pendingText = null;
          text.clear();
        }
        sendError = null;
      });
      bottom(force: true);
    } catch (e) {
      if (mounted && pendingId == id) {
        setState(() {
          sendError = e;
          if (e is ChatException && [401, 403, 404, 409].contains(e.status)) {
            canSend = false;
          }
        });
        if (e is ChatException && e.status == 409) unawaited(load());
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordered = messages.values.toList()
      ..sort(
        (a, b) => BigInt.parse(
          a['numero'] as String,
        ).compareTo(BigInt.parse(b['numero'] as String)),
      );
    final colors = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    final name = widget.name ?? t.chatDefaultName;
    final link = switch (connection) {
      _Link.connecting => t.chatLinkConnecting,
      _Link.paused => t.chatLinkPaused,
      _Link.connected => t.chatLinkConnected,
      _Link.readOnly => t.chatLinkReadOnly,
      _Link.offline => t.chatLinkOffline,
      _Link.reconnecting => t.chatLinkReconnecting,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: t.chatSafety,
            icon: const Icon(Icons.shield_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ChatSafetyScreen(bookingId: widget.bookingId),
                ),
              );
              if (mounted) await load();
            },
          ),
          IconButton(
            tooltip: t.chatRefresh,
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PageContent(
        width: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 18),
                Text(t.chatPrivate),
                Chip(label: Text(link)),
              ],
            ),
            Text(
              canSend
                  ? t.chatBookingWritable(widget.bookingId.substring(0, 8))
                  : t.chatBookingReadOnly(widget.bookingId.substring(0, 8)),
            ),
            if (error != null)
              Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        explain(t, error!),
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                    TextButton(
                      onPressed: load,
                      child: Text(t.chatRetryConnection),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ordered.isEmpty
                  ? EmptyState(
                      title: t.chatEmptyTitle,
                      message: t.chatEmptyMessage,
                      icon: Icons.waving_hand_outlined,
                    )
                  : ListView.builder(
                      controller: scroll,
                      itemCount: ordered.length + (hasOlder ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (hasOlder && index == 0) {
                          return TextButton(
                            onPressed: loadingOlder ? null : older,
                            child: Text(
                              loadingOlder ? t.chatLoading : t.chatLoadOlder,
                            ),
                          );
                        }
                        final messageIndex = index - (hasOlder ? 1 : 0);
                        final m = ordered[messageIndex];
                        final own = m['propio'] == true;
                        final sent = DateTime.parse(
                          m['enviado_en'] as String,
                        ).toLocal();
                        final previous = messageIndex == 0
                            ? null
                            : DateTime.parse(
                                ordered[messageIndex - 1]['enviado_en']
                                    as String,
                              ).toLocal();
                        final startsDay =
                            previous == null ||
                            !DateUtils.isSameDay(previous, sent);
                        return Column(
                          key: ValueKey(m['id']),
                          children: [
                            if (startsDay)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Semantics(
                                  header: true,
                                  container: true,
                                  excludeSemantics: true,
                                  label: MaterialLocalizations.of(
                                    context,
                                  ).formatFullDate(sent),
                                  child: Text(
                                    MaterialLocalizations.of(
                                      context,
                                    ).formatFullDate(sent),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            Align(
                              alignment: own
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: own
                                        ? colors.primaryContainer
                                        : colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        own ? t.chatYou : name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Semantics(
                                        container: true,
                                        label: m['contenido'] as String,
                                        excludeSemantics: true,
                                        child: SelectableText(
                                          m['contenido'] as String,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${dateLabel(sent)} · ${clockLabel(sent)}${own ? ' · ${t.chatSaved}' : ''}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (sendError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    explain(t, sendError!),
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ),
            if (canSend || pendingText != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: text,
                      readOnly: sending || pendingId != null || !canSend,
                      maxLength: 2000,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: t.chatMessage,
                        hintText: t.chatMessageHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: IconButton.filled(
                      tooltip: pendingId != null && !sending
                          ? t.chatRetrySend
                          : t.chatSend,
                      onPressed: canSend && !sending ? send : null,
                      icon: sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
