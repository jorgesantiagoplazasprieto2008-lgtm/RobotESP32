package co.sena.cimm.robot.servlet;

import co.sena.cimm.robot.model.RobotConfig;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Servlet proxy para el stream de video MJPEG del robot ESP32.
 *
 * El ESP32-CAM transmite video como MJPEG multipart stream.
 * Este proxy lo redirige al cliente web, resolviendo problemas de
 * CORS (Cross-Origin Resource Sharing) cuando el robot y el servidor
 * están en dominios/IPs diferentes.
 *
 * URL de uso: GET /camera-proxy
 *
 * Funcionamiento:
 * 1. El JSP carga la cámara como: <img src="camera-proxy">
 * 2. Este servlet solicita el stream al ESP32
 * 3. Retransmite los bytes al navegador en tiempo real
 *
 * @author SENA CIMM - Programa ADSO
 * @version 1.0.0
 */
@WebServlet(urlPatterns = "/camera-proxy", asyncSupported = true)
public class CameraProxyServlet extends HttpServlet {

    private static final int BUFFER_SIZE = 8192;
    private static final int TIMEOUT = 10000; // 10 segundos

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        RobotConfig config = RobotConfigServlet.getConfigFromSession(request);
        String streamUrl = config.getStreamUrl();

        System.out.println("[CameraProxy] Conectando a: " + streamUrl);

        HttpURLConnection connection = null;
        try {
            URL url = new URL(streamUrl);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(TIMEOUT);
            connection.setReadTimeout(0); // Sin timeout para streaming continuo
            connection.setRequestProperty("User-Agent", "SENA-CIMM-RobotController/1.0");
            connection.connect();

            int responseCode = connection.getResponseCode();
            if (responseCode != HttpURLConnection.HTTP_OK
                    && responseCode != HttpURLConnection.HTTP_PARTIAL) {
                response.sendError(HttpServletResponse.SC_BAD_GATEWAY,
                        "El robot respondió con código: " + responseCode);
                return;
            }

            // Copiar headers del Content-Type (importante para MJPEG multipart)
            String contentType = connection.getContentType();
            if (contentType != null) {
                response.setContentType(contentType);
            } else {
                // Asumir MJPEG por defecto para ESP32-CAM
                response.setContentType("multipart/x-mixed-replace; boundary=frame");
            }

            // Headers para evitar caché en el stream
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setHeader("Expires", "0");
            response.setHeader("Access-Control-Allow-Origin", "*");

            // Transmitir el stream en tiempo real
            InputStream inputStream = connection.getInputStream();
            OutputStream outputStream = response.getOutputStream();

            byte[] buffer = new byte[BUFFER_SIZE];
            int bytesRead;

            while ((bytesRead = inputStream.read(buffer)) != -1) {
                try {
                    outputStream.write(buffer, 0, bytesRead);
                    outputStream.flush();
                } catch (IOException e) {
                    // El cliente cerró la conexión (normal al salir de la página)
                    System.out.println("[CameraProxy] Cliente desconectado: " + e.getMessage());
                    break;
                }
            }

        } catch (java.net.ConnectException e) {
            System.err.println("[CameraProxy] No se pudo conectar al robot: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "No se puede conectar a la cámara del robot en " + streamUrl
                            + ". Verifica que el robot esté encendido.");
        } catch (java.net.SocketTimeoutException e) {
            System.err.println("[CameraProxy] Timeout conectando al robot: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_GATEWAY_TIMEOUT,
                    "Timeout al conectar con la cámara del robot.");
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
}
