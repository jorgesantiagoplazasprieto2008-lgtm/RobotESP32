package co.sena.cimm.robot.servlet;

import co.sena.cimm.robot.model.RobotConfig;
import co.sena.cimm.robot.util.RobotHttpClient;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet que verifica y retorna el estado de conexión del robot.
 * Usado por el JavaScript del panel para actualizar el indicador de estado.
 *
 * URL: GET /status
 * Respuesta JSON: {"conectado": true/false, "ip": "192.168.4.1", "nombre":
 * "..."}
 *
 * @author SENA CIMM - Programa ADSO
 */
@WebServlet("/status")
public class RobotStatusServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");

        RobotConfig config = RobotConfigServlet.getConfigFromSession(request);
        PrintWriter out = response.getWriter();

        boolean conectado = RobotHttpClient.verificarConexion(config);
        config.setConnected(conectado);

        out.print("{\"conectado\":" + conectado
                + ",\"ip\":\"" + config.getRobotIp() + "\""
                + ",\"puerto\":" + config.getControlPort()
                + ",\"streamUrl\":\"" + config.getStreamUrl() + "\""
                + ",\"nombre\":\"" + escaparJson(config.getNombre()) + "\""
                + ",\"velocidad\":" + config.getVelocidad() + "}");
    }

    private String escaparJson(String texto) {
        if (texto == null)
            return "";
        return texto.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
