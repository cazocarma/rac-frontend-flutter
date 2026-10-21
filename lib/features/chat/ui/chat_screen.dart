import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/widgets/design.dart';
import '../data/chat_api.dart';
import 'chat_safety_screen.dart';
import 'moderation_screen.dart';
import '../../../shared/services/session.dart';

String chatState(String state) => switch (state) {
  'activa' => 'Confirmada',
  'finalizada' => 'Finalizada · Solo lectura',
  _ => 'Cancelada · Solo lectura',
};

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final role = Session.role();
  late final api = ChatApi(Env.apiBase);
  late Future<Map<String, dynamic>> data = api.conversations();
  int offset = 0;
  @override
  void dispose() {
    api.close();
    super.dispose();
  }

  void load(int page) => setState(() {
    offset = page;
    data = api.conversations(offset: offset);
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mensajes'),
      actions: [
        FutureBuilder<String>(
          future: role,
          builder: (context, snapshot) => snapshot.data == 'admin'
              ? IconButton(
                  tooltip: 'Moderación de reportes',
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
          tooltip: 'Actualizar conversaciones',
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
              title: 'No pudimos cargar tus conversaciones',
              message: snapshot.error is ChatException
                  ? (snapshot.error as ChatException).message
                  : 'Revisa tu conexión e inténtalo nuevamente.',
              action: OutlinedButton(
                onPressed: () => load(offset),
                child: const Text('Reintentar'),
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
                'Conversemos el próximo plan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cada conversación pertenece a una reserva confirmada. Solo sus dos participantes pueden acceder.',
              ),
              const SizedBox(height: 24),
              if (items.isEmpty)
                EmptyState(
                  title: 'Todavía no tienes conversaciones',
                  message:
                      'Al confirmar una reserva podrás coordinar los detalles con tu compa.',
                  icon: Icons.chat_bubble_outline,
                  action: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/match'),
                    child: const Text('Ver mis reservas'),
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
                        '${chatState(item['estado'] as String)} · Reserva ${(item['sesion_id'] as String).substring(0, 8)}\n${(item['ultimo_mensaje'] as String).isEmpty ? 'Sé el primero en saludar' : item['ultimo_mensaje']}',
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
                      child: const Text('Más recientes'),
                    ),
                  if (snapshot.data!['has_more'] == true)
                    TextButton(
                      onPressed: () => load(offset + 20),
                      child: const Text('Anteriores'),
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

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.bookingId,
    this.name = 'Tu conversación',
    this.apiFactory,
  });
  final String bookingId, name;
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
  String cursor = '0', before = '', connection = 'Conectando…';
  String? error, sendError, pendingId, pendingText;
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
      if (mounted) setState(() => connection = 'En pausa');
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

  String explain(Object e) => e is ChatException
      ? e.message
      : 'Se interrumpió la conexión. Reintentaremos sin perder el historial.';
  Future<void> load() async {
    stopPolling();
    final current = generation;
    if (mounted) {
      setState(() {
        error = null;
        connection = 'Conectando…';
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
        connection = canSend ? 'Conectado' : 'Solo lectura';
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
          error = explain(e);
          connection = 'Sin conexión';
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
          connection = canSend ? 'Conectado' : 'Solo lectura';
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
          connection = 'Reconectando…';
          error = explain(e);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(explain(e))));
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
      setState(() => sendError = 'Usa hasta 2000 caracteres por mensaje.');
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
          sendError = explain(e);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Seguridad de la conversación',
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
            tooltip: 'Actualizar conversación',
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
                const Text('Conversación privada'),
                Chip(label: Text(connection)),
              ],
            ),
            Text(
              'Reserva ${widget.bookingId.substring(0, 8)} · ${canSend ? 'Coordina los detalles de tu plan.' : 'El historial se conserva en solo lectura.'}',
            ),
            if (error != null)
              Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                    TextButton(
                      onPressed: load,
                      child: const Text('Reintentar conexión'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ordered.isEmpty
                  ? const EmptyState(
                      title: 'Un saludo abre la conversación',
                      message: 'Los mensajes de esta reserva aparecerán aquí.',
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
                              loadingOlder
                                  ? 'Cargando…'
                                  : 'Cargar mensajes anteriores',
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
                                        own ? 'Tú' : widget.name,
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
                                        '${dateLabel(sent)} · ${clockLabel(sent)}${own ? ' · Guardado' : ''}',
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
                    sendError!,
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
                      decoration: const InputDecoration(
                        labelText: 'Mensaje',
                        hintText: 'Escribe un mensaje…',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: IconButton.filled(
                      tooltip: pendingId != null && !sending
                          ? 'Reintentar envío'
                          : 'Enviar mensaje',
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
