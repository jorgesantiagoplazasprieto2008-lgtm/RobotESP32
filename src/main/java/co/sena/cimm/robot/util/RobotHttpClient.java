package co.sena.cimm.robot.util;

import co.sena.cimm.robot.model.ComandoRobot;
import co.sena.cimm.robot.model.RobotConfig;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Cliente HTTP para comunicarse con el robot ESP32.
 * Envía comandos GET a los endpoints del robot y registra la respuesta.
 *
 * Protocolo del ESP32 AD175:
 *   GET http://{IP}:{PUERTO}/go       → Adelante
 *   GET http://{IP}:{PUERTO}/back     → Atrás
 *   GET http://{IP}:{PUERTO}/left     → Izquierda
 *   GET http://{IP}:{PUERTO}/right    → Derecha
 *   GET http://{IP}:{PUERTO}/stop     → Detener
 *   GET http://{IP}:{PUERTO}/ledon    → LED encendido
 *   GET http://{IP}:{PUERTO}/ledoff   → LED apagado
 *
 * Stream de cámara (MJPEG):
 *   http://{IP}:{STREAM_PUERTO}/stream
 *
 * @author SENA CIMM - Programa ADSO 228118
 * @version 1.0.0
 */
public class RobotHttpClient {

    private static final int TIMEOUT_CONEXION = 3000; // 3 segundos
    private static final int TIMEOUT_LECTURA  = 3000; // 3 segundos

    /**
     * Envía un comando HTTP GET al robot y retorna el resultado.
     *
     * @param config configuración del robot (IP, puerto)
     * @param endpoint endpoint del comando (ej: "/go", "/stop")
     * @return ComandoRobot con el resultado de la operación
     */
    public static ComandoRobot enviarComando(RobotConfig config, String endpoint) {
        ComandoRobot.TipoComando tipo = ComandoRobot.fromEndpoint(endpoint);
        ComandoRobot comando = new ComandoRobot(tipo, endpoint);

        String urlStr = config.getCommandUrl(endpoint);
        long inicio = System.currentTimeMillis();

        HttpURLConnection connection = null;
        try {
            URL url = new URL(urlStr);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(TIMEOUT_CONEXION);
            connection.setReadTimeout(TIMEOUT_LECTURA);
            connection.setRequestProperty("User-Agent", "SENA-CIMM-RobotController/1.0");
            connection.setRequestProperty("Accept", "*/*");
            connection.connect();

            int codigoRespuesta = connection.getResponseCode();
            comando.setCodigoRespuesta(codigoRespuesta);
            comando.setExitoso(codigoRespuesta >= 200 && codigoRespuesta < 300);

        } catch (IOException e) {
            comando.setExitoso(false);
            comando.setCodigoRespuesta(-1);
            System.err.println("[RobotHttpClient] Error al enviar comando "
                    + endpoint + ": " + e.getMessage());
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
            long fin = System.currentTimeMillis();
            comando.setDuracionMs(fin - inicio);
        }

        return comando;
    }

    /**
     * Verifica si el robot está accesible en la red.
     *
     * @param config configuración del robot
     * @return true si el robot responde, false si no
     */
    public static boolean verificarConexion(RobotConfig config) {
        HttpURLConnection connection = null;
        try {
            URL url = new URL("http://" + config.getRobotIp()
                    + ":" + config.getControlPort() + "/");
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(2000);
            connection.setReadTimeout(2000);
            connection.connect();
            int codigo = connection.getResponseCode();
            return codigo >= 200 && codigo < 500;
        } catch (IOException e) {
            return false;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    /**
     * Envía parámetro de velocidad al robot (si el firmware lo soporta).
     * Algunos firmwares del AD175 aceptan: GET /speed?val=150
     *
     * @param config configuración del robot
     * @param velocidad valor de velocidad (0-255)
     * @return true si fue exitoso
     */
    public static boolean configurarVelocidad(RobotConfig config, int velocidad) {
        HttpURLConnection connection = null;
        try {
            String urlStr = config.getControlBaseUrl() + "/speed?val=" + velocidad;
            URL url = new URL(urlStr);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(TIMEOUT_CONEXION);
            connection.setReadTimeout(TIMEOUT_LECTURA);
            connection.connect();
            int codigo = connection.getResponseCode();
            return codigo >= 200 && codigo < 300;
        } catch (IOException e) {
            // Puede que el firmware no soporte este endpoint
            return false;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
}
