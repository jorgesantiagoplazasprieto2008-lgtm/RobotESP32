<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.PasoGrabado, java.util.List" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Grabación de Recorridos - Robot ESP32</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

        :root {
            --bg:       #0d1117;
            --surface:  #161b22;
            --border:   #30363d;
            --rojo:     #f85149;
            --verde:    #3fb950;
            --azul:     #58a6ff;
            --amarillo: #d29922;
            --morado:   #bc8cff;
            --texto:    #c9d1d9;
            --subtexto: #8b949e;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: var(--bg);
            color: var(--texto);
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            padding: 24px;
        }

        /* ── Cabecera ─────────────────────────────────────────────── */
        header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
            padding-bottom: 16px;
            border-bottom: 1px solid var(--border);
        }

        header h1 { font-size: 1.5rem; color: var(--azul); }

        .btn-volver {
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--texto);
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            transition: border-color .2s;
        }
        .btn-volver:hover { border-color: var(--azul); }

        /* ── Grid principal ───────────────────────────────────────── */
        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            max-width: 1100px;
            margin: 0 auto;
        }

        @media (max-width: 700px) { .grid { grid-template-columns: 1fr; } }

        /* ── Card ─────────────────────────────────────────────────── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 20px;
        }

        .card-title {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--subtexto);
            text-transform: uppercase;
            letter-spacing: .08em;
            margin-bottom: 16px;
        }

        /* ── D-pad del robot ──────────────────────────────────────── */
        .dpad {
            display: grid;
            grid-template-columns: repeat(3, 72px);
            grid-template-rows: repeat(3, 72px);
            gap: 8px;
            justify-content: center;
        }

        .btn-dir {
            background: #1c2128;
            border: 1px solid var(--border);
            border-radius: 10px;
            color: var(--texto);
            font-size: 24px;
            cursor: pointer;
            transition: background .15s, transform .1s, border-color .15s;
            display: flex; align-items: center; justify-content: center;
        }

        .btn-dir:hover  { background: #2d333b; border-color: var(--azul); }
        .btn-dir:active { transform: scale(.93); background: #161b22; }

        .btn-stop-dir {
            grid-column: 2; grid-row: 2;
            background: rgba(248, 81, 73, .15);
            border-color: var(--rojo);
            color: var(--rojo);
        }
        .btn-stop-dir:hover { background: rgba(248,81,73,.3); }

        /* ── Botones de acción de grabación ───────────────────────── */
        .acciones {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .btn-accion {
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: opacity .2s, transform .1s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-accion:disabled { opacity: .35; cursor: not-allowed; }
        .btn-accion:not(:disabled):active { transform: scale(.97); }

        .btn-iniciar   { background: var(--rojo);    color: #fff; }
        .btn-detener   { background: var(--amarillo); color: #000; }
        .btn-reproducir{ background: var(--verde);   color: #000; }
        .btn-parar     { background: var(--morado);  color: #000; }
        .btn-limpiar   { background: #21262d; border: 1px solid var(--border); color: var(--subtexto); }

        /* ── Panel de estado ──────────────────────────────────────── */
        .estado-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 14px;
            background: #0d1117;
            border-radius: 8px;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            background: #444;
            flex-shrink: 0;
            transition: background .3s, box-shadow .3s;
        }

        .dot.activo-verde {
            background: var(--verde);
            box-shadow: 0 0 8px var(--verde);
        }

        .dot.activo-rojo {
            background: var(--rojo);
            box-shadow: 0 0 8px var(--rojo);
            animation: blink 1s infinite;
        }

        @keyframes blink { 0%,100%{opacity:1} 50%{opacity:.2} }

        /* ── Barra de progreso ────────────────────────────────────── */
        .progreso-wrap {
            background: #0d1117;
            border-radius: 6px;
            height: 24px;
            overflow: hidden;
            margin-top: 10px;
            border: 1px solid var(--border);
        }

        .progreso-barra {
            height: 100%;
            width: 0;
            background: linear-gradient(90deg, var(--verde), #56d364);
            transition: width .4s ease;
            display: flex;
            align-items: center;
            padding-left: 8px;
            font-size: 12px;
            font-weight: 600;
            color: #0d1117;
            white-space: nowrap;
        }

        /* ── Lista de pasos grabados ──────────────────────────────── */
        .lista-pasos {
            max-height: 260px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .paso-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #0d1117;
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 8px 12px;
            font-size: 13px;
        }

        .paso-num   { color: var(--subtexto); min-width: 30px; }
        .paso-desc  { flex: 1; }
        .paso-dur   { color: var(--azul); font-variant-numeric: tabular-nums; }

        .paso-activo { border-color: var(--verde); background: rgba(63,185,80,.1); }

        .vacio {
            text-align: center;
            color: var(--subtexto);
            font-size: 14px;
            padding: 30px 0;
        }

        /* ── Toast de notificación ────────────────────────────────── */
        #toast {
            position: fixed;
            bottom: 24px; right: 24px;
            background: #2d333b;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 12px 20px;
            font-size: 14px;
            opacity: 0;
            transform: translateY(10px);
            transition: opacity .3s, transform .3s;
            z-index: 999;
            max-width: 300px;
        }
        #toast.show { opacity: 1; transform: translateY(0); }
    </style>
</head>
<body>

<header>
    <h1>🎬 Módulo de Grabación de Recorridos</h1>
    <a class="btn-volver" href="control.jsp">← Volver al Control</a>
</header>

<div class="grid">

    <!-- ════════════════════════════════════════════ -->
    <!-- COLUMNA IZQUIERDA: Control manual + Acciones -->
    <!-- ════════════════════════════════════════════ -->
    <div style="display:flex; flex-direction:column; gap:20px;">

        <!-- D-PAD -->
        <div class="card">
            <div class="card-title">🕹 Control Manual del Robot</div>
            <div class="dpad">
                <div></div>
                <button class="btn-dir" id="btn-go"    onclick="cmd('go')"    title="Avanzar">▲</button>
                <div></div>
                <button class="btn-dir" id="btn-left"  onclick="cmd('left')"  title="Izquierda">◀</button>
                <button class="btn-dir btn-stop-dir"   onclick="cmd('stop')"  title="Stop">⏹</button>
                <button class="btn-dir" id="btn-right" onclick="cmd('right')" title="Derecha">▶</button>
                <div></div>
                <button class="btn-dir" id="btn-back"  onclick="cmd('back')"  title="Retroceder">▼</button>
                <div></div>
            </div>
        </div>

        <!-- ACCIONES DE GRABACIÓN -->
        <div class="card">
            <div class="card-title">⚙ Acciones de Grabación</div>
            <div class="acciones">
                <button class="btn-accion btn-iniciar"
                        id="btnIniciar"
                        onclick="iniciarGrabacion()">
                    ⏺ Iniciar Grabación
                </button>
                <button class="btn-accion btn-detener"
                        id="btnDetener"
                        onclick="detenerGrabacion()"
                        disabled>
                    ⏹ Detener Grabación
                </button>
                <button class="btn-accion btn-reproducir"
                        id="btnReproducir"
                        onclick="reproducir()"
                        disabled>
                    ▶ Reproducir Recorrido
                </button>
                <button class="btn-accion btn-parar"
                        id="btnParar"
                        onclick="pararReproduccion()"
                        disabled>
                    ⏸ Detener Reproducción
                </button>
                <button class="btn-accion btn-limpiar"
                        id="btnLimpiar"
                        onclick="limpiarGrabacion()">
                    🗑 Limpiar todo
                </button>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════════ -->
    <!-- COLUMNA DERECHA: Estado + Lista de pasos    -->
    <!-- ════════════════════════════════════════════ -->
    <div style="display:flex; flex-direction:column; gap:20px;">

        <!-- ESTADO -->
        <div class="card">
            <div class="card-title">📊 Estado del Sistema</div>
            <div class="estado-row">
                <div class="dot" id="dotGrab"></div>
                <span id="txtGrab">Sin grabación activa</span>
            </div>
            <div class="estado-row">
                <div class="dot" id="dotReprod"></div>
                <span id="txtReprod">Sin reproducción activa</span>
            </div>
            <div class="estado-row">
                📋 <span id="txtContador">No hay pasos grabados</span>
            </div>
            <div class="progreso-wrap">
                <div class="progreso-barra" id="barraProgreso"></div>
            </div>
        </div>

        <!-- LISTA DE PASOS GRABADOS -->
        <div class="card" style="flex:1">
            <div class="card-title">📝 Pasos del Recorrido</div>
            <div class="lista-pasos" id="listaPasos">
                <div class="vacio">Presiona "Iniciar Grabación" y mueve el robot</div>
            </div>
        </div>
    </div>

</div>

<!-- Notificación emergente -->
<div id="toast"></div>

<!-- ════════════════════════════════════════════════════════════════ -->
<!-- JAVASCRIPT                                                       -->
<!-- ════════════════════════════════════════════════════════════════ -->
<script>
    // Guardamos los pasos localmente para renderizar la lista sin recargar
    let pasosLocales = [];
    let pasoActivoActual = 0;

    // ── Enviar comando de movimiento al robot ────────────────────────────
    function cmd(comando) {
        fetch('/control?cmd=' + comando)
            .then(r => r.json())
            .then(data => {
                if (data.grabando) {
                    // Agregamos el paso a la lista local para actualización inmediata
                    const emoji = { go:'▲', back:'▼', left:'◀', right:'▶', stop:'⏹' };
                    pasosLocales.push({
                        descripcion: data.descripcion,
                        emoji: emoji[comando] || '•',
                        duracionMs: 0
                    });
                    renderLista(pasosLocales, 0);
                }
            })
            .catch(console.error);
    }

    // ── Iniciar grabación ────────────────────────────────────────────────
    function iniciarGrabacion() {
        fetch('/grabar?accion=iniciar')
            .then(r => r.json())
            .then(data => {
                if (data.ok) {
                    pasosLocales = [];
                    renderLista([], 0);
                    setBotones('grabando');
                    toast('🔴 ' + data.mensaje, '#f85149');
                } else {
                    toast('⚠ ' + data.mensaje);
                }
            }).catch(console.error);
    }

    // ── Detener grabación ────────────────────────────────────────────────
    function detenerGrabacion() {
        fetch('/grabar?accion=detener')
            .then(r => r.json())
            .then(data => {
                if (data.ok) {
                    setBotones('detenido');
                    if (data.totalPasos > 0) {
                        document.getElementById('btnReproducir').disabled = false;
                    }
                    toast('✅ ' + data.mensaje + ' (' + data.totalPasos + ' pasos)', '#3fb950');
                } else {
                    toast('⚠ ' + data.mensaje);
                }
            }).catch(console.error);
    }

    // ── Reproducir recorrido ─────────────────────────────────────────────
    function reproducir() {
        fetch('/grabar?accion=reproducir')
            .then(r => r.json())
            .then(data => {
                if (data.ok) {
                    setBotones('reproduciendo');
                    toast('▶ ' + data.mensaje, '#3fb950');
                } else {
                    toast('⚠ ' + data.mensaje);
                }
            }).catch(console.error);
    }

    // ── Parar reproducción ───────────────────────────────────────────────
    function pararReproduccion() {
        fetch('/grabar?accion=pararReproduccion')
            .then(r => r.json())
            .then(data => {
                if (data.ok) {
                    setBotones('detenido');
                    toast('⏸ ' + data.mensaje, '#bc8cff');
                }
            }).catch(console.error);
    }

    // ── Limpiar grabación ────────────────────────────────────────────────
    function limpiarGrabacion() {
        if (!confirm('¿Deseas eliminar el recorrido grabado?')) return;
        fetch('/grabar?accion=limpiar')
            .then(r => r.json())
            .then(data => {
                if (data.ok) {
                    pasosLocales = [];
                    renderLista([], 0);
                    setBotones('inicial');
                    actualizarContador(0);
                    actualizarBarra(0, 0);
                    toast('🗑 ' + data.mensaje);
                } else {
                    toast('⚠ ' + data.mensaje);
                }
            }).catch(console.error);
    }

    // ── Renderiza la lista de pasos en pantalla ──────────────────────────
    function renderLista(pasos, pasoActivo) {
        const cont = document.getElementById('listaPasos');
        if (pasos.length === 0) {
            cont.innerHTML = '<div class="vacio">Presiona "Iniciar Grabación" y mueve el robot</div>';
            return;
        }
        cont.innerHTML = pasos.map((p, i) => `
            <div class="paso-item ${i === pasoActivo - 1 ? 'paso-activo' : ''}">
                <span class="paso-num">#${i + 1}</span>
                <span class="paso-desc">${p.emoji || '•'} ${p.descripcion}</span>
                <span class="paso-dur">${p.duracionMs > 0 ? p.duracionMs + 'ms' : '—'}</span>
            </div>
        `).join('');

        // Auto-scroll al paso activo
        if (pasoActivo > 0) {
            const items = cont.querySelectorAll('.paso-item');
            if (items[pasoActivo - 1]) {
                items[pasoActivo - 1].scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }
        }
    }

    // ── Actualiza el contador de pasos grabados ──────────────────────────
    function actualizarContador(total) {
        document.getElementById('txtContador').textContent =
            total > 0 ? total + ' paso(s) grabado(s)' : 'No hay pasos grabados';
    }

    // ── Actualiza la barra de progreso ───────────────────────────────────
    function actualizarBarra(actual, total) {
        const barra = document.getElementById('barraProgreso');
        const pct   = total > 0 ? Math.round((actual / total) * 100) : 0;
        barra.style.width  = pct + '%';
        barra.textContent  = total > 0 ? 'Paso ' + actual + '/' + total + '  (' + pct + '%)' : '';
    }

    // ── Gestiona el estado de los botones según el modo ──────────────────
    function setBotones(modo) {
        const ini   = document.getElementById('btnIniciar');
        const det   = document.getElementById('btnDetener');
        const repro = document.getElementById('btnReproducir');
        const parar = document.getElementById('btnParar');
        const limp  = document.getElementById('btnLimpiar');

        ini.disabled   = (modo === 'grabando' || modo === 'reproduciendo');
        det.disabled   = (modo !== 'grabando');
        repro.disabled = (modo !== 'detenido') || (pasosLocales.length === 0);
        parar.disabled = (modo !== 'reproduciendo');
        limp.disabled  = (modo === 'grabando' || modo === 'reproduciendo');
    }

    // ── Toast de notificación ────────────────────────────────────────────
    let toastTimer;
    function toast(msg, color) {
        const el = document.getElementById('toast');
        el.textContent = msg;
        el.style.borderColor = color || '#30363d';
        el.classList.add('show');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(() => el.classList.remove('show'), 3000);
    }

    // ══════════════════════════════════════════════════════════════════════
    // POLLING: Cada 800ms pregunta el estado al servidor y actualiza la UI
    // ══════════════════════════════════════════════════════════════════════
    let estabaReproduciendo = false;

    setInterval(() => {
        fetch('/grabar?accion=estado')
            .then(r => r.json())
            .then(estado => {
                const dotG  = document.getElementById('dotGrab');
                const txtG  = document.getElementById('txtGrab');
                const dotR  = document.getElementById('dotReprod');
                const txtR  = document.getElementById('txtReprod');

                // ─ Estado de grabación ─
                if (estado.grabando) {
                    dotG.className = 'dot activo-rojo';
                    txtG.textContent = '🔴 Grabando... (' + estado.totalGrabados + ' pasos)';
                } else {
                    dotG.className = 'dot';
                    txtG.textContent = 'Sin grabación activa';
                }

                // ─ Estado de reproducción ─
                if (estado.reproduciendo) {
                    dotR.className = 'dot activo-verde';
                    txtR.textContent = '▶ Reproduciendo paso '
                        + estado.pasoActual + ' de ' + estado.totalPasos;
                    actualizarBarra(estado.pasoActual, estado.totalPasos);
                    renderLista(pasosLocales, estado.pasoActual);
                    estabaReproduciendo = true;
                } else {
                    dotR.className = 'dot';
                    txtR.textContent = 'Sin reproducción activa';

                    // Si terminó la reproducción automáticamente, restauramos botones
                    if (estabaReproduciendo) {
                        estabaReproduciendo = false;
                        setBotones('detenido');
                        actualizarBarra(0, 0);
                        renderLista(pasosLocales, 0);
                        if (pasosLocales.length > 0) {
                            document.getElementById('btnReproducir').disabled = false;
                        }
                        toast('✅ Reproducción completada', '#3fb950');
                    }
                }

                // ─ Contador de pasos ─
                actualizarContador(estado.totalGrabados);
            })
            .catch(() => {}); // Silenciamos errores de red
    }, 800);
</script>

</body>
</html>