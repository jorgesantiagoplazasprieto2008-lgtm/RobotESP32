package co.sena.cimm.robot.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Modelo que representa un comando enviado al robot.
 * Registra el historial de comandos ejecutados.
 *
 * @author SENA CIMM - Programa ADSO
 */
public class ComandoRobot implements Serializable {

    private static final long serialVersionUID = 1L;

    public enum TipoComando {
        ADELANTE("Adelante", "↑", "#00ff88"),
        ATRAS("Atrás", "↓", "#ff8800"),
        IZQUIERDA("Izquierda", "←", "#00aaff"),
        DERECHA("Derecha", "→", "#aa00ff"),
        DETENER("Detener", "⏹", "#ff0044"),
        LED_ON("LED Encendido", "💡", "#ffff00"),
        LED_OFF("LED Apagado", "🌑", "#555555"),
        DESCONOCIDO("Desconocido", "?", "#888888");

        private final String descripcion;
        private final String icono;
        private final String color;

        TipoComando(String descripcion, String icono, String color) {
            this.descripcion = descripcion;
            this.icono = icono;
            this.color = color;
        }

        public String getDescripcion() {
            return descripcion;
        }

        public String getIcono() {
            return icono;
        }

        public String getColor() {
            return color;
        }
    }

    private TipoComando tipo;
    private String endpoint;
    private boolean exitoso;
    private int codigoRespuesta;
    private String timestamp;
    private long duracionMs;

    public ComandoRobot() {
        this.timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("HH:mm:ss.SSS"));
    }

    public ComandoRobot(TipoComando tipo, String endpoint) {
        this();
        this.tipo = tipo;
        this.endpoint = endpoint;
    }

    /**
     * Determina el tipo de comando a partir del endpoint.
     */
    public static TipoComando fromEndpoint(String endpoint) {
        if (endpoint == null)
            return TipoComando.DESCONOCIDO;
        if (endpoint.contains("var=car&val=1"))
            return TipoComando.ADELANTE;
        if (endpoint.contains("var=car&val=5"))
            return TipoComando.ATRAS;
        if (endpoint.contains("var=car&val=4"))
            return TipoComando.IZQUIERDA;
        if (endpoint.contains("var=car&val=2"))
            return TipoComando.DERECHA;
        if (endpoint.contains("var=car&val=3"))
            return TipoComando.DETENER;
        if (endpoint.contains("var=flash&val=255"))
            return TipoComando.LED_ON;
        if (endpoint.contains("var=flash&val=0"))
            return TipoComando.LED_OFF;
        return TipoComando.DESCONOCIDO;
    }

    // Getters y Setters
    public TipoComando getTipo() {
        return tipo;
    }

    public void setTipo(TipoComando tipo) {
        this.tipo = tipo;
    }

    public String getEndpoint() {
        return endpoint;
    }

    public void setEndpoint(String endpoint) {
        this.endpoint = endpoint;
    }

    public boolean isExitoso() {
        return exitoso;
    }

    public void setExitoso(boolean exitoso) {
        this.exitoso = exitoso;
    }

    public int getCodigoRespuesta() {
        return codigoRespuesta;
    }

    public void setCodigoRespuesta(int codigoRespuesta) {
        this.codigoRespuesta = codigoRespuesta;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public long getDuracionMs() {
        return duracionMs;
    }

    public void setDuracionMs(long duracionMs) {
        this.duracionMs = duracionMs;
    }

    @Override
    public String toString() {
        return "[" + timestamp + "] " + tipo.getDescripcion()
                + " -> " + (exitoso ? "OK (" + duracionMs + "ms)" : "ERROR " + codigoRespuesta);
    }
}
