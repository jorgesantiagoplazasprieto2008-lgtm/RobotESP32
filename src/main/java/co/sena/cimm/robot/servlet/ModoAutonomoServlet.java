package co.sena.cimm.robot.servlet;

import co.sena.cimm.robot.model.RobotConfig;
import co.sena.cimm.robot.util.RobotHttpClient;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Servlet de Modo Autónomo del Robot ESP32.
 * Compatible con Java 14 (sin uso de records).
 * SENA CIMM - Programa ADSO
 */
@WebServlet("/autonomo")
public class ModoAutonomoServlet extends HttpServlet {

    private static final AtomicBoolean activo = new AtomicBoolean(false);
    private static volatile String modoActual = "ninguno";
    private static volatile String estadoTexto = "Inactivo";
    private static volatile int pasoActual = 0;
    private static volatile int totalPasos = 0;
    private static volatile Future<?> tareaActual = null;

    private static final ExecutorService executor = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "RobotAutonomo");
        t.setDaemon(true);
        return t;
    });

    /** Clase interna compatible con Java 8+ */
    private static final class Paso {
        final String cmd;
        final long duracionMs;
        final String descripcion;

        Paso(String cmd, long duracionMs, String descripcion) {
            this.cmd = cmd;
            this.duracionMs = duracionMs;
            this.descripcion = descripcion;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if ("estado".equals(request.getParameter("accion")))
            responderEstado(response);
        else
            response.sendError(400, "Usa accion=estado");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        String accion = request.getParameter("accion");
        if (accion == null)
            accion = "";
        switch (accion) {
            case "iniciar":
                String modo = request.getParameter("modo");
                iniciarModo(request, modo == null ? "cuadrado" : modo, out);
                break;
            case "detener":
                detenerModo(request, out);
                break;
            default:
                out.print("{\"exito\":false,\"mensaje\":\"Accion desconocida\"}");
        }
    }

    private void iniciarModo(HttpServletRequest req, String modo, PrintWriter out) {
        if (activo.get()) {
            out.print("{\"exito\":false,\"mensaje\":\"Ya hay modo activo\"}");
            return;
        }
        Paso[] sec = construirSecuencia(modo);
        if (sec == null) {
            out.print("{\"exito\":false,\"mensaje\":\"Modo desconocido\"}");
            return;
        }
        RobotConfig config = RobotConfigServlet.getConfigFromSession(req);
        activo.set(true);
        modoActual = modo;
        pasoActual = 0;
        totalPasos = sec.length;
        estadoTexto = "Iniciando: " + modo;
        tareaActual = executor.submit(() -> ejecutarSecuencia(config, sec));
        out.print("{\"exito\":true,\"mensaje\":\"Iniciado: " + modo + "\",\"totalPasos\":" + totalPasos + "}");
    }

    private void detenerModo(HttpServletRequest req, PrintWriter out) {
        activo.set(false);
        if (tareaActual != null)
            tareaActual.cancel(true);
        RobotHttpClient.enviarComando(RobotConfigServlet.getConfigFromSession(req), "/stop");
        modoActual = "ninguno";
        estadoTexto = "Detenido";
        pasoActual = 0;
        totalPasos = 0;
        out.print("{\"exito\":true,\"mensaje\":\"Detenido\"}");
    }

    private void responderEstado(HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        double prog = totalPasos > 0 ? (double) pasoActual / totalPasos * 100 : 0;
        response.getWriter().print("{\"activo\":" + activo.get()
                + ",\"modo\":\"" + modoActual + "\""
                + ",\"estado\":\"" + estadoTexto.replace("\"", "'") + "\""
                + ",\"pasoActual\":" + pasoActual
                + ",\"totalPasos\":" + totalPasos
                + ",\"progreso\":" + String.format("%.0f", prog) + "}");
    }

    private Paso[] construirSecuencia(String modo) {
        switch (modo) {
            case "cuadrado":
                return new Paso[] {
                        new Paso("/go", 1500, "Avanzar lado 1"), new Paso("/stop", 200, "Pausa"),
                        new Paso("/right", 600, "Girar 90°"), new Paso("/stop", 200, "Pausa"),
                        new Paso("/go", 1500, "Avanzar lado 2"), new Paso("/stop", 200, "Pausa"),
                        new Paso("/right", 600, "Girar 90°"), new Paso("/stop", 200, "Pausa"),
                        new Paso("/go", 1500, "Avanzar lado 3"), new Paso("/stop", 200, "Pausa"),
                        new Paso("/right", 600, "Girar 90°"), new Paso("/stop", 200, "Pausa"),
                        new Paso("/go", 1500, "Avanzar lado 4"), new Paso("/stop", 200, "Pausa"),
                        new Paso("/right", 600, "Girar 90°"), new Paso("/stop", 500, "Completado"),
                };
            case "zigzag":
                return new Paso[] {
                        new Paso("/go", 800, "Avanzar"), new Paso("/left", 400, "Izquierda"),
                        new Paso("/go", 800, "Avanzar"), new Paso("/right", 400, "Derecha"),
                        new Paso("/go", 800, "Avanzar"), new Paso("/right", 400, "Derecha"),
                        new Paso("/go", 800, "Avanzar"), new Paso("/left", 400, "Izquierda"),
                        new Paso("/go", 800, "Avanzar"), new Paso("/stop", 500, "Completado"),
                };
            case "ronda":
                return new Paso[] {
                        new Paso("/right", 2400, "Vuelta 1"), new Paso("/stop", 300, "Pausa"),
                        new Paso("/right", 2400, "Vuelta 2"), new Paso("/stop", 300, "Pausa"),
                        new Paso("/left", 2400, "Inversa"), new Paso("/stop", 500, "Completado"),
                };
            case "patrulla":
                return new Paso[] {
                        new Paso("/go", 2000, "Avanzar"), new Paso("/stop", 400, "Pausa"),
                        new Paso("/back", 2000, "Retroceder"), new Paso("/stop", 400, "Pausa"),
                        new Paso("/go", 2000, "Avanzar"), new Paso("/stop", 400, "Pausa"),
                        new Paso("/back", 2000, "Retroceder"), new Paso("/stop", 500, "Completado"),
                };
            case "exploracion":
                return new Paso[] {
                        new Paso("/go", 1200, "Avanzar"), new Paso("/right", 500, "Giro"),
                        new Paso("/go", 900, "Avanzar"), new Paso("/left", 700, "Giro"),
                        new Paso("/go", 1500, "Avanzar"), new Paso("/right", 400, "Giro"),
                        new Paso("/go", 600, "Avanzar"), new Paso("/left", 900, "Giro"),
                        new Paso("/back", 800, "Retroceder"), new Paso("/right", 600, "Giro"),
                        new Paso("/go", 1000, "Avanzar"), new Paso("/stop", 500, "Completado"),
                };
            default:
                return null;
        }
    }

    private void ejecutarSecuencia(RobotConfig config, Paso[] secuencia) {
        try {
            for (int i = 0; i < secuencia.length && activo.get(); i++) {
                pasoActual = i + 1;
                estadoTexto = "Paso " + pasoActual + "/" + totalPasos + ": " + secuencia[i].descripcion;
                RobotHttpClient.enviarComando(config, secuencia[i].cmd);
                Thread.sleep(secuencia[i].duracionMs);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            if (activo.get()) {
                RobotHttpClient.enviarComando(config, "/stop");
                estadoTexto = "Completado ✓";
            }
            activo.set(false);
            modoActual = "ninguno";
        }
    }
}
