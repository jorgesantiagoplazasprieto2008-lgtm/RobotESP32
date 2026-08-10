<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="co.sena.cimm.robot.model.RobotConfig" %>
        <%@ page import="co.sena.cimm.robot.model.ComandoRobot" %>
            <%@ page import="java.util.List" %>
                <% RobotConfig robotConfig=(RobotConfig) request.getAttribute("config"); if (robotConfig==null) {
                    response.sendRedirect(request.getContextPath() + "/config" ); return; } List<ComandoRobot> historial
                    = (List<ComandoRobot>) request.getAttribute("historial");
                        String contextPath = request.getContextPath();
                        %>
                        <!DOCTYPE html>
                        <html lang="es">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
                            <title>Control Robot ESP32 | SENA CIMM</title>
                            <link
                                href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Share+Tech+Mono&family=Inter:wght@300;400;600&display=swap"
                                rel="stylesheet">
                            <style>
                                :root {
                                    --verde: #39A900;
                                    --verde-dark: #2d8400;
                                    --verde-glow: rgba(57, 169, 0, 0.5);
                                    --negro: #080808;
                                    --gris-panel: #141414;
                                    --gris-card: #1c1c1c;
                                    --gris-borde: #2a2a2a;
                                    --texto: #e8e8e8;
                                    --dim: #555;
                                    --acento: #00ffe5;
                                    --acento-glow: rgba(0, 255, 229, 0.4);
                                    --danger: #ff2244;
                                    --danger-glow: rgba(255, 34, 68, 0.4);
                                    --warn: #ffcc00;
                                    --azul: #3399ff;
                                }

                                * {
                                    margin: 0;
                                    padding: 0;
                                    box-sizing: border-box;
                                }

                                body {
                                    background: var(--negro);
                                    color: var(--texto);
                                    font-family: 'Inter', sans-serif;
                                    height: 100vh;
                                    overflow: hidden;
                                    display: grid;
                                    grid-template-rows: 52px 1fr 38px;
                                }

                                /* ===== TOPBAR ===== */
                                .topbar {
                                    background: var(--gris-panel);
                                    border-bottom: 1px solid var(--gris-borde);
                                    display: flex;
                                    align-items: center;
                                    justify-content: space-between;
                                    padding: 0 16px;
                                    gap: 12px;
                                    position: relative;
                                    z-index: 100;
                                }

                                .topbar::after {
                                    content: '';
                                    position: absolute;
                                    bottom: 0;
                                    left: 0;
                                    right: 0;
                                    height: 1px;
                                    background: linear-gradient(90deg, transparent, var(--verde), transparent);
                                }

                                .brand {
                                    font-family: 'Orbitron', monospace;
                                    font-weight: 900;
                                    font-size: 14px;
                                    color: var(--verde);
                                    text-shadow: 0 0 15px var(--verde-glow);
                                    letter-spacing: 2px;
                                }

                                .brand-sub {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    color: var(--dim);
                                }

                                .topbar-tabs {
                                    display: flex;
                                    gap: 4px;
                                }

                                .tab-btn {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    letter-spacing: 1px;
                                    background: transparent;
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 6px;
                                    color: var(--dim);
                                    padding: 5px 12px;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                    text-transform: uppercase;
                                }

                                .tab-btn:hover {
                                    border-color: var(--verde);
                                    color: var(--verde);
                                }

                                .tab-btn.active {
                                    background: var(--verde);
                                    color: white;
                                    border-color: var(--verde);
                                    box-shadow: 0 0 12px var(--verde-glow);
                                }

                                .status-row {
                                    display: flex;
                                    align-items: center;
                                    gap: 10px;
                                }

                                .dot {
                                    width: 8px;
                                    height: 8px;
                                    border-radius: 50%;
                                    background: var(--danger);
                                    box-shadow: 0 0 6px var(--danger-glow);
                                }

                                .dot.online {
                                    background: var(--verde);
                                    box-shadow: 0 0 8px var(--verde-glow);
                                    animation: pulse 2s infinite;
                                }

                                @keyframes pulse {

                                    0%,
                                    100% {
                                        opacity: 1
                                    }

                                    50% {
                                        opacity: 0.4
                                    }
                                }

                                .status-txt {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                }

                                .config-btn {
                                    background: var(--gris-card);
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 6px;
                                    color: var(--dim);
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    padding: 5px 10px;
                                    cursor: pointer;
                                    text-decoration: none;
                                    display: inline-flex;
                                    align-items: center;
                                    gap: 5px;
                                    transition: all 0.2s;
                                }

                                .config-btn:hover {
                                    border-color: var(--verde);
                                    color: var(--verde);
                                }

                                .rec-btn {
                                    background: var(--gris-card);
                                    border: 1px solid var(--danger);
                                    border-radius: 6px;
                                    color: var(--danger);
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    padding: 5px 10px;
                                    cursor: pointer;
                                    text-decoration: none;
                                    display: inline-flex;
                                    align-items: center;
                                    gap: 5px;
                                    transition: all 0.2s;
                                    animation: rec-pulse 2.5s ease-in-out infinite;
                                }
                                .rec-btn:hover {
                                    background: rgba(255,34,68,0.15);
                                    box-shadow: 0 0 10px var(--danger-glow);
                                    color: var(--danger);
                                }
                                @keyframes rec-pulse {
                                    0%, 100% { box-shadow: none; }
                                    50% { box-shadow: 0 0 7px var(--danger-glow); }
                                }

                                /* ===== PANELS ===== */
                                .panels {
                                    display: grid;
                                    grid-template-columns: 1fr 300px;
                                    height: 100%;
                                    overflow: hidden;
                                }

                                .tab-panel {
                                    display: none;
                                    flex-direction: column;
                                    height: 100%;
                                    overflow: hidden;
                                }

                                .tab-panel.active {
                                    display: flex;
                                }

                                /* ===== CAMERA ===== */
                                .camera-wrap {
                                    flex: 1;
                                    position: relative;
                                    background: #000;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    overflow: hidden;
                                    margin: 12px 12px 0;
                                    border-radius: 12px;
                                    border: 1px solid var(--gris-borde);
                                    min-height: 0;
                                }

                                .camera-feed {
                                    width: 100%;
                                    height: 100%;
                                    object-fit: contain;
                                    display: block;
                                }

                                .cam-corner {
                                    position: absolute;
                                    width: 18px;
                                    height: 18px;
                                    border-color: var(--acento);
                                    border-style: solid;
                                    opacity: 0.6;
                                }

                                .cam-corner.tl {
                                    top: 8px;
                                    left: 8px;
                                    border-width: 2px 0 0 2px
                                }

                                .cam-corner.tr {
                                    top: 8px;
                                    right: 8px;
                                    border-width: 2px 2px 0 0
                                }

                                .cam-corner.bl {
                                    bottom: 8px;
                                    left: 8px;
                                    border-width: 0 0 2px 2px
                                }

                                .cam-corner.br {
                                    bottom: 8px;
                                    right: 8px;
                                    border-width: 0 2px 2px 0
                                }

                                .cam-badge {
                                    position: absolute;
                                    top: 10px;
                                    left: 50%;
                                    transform: translateX(-50%);
                                    background: rgba(255, 34, 68, 0.85);
                                    color: white;
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    padding: 3px 10px;
                                    border-radius: 4px;
                                    letter-spacing: 2px;
                                    display: flex;
                                    align-items: center;
                                    gap: 6px;
                                }

                                .rec-dot {
                                    width: 6px;
                                    height: 6px;
                                    background: white;
                                    border-radius: 50%;
                                    animation: pulse 1s infinite;
                                }

                                .capture-flash {
                                    position: absolute;
                                    inset: 0;
                                    background: white;
                                    border-radius: 12px;
                                    opacity: 0;
                                    pointer-events: none;
                                    transition: opacity 0.08s;
                                }

                                .capture-flash.flash {
                                    opacity: 0.85;
                                }

                                .cam-offline {
                                    display: flex;
                                    flex-direction: column;
                                    align-items: center;
                                    justify-content: center;
                                    gap: 10px;
                                    color: var(--dim);
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 12px;
                                    text-align: center;
                                    padding: 20px;
                                }

                                /* ===== D-PAD ===== */
                                .controls-bar {
                                    padding: 10px 12px;
                                    display: grid;
                                    grid-template-columns: auto 1fr auto;
                                    gap: 12px;
                                    align-items: center;
                                }

                                .dpad {
                                    display: grid;
                                    grid-template-areas: ". up ." "left stop right" ". down .";
                                    gap: 6px;
                                }

                                .btn-d {
                                    width: 56px;
                                    height: 56px;
                                    border: none;
                                    border-radius: 10px;
                                    cursor: pointer;
                                    font-size: 20px;
                                    display: flex;
                                    flex-direction: column;
                                    align-items: center;
                                    justify-content: center;
                                    transition: all 0.1s;
                                    user-select: none;
                                    -webkit-user-select: none;
                                    font-family: 'Share Tech Mono', monospace;
                                }

                                .btn-d span {
                                    font-size: 8px;
                                    letter-spacing: 1px;
                                    opacity: 0.5;
                                    margin-top: 2px;
                                }

                                .btn-d:active,
                                .btn-d.pressed {
                                    transform: scale(0.88);
                                }

                                .d-up {
                                    grid-area: up;
                                    background: #1a2a1a;
                                    border: 2px solid var(--verde);
                                    color: var(--verde);
                                }

                                .d-down {
                                    grid-area: down;
                                    background: #1a1a2a;
                                    border: 2px solid var(--azul);
                                    color: var(--azul);
                                }

                                .d-left {
                                    grid-area: left;
                                    background: #2a2a14;
                                    border: 2px solid var(--warn);
                                    color: var(--warn);
                                }

                                .d-right {
                                    grid-area: right;
                                    background: #2a2a14;
                                    border: 2px solid var(--warn);
                                    color: var(--warn);
                                }

                                .d-stop {
                                    grid-area: stop;
                                    background: #2a1a1a;
                                    border: 2px solid var(--danger);
                                    color: var(--danger);
                                    font-size: 16px;
                                }

                                .d-up:hover {
                                    box-shadow: 0 0 14px var(--verde-glow);
                                }

                                .d-down:hover {
                                    box-shadow: 0 0 14px rgba(51, 153, 255, 0.4);
                                }

                                .d-left:hover,
                                .d-right:hover {
                                    box-shadow: 0 0 14px rgba(255, 204, 0, 0.3);
                                }

                                .d-stop:hover {
                                    box-shadow: 0 0 14px var(--danger-glow);
                                }

                                .extras-col {
                                    display: flex;
                                    flex-direction: column;
                                    gap: 6px;
                                }

                                .btn-extra {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    background: var(--gris-card);
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 7px;
                                    color: var(--texto);
                                    padding: 8px 12px;
                                    cursor: pointer;
                                    display: flex;
                                    align-items: center;
                                    gap: 7px;
                                    transition: all 0.2s;
                                    white-space: nowrap;
                                }

                                .btn-extra:hover {
                                    border-color: var(--acento);
                                    color: var(--acento);
                                }

                                .speed-col {
                                    display: flex;
                                    flex-direction: column;
                                    gap: 8px;
                                    min-width: 90px;
                                }

                                .speed-lbl {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 9px;
                                    color: var(--dim);
                                    letter-spacing: 2px;
                                    text-transform: uppercase;
                                }

                                .speed-num {
                                    font-family: 'Orbitron', monospace;
                                    font-size: 22px;
                                    color: var(--verde);
                                    text-align: center;
                                }

                                input[type=range] {
                                    width: 100%;
                                    accent-color: var(--verde);
                                    cursor: pointer;
                                }

                                .speed-presets {
                                    display: flex;
                                    gap: 4px;
                                    justify-content: center;
                                }

                                .sp-btn {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    background: var(--gris-card);
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 5px;
                                    color: var(--dim);
                                    padding: 4px 8px;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                }

                                .sp-btn:hover {
                                    border-color: var(--verde);
                                    color: var(--verde);
                                }

                                /* ===== JOYSTICK ===== */
                                .joystick-layout {
                                    flex: 1;
                                    display: grid;
                                    grid-template-columns: 1fr auto 1fr;
                                    align-items: center;
                                    padding: 12px;
                                    gap: 16px;
                                    overflow: hidden;
                                }

                                .joystick-area {
                                    display: flex;
                                    flex-direction: column;
                                    align-items: center;
                                    gap: 12px;
                                }

                                .joystick-container {
                                    position: relative;
                                    width: 200px;
                                    height: 200px;
                                    border-radius: 50%;
                                    background: radial-gradient(ellipse at center, #1c1c1c 0%, #0a0a0a 100%);
                                    border: 2px solid var(--gris-borde);
                                    box-shadow: 0 0 30px rgba(0, 0, 0, 0.8), inset 0 0 20px rgba(0, 0, 0, 0.5);
                                    touch-action: none;
                                    user-select: none;
                                    -webkit-user-select: none;
                                }

                                .joystick-container::before,
                                .joystick-container::after {
                                    content: '';
                                    position: absolute;
                                    background: var(--gris-borde);
                                    opacity: 0.3;
                                }

                                .joystick-container::before {
                                    width: 1px;
                                    height: 100%;
                                    left: 50%;
                                    top: 0;
                                }

                                .joystick-container::after {
                                    height: 1px;
                                    width: 100%;
                                    top: 50%;
                                    left: 0;
                                }

                                .joystick-knob {
                                    position: absolute;
                                    width: 70px;
                                    height: 70px;
                                    border-radius: 50%;
                                    background: radial-gradient(ellipse at 35% 35%, #444, #1a1a1a);
                                    border: 2px solid var(--verde);
                                    box-shadow: 0 0 15px var(--verde-glow);
                                    cursor: grab;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    font-size: 20px;
                                    transition: box-shadow 0.1s;
                                }

                                .joystick-knob.active {
                                    cursor: grabbing;
                                    box-shadow: 0 0 28px var(--verde-glow);
                                }

                                .jz-labels {
                                    position: absolute;
                                    inset: 0;
                                    pointer-events: none;
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    color: var(--dim);
                                }

                                .jz-labels span {
                                    position: absolute;
                                }

                                .jz-u {
                                    top: 8px;
                                    left: 50%;
                                    transform: translateX(-50%);
                                }

                                .jz-d {
                                    bottom: 8px;
                                    left: 50%;
                                    transform: translateX(-50%);
                                }

                                .jz-l {
                                    left: 8px;
                                    top: 50%;
                                    transform: translateY(-50%);
                                }

                                .jz-r {
                                    right: 8px;
                                    top: 50%;
                                    transform: translateY(-50%);
                                }

                                .joy-data {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 12px;
                                    color: var(--dim);
                                    text-align: center;
                                    line-height: 1.8;
                                }

                                .joy-data strong {
                                    color: var(--acento);
                                }

                                /* ===== GYRO ===== */
                                .gyro-layout {
                                    flex: 1;
                                    display: flex;
                                    flex-direction: column;
                                    align-items: center;
                                    justify-content: center;
                                    padding: 16px;
                                    gap: 18px;
                                    overflow-y: auto;
                                }

                                .gyro-circle {
                                    width: 190px;
                                    height: 190px;
                                    border-radius: 50%;
                                    border: 2px solid var(--gris-borde);
                                    background: radial-gradient(ellipse at center, #1c1c1c, #0a0a0a);
                                    position: relative;
                                    overflow: hidden;
                                }

                                .gyro-horizon {
                                    position: absolute;
                                    left: 0;
                                    right: 0;
                                    height: 2px;
                                    background: var(--acento);
                                    top: 50%;
                                    box-shadow: 0 0 8px var(--acento-glow);
                                }

                                .gyro-center-dot {
                                    position: absolute;
                                    width: 10px;
                                    height: 10px;
                                    border-radius: 50%;
                                    background: var(--verde);
                                    top: 50%;
                                    left: 50%;
                                    transform: translate(-50%, -50%);
                                    box-shadow: 0 0 8px var(--verde-glow);
                                }

                                .gyro-arrow {
                                    position: absolute;
                                    font-size: 28px;
                                    top: 50%;
                                    left: 50%;
                                    transform: translate(-50%, -50%) rotate(0deg);
                                    transition: transform 0.12s;
                                    color: var(--verde);
                                    text-shadow: 0 0 12px var(--verde-glow);
                                    pointer-events: none;
                                }

                                .gyro-data {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 12px;
                                    text-align: center;
                                    color: var(--dim);
                                    line-height: 2;
                                }

                                .gyro-data strong {
                                    color: var(--acento);
                                    font-size: 15px;
                                }

                                .gyro-btn-group {
                                    display: flex;
                                    gap: 10px;
                                    flex-wrap: wrap;
                                    justify-content: center;
                                }

                                .gyro-btn {
                                    font-family: 'Orbitron', monospace;
                                    font-size: 12px;
                                    font-weight: 700;
                                    border: none;
                                    border-radius: 8px;
                                    padding: 12px 20px;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                    letter-spacing: 1px;
                                }

                                .gbtn-start {
                                    background: var(--verde);
                                    color: white;
                                    box-shadow: 0 0 16px var(--verde-glow);
                                }

                                .gbtn-stop {
                                    background: transparent;
                                    border: 1px solid var(--danger);
                                    color: var(--danger);
                                }

                                .gbtn-stop:hover {
                                    background: rgba(255, 34, 68, 0.15);
                                }

                                .gyro-info {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    color: var(--dim);
                                    text-align: center;
                                    max-width: 280px;
                                    line-height: 1.7;
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 8px;
                                    padding: 12px;
                                }

                                /* ===== FOTOS ===== */
                                .foto-layout {
                                    flex: 1;
                                    display: grid;
                                    grid-template-rows: auto 1fr;
                                    overflow: hidden;
                                    padding: 12px;
                                    gap: 10px;
                                }

                                .foto-toolbar {
                                    display: flex;
                                    gap: 10px;
                                    align-items: center;
                                    flex-wrap: wrap;
                                }

                                .btn-capturar {
                                    font-family: 'Orbitron', monospace;
                                    font-size: 12px;
                                    font-weight: 900;
                                    background: var(--acento);
                                    color: var(--negro);
                                    border: none;
                                    border-radius: 8px;
                                    padding: 12px 22px;
                                    cursor: pointer;
                                    letter-spacing: 2px;
                                    box-shadow: 0 0 20px var(--acento-glow);
                                    transition: all 0.2s;
                                }

                                .btn-capturar:hover {
                                    transform: translateY(-1px);
                                    box-shadow: 0 0 35px var(--acento-glow);
                                }

                                .btn-capturar:active {
                                    transform: scale(0.95);
                                }

                                .btn-limpiar {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    background: transparent;
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 8px;
                                    color: var(--dim);
                                    padding: 12px 14px;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                }

                                .btn-limpiar:hover {
                                    border-color: var(--danger);
                                    color: var(--danger);
                                }

                                .foto-count {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 12px;
                                    color: var(--dim);
                                }

                                .foto-grid {
                                    display: grid;
                                    grid-template-columns: repeat(auto-fill, minmax(155px, 1fr));
                                    gap: 10px;
                                    overflow-y: auto;
                                    align-content: start;
                                    padding-right: 4px;
                                }

                                .foto-grid::-webkit-scrollbar {
                                    width: 3px;
                                }

                                .foto-grid::-webkit-scrollbar-thumb {
                                    background: var(--gris-borde);
                                }

                                .foto-item {
                                    background: var(--gris-card);
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 10px;
                                    overflow: hidden;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                }

                                .foto-item:hover {
                                    border-color: var(--acento);
                                    transform: scale(1.02);
                                }

                                .foto-item img {
                                    width: 100%;
                                    height: 105px;
                                    object-fit: cover;
                                    display: block;
                                }

                                .foto-meta {
                                    padding: 5px 8px;
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    color: var(--dim);
                                    display: flex;
                                    justify-content: space-between;
                                }

                                .foto-empty {
                                    grid-column: 1/-1;
                                    text-align: center;
                                    padding: 40px;
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 12px;
                                    color: var(--dim);
                                }

                                .foto-modal {
                                    display: none;
                                    position: fixed;
                                    inset: 0;
                                    background: rgba(0, 0, 0, 0.92);
                                    z-index: 1000;
                                    align-items: center;
                                    justify-content: center;
                                    flex-direction: column;
                                    gap: 14px;
                                }

                                .foto-modal.open {
                                    display: flex;
                                }

                                .foto-modal img {
                                    max-width: 90vw;
                                    max-height: 80vh;
                                    border-radius: 8px;
                                    border: 1px solid var(--gris-borde);
                                }

                                .foto-modal-close {
                                    position: absolute;
                                    top: 18px;
                                    right: 22px;
                                    font-size: 26px;
                                    color: var(--texto);
                                    cursor: pointer;
                                    background: none;
                                    border: none;
                                }

                                .foto-modal-info {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 12px;
                                    color: var(--dim);
                                }

                                .btn-descargar {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 11px;
                                    background: var(--verde);
                                    color: white;
                                    border: none;
                                    border-radius: 6px;
                                    padding: 8px 20px;
                                    cursor: pointer;
                                }

                                /* ===== AUTÓNOMO ===== */
                                .auto-layout {
                                    flex: 1;
                                    display: flex;
                                    flex-direction: column;
                                    align-items: center;
                                    justify-content: flex-start;
                                    padding: 20px;
                                    gap: 18px;
                                    overflow-y: auto;
                                }

                                .auto-title {
                                    font-family: 'Orbitron', monospace;
                                    font-size: 13px;
                                    color: var(--acento);
                                    letter-spacing: 3px;
                                    text-transform: uppercase;
                                }

                                .modos-grid {
                                    display: grid;
                                    grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
                                    gap: 10px;
                                    width: 100%;
                                    max-width: 580px;
                                }

                                .modo-card {
                                    background: var(--gris-card);
                                    border: 2px solid var(--gris-borde);
                                    border-radius: 12px;
                                    padding: 14px 10px;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                    text-align: center;
                                    display: flex;
                                    flex-direction: column;
                                    gap: 6px;
                                    align-items: center;
                                }

                                .modo-card:hover {
                                    border-color: var(--verde);
                                    transform: translateY(-2px);
                                    box-shadow: 0 6px 20px rgba(57, 169, 0, 0.2);
                                }

                                .modo-card.selected {
                                    border-color: var(--verde);
                                    background: rgba(57, 169, 0, 0.1);
                                    box-shadow: 0 0 18px var(--verde-glow);
                                }

                                .modo-icon {
                                    font-size: 28px;
                                }

                                .modo-nombre {
                                    font-family: 'Orbitron', monospace;
                                    font-size: 11px;
                                    color: var(--verde);
                                }

                                .modo-desc {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    color: var(--dim);
                                    line-height: 1.4;
                                }

                                .auto-status-card {
                                    background: var(--gris-card);
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 12px;
                                    padding: 14px 18px;
                                    width: 100%;
                                    max-width: 480px;
                                }

                                .auto-status-lbl {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    color: var(--dim);
                                    letter-spacing: 2px;
                                    margin-bottom: 8px;
                                }

                                .auto-status-txt {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 13px;
                                    color: var(--texto);
                                    margin-bottom: 10px;
                                }

                                .prog-wrap {
                                    background: var(--gris-borde);
                                    border-radius: 4px;
                                    height: 5px;
                                    overflow: hidden;
                                }

                                .prog-bar {
                                    height: 100%;
                                    background: var(--verde);
                                    box-shadow: 0 0 8px var(--verde-glow);
                                    width: 0%;
                                    transition: width 0.5s;
                                }

                                .auto-btn-group {
                                    display: flex;
                                    gap: 10px;
                                    justify-content: center;
                                }

                                .btn-iniciar {
                                    font-family: 'Orbitron', monospace;
                                    font-size: 13px;
                                    font-weight: 900;
                                    background: var(--verde);
                                    color: white;
                                    border: none;
                                    border-radius: 8px;
                                    padding: 13px 26px;
                                    cursor: pointer;
                                    box-shadow: 0 0 20px var(--verde-glow);
                                    transition: all 0.2s;
                                    letter-spacing: 2px;
                                }

                                .btn-iniciar:hover {
                                    transform: translateY(-1px);
                                    box-shadow: 0 0 32px var(--verde-glow);
                                }

                                .btn-iniciar:disabled {
                                    opacity: 0.4;
                                    cursor: not-allowed;
                                    transform: none;
                                }

                                .btn-detener {
                                    font-family: 'Orbitron', monospace;
                                    font-size: 13px;
                                    font-weight: 900;
                                    background: transparent;
                                    border: 2px solid var(--danger);
                                    color: var(--danger);
                                    border-radius: 8px;
                                    padding: 13px 26px;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                    letter-spacing: 2px;
                                }

                                .btn-detener:hover {
                                    background: rgba(255, 34, 68, 0.15);
                                }

                                /* ===== RIGHT PANEL ===== */
                                .right-panel {
                                    display: flex;
                                    flex-direction: column;
                                    overflow: hidden;
                                    background: var(--gris-panel);
                                    border-left: 1px solid var(--gris-borde);
                                }

                                .panel-header {
                                    padding: 11px 14px;
                                    border-bottom: 1px solid var(--gris-borde);
                                    font-family: 'Orbitron', monospace;
                                    font-size: 10px;
                                    color: var(--acento);
                                    letter-spacing: 2px;
                                    display: flex;
                                    justify-content: space-between;
                                    align-items: center;
                                }

                                .log-container {
                                    flex: 1;
                                    overflow-y: auto;
                                    padding: 8px;
                                    display: flex;
                                    flex-direction: column;
                                    gap: 4px;
                                }

                                .log-container::-webkit-scrollbar {
                                    width: 3px;
                                }

                                .log-container::-webkit-scrollbar-thumb {
                                    background: var(--gris-borde);
                                }

                                .log-entry {
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    padding: 6px 8px;
                                    border-radius: 5px;
                                    background: var(--gris-card);
                                    border-left: 3px solid var(--gris-borde);
                                    line-height: 1.5;
                                }

                                .log-entry.ok {
                                    border-left-color: var(--verde);
                                }

                                .log-entry.err {
                                    border-left-color: var(--danger);
                                }

                                .log-time {
                                    color: var(--dim);
                                    font-size: 9px;
                                }

                                .log-dur {
                                    color: var(--dim);
                                    font-size: 9px;
                                }

                                /* ===== TOAST ===== */
                                .toast-wrap {
                                    position: fixed;
                                    top: 60px;
                                    left: 50%;
                                    transform: translateX(-50%);
                                    z-index: 999;
                                    pointer-events: none;
                                }

                                .toast {
                                    background: var(--gris-panel);
                                    border: 1px solid var(--gris-borde);
                                    border-radius: 10px;
                                    padding: 9px 18px;
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 12px;
                                    display: flex;
                                    align-items: center;
                                    gap: 10px;
                                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
                                    opacity: 0;
                                    transition: opacity 0.3s;
                                    white-space: nowrap;
                                }

                                .toast.show {
                                    opacity: 1;
                                }

                                /* ===== FOOTER ===== */
                                .footer {
                                    height: 38px;
                                    background: var(--gris-panel);
                                    border-top: 1px solid var(--gris-borde);
                                    display: flex;
                                    align-items: center;
                                    justify-content: space-between;
                                    padding: 0 16px;
                                    font-family: 'Share Tech Mono', monospace;
                                    font-size: 10px;
                                    color: var(--dim);
                                    letter-spacing: 1px;
                                    grid-column: 1/-1;
                                }

                                .footer .v {
                                    color: var(--verde);
                                }

                                @media(max-width:768px) {
                                    body {
                                        height: auto;
                                        overflow: auto;
                                    }

                                    .panels {
                                        grid-template-columns: 1fr;
                                    }

                                    .right-panel {
                                        height: 220px;
                                    }

                                    .joystick-layout {
                                        grid-template-columns: 1fr;
                                    }
                                }
                            </style>
                        </head>

                        <body>

                            <!-- TOPBAR -->
                            <header class="topbar">
                                <div>
                                    <div class="brand">🤖 ROBOT CTRL</div>
                                    <div class="brand-sub">ESP32 AD175 · SENA CIMM ADSO</div>
                                </div>
                                <div class="topbar-tabs">
                                    <button class="tab-btn active" onclick="cambiarTab('dpad',this)">🕹 D-Pad</button>
                                    <button class="tab-btn" onclick="cambiarTab('joystick',this)">🕹 Joystick</button>
                                    <button class="tab-btn" onclick="cambiarTab('gyro',this)">📱 Giroscopio</button>
                                    <button class="tab-btn" onclick="cambiarTab('fotos',this)">📷 Fotos</button>
                                    <button class="tab-btn" onclick="cambiarTab('auto',this)">🤖 Autónomo</button>
                                </div>
                                <div class="status-row">
                                    <div class="dot <%= robotConfig.isConnected() ? " online" : "" %>" id="statusDot">
                                    </div>
                                    <span class="status-txt" id="statusTxt">
                                        <%= robotConfig.isConnected() ? "ONLINE · " + robotConfig.getRobotIp()
                                            : "OFFLINE" %>
                                    </span>
                                    <a href="<%= contextPath %>/grabar.jsp" class="rec-btn">⏺ REC</a>
                                    <a href="<%= contextPath %>/config" class="config-btn">⚙</a>
                                </div>
                            </header>

                            <div class="panels">
                                <div style="display:flex;flex-direction:column;overflow:hidden;">

                                    <!-- ========== TAB D-PAD ========== -->
                                    <div class="tab-panel active" id="tab-dpad">
                                        <div class="camera-wrap" id="cameraWrap">
                                            <div class="cam-corner tl"></div>
                                            <div class="cam-corner tr"></div>
                                            <div class="cam-corner bl"></div>
                                            <div class="cam-corner br"></div>
                                            <div class="cam-badge">
                                                <div class="rec-dot"></div>LIVE FPV
                                            </div>
                                            <div class="capture-flash" id="captureFlash"></div>
                                            <img class="camera-feed" id="cameraFeed"
                                                src="<%= contextPath %>/camera-proxy" alt="Camera ESP32"
                                                onerror="camaraError()" onload="camaraOk()">
                                            <div class="cam-offline" id="camOffline" style="display:none">
                                                <div style="font-size:42px">📷</div>
                                                <div>Cámara no disponible</div>
                                                <button class="btn-extra" onclick="reloadCam()"
                                                    style="margin-top:8px">🔄 Reintentar</button>
                                            </div>
                                        </div>
                                        <div class="controls-bar">
                                            <div class="extras-col">
                                                <button class="btn-extra" onclick="enviarCmd('ledon')">💡 LED
                                                    ON</button>
                                                <button class="btn-extra" onclick="enviarCmd('ledoff')">🌑 LED
                                                    OFF</button>
                                                <button class="btn-extra" onclick="reloadCam()">📷 Cam</button>
                                            </div>
                                            <div style="display:flex;flex-direction:column;align-items:center;gap:8px;">
                                                <div class="dpad">
                                                    <button class="btn-d d-up" id="bUp" onmousedown="startMove('go')"
                                                        onmouseup="stopMove()" onmouseleave="stopMove()"
                                                        ontouchstart="startMove('go')"
                                                        ontouchend="stopMove()">↑<span>W/↑</span></button>
                                                    <button class="btn-d d-left" id="bLeft"
                                                        onmousedown="startMove('left')" onmouseup="stopMove()"
                                                        onmouseleave="stopMove()" ontouchstart="startMove('left')"
                                                        ontouchend="stopMove()">←<span>A/←</span></button>
                                                    <button class="btn-d d-stop"
                                                        onclick="enviarCmd('stop')">⏹<span>STOP</span></button>
                                                    <button class="btn-d d-right" id="bRight"
                                                        onmousedown="startMove('right')" onmouseup="stopMove()"
                                                        onmouseleave="stopMove()" ontouchstart="startMove('right')"
                                                        ontouchend="stopMove()">→<span>D/→</span></button>
                                                    <button class="btn-d d-down" id="bDown"
                                                        onmousedown="startMove('back')" onmouseup="stopMove()"
                                                        onmouseleave="stopMove()" ontouchstart="startMove('back')"
                                                        ontouchend="stopMove()">↓<span>S/↓</span></button>
                                                </div>
                                                <div
                                                    style="font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--dim);letter-spacing:1px;">
                                                    WASD / flechas · mantén presionado
                                                </div>
                                            </div>
                                            <div class="speed-col">
                                                <div class="speed-lbl">Velocidad</div>
                                                <input type="range" min="50" max="255"
                                                    value="<%= robotConfig.getVelocidad() %>" id="speedSlider"
                                                    oninput="updateSpeed(this.value)">
                                                <div class="speed-num" id="speedNum">
                                                    <%= robotConfig.getVelocidad() %>
                                                </div>
                                                <div class="speed-presets">
                                                    <button class="sp-btn" onclick="setSpeed(85)"
                                                        title="Lenta">🐢</button>
                                                    <button class="sp-btn" onclick="setSpeed(150)"
                                                        title="Media">🚗</button>
                                                    <button class="sp-btn" onclick="setSpeed(220)"
                                                        title="Máxima">🚀</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ========== TAB JOYSTICK ========== -->
                                    <div class="tab-panel" id="tab-joystick">
                                        <div class="joystick-layout">
                                            <div class="joystick-area">
                                                <div
                                                    style="font-family:'Orbitron',monospace;font-size:12px;color:var(--acento);letter-spacing:2px;">
                                                    JOYSTICK VIRTUAL</div>
                                                <div class="joystick-container" id="joystickZone">
                                                    <div class="jz-labels">
                                                        <span class="jz-u">↑</span><span class="jz-d">↓</span>
                                                        <span class="jz-l">←</span><span class="jz-r">→</span>
                                                    </div>
                                                    <div class="joystick-knob" id="joystickKnob">🕹</div>
                                                </div>
                                                <div class="joy-data">
                                                    X: <strong id="joyX">0</strong> &nbsp; Y: <strong
                                                        id="joyY">0</strong><br>
                                                    Comando: <strong id="joyCmd">—</strong>
                                                </div>
                                            </div>

                                            <div class="camera-wrap"
                                                style="margin:12px 0;border-radius:12px;flex:1;min-height:180px;">
                                                <div class="cam-corner tl"></div>
                                                <div class="cam-corner tr"></div>
                                                <div class="cam-corner bl"></div>
                                                <div class="cam-corner br"></div>
                                                <div class="cam-badge">
                                                    <div class="rec-dot"></div>FPV
                                                </div>
                                                <img style="width:100%;height:100%;object-fit:contain;"
                                                    src="<%= contextPath %>/camera-proxy" alt="cam"
                                                    onerror="this.style.display='none'">
                                            </div>

                                            <div class="joystick-area">
                                                <div style="font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--dim);
                            text-align:center;line-height:1.9;border:1px solid var(--gris-borde);
                            border-radius:10px;padding:16px;max-width:180px;">
                                                    <div style="color:var(--acento);margin-bottom:8px;">CÓMO USAR</div>
                                                    Arrastra el joystick<br>en cualquier dirección.<br><br>
                                                    El robot se mueve<br>mientras lo sostienes.<br><br>
                                                    Al soltar, se detiene<br>automáticamente.
                                                </div>
                                                <div class="speed-col" style="min-width:140px;">
                                                    <div class="speed-lbl">Velocidad</div>
                                                    <input type="range" min="50" max="255"
                                                        value="<%= robotConfig.getVelocidad() %>" id="speedSlider2"
                                                        oninput="updateSpeed(this.value)">
                                                    <div class="speed-num" id="speedNum2">
                                                        <%= robotConfig.getVelocidad() %>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ========== TAB GIROSCOPIO ========== -->
                                    <div class="tab-panel" id="tab-gyro">
                                        <div class="gyro-layout">
                                            <div class="auto-title">Control por Giroscopio</div>
                                            <div class="gyro-circle">
                                                <div class="gyro-horizon" id="gyroHorizon"></div>
                                                <div class="gyro-center-dot"></div>
                                                <div class="gyro-arrow" id="gyroArrow">↑</div>
                                            </div>
                                            <div class="gyro-data">
                                                Inclinación X (giro): <strong id="gyroX">0°</strong><br>
                                                Inclinación Y (avance): <strong id="gyroY">0°</strong><br>
                                                Comando: <strong id="gyroCmdTxt">—</strong>
                                            </div>
                                            <div class="gyro-btn-group">
                                                <button class="gyro-btn gbtn-start" id="btnGyroStart"
                                                    onclick="iniciarGiro()">📱 Activar Giroscopio</button>
                                                <button class="gyro-btn gbtn-stop" id="btnGyroStop"
                                                    onclick="detenerGiro()" style="display:none">⏹ Detener</button>
                                            </div>
                                            <div class="gyro-info">
                                                <strong style="color:var(--acento);">📱 Modo FPV
                                                    Inmersivo</strong><br><br>
                                                Inclina tu dispositivo para mover el robot:<br><br>
                                                ↑ Adelante → avanza &nbsp; ↓ Atrás → retrocede<br>
                                                ← Izquierda → gira &nbsp; → Derecha → gira<br><br>
                                                <em style="color:var(--dim);">Requiere Chrome en Android o Safari iOS
                                                    13+</em>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ========== TAB FOTOS ========== -->
                                    <div class="tab-panel" id="tab-fotos">
                                        <div class="foto-layout">
                                            <div class="foto-toolbar">
                                                <button class="btn-capturar" onclick="capturarFoto()">📸 Capturar
                                                    Foto</button>
                                                <button class="btn-limpiar" onclick="limpiarFotos()">🗑 Limpiar</button>
                                                <span class="foto-count" id="fotoCount">0 fotos</span>
                                            </div>
                                            <div class="foto-grid" id="fotoGrid">
                                                <div class="foto-empty">📷 Aún no hay fotos.<br>Presiona
                                                    <strong>Capturar Foto</strong>.
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ========== TAB AUTÓNOMO ========== -->
                                    <div class="tab-panel" id="tab-auto">
                                        <div class="auto-layout">
                                            <div class="auto-title">🤖 Modo Autónomo</div>
                                            <div class="modos-grid">
                                                <div class="modo-card selected" data-modo="cuadrado"
                                                    onclick="seleccionarModoAuto('cuadrado', this)">
                                                    <div class="modo-icon">⬜</div>
                                                    <div class="modo-nombre">Cuadrado</div>
                                                    <div class="modo-desc">4 lados iguales con giros de 90°</div>
                                                </div>
                                                <div class="modo-card" data-modo="zigzag"
                                                    onclick="seleccionarModoAuto('zigzag', this)">
                                                    <div class="modo-icon">⚡</div>
                                                    <div class="modo-nombre">Zigzag</div>
                                                    <div class="modo-desc">Avanza alternando giros iz/der</div>
                                                </div>
                                                <div class="modo-card" data-modo="ronda"
                                                    onclick="seleccionarModoAuto('ronda', this)">
                                                    <div class="modo-icon">🔄</div>
                                                    <div class="modo-nombre">Ronda</div>
                                                    <div class="modo-desc">Gira 360° (barrido de cámara)</div>
                                                </div>
                                                <div class="modo-card" data-modo="patrulla"
                                                    onclick="seleccionarModoAuto('patrulla', this)">
                                                    <div class="modo-icon">↕</div>
                                                    <div class="modo-nombre">Patrulla</div>
                                                    <div class="modo-desc">Avanza y retrocede en línea</div>
                                                </div>
                                                <div class="modo-card" data-modo="exploracion"
                                                    onclick="seleccionarModoAuto('exploracion', this)">
                                                    <div class="modo-icon">🗺</div>
                                                    <div class="modo-nombre">Exploración</div>
                                                    <div class="modo-desc">Secuencia variada de movimientos</div>
                                                </div>
                                            </div>
                                            <div class="auto-status-card">
                                                <div class="auto-status-lbl">▶ ESTADO DE EJECUCIÓN</div>
                                                <div class="auto-status-txt" id="autoStatusTxt">Listo para iniciar</div>
                                                <div class="prog-wrap">
                                                    <div class="prog-bar" id="autoProgress"></div>
                                                </div>
                                            </div>
                                            <div class="auto-btn-group">
                                                <button class="btn-iniciar" id="btnIniciarAuto"
                                                    onclick="iniciarModoAuto()">▶ INICIAR</button>
                                                <button class="btn-detener" id="btnDetenerAuto"
                                                    onclick="detenerAutonomo()" style="display:none">⏹ DETENER</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- RIGHT: LOG -->
                                <div class="right-panel">
                                    <div class="panel-header">
                                        <span>📋 LOG</span>
                                        <button class="config-btn" onclick="clearLog()">✕ Limpiar</button>
                                    </div>
                                    <div class="log-container" id="logContainer">
                                        <% if (historial !=null && !historial.isEmpty()) { for (ComandoRobot cmd :
                                            historial) { %>
                                            <div class="log-entry <%= cmd.isExitoso() ? " ok" : "err" %>">
                                                <div class="log-time">
                                                    <%= cmd.getTimestamp() %>
                                                </div>
                                                <div class="log-txt" data-color="<%= cmd.getTipo().getColor() %>">
                                                    <%= cmd.getTipo().getIcono() %>
                                                        <%= cmd.getTipo().getDescripcion() %>
                                                </div>
                                                <div class="log-dur">
                                                    <%= cmd.getDuracionMs() %>ms · <%= cmd.getEndpoint() %>
                                                </div>
                                            </div>
                                            <% } } else { %>
                                                <div
                                                    style="text-align:center;color:var(--dim);font-family:'Share Tech Mono',monospace;font-size:11px;padding:20px;opacity:0.5;">
                                                    Sin comandos aún</div>
                                                <% } %>
                                    </div>
                                </div>
                            </div>

                            <!-- TOAST -->
                            <div class="toast-wrap">
                                <div class="toast" id="toast">
                                    <span id="toastIcon">✓</span><span id="toastMsg">OK</span>
                                </div>
                            </div>

                            <!-- MODAL FOTO -->
                            <div class="foto-modal" id="fotoModal">
                                <button class="foto-modal-close" onclick="closeFotoModal()">✕</button>
                                <img id="fotoModalImg" src="" alt="Foto">
                                <div class="foto-modal-info" id="fotoModalInfo"></div>
                                <div style="display:flex;gap:10px;">
                                    <button class="btn-descargar" id="btnDescargar">⬇ Descargar</button>
                                    <button class="btn-limpiar" id="btnEliminarIndividual" style="border-color:var(--danger);color:var(--danger);">🗑 Eliminar</button>
                                </div>
                            </div>

                            <!-- FOOTER -->
                            <footer class="footer">
                                <span>SENA CIMM · <span class="v">ADSO</span></span>
                                <span>IP: <span class="v">
                                        <%= robotConfig.getRobotIp() %>:<%= robotConfig.getControlPort() %>
                                    </span></span>
                                <span>Stream: <span class="v">
                                        <%= robotConfig.getStreamUrl() %>
                                    </span></span>
                            </footer>

                            <script>
                                const CTX = '<%= contextPath %>';

                                function toast(icon, msg, color = '#39A900') {
                                    const t = document.getElementById('toast');
                                    if (!t) return;
                                    document.getElementById('toastIcon').textContent = icon;
                                    document.getElementById('toastMsg').textContent = msg;
                                    t.style.borderColor = color;
                                    t.classList.add('show');
                                    setTimeout(() => t.classList.remove('show'), 2000);
                                }

                                function addLog(data, cmd) {
                                    const c = document.getElementById('logContainer');
                                    if (!c) return;
                                    const e = document.createElement('div');
                                    e.className = 'log-entry ' + (data.exito ? 'ok' : 'err');
                                    const ts = data.timestamp || new Date().toLocaleTimeString();
                                    e.innerHTML = `<div class="log-time">${ts}</div><div style="color:${data.color || '#fff'}">${data.icono || '▶'} ${data.mensaje || cmd}</div>`;
                                    c.insertBefore(e, c.firstChild);
                                    if (c.children.length > 20) c.removeChild(c.lastChild);
                                }

                                function enviarCmd(cmd, showToast = true) {
                                    const fd = new FormData(); fd.append('cmd', cmd);
                                    return fetch(CTX + '/control', { method: 'POST', body: fd })
                                        .then(r => r.json())
                                        .then(d => {
                                            if (showToast) toast(d.exito ? '✓' : '✕', d.mensaje, d.color);
                                            addLog(d, cmd); return d;
                                        }).catch(() => { if (showToast) toast('✕', 'Error de red', '#f00'); });
                                }

                                /* CÁMARA (Para evitar los ReferenceError) */
                                function camaraOk() {
                                    if (document.getElementById('camOffline')) document.getElementById('camOffline').style.display = 'none';
                                    if (document.getElementById('cameraFeed')) document.getElementById('cameraFeed').style.display = 'block';
                                }
                                function camaraError() {
                                    if (document.getElementById('camOffline')) document.getElementById('camOffline').style.display = 'flex';
                                    if (document.getElementById('cameraFeed')) document.getElementById('cameraFeed').style.display = 'none';
                                }
                                function reloadCam() {
                                    const f = document.getElementById('cameraFeed');
                                    if (f) f.src = CTX + '/camera-proxy?t=' + Date.now();
                                }

                                /* MANUAL */
                                let _mAct = null, _mInt = null;
                                function startMove(c) { if (_mAct === c) return; _mAct = c; enviarCmd(c); _mInt = setInterval(() => enviarCmd(c, false), 300); }
                                function stopMove() { if (!_mAct) return; clearInterval(_mInt); _mAct = null; enviarCmd('stop'); }

                                document.addEventListener('keydown', e => {
                                    const m = { ArrowUp: 'go', KeyW: 'go', ArrowDown: 'back', KeyS: 'back', ArrowLeft: 'left', KeyA: 'left', ArrowRight: 'right', KeyD: 'right' };
                                    if (m[e.code]) { e.preventDefault(); startMove(m[e.code]); }
                                });
                                document.addEventListener('keyup', e => { stopMove(); });

                                /* AUTO */
                                let _aRun = false, _aT = null;
                                function selectModo(el) {
                                    document.querySelectorAll('.modo-card').forEach(c => c.classList.remove('selected'));
                                    el.classList.add('selected');
                                    document.getElementById('autoStatusTxt').textContent = 'Modo: ' + el.dataset.modo.toUpperCase();
                                }

                                async function iniciarModoAuto() {
                                    const s = document.querySelector('.modo-card.selected');
                                    if (!s || _aRun) return; _aRun = true;
                                    document.getElementById('btnIniciarAuto').style.display = 'none';
                                    document.getElementById('btnDetenerAuto').style.display = 'inline-flex';

                                    const m = s.dataset.modo;
                                    const seq = {
                                        'cuadrado': [{ c: 'go', d: 1200, t: 'L1' }, { c: 'right', d: 600, t: 'G1' }, { c: 'go', d: 1200, t: 'L2' }, { c: 'right', d: 600, t: 'G2' }, { c: 'go', d: 1200, t: 'L3' }, { c: 'right', d: 600, t: 'G3' }, { c: 'go', d: 1200, t: 'L4' }, { c: 'stop', d: 100, t: 'Fin' }],
                                        'ronda': [{ c: 'right', d: 3000, t: 'Giro 360' }],
                                        'patrulla': [{ c: 'go', d: 1500, t: 'Ida' }, { c: 'back', d: 1500, t: 'Vuelta' }],
                                        'zigzag': [{ c: 'go', d: 700, t: 'F' }, { c: 'left', d: 400, t: 'Z' }, { c: 'go', d: 700, t: 'F' }, { c: 'right', d: 400, t: 'Z' }, { c: 'go', d: 700, t: 'F' }, { c: 'left', d: 400, t: 'Z' }],
                                        'exploracion': [{ c: 'go', d: 1000, t: 'Busca' }, { c: 'right', d: 500, t: 'Mira' }, { c: 'go', d: 1500, t: 'Corre' }, { c: 'back', d: 500, t: 'Ups' }, { c: 'left', d: 800, t: 'Gira' }]
                                    };
                                    const p = seq[m] || [];
                                    for (let i = 0; i < p.length && _aRun; i++) {
                                        document.getElementById('autoStatusTxt').textContent = 'Ejecutando: ' + p[i].t + ' (' + (i + 1) + '/' + p.length + ')';
                                        await enviarCmd(p[i].c, false);
                                        await new Promise(r => _aT = setTimeout(r, p[i].d));
                                    }
                                    detenerAutonomo();
                                }
                                function detenerAutonomo() { _aRun = false; clearTimeout(_aT); enviarCmd('stop'); document.getElementById('btnIniciarAuto').style.display = 'inline-flex'; document.getElementById('btnDetenerAuto').style.display = 'none'; document.getElementById('autoStatusTxt').textContent = 'Listo'; }

                                function cambiarTab(t, b) { document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active')); document.getElementById('tab-' + t).classList.add('active'); if (b) { document.querySelectorAll('.tab-btn').forEach(x => x.classList.remove('active')); b.classList.add('active'); } }
                                function updateSpeed(v) { document.getElementById('speedNum2').textContent = v; enviarCmd('speed-' + v, false); }

                                /* FOTOS */
                                function capturarFoto() {
                                    toast('📸', 'Capturando...', '#00ffe5');
                                    fetch(CTX + '/foto').then(r => r.json()).then(d => {
                                        if (d.exito) { toast('✅', 'Foto guardada', '#39A900'); cargarFotos(); }
                                        else toast('✕', d.mensaje, '#f00');
                                    }).catch(() => toast('✕', 'Error de cámara', '#f00'));
                                }
                                function cargarFotos() {
                                    fetch(CTX + '/foto?accion=lista').then(r => r.json()).then(d => {
                                        const grid = document.getElementById('fotoGrid');
                                        const count = document.getElementById('fotoCount');
                                        if (!grid) return;
                                        count.textContent = (d.total || 0) + ' fotos';
                                        if (!d.total) { grid.innerHTML = '<div class="foto-empty">📷 No hay fotos</div>'; return; }
                                        grid.innerHTML = (d.fotos || []).map(f => `
            <div class="foto-item" onclick="verFoto(${f.idx})">
                <img src="${CTX}/foto?accion=ver&idx=${f.idx}" alt="Foto">
                <div class="foto-meta"><span>${f.timestamp}</span><span>${f.tamañoKb}KB</span></div>
            </div>`).join('');
                                    });
                                }
                                function verFoto(idx) {
                                    const url = CTX + '/foto?accion=ver&idx=' + idx;
                                    document.getElementById('fotoModalImg').src = url;
                                    document.getElementById('btnDescargar').onclick = () => { const a = document.createElement('a'); a.href = url; a.download = 'foto.jpg'; a.click(); };
                                    document.getElementById('btnEliminarIndividual').onclick = () => { eliminarFoto(idx); };
                                    document.getElementById('fotoModal').classList.add('open');
                                }
                                function eliminarFoto(idx) {
                                    if (!confirm('¿Deseas eliminar esta foto?')) return;
                                    fetch(CTX + '/foto?accion=eliminar&idx=' + idx)
                                        .then(r => r.json())
                                        .then(d => {
                                            if (d.exito) {
                                                toast('🗑', 'Foto eliminada', '#ff2244');
                                                closeFotoModal();
                                                cargarFotos();
                                            } else {
                                                toast('✕', d.mensaje, '#f00');
                                            }
                                        }).catch(() => toast('✕', 'Error al eliminar', '#f00'));
                                }
                                function closeFotoModal() { document.getElementById('fotoModal').classList.remove('open'); }
                                function limpiarFotos() {
                                    if (!confirm('¿Borrar galería?')) return;
                                    fetch(CTX + '/foto?accion=limpiar').then(() => { cargarFotos(); toast('🗑', 'Limpio', '#ffcc00'); });
                                }
                                window.addEventListener('DOMContentLoaded', cargarFotos);

                                /* GIROSCOPIO */
                                let _gRun = false, _gInt = null, _gCmd = null;
                                function iniciarGiro() {
                                    if (typeof DeviceOrientationEvent !== 'undefined' && typeof DeviceOrientationEvent.requestPermission === 'function') {
                                        DeviceOrientationEvent.requestPermission().then(s => { if (s === 'granted') activarG(); }).catch(() => toast('✕', 'Error permiso', '#f00'));
                                    } else { activarG(); }
                                }
                                function activarG() {
                                    _gRun = true; document.getElementById('btnGyroStart').style.display = 'none'; document.getElementById('btnGyroStop').style.display = 'block';
                                    window.addEventListener('deviceorientation', manejarG);
                                    _gInt = setInterval(() => { if (_gCmd) enviarCmd(_gCmd, false); }, 300);
                                }
                                function detenerGiro() {
                                    _gRun = false; window.removeEventListener('deviceorientation', manejarG);
                                    clearInterval(_gInt); _gCmd = null; enviarCmd('stop');
                                    document.getElementById('btnGyroStart').style.display = 'block'; document.getElementById('btnGyroStop').style.display = 'none';
                                }
                                function manejarG(e) {
                                    const y = e.beta, x = e.gamma; // y: inclinación adelante/atrás, x: giros
                                    let c = null;
                                    if (y > 25) c = 'back'; else if (y < -5) c = 'go';
                                    else if (x > 20) c = 'right'; else if (x < -20) c = 'left';
                                    _gCmd = c;
                                    if (document.getElementById('gyroCmdTxt')) document.getElementById('gyroCmdTxt').textContent = c ? c.toUpperCase() : 'NEUTRO';
                                }

                                // Fix para los onclick del HTML
                                document.querySelectorAll('.modo-card').forEach(c => { c.onclick = function () { selectModo(this); }; });
                                document.getElementById('btnIniciarAuto').onclick = iniciarModoAuto;
                                document.getElementById('btnDetenerAuto').onclick = detenerAutonomo;
                                if (document.getElementById('btnGyroStart')) document.getElementById('btnGyroStart').onclick = iniciarGiro;
                                if (document.getElementById('btnGyroStop')) document.getElementById('btnGyroStop').onclick = detenerGiro;

                                setInterval(() => { fetch(CTX + '/status').then(r => r.json()).then(d => { document.getElementById('statusTxt').textContent = d.conectado ? 'ONLINE' : 'OFFLINE'; document.getElementById('statusDot').className = 'dot' + (d.conectado ? ' online' : ''); }).catch(() => { }); }, 5000);
                            </script>
                        </body>

                        </html>