package co.sena.cimm.robot.model;

import java.io.Serializable;

public class PasoGrabado implements Serializable {
    private static final long serialVersionUID = 1L;

    private String comando;       // Ej: "/go", "/left", "/stop"
    private long duracionMs;      // Duración en milisegundos
    private String descripcion;   // Texto legible para la interfaz (Ej: "Avanzar")

    // Constructor vacío requerido para serialización
    public PasoGrabado() {
    }

    public PasoGrabado(String comando, long duracionMs, String descripcion) {
        this.comando = comando;
        this.duracionMs = duracionMs;
        this.descripcion = descripcion;
    }

    public String getComando()                  { return comando; }
    public void   setComando(String comando)    { this.comando = comando; }
    public long   getDuracionMs()               { return duracionMs; }
    public void   setDuracionMs(long ms)        { this.duracionMs = ms; }
    public String getDescripcion()              { return descripcion; }
    public void   setDescripcion(String d)      { this.descripcion = d; }
    @Override
    public String toString() {
        return descripcion + " [" + duracionMs + "ms]";
    }
}
