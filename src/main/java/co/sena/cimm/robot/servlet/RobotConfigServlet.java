package co.sena.cimm.robot.servlet;

import co.sena.cimm.robot.model.RobotConfig;
import co.sena.cimm.robot.util.RobotHttpClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Servlet de configuración del robot ESP32.
 * Permite configurar la IP, puertos y velocidad del robot.
 * Almacena la configuración en la sesión del usuario.
 *
 * URL: /config
 *
 * @author SENA CIMM - Programa ADSO
 * @version 1.0.0
 */
@WebServlet("/config")
public class RobotConfigServlet extends HttpServlet {

    public static final String SESSION_CONFIG = "robotConfig";

    @Override
    public void init() throws ServletException {
        super.init();
        System.out.println("[RobotConfigServlet] Servlet inicializado - SENA CIMM ADSO");
    }

    /**
     * GET /config → muestra el formulario de configuración
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        RobotConfig config = (RobotConfig) session.getAttribute(SESSION_CONFIG);

        // Crear configuración por defecto si no existe
        if (config == null) {
            config = new RobotConfig();
            session.setAttribute(SESSION_CONFIG, config);
        }

        request.setAttribute("config", config);
        request.getRequestDispatcher("/config.jsp").forward(request, response);
    }

    /**
     * POST /config → guarda la configuración y verifica conexión
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);

        // Leer parámetros del formulario
        String accion = request.getParameter("accion");

        if ("reset".equals(accion)) {
            // Restaurar configuración por defecto
            RobotConfig configDefault = new RobotConfig();
            session.setAttribute(SESSION_CONFIG, configDefault);
            request.setAttribute("mensaje", "Configuración restaurada a valores por defecto.");
            request.setAttribute("tipoMensaje", "info");
            request.setAttribute("config", configDefault);
            request.getRequestDispatcher("/config.jsp").forward(request, response);
            return;
        }

        // Guardar nueva configuración
        String ip = request.getParameter("robotIp");
        String controlPortStr = request.getParameter("controlPort");
        String streamPortStr = request.getParameter("streamPort");
        String velocidadStr = request.getParameter("velocidad");
        String nombre = request.getParameter("nombre");

        RobotConfig config = new RobotConfig();

        try {
            if (ip != null && !ip.trim().isEmpty()) {
                config.setRobotIp(ip.trim());
            }
            if (controlPortStr != null && !controlPortStr.trim().isEmpty()) {
                config.setControlPort(Integer.parseInt(controlPortStr.trim()));
            }
            if (streamPortStr != null && !streamPortStr.trim().isEmpty()) {
                config.setStreamPort(Integer.parseInt(streamPortStr.trim()));
            }
            if (velocidadStr != null && !velocidadStr.trim().isEmpty()) {
                int vel = Integer.parseInt(velocidadStr.trim());
                config.setVelocidad(Math.max(0, Math.min(255, vel)));
            }
            if (nombre != null && !nombre.trim().isEmpty()) {
                config.setNombre(nombre.trim());
            }
        } catch (NumberFormatException e) {
            request.setAttribute("mensaje", "Error: Los puertos y velocidad deben ser números válidos.");
            request.setAttribute("tipoMensaje", "error");
            request.setAttribute("config", config);
            request.getRequestDispatcher("/config.jsp").forward(request, response);
            return;
        }

        // Verificar conexión con el robot
        boolean conectado = RobotHttpClient.verificarConexion(config);
        config.setConnected(conectado);

        // Configurar velocidad si el robot está conectado
        if (conectado) {
            RobotHttpClient.configurarVelocidad(config, config.getVelocidad());
        }

        // Guardar en sesión
        session.setAttribute(SESSION_CONFIG, config);

        if (conectado) {
            request.setAttribute("mensaje",
                    "✅ Robot conectado exitosamente en " + config.getRobotIp()
                            + ". ¡Puedes empezar a controlarlo!");
            request.setAttribute("tipoMensaje", "exito");
        } else {
            request.setAttribute("mensaje",
                    "⚠️ Configuración guardada, pero el robot no responde en "
                            + config.getRobotIp() + ":" + config.getControlPort()
                            + ". Verifica que el robot esté encendido y conectado a la misma red WiFi.");
            request.setAttribute("tipoMensaje", "advertencia");
        }

        request.setAttribute("config", config);
        request.getRequestDispatcher("/config.jsp").forward(request, response);
    }

    /**
     * Método de utilidad estático para obtener la config de la sesión.
     */
    public static RobotConfig getConfigFromSession(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        RobotConfig config = (RobotConfig) session.getAttribute(SESSION_CONFIG);
        if (config == null) {
            config = new RobotConfig();
            session.setAttribute(SESSION_CONFIG, config);
        }
        return config;
    }
}
