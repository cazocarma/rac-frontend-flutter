(function () {
            'use strict';

            // --- protocol / storage constants (keep in sync with the plugin) ---
            const WIRE_VERSION = 2;
            const requestBroadcastChannel = 'oidc_flutter_web/request';
            const redirectBroadcastChannel = 'oidc_flutter_web/redirect';
            const stateNamespace = 'state';
            const stateResponseNamespace = 'response.state';
            const requestNamespace = 'request';

            // How long to wait for the app's ack before falling back to a
            // neutral "return to the app" state. Covers older app versions that
            // never ack.
            const ACK_TIMEOUT_MS = 10000;

            // --- user-visible copy (localize here) ---
            const messages = {
                working: 'Completando tu acceso…',
                redirecting: 'Volviendo a RAC…',
                success: 'Acceso completado. Vuelve a RAC.',
                loggedOut: 'Sesión cerrada. Vuelve a RAC.',
                safeToClose: 'Vuelve a RAC para continuar.',
                errorTitle: 'No pudimos completar el acceso',
                appError: 'Vuelve a RAC e inténtalo nuevamente.',
                noChannel: 'Your browser does not support cross-tab messaging. Please return to the app; it will continue automatically.',
            };

            const channelSupported = typeof BroadcastChannel !== 'undefined';

            // Front-channel logout takes precedence; otherwise handle a redirect.
            if (!handleFrontChannelLogout()) {
                handleRedirect();
            }

            // --- redirect (redirect_uri / post_logout_redirect_uri) ---
            function handleRedirect() {
                render('status', messages.working, '');

                const errorInfo = parseError();
                let bc = null;
                let settled = false;
                let timer = null;

                function finish(state, title, detail, errorUri, close) {
                    if (settled) {
                        return;
                    }
                    settled = true;
                    if (timer !== null) {
                        clearTimeout(timer);
                    }
                    if (bc) {
                        try { bc.close(); } catch (e) { /* ignore */ }
                    }
                    render(state, title, detail, errorUri);
                    if (close) {
                        attemptClose();
                    }
                }

                // Open the channel BEFORE posting so an immediate ack isn't
                // missed; a BroadcastChannel never receives its own messages, so
                // our own "redirect" post won't come back to us.
                if (channelSupported) {
                    try {
                        bc = new BroadcastChannel(redirectBroadcastChannel);
                        bc.onmessage = function (event) {
                            let msg;
                            try { msg = JSON.parse(event.data); } catch (e) { return; }
                            if (!msg || msg.v !== WIRE_VERSION || msg.type !== 'ack') {
                                return;
                            }
                            if (msg.status === 'ok') {
                                finish('status', messages.success, '', null, true);
                            } else {
                                finish('error', messages.errorTitle, msg.message || messages.appError, null, false);
                            }
                        };
                        bc.postMessage(JSON.stringify({
                            v: WIRE_VERSION,
                            type: 'redirect',
                            uri: window.location.toString(),
                        }));
                    } catch (e) {
                        bc = null;
                    }
                }

                // If this is a same-page launch, the SPA is navigated back to
                // its original url and reads the response from storage; the page
                // unloads, so there is no ack to await.
                if (maybeSelfNavigate()) {
                    if (timer !== null) {
                        clearTimeout(timer);
                    }
                    render('status', messages.redirecting, '');
                    return;
                }

                // The OP returned an error in the url (RFC 6749 sec 4.1.2.1): show
                // it immediately, we already know the outcome.
                if (errorInfo) {
                    finish('error', messages.errorTitle, errorInfo.description || errorInfo.error, errorInfo.uri, true);
                    return;
                }

                if (!bc) {
                    // No channel: nothing to await, surface a neutral state.
                    render('status', messages.working, messages.noChannel);
                    attemptClose();
                    return;
                }

                // Await the app's ack, with a timeout for old app versions.
                timer = setTimeout(function () {
                    finish('status', messages.safeToClose, '', null, true);
                }, ACK_TIMEOUT_MS);
            }

            // --- front-channel logout (frontchannel_logout_uri) ---
            function handleFrontChannelLogout() {
                const queryParams = new URLSearchParams(window.location.search);
                if (queryParams.get('requestType') !== 'front-channel-logout') {
                    return false;
                }
                if (channelSupported) {
                    try {
                        // Legacy plain-string wire: the front-channel listener
                        // consumes a bare url.
                        const bc = new BroadcastChannel(requestBroadcastChannel);
                        bc.postMessage(window.location.toString());
                        bc.close();
                    } catch (e) { /* ignore */ }
                }
                // Marker for the flutter app: if this exists we don't auth the
                // cached user in `UserManager.init()`, and we clear cached data.
                setLocalStorage(requestNamespace, 'front-channel-logout', window.location.toString());
                render('status', messages.loggedOut, '');
                attemptClose();
                return true;
            }

            // Handles the same-page launch mode: stores the response for the app
            // and, when webLaunchMode == samePage, navigates back to the
            // original url. Returns true if it navigated the page away.
            function maybeSelfNavigate() {
                let dataSrc = new URLSearchParams(window.location.search);
                let state = dataSrc.get('state');
                if (!state && window.location.hash) {
                    dataSrc = new URLSearchParams(window.location.hash.substring(1));
                    state = dataSrc.get('state');
                }
                if (!state) {
                    window.location.replace(window.location.pathname === '/staff/redirect.html' ? '/#/staff' : '/');
                    return true;
                }
                const stateDataRaw = getLocalStorage(stateNamespace, state);
                if (!stateDataRaw) {
                    // A consumed/expired callback must return to the app.
                    // No code is redeemed here: the app validates/restores its own session.
                    window.location.replace(window.location.pathname === '/staff/redirect.html' ? '/#/staff' : '/');
                    return true;
                }
                setLocalStorage(stateResponseNamespace, state, window.location.toString());
                let parsedStateString;
                try { parsedStateString = JSON.parse(stateDataRaw); } catch (_) {
                    window.location.replace(window.location.pathname === '/staff/redirect.html' ? '/#/staff' : '/');
                    return true;
                }
                if (!parsedStateString) {
                    window.location.replace(window.location.pathname === '/staff/redirect.html' ? '/#/staff' : '/');
                    return true;
                }
                const webLaunchMode = parsedStateString.options?.webLaunchMode;
                if (webLaunchMode !== 'samePage') {
                    return false;
                }
                const original_uri = parsedStateString.original_uri;
                if (!original_uri) {
                    console.warn("it's preferred that original_uri is used when webLaunchMode is samePage.");
                    return false;
                }
                window.location.assign(original_uri);
                return true;
            }

            // Parses error/error_description/error_uri from both the query and
            // the fragment (RFC 6749 sec 4.1.2.1). Returns null when there is none.
            function parseError() {
                function read(params) {
                    const error = params.get('error');
                    if (!error) {
                        return null;
                    }
                    return {
                        error: error,
                        description: params.get('error_description'),
                        uri: params.get('error_uri'),
                    };
                }
                const fromQuery = read(new URLSearchParams(window.location.search));
                if (fromQuery) {
                    return fromQuery;
                }
                if (window.location.hash) {
                    return read(new URLSearchParams(window.location.hash.substring(1)));
                }
                return null;
            }

            // Best-effort close. Only works for tabs the script itself opened
            // (newPage / popup); for email-link orphan tabs it's a silent no-op,
            // so the visible copy always tells the user they may close manually.
            function attemptClose() {
                try { if (window.opener) window.close(); } catch (e) { /* ignore */ }
            }

            // Renders a state. `title`/`detail` are set with textContent so the
            // attacker-influenced error params can never inject markup.
            function render(state, title, detail, errorUri) {
                const card = document.getElementById('oidc-card');
                const titleEl = document.getElementById('oidc-title');
                const detailEl = document.getElementById('oidc-detail');
                const errUriEl = document.getElementById('oidc-error-uri');
                if (card) {
                    card.setAttribute('data-state', state);
                }
                if (titleEl) {
                    titleEl.textContent = title || '';
                }
                if (detailEl) {
                    detailEl.textContent = detail || '';
                }
                if (!errUriEl) {
                    return;
                }
                // Only render http(s) error_uri values, and as text/link only.
                if (errorUri && /^https?:\/\//i.test(errorUri)) {
                    errUriEl.textContent = '';
                    const a = document.createElement('a');
                    a.href = errorUri;
                    a.textContent = errorUri;
                    a.rel = 'noopener noreferrer';
                    errUriEl.appendChild(a);
                    errUriEl.hidden = false;
                } else if (errorUri) {
                    errUriEl.textContent = errorUri;
                    errUriEl.hidden = false;
                } else {
                    errUriEl.textContent = '';
                    errUriEl.hidden = true;
                }
            }

            function getLocalStorage(namespace, key) {
                const rawRes = localStorage.getItem('oidc.' + namespace + '.' + key);
                if (!rawRes) {
                    return null;
                }
                return rawRes;
            }

            function setLocalStorage(namespace, key, value) {
                const keysEntryKey = 'oidc.keys.' + namespace;
                var keys = localStorage.getItem(keysEntryKey);
                if (!keys) {
                    keys = "[]";
                }
                const parsedKeys = JSON.parse(keys);
                if (!(parsedKeys instanceof Array)) {
                    console.error('parsedKeys is not an array.', parsedKeys);
                }
                parsedKeys.push(key);
                localStorage.setItem(keysEntryKey, JSON.stringify(parsedKeys));
                localStorage.setItem('oidc.' + namespace + '.' + key, value);
            }
        })();
