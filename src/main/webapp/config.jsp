<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="co.sena.cimm.robot.model.RobotConfig" %>
        <% RobotConfig robotConfig=(RobotConfig) request.getAttribute("config"); if (robotConfig==null) robotConfig=new
            RobotConfig(); String mensaje=(String) request.getAttribute("mensaje"); String tipoMensaje=(String)
            request.getAttribute("tipoMensaje"); %>
            <!DOCTYPE html>
            <html lang="es">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Configuración – Robot ESP32 | SENA CIMM</title>
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link
                    href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Share+Tech+Mono&family=Inter:wght@300;400;600&display=swap"
                    rel="stylesheet">
                <style>
                    :root {
                        --verde-sena: #39A900;
                        --verde-sena-dark: #2d8400;
                        --verde-sena-glow: rgba(57, 169, 0, 0.4);
                        --negro: #0a0a0a;
                        --gris-oscuro: #111111;
                        --gris-panel: #1a1a1a;
                        --gris-borde: #2a2a2a;
                        --texto: #e8e8e8;
                        --texto-dim: #888888;
                        --acento: #00ffe5;
                        --acento-glow: rgba(0, 255, 229, 0.3);
                        --peligro: #ff2244;
                        --advertencia: #ff9900;
                        --exito: #39A900;
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
                        min-height: 100vh;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        padding: 20px;
                        background-image:
                            radial-gradient(ellipse at 20% 50%, rgba(57, 169, 0, 0.05) 0%, transparent 60%),
                            radial-gradient(ellipse at 80% 20%, rgba(0, 255, 229, 0.03) 0%, transparent 50%),
                            repeating-linear-gradient(0deg,
                                transparent,
                                transparent 40px,
                                rgba(57, 169, 0, 0.02) 40px,
                                rgba(57, 169, 0, 0.02) 41px),
                            repeating-linear-gradient(90deg,
                                transparent,
                                transparent 40px,
                                rgba(57, 169, 0, 0.02) 40px,
                                rgba(57, 169, 0, 0.02) 41px);
                    }

                    .header {
                        text-align: center;
                        margin-bottom: 40px;
                        width: 100%;
                        max-width: 700px;
                    }

                    .logo-sena {
                        display: inline-flex;
                        align-items: center;
                        gap: 12px;
                        background: var(--gris-panel);
                        border: 1px solid var(--verde-sena);
                        border-radius: 8px;
                        padding: 8px 20px;
                        margin-bottom: 24px;
                        box-shadow: 0 0 20px var(--verde-sena-glow);
                    }

                    .logo-sena span {
                        font-family: 'Orbitron', monospace;
                        font-weight: 700;
                        font-size: 13px;
                        color: var(--verde-sena);
                        letter-spacing: 3px;
                        text-transform: uppercase;
                    }

                    .robot-icon {
                        font-size: 28px;
                        animation: float 3s ease-in-out infinite;
                    }

                    @keyframes float {

                        0%,
                        100% {
                            transform: translateY(0);
                        }

                        50% {
                            transform: translateY(-6px);
                        }
                    }

                    h1 {
                        font-family: 'Orbitron', monospace;
                        font-size: clamp(24px, 5vw, 42px);
                        font-weight: 900;
                        color: var(--acento);
                        text-shadow: 0 0 30px var(--acento-glow), 0 0 60px rgba(0, 255, 229, 0.1);
                        letter-spacing: 2px;
                        line-height: 1.1;
                        margin-bottom: 8px;
                    }

                    .subtitle {
                        font-family: 'Share Tech Mono', monospace;
                        color: var(--texto-dim);
                        font-size: 13px;
                        letter-spacing: 2px;
                    }

                    .card {
                        background: var(--gris-panel);
                        border: 1px solid var(--gris-borde);
                        border-radius: 16px;
                        padding: 36px;
                        width: 100%;
                        max-width: 700px;
                        position: relative;
                        overflow: hidden;
                    }

                    .card::before {
                        content: '';
                        position: absolute;
                        top: 0;
                        left: 0;
                        right: 0;
                        height: 2px;
                        background: linear-gradient(90deg, transparent, var(--verde-sena), var(--acento), transparent);
                    }

                    .card-title {
                        font-family: 'Orbitron', monospace;
                        font-size: 14px;
                        color: var(--verde-sena);
                        letter-spacing: 3px;
                        text-transform: uppercase;
                        margin-bottom: 28px;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                    }

                    .card-title::after {
                        content: '';
                        flex: 1;
                        height: 1px;
                        background: var(--gris-borde);
                    }

                    .form-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 20px;
                        margin-bottom: 24px;
                    }

                    .form-group {
                        display: flex;
                        flex-direction: column;
                        gap: 8px;
                    }

                    .form-group.full-width {
                        grid-column: 1 / -1;
                    }

                    label {
                        font-family: 'Share Tech Mono', monospace;
                        font-size: 11px;
                        color: var(--acento);
                        letter-spacing: 2px;
                        text-transform: uppercase;
                    }

                    input[type="text"],
                    input[type="number"],
                    input[type="range"] {
                        background: var(--negro);
                        border: 1px solid var(--gris-borde);
                        border-radius: 8px;
                        color: var(--texto);
                        font-family: 'Share Tech Mono', monospace;
                        font-size: 15px;
                        padding: 12px 16px;
                        transition: border-color 0.2s, box-shadow 0.2s;
                        outline: none;
                        width: 100%;
                    }

                    input:focus {
                        border-color: var(--verde-sena);
                        box-shadow: 0 0 10px var(--verde-sena-glow);
                    }

                    .range-display {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        gap: 12px;
                    }

                    .range-display input[type="range"] {
                        flex: 1;
                        padding: 4px 0;
                        cursor: pointer;
                        accent-color: var(--verde-sena);
                    }

                    .range-value {
                        background: var(--negro);
                        border: 1px solid var(--verde-sena);
                        border-radius: 6px;
                        padding: 6px 12px;
                        font-family: 'Orbitron', monospace;
                        font-size: 16px;
                        color: var(--verde-sena);
                        min-width: 64px;
                        text-align: center;
                    }

                    .hint {
                        font-size: 11px;
                        color: var(--texto-dim);
                        margin-top: 4px;
                    }

                    .btn-group {
                        display: flex;
                        gap: 12px;
                        flex-wrap: wrap;
                    }

                    .btn {
                        font-family: 'Orbitron', monospace;
                        font-weight: 700;
                        font-size: 13px;
                        letter-spacing: 2px;
                        border: none;
                        border-radius: 8px;
                        padding: 14px 28px;
                        cursor: pointer;
                        transition: all 0.2s;
                        text-transform: uppercase;
                    }

                    .btn-primary {
                        background: var(--verde-sena);
                        color: white;
                        box-shadow: 0 0 20px var(--verde-sena-glow);
                        flex: 1;
                    }

                    .btn-primary:hover {
                        background: var(--verde-sena-dark);
                        box-shadow: 0 0 30px var(--verde-sena-glow);
                        transform: translateY(-1px);
                    }

                    .btn-secondary {
                        background: transparent;
                        color: var(--texto-dim);
                        border: 1px solid var(--gris-borde);
                    }

                    .btn-secondary:hover {
                        border-color: var(--texto-dim);
                        color: var(--texto);
                    }

                    .btn-ir-control {
                        background: linear-gradient(135deg, var(--acento), #0099aa);
                        color: var(--negro);
                        font-weight: 900;
                        text-decoration: none;
                        display: inline-flex;
                        align-items: center;
                        gap: 8px;
                        padding: 14px 28px;
                        border-radius: 8px;
                        font-family: 'Orbitron', monospace;
                        font-size: 13px;
                        letter-spacing: 2px;
                        text-transform: uppercase;
                        transition: all 0.2s;
                        box-shadow: 0 0 20px var(--acento-glow);
                    }

                    .btn-ir-control:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 0 40px var(--acento-glow);
                    }

                    .mensaje {
                        padding: 16px 20px;
                        border-radius: 10px;
                        margin-bottom: 24px;
                        font-family: 'Share Tech Mono', monospace;
                        font-size: 13px;
                        line-height: 1.5;
                        border: 1px solid;
                    }

                    .mensaje-exito {
                        background: rgba(57, 169, 0, 0.1);
                        border-color: var(--exito);
                        color: #77dd55;
                    }

                    .mensaje-advertencia {
                        background: rgba(255, 153, 0, 0.1);
                        border-color: var(--advertencia);
                        color: var(--advertencia);
                    }

                    .mensaje-error {
                        background: rgba(255, 34, 68, 0.1);
                        border-color: var(--peligro);
                        color: var(--peligro);
                    }

                    .mensaje-info {
                        background: rgba(0, 255, 229, 0.1);
                        border-color: var(--acento);
                        color: var(--acento);
                    }

                    .info-box {
                        margin-top: 28px;
                        background: rgba(0, 255, 229, 0.04);
                        border: 1px solid rgba(0, 255, 229, 0.15);
                        border-radius: 10px;
                        padding: 20px;
                    }

                    .info-box-title {
                        font-family: 'Share Tech Mono', monospace;
                        font-size: 11px;
                        color: var(--acento);
                        letter-spacing: 2px;
                        margin-bottom: 14px;
                        text-transform: uppercase;
                    }

                    .endpoints-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
                        gap: 8px;
                    }

                    .endpoint-item {
                        background: var(--negro);
                        border-radius: 6px;
                        padding: 8px 12px;
                        font-family: 'Share Tech Mono', monospace;
                        font-size: 12px;
                    }

                    .endpoint-item .method {
                        color: var(--verde-sena);
                        font-size: 10px;
                    }

                    .endpoint-item .path {
                        color: var(--acento);
                    }

                    .endpoint-item .desc {
                        color: var(--texto-dim);
                        font-size: 11px;
                    }

                    footer {
                        margin-top: 40px;
                        text-align: center;
                        font-family: 'Share Tech Mono', monospace;
                        font-size: 11px;
                        color: var(--texto-dim);
                        letter-spacing: 1px;
                    }

                    .footer-verde {
                        color: var(--verde-sena);
                    }

                    @media (max-width: 600px) {
                        .form-grid {
                            grid-template-columns: 1fr;
                        }

                        .form-group.full-width {
                            grid-column: 1;
                        }
                    }
                </style>
            </head>

            <body>

                <div class="header">
                    <div class="logo-sena">
                        <span>🌿 SENA</span>
                        <span style="color: var(--texto-dim)">|</span>
                        <span>CIMM</span>
                        <span style="color: var(--texto-dim)">|</span>
                        <span>ADSO</span>
                    </div>
                    <h1>ROBOT<br>CONTROLLER</h1>
                    <p class="subtitle">// ESP32 WiFi Camera 2WD — AD175 // KUONGSHUN</p>
                </div>

                <div class="card">
                    <div class="card-title">⚙ Configuración de Conexión</div>

                    <% if (mensaje !=null) { %>
                        <div class="mensaje mensaje-<%= tipoMensaje %>">
                            <%= mensaje %>
                                <% if ("exito".equals(tipoMensaje)) { %>
                                    <br><br>
                                    <a href="<%= request.getContextPath() %>/control" class="btn-ir-control">
                                        🎮 Ir al Panel de Control →
                                    </a>
                                    <% } %>
                        </div>
                        <% } %>

                            <form method="POST" action="<%= request.getContextPath() %>/config">

                                <div class="form-grid">
                                    <div class="form-group full-width">
                                        <label>Nombre del robot</label>
                                        <input type="text" name="nombre" value="<%= robotConfig.getNombre() %>"
                                            placeholder="Mi Robot ESP32">
                                    </div>

                                    <div class="form-group">
                                        <label>Dirección IP del Robot</label>
                                        <input type="text" name="robotIp" value="<%= robotConfig.getRobotIp() %>"
                                            placeholder="192.168.4.1" required>
                                        <p class="hint">
                                            📡 Conéctate al WiFi del robot primero.<br>
                                            En modo AP, la IP es generalmente <strong>192.168.4.1</strong>
                                        </p>
                                    </div>

                                    <div class="form-group">
                                        <label>Puerto de Control</label>
                                        <input type="number" name="controlPort"
                                            value="<%= robotConfig.getControlPort() %>" min="1" max="65535"
                                            placeholder="80">
                                        <p class="hint">Puerto HTTP del servidor de comandos (default: 80)</p>
                                    </div>

                                    <div class="form-group">
                                        <label>Puerto Stream Cámara</label>
                                        <input type="number" name="streamPort"
                                            value="<%= robotConfig.getStreamPort() %>" min="1" max="65535"
                                            placeholder="81">
                                        <p class="hint">Puerto del stream MJPEG (default: 81, algunos usan 80)</p>
                                    </div>

                                    <div class="form-group">
                                        <label>Velocidad inicial (PWM 0-255)</label>
                                        <div class="range-display">
                                            <input type="range" name="velocidadRange" id="velocidadRange" min="0"
                                                max="255" value="<%= robotConfig.getVelocidad() %>"
                                                oninput="syncVelocidad(this.value)">
                                            <span class="range-value" id="velDisplay">
                                                <%= robotConfig.getVelocidad() %>
                                            </span>
                                        </div>
                                        <input type="hidden" name="velocidad" id="velocidadHidden"
                                            value="<%= robotConfig.getVelocidad() %>">
                                        <p class="hint">0 = parado | 150 = medio | 255 = máxima velocidad</p>
                                    </div>
                                </div>

                                <div class="btn-group">
                                    <button type="submit" class="btn btn-primary">
                                        🔗 Conectar y Guardar
                                    </button>
                                    <button type="submit" name="accion" value="reset" class="btn btn-secondary">
                                        ↺ Restaurar Default
                                    </button>
                                    <% if (robotConfig.isConnected()) { %>
                                        <a href="<%= request.getContextPath() %>/control" class="btn-ir-control">
                                            🎮 Panel de Control
                                        </a>
                                        <% } %>
                                </div>
                            </form>

                            <div class="info-box">
                                <div class="info-box-title">📋 Endpoints HTTP del Robot ESP32 AD175</div>
                                <div class="endpoints-grid">
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/go</div>
                                        <div class="desc">Avanzar</div>
                                    </div>
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/back</div>
                                        <div class="desc">Retroceder</div>
                                    </div>
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/left</div>
                                        <div class="desc">Girar izquierda</div>
                                    </div>
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/right</div>
                                        <div class="desc">Girar derecha</div>
                                    </div>
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/stop</div>
                                        <div class="desc">Detener</div>
                                    </div>
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/stream</div>
                                        <div class="desc">Video MJPEG</div>
                                    </div>
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/ledon</div>
                                        <div class="desc">LED encendido</div>
                                    </div>
                                    <div class="endpoint-item">
                                        <div class="method">GET</div>
                                        <div class="path">/ledoff</div>
                                        <div class="desc">LED apagado</div>
                                    </div>
                                </div>
                            </div>
                </div>

                <footer>
                    <p>
                        <span class="footer-verde">■</span>
                        SENA – Centro Industrial de Mantenimiento y Manufactura (CIMM)
                        <span class="footer-verde">■</span>
                    </p>
                    <p style="margin-top:6px">
                        Tecnólogo ADSO · Regional Boyacá ·
                    </p>
                </footer>

                <script>
                    function syncVelocidad(val) {
                        document.getElementById('velDisplay').textContent = val;
                        document.getElementById('velocidadHidden').value = val;
                    }
                </script>

            </body>

            </html>