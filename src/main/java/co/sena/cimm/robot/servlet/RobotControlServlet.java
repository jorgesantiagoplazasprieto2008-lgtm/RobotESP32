package co.sena.cimm.robot.servlet;

import co.sena.cimm.robot.model.*;

import co.sena.cimm.robot.util.RobotHttpClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


@WebServlet("/control")
public class RobotControlServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String cmd = req.getParameter("cmd");
        if (cmd == null || cmd.trim().isEmpty()) {
            // ══════════════════════════════════════════════════════════
            // EL USUARIO NAVEGÓ A /control SIN PARÁMETROS
            // → Renderizamos la página de control (control.jsp)
            // ══════════════════════════════════════════════════════════
            HttpSession session = req.getSession();
            // Recuperamos el config desde la SESIÓN
            RobotConfig config = (RobotConfig) session.getAttribute("config");
            if (config == null) {
                // Si tampoco está en sesión, mandamos a configurar el robot
                res.sendRedirect(req.getContextPath() + "/config");
                return;
            }
            // ✅ CLAVE: Ponemos el config como atributo del REQUEST
            //    para que control.jsp pueda leerlo con request.getAttribute("config")
            req.setAttribute("config", config);
            // También ponemos el historial si existe en sesión
            Object historial = session.getAttribute("historial");
            if (historial != null) {
                req.setAttribute("historial", historial);
            }
            // Hacemos forward al JSP (no redirect, para que los atributos lleguen)
            req.getRequestDispatcher("/control.jsp").forward(req, res);
            return;
        }
        // Si hay cmd, procesamos el comando
        procesarComando(req, res, cmd.trim().toLowerCase());
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // El JSP original envía los comandos por POST con FormData
        // Ejemplo: fetch('/control', { method: 'POST', body: formData })
        String cmd = req.getParameter("cmd");
        if (cmd == null || cmd.trim().isEmpty()) {
            res.setContentType("application/json");
            res.getWriter().print("{\"exito\":false,\"mensaje\":\"Sin comando\"}");
            return;
        }
        procesarComando(req, res, cmd.trim().toLowerCase());
    }
    @SuppressWarnings("unchecked")
    private void procesarComando(HttpServletRequest req, HttpServletResponse res, String cmd)
            throws IOException {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();
        HttpSession session = req.getSession();
        RobotConfig config  = (RobotConfig) session.getAttribute("config");
        // Comandos especiales: velocidad (ej: "speed-150")
        if (cmd.startsWith("speed-")) {
            try {
                int velocidad = Integer.parseInt(cmd.substring(6));
                if (config != null) {
                    config.setVelocidad(velocidad);
                    session.setAttribute("config", config);
                }
                out.print("{\"exito\":true,\"mensaje\":\"Velocidad: " + velocidad + "\","
                        + "\"color\":\"#39A900\",\"icono\":\"⚡\"}");
            } catch (NumberFormatException e) {
                out.print("{\"exito\":false,\"mensaje\":\"Velocidad inválida\"}");
            }
            return;
        }
        // Validamos que sea un comando de movimiento reconocido
        if (!esComandoValido(cmd)) {
            out.print("{\"exito\":false,\"mensaje\":\"Comando no reconocido: " + cmd + "\","
                    + "\"color\":\"#ff2244\",\"icono\":\"✕\"}");
            return;
        }
        String ruta        = "/" + cmd;
        String descripcion = toDescripcion(cmd);
        String color       = toColor(cmd);
        String icono       = toIcono(cmd);
        // ══════════════════════════════════════════════════════════
        // LÓGICA DE GRABACIÓN
        // Si grabando=true en sesión, guardamos el paso
        // ══════════════════════════════════════════════════════════
        boolean estaGrabando = Boolean.TRUE.equals(session.getAttribute("grabando"));
        if (estaGrabando) {
            List<PasoGrabado> grabacion = (List<PasoGrabado>) session.getAttribute("grabacion");
            if (grabacion == null) {
                grabacion = new ArrayList<>();
                session.setAttribute("grabacion", grabacion);
            }
            LocalDateTime ahora      = LocalDateTime.now();
            LocalDateTime inicioPaso = (LocalDateTime) session.getAttribute("inicioPaso");
            // Cerramos la duración del paso anterior
            if (inicioPaso != null && !grabacion.isEmpty()) {
                long durMs = Duration.between(inicioPaso, ahora).toMillis();
                grabacion.get(grabacion.size() - 1).setDuracionMs(durMs);
            }
            grabacion.add(new PasoGrabado(ruta, 0, descripcion));
            session.setAttribute("inicioPaso", ahora);
            System.out.println("[GRAB] +" + descripcion + " | Total: " + grabacion.size());
        }
        // Siempre enviamos el comando al robot
        RobotHttpClient.enviarComando(config, ruta);
        // Respondemos en el formato que el JSP original espera:
        // { exito, mensaje, color, icono, timestamp }
        String timestamp = java.time.LocalTime.now()
                .truncatedTo(java.time.temporal.ChronoUnit.SECONDS).toString();
        out.print(String.format(
                "{\"exito\":true,\"mensaje\":\"%s\",\"color\":\"%s\",\"icono\":\"%s\","
                        + "\"timestamp\":\"%s\",\"grabando\":%b}",
                descripcion, color, icono, timestamp, estaGrabando
        ));
        out.flush();
    }
    // ── Validación de comandos permitidos ────────────────────────────────
    private boolean esComandoValido(String cmd) {
        switch (cmd) {
            case "go": case "back": case "left":
            case "right": case "stop":
            case "ledon": case "ledoff":
                return true;
            default: return false;
        }
    }
    // ── Descripciones ────────────────────────────────────────────────────
    private String toDescripcion(String cmd) {
        switch (cmd) {
            case "go":     return "Avanzar";
            case "back":   return "Retroceder";
            case "left":   return "Girar izquierda";
            case "right":  return "Girar derecha";
            case "stop":   return "Detener";
            case "ledon":  return "LED encendido";
            case "ledoff": return "LED apagado";
            default:       return cmd;
        }
    }
    // ── Colores para el log del JSP ──────────────────────────────────────
    private String toColor(String cmd) {
        switch (cmd) {
            case "go":    return "#39A900";
            case "back":  return "#3399ff";
            case "left":
            case "right": return "#ffcc00";
            case "stop":  return "#ff2244";
            default:      return "#ffffff";
        }
    }
    // ── Íconos para el log del JSP ───────────────────────────────────────
    private String toIcono(String cmd) {
        switch (cmd) {
            case "go":     return "↑";
            case "back":   return "↓";
            case "left":   return "←";
            case "right":  return "→";
            case "stop":   return "⏹";
            case "ledon":  return "💡";
            case "ledoff": return "🌑";
            default:       return "▶";
        }
    }
}