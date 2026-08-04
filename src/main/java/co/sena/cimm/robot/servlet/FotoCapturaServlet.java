package co.sena.cimm.robot.servlet;

import co.sena.cimm.robot.model.RobotConfig;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet para capturar fotos desde la cámara del robot ESP32-CAM.
 *
 * GET /foto → captura una foto y la guarda en sesión
 * GET /foto?accion=lista → retorna JSON con lista de fotos capturadas
 * GET /foto?accion=ver&idx=0 → retorna la imagen en bytes (Content-Type:
 * image/jpeg)
 * POST /foto?accion=limpiar → elimina todas las fotos de sesión
 *
 * El ESP32-CAM expone una foto estática en: GET /capture
 * (algunos firmwares usan /jpg o /photo)
 *
 * @author SENA CIMM - Programa ADSO
 */
@WebServlet("/foto")
public class FotoCapturaServlet extends HttpServlet {

    private static final String SESSION_FOTOS = "fotosCapturas";
    private static final int MAX_FOTOS = 20;

    // Endpoints de captura según firmware del ESP32
    private static final String[] ENDPOINTS_CAPTURA = { "/capture", "/jpg", "/photo", "/snapshot" };

    public static class FotoCaptura implements Serializable {
        private static final long serialVersionUID = 1L;
        public final String timestamp;
        public final byte[] datos;
        public final int tamañoKb;

        public FotoCaptura(byte[] datos) {
            this.datos = datos;
            this.tamañoKb = datos.length / 1024;
            this.timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("HH:mm:ss"));
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String accion = request.getParameter("accion");
        if (accion == null)
            accion = "capturar";

        switch (accion) {
            case "lista":
                responderLista(request, response);
                break;
            case "ver":
                responderFoto(request, response);
                break;
            case "limpiar":
                limpiarFotos(request, response);
                break;
            default:
                capturarFoto(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String accion = request.getParameter("accion");
        if ("limpiar".equals(accion)) {
            limpiarFotos(request, response);
        } else {
            capturarFoto(request, response);
        }
    }

    // ==================== ACCIONES ====================

    private void capturarFoto(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        RobotConfig config = RobotConfigServlet.getConfigFromSession(request);
        byte[] datos = null;
        String endpointUsado = null;

        // Intentar con cada endpoint de captura conocido
        for (String ep : ENDPOINTS_CAPTURA) {
            datos = intentarCaptura(config, ep);
            if (datos != null && datos.length > 0) {
                endpointUsado = ep;
                break;
            }
        }

        if (datos == null || datos.length == 0) {
            out.print("{\"exito\":false,\"mensaje\":\"No se pudo capturar foto. "
                    + "Verifica que el robot esté conectado.\"}");
            return;
        }

        // Guardar en sesión
        HttpSession session = request.getSession(true);
        List<FotoCaptura> fotos = obtenerListaFotos(session);
        fotos.add(0, new FotoCaptura(datos));
        while (fotos.size() > MAX_FOTOS)
            fotos.remove(fotos.size() - 1);
        session.setAttribute(SESSION_FOTOS, fotos);

        int idx = 0;
        out.print("{\"exito\":true,"
                + "\"mensaje\":\"Foto capturada (" + (datos.length / 1024) + " KB)\","
                + "\"idx\":" + idx + ","
                + "\"total\":" + fotos.size() + ","
                + "\"endpoint\":\"" + endpointUsado + "\","
                + "\"tamañoKb\":" + (datos.length / 1024) + ","
                + "\"timestamp\":\"" + fotos.get(0).timestamp + "\"}");
    }

    private void responderFoto(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(404);
            return;
        }

        String idxStr = request.getParameter("idx");
        int idx = 0;
        try {
            idx = Integer.parseInt(idxStr);
        } catch (Exception ignored) {
        }

        List<FotoCaptura> fotos = obtenerListaFotos(session);
        if (idx < 0 || idx >= fotos.size()) {
            response.sendError(404, "Foto no encontrada");
            return;
        }

        FotoCaptura foto = fotos.get(idx);
        response.setContentType("image/jpeg");
        response.setContentLength(foto.datos.length);
        response.setHeader("Cache-Control", "no-cache");
        response.getOutputStream().write(foto.datos);
    }

    private void responderLista(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        List<FotoCaptura> fotos = obtenerListaFotos(session);

        StringBuilder sb = new StringBuilder("{\"total\":" + fotos.size() + ",\"fotos\":[");
        for (int i = 0; i < fotos.size(); i++) {
            FotoCaptura f = fotos.get(i);
            if (i > 0)
                sb.append(",");
            sb.append("{\"idx\":").append(i)
                    .append(",\"timestamp\":\"").append(f.timestamp).append("\"")
                    .append(",\"tamañoKb\":").append(f.tamañoKb).append("}");
        }
        sb.append("]}");
        response.getWriter().print(sb);
    }

    private void limpiarFotos(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null)
            session.removeAttribute(SESSION_FOTOS);

        response.setContentType("application/json");
        response.getWriter().print("{\"exito\":true,\"mensaje\":\"Fotos eliminadas\"}");
    }

    // ==================== UTILIDADES ====================

    private byte[] intentarCaptura(RobotConfig config, String endpoint) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL("http://" + config.getRobotIp()
                    + ":" + config.getControlPort() + endpoint);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(5000);
            conn.setRequestProperty("User-Agent", "SENA-CIMM-Robot/1.0");
            conn.connect();

            if (conn.getResponseCode() != 200)
                return null;
            String ct = conn.getContentType();
            if (ct != null && !ct.contains("image") && !ct.contains("jpeg"))
                return null;

            InputStream in = conn.getInputStream();
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buf = new byte[4096];
            int n;
            while ((n = in.read(buf)) != -1)
                baos.write(buf, 0, n);
            return baos.toByteArray();

        } catch (IOException e) {
            return null;
        } finally {
            if (conn != null)
                conn.disconnect();
        }
    }

    @SuppressWarnings("unchecked")
    private List<FotoCaptura> obtenerListaFotos(HttpSession session) {
        if (session == null)
            return new ArrayList<>();
        List<FotoCaptura> fotos = (List<FotoCaptura>) session.getAttribute(SESSION_FOTOS);
        if (fotos == null) {
            fotos = new ArrayList<>();
        }
        return fotos;
    }
}
