<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String contextPath = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Grabar Recorrido | Robot ESP32 — SENA CIMM</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Share+Tech+Mono&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --verde:        #39A900;
            --verde-dark:   #2d8400;
            --verde-glow:   rgba(57,169,0,0.45);
            --negro:        #080808;
            --panel:        #111111;
            --card:         #181818;
            --borde:        #252525;
            --borde2:       #333;
            --texto:        #e8e8e8;
            --dim:          #666;
            --acento:       #00ffe5;
            --acento-glow:  rgba(0,255,229,0.35);
            --rojo:         #ff2244;
            --rojo-glow:    rgba(255,34,68,0.4);
            --warn:         #ffcc00;
            --warn-glow:    rgba(255,204,0,0.35);
            --azul:         #3399ff;
            --azul-glow:    rgba(51,153,255,0.35);
            --morado:       #9966ff;
        }

        * { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }

        html, body {
            height: 100%;
            background: var(--negro);
            color: var(--texto);
            font-family: 'Inter', sans-serif;
            overflow-x: hidden;
        }

        /* ═══════════════ TOPBAR ═══════════════ */
        .topbar {
            position: sticky;
            top: 0;
            z-index: 200;
            height: 52px;
            background: var(--panel);
            border-bottom: 1px solid var(--borde2);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 18px;
        }
        .topbar::after {
            content:'';
            position:absolute;
            bottom:0; left:0; right:0;
            height:1px;
            background: linear-gradient(90deg, transparent, var(--verde) 40%, var(--acento) 60%, transparent);
        }
        .brand {
            font-family: 'Orbitron', monospace;
            font-weight: 900;
            font-size: 14px;
            color: var(--verde);
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        .brand span { color: var(--acento); }
        .topbar-nav { display:flex; gap:8px; }
        .nav-btn {
            font-size: 11px;
            font-family: 'Share Tech Mono', monospace;
            color: var(--dim);
            text-decoration: none;
            background: var(--card);
            border: 1px solid var(--borde2);
            border-radius: 6px;
            padding: 5px 12px;
            transition: all .2s;
            cursor: pointer;
        }
        .nav-btn:hover { color: var(--acento); border-color: var(--acento); }
        .rec-badge {
            display: none;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-family: 'Share Tech Mono', monospace;
            color: var(--rojo);
            animation: blink 1s step-start infinite;
        }
        .rec-badge.visible { display: flex; }
        .rec-dot { width:8px; height:8px; border-radius:50%; background:var(--rojo); }
        @keyframes blink { 50% { opacity: 0; } }

        /* ═══════════════ LAYOUT PRINCIPAL ═══════════════ */
        .main {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 16px;
            padding: 16px;
            max-width: 1100px;
            margin: 0 auto;
        }
        @media (max-width: 768px) {
            .main { grid-template-columns: 1fr; }
        }

        /* ═══════════════ CARDS ═══════════════ */
        .card {
            background: var(--card);
            border: 1px solid var(--borde);
            border-radius: 14px;
            padding: 18px;
            position: relative;
            overflow: hidden;
        }
        .card::before {
            content:'';
            position:absolute;
            top:0; left:20px; right:20px;
            height:1px;
            background: linear-gradient(90deg, transparent, var(--borde2), transparent);
        }
        .card-title {
            font-family: 'Orbitron', monospace;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 2px;
            color: var(--dim);
            text-transform: uppercase;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .card-title .dot-indicator {
            width: 6px; height: 6px;
            border-radius: 50%;
            background: var(--verde);
            box-shadow: 0 0 6px var(--verde-glow);
        }

        /* ═══════════════ PANEL IZQUIERDO ═══════════════ */
        .left-panel { display: flex; flex-direction: column; gap: 14px; }

        /* ═══════════════ BARRA DE GRABACION ═══════════════ */
        .rec-bar {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .btn-grabar {
            display: flex;
            align-items: center;
            gap: 8px;
            font-family: 'Orbitron', monospace;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1.5px;
            padding: 10px 20px;
            border-radius: 8px;
            border: 2px solid var(--rojo);
            background: rgba(255,34,68,0.1);
            color: var(--rojo);
            cursor: pointer;
            transition: all .2s;
            text-transform: uppercase;
        }
        .btn-grabar:hover { background: rgba(255,34,68,0.25); box-shadow: 0 0 14px var(--rojo-glow); }
        .btn-grabar.grabando {
            background: var(--rojo);
            color: #fff;
            box-shadow: 0 0 20px var(--rojo-glow);
            animation: pulse-red 1.2s ease-in-out infinite;
        }
        @keyframes pulse-red { 0%,100% { box-shadow:0 0 14px var(--rojo-glow); } 50% { box-shadow:0 0 28px rgba(255,34,68,0.7); } }

        .btn-reproducir {
            display: flex;
            align-items: center;
            gap: 8px;
            font-family: 'Orbitron', monospace;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1.5px;
            padding: 10px 20px;
            border-radius: 8px;
            border: 2px solid var(--verde);
            background: rgba(57,169,0,0.1);
            color: var(--verde);
            cursor: pointer;
            transition: all .2s;
            text-transform: uppercase;
        }
        .btn-reproducir:hover:not(:disabled) { background: rgba(57,169,0,0.25); box-shadow: 0 0 14px var(--verde-glow); }
        .btn-reproducir:disabled { opacity: .35; cursor: not-allowed; }
        .btn-reproducir.reproduciendo {
            background: var(--verde);
            color: #fff;
            box-shadow: 0 0 20px var(--verde-glow);
        }

        .btn-accion {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-family: 'Share Tech Mono', monospace;
            padding: 9px 14px;
            border-radius: 8px;
            border: 1px solid var(--borde2);
            background: var(--panel);
            color: var(--texto);
            cursor: pointer;
            transition: all .2s;
        }
        .btn-accion:hover:not(:disabled) { border-color: var(--acento); color: var(--acento); }
        .btn-accion:disabled { opacity: .35; cursor: not-allowed; }
        .btn-accion.danger:hover:not(:disabled) { border-color: var(--rojo); color: var(--rojo); }

        .cronometro {
            font-family: 'Share Tech Mono', monospace;
            font-size: 22px;
            color: var(--rojo);
            min-width: 90px;
            text-align: center;
            letter-spacing: 2px;
            text-shadow: 0 0 10px var(--rojo-glow);
        }
        .cronometro.idle { color: var(--dim); text-shadow: none; }

        /* ═══════════════ PROGRESO ═══════════════ */
        .progress-wrap {
            display: none;
            flex-direction: column;
            gap: 6px;
        }
        .progress-wrap.visible { display: flex; }
        .progress-label {
            font-size: 11px;
            font-family: 'Share Tech Mono', monospace;
            color: var(--acento);
            display: flex;
            justify-content: space-between;
        }
        .progress-bar-bg {
            height: 6px;
            background: var(--borde2);
            border-radius: 6px;
            overflow: hidden;
        }
        .progress-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--verde), var(--acento));
            border-radius: 6px;
            width: 0%;
            transition: width .3s ease;
            box-shadow: 0 0 8px var(--verde-glow);
        }

        /* ═══════════════ D-PAD ═══════════════ */
        .dpad-section {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 10px 0;
        }
        .dpad {
            display: grid;
            grid-template-areas:
                ". up ."
                "left stop right"
                ". down .";
            gap: 10px;
            grid-template-columns: 90px 90px 90px;
            grid-template-rows: 90px 90px 90px;
        }
        .dpad-btn {
            border-radius: 12px;
            border: 2px solid var(--borde2);
            background: var(--panel);
            color: var(--texto);
            font-size: 28px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            user-select: none;
            transition: all .12s;
            position: relative;
            overflow: hidden;
            gap: 4px;
        }
        .dpad-btn::after {
            content:'';
            position:absolute; inset:0;
            background: radial-gradient(circle at center, rgba(255,255,255,0.08), transparent 70%);
            opacity: 0;
            transition: opacity .1s;
        }
        .dpad-btn:active::after, .dpad-btn.active::after { opacity: 1; }

        .dpad-btn[data-cmd="go"]    { grid-area: up;    border-color: var(--verde); color: var(--verde); }
        .dpad-btn[data-cmd="back"]  { grid-area: down;  border-color: var(--azul);  color: var(--azul);  }
        .dpad-btn[data-cmd="left"]  { grid-area: left;  border-color: var(--acento);color: var(--acento);}
        .dpad-btn[data-cmd="right"] { grid-area: right; border-color: var(--acento);color: var(--acento);}
        .dpad-btn[data-cmd="stop"]  { grid-area: stop;  border-color: var(--rojo);  color: var(--rojo);  font-size:22px; }

        .dpad-btn.active, .dpad-btn:active {
            transform: scale(0.92);
            filter: brightness(1.4);
        }
        .dpad-btn[data-cmd="go"].active    { background: rgba(57,169,0,0.2);  box-shadow: 0 0 18px var(--verde-glow); }
        .dpad-btn[data-cmd="back"].active  { background: rgba(51,153,255,0.2);box-shadow: 0 0 18px var(--azul-glow); }
        .dpad-btn[data-cmd="left"].active,
        .dpad-btn[data-cmd="right"].active { background: rgba(0,255,229,0.12);box-shadow: 0 0 18px var(--acento-glow); }
        .dpad-btn[data-cmd="stop"].active  { background: rgba(255,34,68,0.2); box-shadow: 0 0 18px var(--rojo-glow); }

        .dpad-label {
            font-size: 8px;
            font-family: 'Share Tech Mono', monospace;
            opacity: .5;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        /* ═══════════════ TECLADO INFO ═══════════════ */
        .kbd-info {
            display: flex;
            justify-content: center;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 8px;
        }
        .kbd {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            background: var(--borde2);
            color: var(--dim);
            padding: 2px 7px;
            border-radius: 4px;
            border-bottom: 2px solid #444;
        }

        /* ═══════════════ PANEL DERECHO ═══════════════ */
        .right-panel { display: flex; flex-direction: column; gap: 14px; }

        /* ═══════════════ SECUENCIA ═══════════════ */
        .seq-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }
        .seq-count {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--acento);
        }
        .seq-list {
            display: flex;
            flex-direction: column;
            gap: 5px;
            max-height: 260px;
            overflow-y: auto;
            padding-right: 4px;
        }
        .seq-list::-webkit-scrollbar { width: 4px; }
        .seq-list::-webkit-scrollbar-track { background: var(--panel); border-radius:4px; }
        .seq-list::-webkit-scrollbar-thumb { background: var(--borde2); border-radius:4px; }

        .seq-item {
            display: grid;
            grid-template-columns: 24px 22px 1fr auto 20px;
            align-items: center;
            gap: 8px;
            background: var(--panel);
            border: 1px solid var(--borde);
            border-radius: 8px;
            padding: 7px 10px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            transition: all .15s;
            animation: fadeSlide .2s ease;
        }
        @keyframes fadeSlide {
            from { opacity:0; transform: translateX(10px); }
            to   { opacity:1; transform: translateX(0); }
        }
        .seq-item.playing {
            border-color: var(--acento);
            background: rgba(0,255,229,0.06);
            box-shadow: 0 0 10px var(--acento-glow);
        }
        .seq-item.done { opacity: .4; }
        .seq-num  { color: var(--dim); font-size: 10px; text-align:center; }
        .seq-icono { font-size: 15px; }
        .seq-cmd  { color: var(--texto); }
        .seq-dur  { color: var(--dim); font-size: 11px; text-align: right; }
        .seq-del  {
            background: none; border: none;
            color: var(--dim); cursor: pointer;
            font-size: 14px; padding: 0 2px;
            border-radius: 4px; transition: all .15s;
        }
        .seq-del:hover { color: var(--rojo); }

        .seq-empty {
            text-align: center;
            padding: 30px 16px;
            color: var(--dim);
            font-size: 12px;
            font-family: 'Share Tech Mono', monospace;
            line-height: 1.9;
        }
        .seq-empty-icon { font-size: 32px; margin-bottom: 8px; display: block; opacity: .4; }

        /* ═══════════════ RESUMEN ═══════════════ */
        .resumen-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
        }
        .resumen-item {
            background: var(--panel);
            border: 1px solid var(--borde);
            border-radius: 8px;
            padding: 10px 12px;
            text-align: center;
        }
        .resumen-val {
            font-family: 'Orbitron', monospace;
            font-size: 20px;
            font-weight: 700;
            color: var(--acento);
        }
        .resumen-lbl {
            font-size: 9px;
            color: var(--dim);
            font-family: 'Share Tech Mono', monospace;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-top: 2px;
        }

        /* ═══════════════ CONFIG ═══════════════ */
        .config-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .config-label {
            font-size: 11px;
            font-family: 'Share Tech Mono', monospace;
            color: var(--dim);
            white-space: nowrap;
        }
        .config-input {
            flex: 1;
            min-width: 0;
            background: var(--panel);
            border: 1px solid var(--borde2);
            border-radius: 6px;
            padding: 7px 10px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            color: var(--texto);
            outline: none;
            transition: border-color .2s;
        }
        .config-input:focus { border-color: var(--acento); }
        .btn-test {
            font-size: 11px;
            font-family: 'Share Tech Mono', monospace;
            padding: 7px 12px;
            background: var(--panel);
            border: 1px solid var(--borde2);
            color: var(--dim);
            border-radius: 6px;
            cursor: pointer;
            white-space: nowrap;
            transition: all .2s;
        }
        .btn-test:hover { border-color: var(--verde); color: var(--verde); }
        .status-srv {
            font-size: 11px;
            font-family: 'Share Tech Mono', monospace;
            padding: 4px 10px;
            border-radius: 20px;
            border: 1px solid var(--borde);
            color: var(--dim);
            background: var(--panel);
            transition: all .3s;
            white-space: nowrap;
        }
        .status-srv.online  { border-color: var(--verde); color: var(--verde); background: rgba(57,169,0,0.1); }
        .status-srv.offline { border-color: var(--rojo);  color: var(--rojo);  background: rgba(255,34,68,0.1); }

        /* ═══════════════ TOAST ═══════════════ */
        .toast {
            position: fixed;
            top: 70px;
            left: 50%;
            transform: translateX(-50%) translateY(-10px);
            background: var(--card);
            border: 1px solid var(--borde2);
            border-radius: 10px;
            padding: 10px 18px;
            font-size: 13px;
            font-family: 'Share Tech Mono', monospace;
            display: flex;
            align-items: center;
            gap: 8px;
            z-index: 1000;
            opacity: 0;
            pointer-events: none;
            transition: all .25s;
            white-space: nowrap;
            box-shadow: 0 8px 32px rgba(0,0,0,0.5);
        }
        .toast.show {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }

        /* ═══════════════ FOOTER ═══════════════ */
        footer {
            text-align: center;
            padding: 12px;
            font-size: 10px;
            color: var(--dim);
            font-family: 'Share Tech Mono', monospace;
            letter-spacing: 1px;
            border-top: 1px solid var(--borde);
            margin-top: 4px;
        }

        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: var(--negro); }
        ::-webkit-scrollbar-thumb { background: var(--borde2); border-radius:4px; }
    </style>
</head>
<body>

<!-- TOPBAR -->
<header class="topbar">
    <div class="brand">SENA<span>CIMM</span> &middot; REC MODE</div>
    <div class="rec-badge" id="recBadge">
        <div class="rec-dot"></div> REC
    </div>
    <nav class="topbar-nav">
        <a href="<%= contextPath %>/control" class="nav-btn">&#9664; Control</a>
        <a href="<%= contextPath %>/config"  class="nav-btn">&#9881; Config</a>
    </nav>
</header>

<!-- TOAST -->
<div class="toast" id="toast">
    <span id="toastIcon">&#10003;</span>
    <span id="toastMsg">OK</span>
</div>

<!-- MAIN -->
<div class="main">

    <!-- PANEL IZQUIERDO -->
    <div class="left-panel">

        <!-- CONFIG SERVIDOR -->
        <div class="card">
            <div class="card-title">
                <div class="dot-indicator" style="background:var(--azul);box-shadow:0 0 6px var(--azul-glow)"></div>
                Servidor Tomcat
            </div>
            <div class="config-row">
                <span class="config-label">URL:</span>
                <input class="config-input" id="serverUrl" type="text" placeholder="http://localhost:8080/RobotESP32">
                <button class="btn-test" onclick="probarConexion()">Probar</button>
                <span class="status-srv" id="statusSrv">&#8212;</span>
            </div>
        </div>

        <!-- BARRA DE GRABACION -->
        <div class="card">
            <div class="card-title">
                <div class="dot-indicator" style="background:var(--rojo);box-shadow:0 0 6px var(--rojo-glow)"></div>
                Grabacion de recorrido
            </div>
            <div class="rec-bar">
                <button class="btn-grabar" id="btnGrabar" onclick="toggleGrabar()">
                    <span id="btnGrabarIcon">&#9210;</span>
                    <span id="btnGrabarTxt">GRABAR</span>
                </button>
                <div class="cronometro idle" id="cronometro">00:00.0</div>
                <button class="btn-reproducir" id="btnReproducir" onclick="manejarReproduccion()" disabled>
                    <span id="btnRepIcon">&#9654;</span>
                    <span id="btnRepTxt">REPRODUCIR</span>
                </button>
            </div>
            <div class="progress-wrap" id="progressWrap" style="margin-top:14px;">
                <div class="progress-label">
                    <span id="progressTxt">Paso 0 / 0</span>
                    <span id="progressPct">0%</span>
                </div>
                <div class="progress-bar-bg">
                    <div class="progress-bar-fill" id="progressBar"></div>
                </div>
            </div>
        </div>

        <!-- D-PAD -->
        <div class="card">
            <div class="card-title"><div class="dot-indicator"></div>Control Manual</div>
            <div class="dpad-section">
                <div class="dpad">
                    <button class="dpad-btn" data-cmd="go"    id="btn-go">
                        &#8593;
                        <span class="dpad-label">W / &#8593;</span>
                    </button>
                    <button class="dpad-btn" data-cmd="left"  id="btn-left">
                        &#8592;
                        <span class="dpad-label">A / &#8592;</span>
                    </button>
                    <button class="dpad-btn" data-cmd="stop"  id="btn-stop">
                        &#9209;
                        <span class="dpad-label">STOP</span>
                    </button>
                    <button class="dpad-btn" data-cmd="right" id="btn-right">
                        &#8594;
                        <span class="dpad-label">D / &#8594;</span>
                    </button>
                    <button class="dpad-btn" data-cmd="back"  id="btn-back">
                        &#8595;
                        <span class="dpad-label">S / &#8595;</span>
                    </button>
                </div>
            </div>
            <div class="kbd-info">
                <span class="kbd">W adelante</span>
                <span class="kbd">S atras</span>
                <span class="kbd">A izquierda</span>
                <span class="kbd">D derecha</span>
                <span class="kbd">Espacio stop</span>
            </div>
        </div>

    </div>

    <!-- PANEL DERECHO -->
    <div class="right-panel">

        <!-- RESUMEN -->
        <div class="card">
            <div class="card-title">
                <div class="dot-indicator" style="background:var(--acento);box-shadow:0 0 6px var(--acento-glow)"></div>
                Resumen
            </div>
            <div class="resumen-grid">
                <div class="resumen-item">
                    <div class="resumen-val" id="resumenPasos">0</div>
                    <div class="resumen-lbl">Pasos</div>
                </div>
                <div class="resumen-item">
                    <div class="resumen-val" id="resumenDur">0s</div>
                    <div class="resumen-lbl">Duracion total</div>
                </div>
            </div>
        </div>

        <!-- SECUENCIA -->
        <div class="card" style="flex:1;">
            <div class="seq-header">
                <div class="card-title" style="margin-bottom:0;">
                    <div class="dot-indicator" style="background:var(--morado);box-shadow:0 0 6px rgba(153,102,255,0.4)"></div>
                    Secuencia grabada
                </div>
                <span class="seq-count" id="seqCount">0 pasos</span>
            </div>
            <div class="seq-list" id="seqList">
                <div class="seq-empty">
                    <span class="seq-empty-icon">&#127897;</span>
                    Presiona <strong>GRABAR</strong> y mueve<br>
                    el robot con el D-PAD o el teclado.<br>
                    Cada movimiento quedara registrado.
                </div>
            </div>
        </div>

        <!-- ACCIONES -->
        <div class="card">
            <div class="card-title">
                <div class="dot-indicator" style="background:var(--warn);box-shadow:0 0 6px var(--warn-glow)"></div>
                Acciones
            </div>
            <div style="display:flex; gap:8px; flex-wrap:wrap;">
                <button class="btn-accion" id="btnExportar" onclick="exportarJSON()" disabled>&#128190; Exportar JSON</button>
                <button class="btn-accion" onclick="importarJSON()">&#128194; Importar JSON</button>
                <button class="btn-accion danger" id="btnBorrar" onclick="borrarSecuencia()" disabled>&#128465; Borrar todo</button>
            </div>
            <input type="file" id="fileImport" accept=".json" style="display:none" onchange="leerArchivoJSON(event)">
        </div>

    </div>
</div>

<footer>SENA CIMM &mdash; ADSO 228118 &mdash; Robot ESP32 Recorder &mdash; 2026</footer>

<script>
// ═══════════════════════════════════════════
// CONTEXTO DEL SERVIDOR (inyectado por JSP)
// ═══════════════════════════════════════════
var _CTX = '<%= contextPath %>';
document.getElementById('serverUrl').value = window.location.origin + _CTX;

function getCtx() {
    return document.getElementById('serverUrl').value.replace(/\/$/, '');
}

// ═══════════════════════════════════════════
// TOAST
// ═══════════════════════════════════════════
function toast(icon, msg, color) {
    color = color || '#39A900';
    var t = document.getElementById('toast');
    document.getElementById('toastIcon').textContent = icon;
    document.getElementById('toastMsg').textContent  = msg;
    t.style.borderColor = color;
    t.classList.add('show');
    clearTimeout(t._tid);
    t._tid = setTimeout(function() { t.classList.remove('show'); }, 2300);
}

// ═══════════════════════════════════════════
// COMUNICACION CON EL ROBOT
// ═══════════════════════════════════════════
async function enviarCmd(cmd) {
    var fd = new FormData();
    fd.append('cmd', cmd);
    try {
        var r = await fetch(getCtx() + '/control', { method: 'POST', body: fd });
        return await r.json();
    } catch(e) {
        return { exito: false, mensaje: 'Sin respuesta' };
    }
}

async function probarConexion() {
    var el = document.getElementById('statusSrv');
    el.textContent = '...';
    el.className = 'status-srv';
    try {
        var r = await fetch(getCtx() + '/status');
        if (r.ok) {
            var d = await r.json();
            el.textContent = d.conectado ? 'ROBOT ONLINE' : 'SERVIDOR OK';
            el.className = 'status-srv online';
            toast('\u2713', d.conectado ? 'Robot conectado' : 'Servidor OK', '#39A900');
        } else { throw new Error(); }
    } catch(e) {
        el.textContent = 'SIN CONEXION';
        el.className = 'status-srv offline';
        toast('\u2715', 'No se pudo conectar', '#ff2244');
    }
}

// ═══════════════════════════════════════════
// METADATA DE COMANDOS
// ═══════════════════════════════════════════
var CMD_META = {
    go:    { label: 'Adelante',  icono: '\u2b06\ufe0f', color: '#39A900' },
    back:  { label: 'Atras',     icono: '\u2b07\ufe0f', color: '#3399ff' },
    left:  { label: 'Izquierda', icono: '\u2b05\ufe0f', color: '#00ffe5' },
    right: { label: 'Derecha',   icono: '\u27a1\ufe0f', color: '#00ffe5' },
    stop:  { label: 'Detener',   icono: '\u23f9\ufe0f', color: '#ff2244' },
    ledon: { label: 'LED ON',    icono: '\U0001f4a1',   color: '#ffcc00' },
    ledoff:{ label: 'LED OFF',   icono: '\U0001f311',   color: '#666'    }
};

// ═══════════════════════════════════════════
// ESTADO GLOBAL
// ═══════════════════════════════════════════
var grabando      = false;
var secuencia     = [];
var cmdActual     = null;
var tCmdInicio    = null;
var tGrabInicio   = null;
var cronInterval  = null;
var btnActivo     = null;
var reproduciendo = false;
var stopRepr      = false;
var reprTimeout   = null;

// ═══════════════════════════════════════════
// CRONOMETRO
// ═══════════════════════════════════════════
function formatMs(ms) {
    var total = Math.floor(ms / 100);
    var dec   = total % 10;
    var segs  = Math.floor(total / 10) % 60;
    var mins  = Math.floor(total / 600);
    return (mins < 10 ? '0' : '') + mins + ':' +
           (segs < 10 ? '0' : '') + segs + '.' + dec;
}

function iniciarCronometro() {
    tGrabInicio = Date.now();
    var el = document.getElementById('cronometro');
    el.classList.remove('idle');
    cronInterval = setInterval(function() {
        el.textContent = formatMs(Date.now() - tGrabInicio);
    }, 100);
}

function detenerCronometro() {
    clearInterval(cronInterval);
    document.getElementById('cronometro').classList.add('idle');
}

// ═══════════════════════════════════════════
// TOGGLE GRABACION
// ═══════════════════════════════════════════
function toggleGrabar() {
    if (reproduciendo) { toast('\u26a0', 'Deten la reproduccion primero', '#ffcc00'); return; }

    if (!grabando) {
        // -- INICIAR --
        grabando  = true;
        secuencia = [];
        renderSecuencia();
        iniciarCronometro();

        document.getElementById('btnGrabar').classList.add('grabando');
        document.getElementById('btnGrabarIcon').textContent = '\u23f9';
        document.getElementById('btnGrabarTxt').textContent  = 'DETENER GRAB.';
        document.getElementById('btnReproducir').disabled = true;
        document.getElementById('btnExportar').disabled   = true;
        document.getElementById('btnBorrar').disabled     = true;
        document.getElementById('recBadge').classList.add('visible');
        toast('\u25cf', 'Grabacion iniciada', '#ff2244');

    } else {
        // -- DETENER --
        grabando = false;

        // Cerrar paso activo si habia boton presionado
        if (cmdActual && tCmdInicio) {
            var dur = Date.now() - tCmdInicio;
            if (dur > 50) secuencia.push({ cmd: cmdActual, duracion: dur });
            enviarCmd('stop');
        }
        cmdActual  = null;
        tCmdInicio = null;
        soltarBotones();
        detenerCronometro();

        document.getElementById('btnGrabar').classList.remove('grabando');
        document.getElementById('btnGrabarIcon').textContent = '\u23fa';
        document.getElementById('btnGrabarTxt').textContent  = 'GRABAR';
        document.getElementById('recBadge').classList.remove('visible');

        var tiene = secuencia.length > 0;
        document.getElementById('btnReproducir').disabled = !tiene;
        document.getElementById('btnExportar').disabled   = !tiene;
        document.getElementById('btnBorrar').disabled     = !tiene;

        renderSecuencia();
        toast('\u23f9', 'Grabacion completada: ' + secuencia.length + ' pasos', '#39A900');
    }
}

// ═══════════════════════════════════════════
// CONTROL D-PAD
// ═══════════════════════════════════════════
function presionar(cmd) {
    if (btnActivo === cmd) return;

    // Cerrar paso anterior si habia otro activo
    if (btnActivo && btnActivo !== 'stop') {
        if (grabando && cmdActual && tCmdInicio) {
            var dur = Date.now() - tCmdInicio;
            if (dur > 50) { secuencia.push({ cmd: cmdActual, duracion: dur }); renderSecuencia(); }
        }
        cmdActual  = null;
        tCmdInicio = null;
    }

    btnActivo = cmd;

    if (cmd === 'stop') {
        enviarCmd('stop');
        if (grabando) { secuencia.push({ cmd: 'stop', duracion: 300 }); renderSecuencia(); }
    } else {
        enviarCmd(cmd);
        if (grabando) { cmdActual = cmd; tCmdInicio = Date.now(); }
    }

    // Visual
    document.querySelectorAll('.dpad-btn').forEach(function(b) { b.classList.remove('active'); });
    var el = document.getElementById('btn-' + cmd);
    if (el) el.classList.add('active');
}

function soltar() {
    if (!btnActivo || btnActivo === 'stop') { soltarBotones(); return; }

    enviarCmd('stop');

    if (grabando && cmdActual && tCmdInicio) {
        var dur = Date.now() - tCmdInicio;
        if (dur > 50) { secuencia.push({ cmd: cmdActual, duracion: dur }); renderSecuencia(); }
    }

    cmdActual  = null;
    tCmdInicio = null;
    btnActivo  = null;
    soltarBotones();
}

function soltarBotones() {
    document.querySelectorAll('.dpad-btn').forEach(function(b) { b.classList.remove('active'); });
    btnActivo = null;
}

// ═══════════════════════════════════════════
// EVENTOS D-PAD
// ═══════════════════════════════════════════
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.dpad-btn').forEach(function(btn) {
        var cmd = btn.dataset.cmd;
        btn.addEventListener('mousedown',  function(e) { e.preventDefault(); presionar(cmd); });
        btn.addEventListener('mouseup',    function(e) { e.preventDefault(); soltar(); });
        btn.addEventListener('mouseleave', function(e) { if (btnActivo === cmd) soltar(); });
        btn.addEventListener('touchstart', function(e) { e.preventDefault(); presionar(cmd); }, { passive: false });
        btn.addEventListener('touchend',   function(e) { e.preventDefault(); soltar(); },       { passive: false });
        btn.addEventListener('touchcancel',function(e) { e.preventDefault(); soltar(); },       { passive: false });
    });

    var teclado = {
        ArrowUp: 'go', KeyW: 'go',
        ArrowDown: 'back', KeyS: 'back',
        ArrowLeft: 'left', KeyA: 'left',
        ArrowRight: 'right', KeyD: 'right',
        Space: 'stop'
    };
    document.addEventListener('keydown', function(e) {
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;
        var cmd = teclado[e.code];
        if (cmd) { e.preventDefault(); presionar(cmd); }
    });
    document.addEventListener('keyup', function(e) {
        var cmd = teclado[e.code];
        if (cmd) { e.preventDefault(); soltar(); }
    });
});

// ═══════════════════════════════════════════
// RENDER SECUENCIA
// ═══════════════════════════════════════════
function renderSecuencia() {
    var list = document.getElementById('seqList');
    document.getElementById('seqCount').textContent = secuencia.length + ' pasos';
    document.getElementById('resumenPasos').textContent = secuencia.length;

    var totalMs = secuencia.reduce(function(s, p) { return s + p.duracion; }, 0);
    document.getElementById('resumenDur').textContent =
        totalMs >= 1000 ? (totalMs / 1000).toFixed(1) + 's' : totalMs + 'ms';

    if (secuencia.length === 0) {
        list.innerHTML = '<div class="seq-empty">'
            + '<span class="seq-empty-icon">&#127897;</span>'
            + 'Presiona <strong>GRABAR</strong> y mueve<br>'
            + 'el robot con el D-PAD o el teclado.<br>'
            + 'Cada movimiento quedara registrado.'
            + '</div>';
        return;
    }

    list.innerHTML = '';
    secuencia.forEach(function(paso, i) {
        var meta = CMD_META[paso.cmd] || { label: paso.cmd, icono: '\u25b6', color: '#fff' };
        var dur  = paso.duracion >= 1000
            ? (paso.duracion / 1000).toFixed(2) + 's'
            : paso.duracion + 'ms';

        var item = document.createElement('div');
        item.className = 'seq-item';
        item.id = 'seq-item-' + i;
        item.innerHTML =
            '<span class="seq-num">' + (i + 1) + '</span>' +
            '<span class="seq-icono">' + meta.icono + '</span>' +
            '<span class="seq-cmd" style="color:' + meta.color + '">' + meta.label + '</span>' +
            '<span class="seq-dur">' + dur + '</span>' +
            '<button class="seq-del" onclick="eliminarPaso(' + i + ')" title="Eliminar">\u00d7</button>';
        list.appendChild(item);
    });
    list.scrollTop = list.scrollHeight;
}

function eliminarPaso(i) {
    secuencia.splice(i, 1);
    renderSecuencia();
    var tiene = secuencia.length > 0;
    document.getElementById('btnReproducir').disabled = !tiene;
    document.getElementById('btnExportar').disabled   = !tiene;
    document.getElementById('btnBorrar').disabled     = !tiene;
    toast('\u2715', 'Paso eliminado', '#ffcc00');
}

// ═══════════════════════════════════════════
// REPRODUCCION
// ═══════════════════════════════════════════
function manejarReproduccion() {
    if (reproduciendo) { detenerReproduccion(); }
    else               { reproducir(); }
}

async function reproducir() {
    if (grabando)          { toast('\u26a0', 'Deten la grabacion primero', '#ffcc00'); return; }
    if (secuencia.length === 0) { toast('\u26a0', 'Sin secuencia grabada', '#ffcc00'); return; }

    reproduciendo = true;
    stopRepr      = false;

    document.getElementById('btnReproducir').classList.add('reproduciendo');
    document.getElementById('btnRepIcon').textContent = '\u23f9';
    document.getElementById('btnRepTxt').textContent  = 'DETENER';
    document.getElementById('btnGrabar').disabled      = true;
    document.getElementById('progressWrap').classList.add('visible');
    toast('\u25b6', 'Reproduciendo recorrido...', '#39A900');

    for (var i = 0; i < secuencia.length && !stopRepr; i++) {
        var paso = secuencia[i];
        var pct  = Math.round((i / secuencia.length) * 100);
        actualizarProgreso(i + 1, secuencia.length, pct);
        marcarItemActivo(i);
        await enviarCmd(paso.cmd);
        await new Promise(function(res) {
            reprTimeout = setTimeout(res, paso.duracion);
        });
    }

    if (!stopRepr) {
        await enviarCmd('stop');
        actualizarProgreso(secuencia.length, secuencia.length, 100);
        toast('\u2713', 'Recorrido completado', '#39A900');
    }
    finalizarReproduccion();
}

function detenerReproduccion() {
    stopRepr = true;
    clearTimeout(reprTimeout);
    enviarCmd('stop');
    finalizarReproduccion();
    toast('\u23f9', 'Reproduccion detenida', '#ffcc00');
}

function finalizarReproduccion() {
    reproduciendo = false;
    stopRepr      = false;
    document.getElementById('btnReproducir').classList.remove('reproduciendo');
    document.getElementById('btnRepIcon').textContent = '\u25b6';
    document.getElementById('btnRepTxt').textContent  = 'REPRODUCIR';
    document.getElementById('btnGrabar').disabled      = false;
    document.getElementById('progressWrap').classList.remove('visible');
    document.querySelectorAll('.seq-item').forEach(function(el) {
        el.classList.remove('playing', 'done');
    });
}

function actualizarProgreso(paso, total, pct) {
    document.getElementById('progressTxt').textContent = 'Paso ' + paso + ' / ' + total;
    document.getElementById('progressPct').textContent = pct + '%';
    document.getElementById('progressBar').style.width = pct + '%';
}

function marcarItemActivo(idx) {
    document.querySelectorAll('.seq-item').forEach(function(el, i) {
        el.classList.remove('playing', 'done');
        if (i === idx) el.classList.add('playing');
        if (i <  idx) el.classList.add('done');
    });
    var el = document.getElementById('seq-item-' + idx);
    if (el) el.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
}

// ═══════════════════════════════════════════
// BORRAR
// ═══════════════════════════════════════════
function borrarSecuencia() {
    if (!confirm('Borrar toda la secuencia grabada?')) return;
    secuencia = [];
    renderSecuencia();
    document.getElementById('btnReproducir').disabled = true;
    document.getElementById('btnExportar').disabled   = true;
    document.getElementById('btnBorrar').disabled     = true;
    document.getElementById('cronometro').textContent = '00:00.0';
    toast('\u2715', 'Secuencia borrada', '#ffcc00');
}

// ═══════════════════════════════════════════
// EXPORTAR / IMPORTAR JSON
// ═══════════════════════════════════════════
function exportarJSON() {
    if (secuencia.length === 0) return;
    var data = {
        nombre:          'Recorrido Robot ESP32',
        fecha:           new Date().toISOString(),
        servidor:        getCtx(),
        totalPasos:      secuencia.length,
        duracionTotalMs: secuencia.reduce(function(s, p) { return s + p.duracion; }, 0),
        secuencia:       secuencia
    };
    var blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    var url  = URL.createObjectURL(blob);
    var a    = document.createElement('a');
    a.href   = url;
    a.download = 'recorrido_robot_' + Date.now() + '.json';
    a.click();
    URL.revokeObjectURL(url);
    toast('\u2714', 'Recorrido exportado como JSON', '#39A900');
}

function importarJSON() {
    document.getElementById('fileImport').click();
}

function leerArchivoJSON(event) {
    var file = event.target.files[0];
    if (!file) return;
    var reader = new FileReader();
    reader.onload = function(e) {
        try {
            var data = JSON.parse(e.target.result);
            if (!Array.isArray(data.secuencia)) throw new Error();
            secuencia = data.secuencia.filter(function(p) {
                return p.cmd && typeof p.duracion === 'number';
            });
            renderSecuencia();
            var tiene = secuencia.length > 0;
            document.getElementById('btnReproducir').disabled = !tiene;
            document.getElementById('btnExportar').disabled   = !tiene;
            document.getElementById('btnBorrar').disabled     = !tiene;
            toast('\u2714', 'Importado: ' + secuencia.length + ' pasos', '#39A900');
        } catch(err) {
            toast('\u2715', 'Archivo JSON invalido', '#ff2244');
        }
        event.target.value = '';
    };
    reader.readAsText(file);
}
</script>

</body>
</html>
