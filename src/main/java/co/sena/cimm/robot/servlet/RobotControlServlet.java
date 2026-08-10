package co.sena.cimm.robot.servlet;

import co.sena.cimm.robot.model.ComandoRobot;
import co.sena.cimm.robot.model.RobotConfig;
import co.sena.cimm.robot.util.RobotHttpClient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

/**
 * Servlet principal de control del robot ESP32.
 * Recibe comandos desde la interfaz web y los reenvía al robot via HTTP.
 *
 * Método: POST /control
 * Param: cmd = go | back | left | right | stop | ledon | ledoff
 *
 * Responde en formato JSON para ser consumido por el JavaScript de la UI.
 *
 * Ejemplo de respuesta exitosa:
 * {"exito": true, "mensaje": "Adelante", "timestamp": "14:30:05.123",
 * "duracionMs": 45}
 *
 * @author SENA CIMM - Programa ADSO
 * @version 1.0.0
 */
@WebServlet("/control")
@javax.servlet.annotation.MultipartConfig
public class RobotControlServlet extends HttpServlet {

    private static final String SESSION_HISTORIAL = "historialComandos";
    private static final int MAX_HISTORIAL = 50;

    /**
     * POST /control → ejecuta el comando y responde en JSON
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Obtener configuración del robot de la sesión
        RobotConfig config = RobotConfigServlet.getConfigFromSession(request);

        // Leer comando solicitado
        String cmdParam = request.getParameter("cmd");
        if (cmdParam == null || cmdParam.trim().isEmpty()) {
            out.print(jsonError("Parámetro 'cmd' requerido"));
            return;
        }

        // Traducir el comando al formato del firmware ESP32-CAM
        String endpoint;
        switch (cmdParam.toLowerCase().replace("/", "")) {
            case "go":
                endpoint = "/control?var=car&val=1";
                break;
            case "right":
                endpoint = "/control?var=car&val=2";
                break;
            case "stop":
                endpoint = "/control?var=car&val=3";
                break;
            case "left":
                endpoint = "/control?var=car&val=4";
                break;
            case "back":
                endpoint = "/control?var=car&val=5";
                break;
            case "ledon":
                endpoint = "/control?var=flash&val=255";
                break;
            case "ledoff":
                endpoint = "/control?var=flash&val=0";
                break;
            default:
                // Si es un comando de velocidad (ej: speed-200)
                if (cmdParam.startsWith("speed-")) {
                    String val = cmdParam.substring(6);
                    endpoint = "/control?var=speed&val=" + val;
                } else {
                    endpoint = cmdParam.startsWith("/") ? cmdParam : "/" + cmdParam;
                }
        }

        System.out.println("Comando CMD " + endpoint);
        System.out.println("Comando CMD " + cmdParam);

        // Enviar comando al robot
        ComandoRobot resultado = RobotHttpClient.enviarComando(config, endpoint);

        // Registrar en historial de sesión
        registrarHistorial(request, resultado);

        // Actualizar estado de conexión en la config
        config.setConnected(resultado.isExitoso());

        // Responder en JSON
        if (resultado.isExitoso()) {
            out.print(jsonExito(
                    resultado.getTipo().getDescripcion(),
                    resultado.getTipo().getIcono(),
                    resultado.getTipo().getColor(),
                    resultado.getTimestamp(),
                    resultado.getDuracionMs()));
        } else {
            out.print(jsonError("Error al comunicar con el robot. "
                    + "Verifica la conexión WiFi o los parámetros. (código: " + resultado.getCodigoRespuesta() + ")"));
        }
    }

    /**
     * GET /control → muestra el panel de control principal
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RobotConfig config = RobotConfigServlet.getConfigFromSession(request);
        List<ComandoRobot> historial = obtenerHistorial(request);

        request.setAttribute("config", config);
        request.setAttribute("historial", historial);
        request.getRequestDispatcher("/control.jsp").forward(request, response);
    }

    // ==================== Métodos privados ====================

    @SuppressWarnings("unchecked")
    private void registrarHistorial(HttpServletRequest request, ComandoRobot comando) {
        HttpSession session = request.getSession(true);
        Deque<ComandoRobot> historial = (Deque<ComandoRobot>) session.getAttribute(SESSION_HISTORIAL);
        if (historial == null) {
            historial = new ArrayDeque<>();
            session.setAttribute(SESSION_HISTORIAL, historial);
        }
        historial.addFirst(comando);
        // Mantener máximo de entradas
        while (historial.size() > MAX_HISTORIAL) {
            historial.removeLast();
        }
    }

    @SuppressWarnings("unchecked")
    private List<ComandoRobot> obtenerHistorial(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Deque<ComandoRobot> historial = (Deque<ComandoRobot>) session.getAttribute(SESSION_HISTORIAL);
        if (historial == null)
            return new ArrayList<>();
        return new ArrayList<>(historial);
    }

    private String jsonExito(String mensaje, String icono, String color,
            String timestamp, long duracionMs) {
        return "{\"exito\":true,"
                + "\"mensaje\":\"" + escaparJson(mensaje) + "\","
                + "\"icono\":\"" + escaparJson(icono) + "\","
                + "\"color\":\"" + escaparJson(color) + "\","
                + "\"timestamp\":\"" + escaparJson(timestamp) + "\","
                + "\"duracionMs\":" + duracionMs + "}";
    }

    private String jsonError(String mensaje) {
        return "{\"exito\":false,\"mensaje\":\"" + escaparJson(mensaje) + "\"}";
    }

    private String escaparJson(String texto) {
        if (texto == null)
            return "";
        return texto.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
