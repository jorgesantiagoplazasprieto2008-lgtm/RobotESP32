package co.sena.cimm.robot.model;

import java.io.Serializable;

/**
 * Modelo de configuración del robot ESP32.
 * Almacena la IP del robot y sus parámetros de conexión.
 *
 * @author SENA CIMM - Programa ADSO
 * @version 1.0.0
 */
public class RobotConfig implements Serializable {

    private static final long serialVersionUID = 1L;

    // IP por defecto del ESP32 en modo Access Point
    private String robotIp = "192.168.4.1";
    private int controlPort = 80;
    private int streamPort = 81;
    private int velocidad = 150; // PWM 0-255
    private boolean connected = false;
    private String nombre = "Robot ESP32 AD175";

    // ==================== Endpoints del robot ====================
    public static final String ENDPOINT_FORWARD = "/go";
    public static final String ENDPOINT_BACKWARD = "/back";
    public static final String ENDPOINT_LEFT = "/left";
    public static final String ENDPOINT_RIGHT = "/right";
    public static final String ENDPOINT_STOP = "/stop";
    public static final String ENDPOINT_STREAM = "/stream";
    public static final String ENDPOINT_LED_ON = "/ledon";
    public static final String ENDPOINT_LED_OFF = "/ledoff";

    // ==================== Constructores ====================

    public RobotConfig() {
    }

    public RobotConfig(String robotIp, int controlPort, int streamPort) {
        this.robotIp = robotIp;
        this.controlPort = controlPort;
        this.streamPort = streamPort;
    }

    // ==================== Métodos utilitarios ====================

    /**
     * Retorna la URL base del servidor de control del robot.
     */
    public String getControlBaseUrl() {
        return "http://" + robotIp + ":" + controlPort;
    }

    /**
     * Retorna la URL del stream de video MJPEG.
     */
    public String getStreamUrl() {
        if (streamPort == controlPort) {
            return "http://" + robotIp + ":" + controlPort + ENDPOINT_STREAM;
        }
        return "http://" + robotIp + ":" + streamPort + ENDPOINT_STREAM;
    }

    /**
     * Retorna la URL completa para un comando de movimiento.
     * 
     * @param endpoint endpoint del comando (usar constantes ENDPOINT_*)
     */
    public String getCommandUrl(String endpoint) {
        return getControlBaseUrl() + endpoint;
    }

    // ==================== Getters y Setters ====================

    public String getRobotIp() {
        return robotIp;
    }

    public void setRobotIp(String robotIp) {
        this.robotIp = robotIp;
    }

    public int getControlPort() {
        return controlPort;
    }

    public void setControlPort(int controlPort) {
        this.controlPort = controlPort;
    }

    public int getStreamPort() {
        return streamPort;
    }

    public void setStreamPort(int streamPort) {
        this.streamPort = streamPort;
    }

    public int getVelocidad() {
        return velocidad;
    }

    public void setVelocidad(int velocidad) {
        if (velocidad >= 0 && velocidad <= 255) {
            this.velocidad = velocidad;
        }
    }

    public boolean isConnected() {
        return connected;
    }

    public void setConnected(boolean connected) {
        this.connected = connected;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    @Override
    public String toString() {
        return "RobotConfig{ip=" + robotIp + ", controlPort=" + controlPort
                + ", streamPort=" + streamPort + ", velocidad=" + velocidad + "}";
    }
}
