package co.sena.cimm.robot.servlet;
import co.sena.cimm.robot.model.PasoGrabado;
import co.sena.cimm.robot.model.RobotConfig; // Asumiendo que esta clase existe en el modelo
import co.sena.cimm.robot.util.RobotHttpClient; // Asumiendo que esta clase utilitaria existe

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

@WebServlet("/grabar")
public class GrabacionServlet extends HttpServlet {

    // Pool de UN solo hilo para reproducción. Evita que dos reproducciones corran al mismo tiempo.
    private final ExecutorService executorService = Executors.newSingleThreadExecutor();

    // Referencia a la tarea de reproducción actual (para poder cancelarla)
    private volatile Future<?> tareaActual = null;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        manejar(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        manejar(req, res);
    }

    @SuppressWarnings("unchecked")
    private void manejar(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();

        HttpSession session = req.getSession();
        String accion = req.getParameter("accion");

        // Siempre garantizamos que la lista exista en sesión
        List<PasoGrabado> grabacion = (List<PasoGrabado>) session.getAttribute("grabacion");
        if (grabacion == null) {
            grabacion = new ArrayList<>();
            session.setAttribute("grabacion", grabacion);
        }

        if (accion == null) {
            out.print("{\"error\":\"Falta parámetro accion\"}");
            return;
        }

        switch (accion) {

            // ══════════════════════════════════════════════════════════════
            // INICIAR: Limpiamos la grabación anterior y activamos la bandera
            // ══════════════════════════════════════════════════════════════
            case "iniciar": {
                // Si hay reproducción en curso, no permitimos grabar
                if (Boolean.TRUE.equals(session.getAttribute("reproduciendo"))) {
                    out.print("{\"ok\":false,\"mensaje\":\"Detén la reproducción antes de grabar\"}");
                    break;
                }
                grabacion.clear();
                session.setAttribute("grabacion",    grabacion);
                session.setAttribute("grabando",     true);
                session.setAttribute("reproduciendo",false);
                session.setAttribute("inicioPaso",   LocalDateTime.now());
                out.print("{\"ok\":true,\"mensaje\":\"Grabación iniciada. Mueve el robot!\"}");
                break;
            }

            // ══════════════════════════════════════════════════════════════
            // DETENER: Cerramos el último paso y desactivamos la bandera
            // ══════════════════════════════════════════════════════════════
            case "detener": {
                if (!Boolean.TRUE.equals(session.getAttribute("grabando"))) {
                    out.print("{\"ok\":false,\"mensaje\":\"No hay grabación activa\"}");
                    break;
                }
                // Calculamos la duración del ÚLTIMO paso grabado
                LocalDateTime inicio = (LocalDateTime) session.getAttribute("inicioPaso");
                if (inicio != null && !grabacion.isEmpty()) {
                    long ms = Duration.between(inicio, LocalDateTime.now()).toMillis();
                    grabacion.get(grabacion.size() - 1).setDuracionMs(ms);
                }
                session.setAttribute("grabando", false);
                session.removeAttribute("inicioPaso");

                out.print("{\"ok\":true,\"mensaje\":\"Grabación guardada\",\"totalPasos\":"
                        + grabacion.size() + "}");
                break;
            }

            // ══════════════════════════════════════════════════════════════
            // REPRODUCIR: Lanzamos la secuencia en un hilo separado
            // ══════════════════════════════════════════════════════════════
            case "reproducir": {
                if (Boolean.TRUE.equals(session.getAttribute("grabando"))) {
                    out.print("{\"ok\":false,\"mensaje\":\"Detén la grabación primero\"}");
                    break;
                }
                if (Boolean.TRUE.equals(session.getAttribute("reproduciendo"))) {
                    out.print("{\"ok\":false,\"mensaje\":\"Ya se está reproduciendo\"}");
                    break;
                }
                if (grabacion.isEmpty()) {
                    out.print("{\"ok\":false,\"mensaje\":\"No hay pasos grabados\"}");
                    break;
                }

                // Preparamos el estado de reproducción
                session.setAttribute("reproduciendo", true);
                session.setAttribute("pasoActual",    0);
                session.setAttribute("totalPasos",    grabacion.size());

                RobotConfig config  = (RobotConfig) session.getAttribute("config");
                List<PasoGrabado> copia = new ArrayList<>(grabacion); // copia para el hilo

                // Lanzamos en segundo plano (el servlet responde inmediato)
                tareaActual = executorService.submit(
                        () -> ejecutarSecuencia(copia, config, session)
                );

                out.print("{\"ok\":true,\"mensaje\":\"Reproducción iniciada\",\"totalPasos\":"
                        + copia.size() + "}");
                break;
            }

            // ══════════════════════════════════════════════════════════════
            // PARAR REPRODUCCION: Cancelamos el hilo si sigue corriendo
            // ══════════════════════════════════════════════════════════════
            case "pararReproduccion": {
                session.setAttribute("reproduciendo", false);
                // Cancelamos el Future (interrumpe el Thread.sleep del hilo)
                if (tareaActual != null && !tareaActual.isDone()) {
                    tareaActual.cancel(true);
                }
                out.print("{\"ok\":true,\"mensaje\":\"Reproducción detenida\"}");
                break;
            }

            // ══════════════════════════════════════════════════════════════
            // ESTADO: Responde el estado actual (usado por el polling JS)
            // ══════════════════════════════════════════════════════════════
            case "estado": {
                boolean grabando     = Boolean.TRUE.equals(session.getAttribute("grabando"));
                boolean reproduciendo= Boolean.TRUE.equals(session.getAttribute("reproduciendo"));
                int pasoActual       = session.getAttribute("pasoActual") != null
                        ? (int) session.getAttribute("pasoActual") : 0;
                int totalPasos       = session.getAttribute("totalPasos") != null
                        ? (int) session.getAttribute("totalPasos") : 0;
                int totalGrabados    = grabacion.size();

                out.print(String.format(
                        "{\"grabando\":%b,\"reproduciendo\":%b,\"pasoActual\":%d,\"totalPasos\":%d,\"totalGrabados\":%d}",
                        grabando, reproduciendo, pasoActual, totalPasos, totalGrabados
                ));
                break;
            }

            // ══════════════════════════════════════════════════════════════
            // LIMPIAR: Borramos todo lo grabado
            // ══════════════════════════════════════════════════════════════
            case "limpiar": {
                if (Boolean.TRUE.equals(session.getAttribute("reproduciendo"))) {
                    out.print("{\"ok\":false,\"mensaje\":\"No puedes limpiar mientras reproduce\"}");
                    break;
                }
                grabacion.clear();
                session.setAttribute("grabando",      false);
                session.setAttribute("reproduciendo", false);
                session.removeAttribute("inicioPaso");
                out.print("{\"ok\":true,\"mensaje\":\"Grabación eliminada\"}");
                break;
            }

            default:
                out.print("{\"error\":\"Acción desconocida: " + accion + "\"}");
        }

        out.flush();
    }

    // ══════════════════════════════════════════════════════════════════════
    // HILO SECUNDARIO: Reproduce paso a paso con los tiempos grabados
    // ══════════════════════════════════════════════════════════════════════
    private void ejecutarSecuencia(List<PasoGrabado> secuencia,
                                   RobotConfig config,
                                   HttpSession session) {
        try {
            for (int i = 0; i < secuencia.size(); i++) {

                // ¿El usuario pidió detener?
                if (!Boolean.TRUE.equals(session.getAttribute("reproduciendo"))) {
                    System.out.println("[ROBOT] Reproducción cancelada en paso " + (i + 1));
                    break;
                }

                PasoGrabado paso = secuencia.get(i);
                session.setAttribute("pasoActual", i + 1);

                System.out.println("[ROBOT] Paso " + (i+1) + "/" + secuencia.size()
                        + " → " + paso.getDescripcion()
                        + " (" + paso.getDuracionMs() + "ms)");

                // Enviamos el comando al robot físico
                RobotHttpClient.enviarComando(config, paso.getComando());

                // Esperamos exactamente lo que duró ese movimiento al grabar
                if (paso.getDuracionMs() > 50) { // mínimo 50ms para evitar ruido
                    Thread.sleep(paso.getDuracionMs());
                }
            }
        } catch (InterruptedException e) {
            // El hilo fue interrumpido (usuario presionó "Parar")
            Thread.currentThread().interrupt();
            System.out.println("[ROBOT] Hilo de reproducción interrumpido");
        } finally {
            // SIEMPRE detenemos el robot al terminar
            RobotHttpClient.enviarComando(config, "/stop");
            session.setAttribute("reproduciendo", false);
            session.setAttribute("pasoActual",    0);
            System.out.println("[ROBOT] Secuencia finalizada. Robot detenido.");
        }
    }

    @Override
    public void destroy() {
        executorService.shutdownNow(); // Cierra el hilo al apagar Tomcat
        super.destroy();
    }
}
