# 🤖 Manual de Control - Robot ESP32-CAM

Este documento detalla el funcionamiento y la configuración del sistema de control inalámbrico para el robot basado en ESP32-CAM.

---

## 🌐 1. Conexión de Red
Para controlar el robot, todos los dispositivos (computador y celular) deben estar en la misma red:
1.  **Red Wi-Fi:** `KUONGSHUN-AD175`
2.  **Contraseña:** `12345678`
3.  **IP del Robot:** `192.168.4.1` (fija por el firmware)

---

## 🚀 2. Modos de Control

### 🎮 A. Control Manual (Teclado y Pantalla)
*   **En PC:** Usa las flechas del teclado o las teclas `W` (Adelante), `A` (Izquierda), `S` (Atrás), `D` (Derecha).
*   **En Pantalla:** Usa el panel de control táctil (D-PAD).

### 📱 B. Giroscopio (Control por Movimiento)
1.  Abre la web desde tu celular (`http://[IP-TU-PC]:8080/RobotESP32/control`).
2.  Ve a la pestaña **Giroscopio** y presiona **Activar**.
3.  Inclina el celular hacia adelante para avanzar e inclínalo a los lados para girar.

### 🤖 C. Modo Autónomo
El robot incluye coreografías pre-programadas:
*   **Cuadrado:** Traza un cuadrado perfecto con giros de 90°.
*   **Zigzag:** Movimiento de evasión lateral.
*   **Patrulla:** Va y regresa en línea recta.
*   **Exploración:** Secuencia variada de búsqueda.

---

## 📸 3. Cámara y Galería
*   **Stream en Vivo:** Se visualiza en la pestaña principal (Puerto 81).
*   **Captura de Fotos:** Haz clic en "Capturar Foto" para guardar un instante.
*   **Galería:** Las fotos se guardan en la sesión y pueden descargarse a tu dispositivo.

---

## 🛠 4. Configuración Técnica (Servlets)
El sistema utiliza una arquitectura de Servlets en Java para comunicar la web con el hardware:
*   `RobotControlServlet`: Traduce los comandos web al protocolo `/control?var=car&val=X`.
*   `CameraProxyServlet`: Sirve de puente para que el video no se corte.
*   `FotoCapturaServlet`: Gestiona el almacenamiento local de imágenes.

---

## ⚠️ 5. Solución de Fallos Rápidos
*   **¿No se mueve?:** Pulsa `Ctrl + F5` en el navegador para refrescar los scripts.
*   **¿No carga el video?:** Asegúrate de que no haya otra cámara abierta en otra pestaña y verifica que el puerto sea el **81**.
*   **¿Dice OFFLINE?:** Verifica tu conexión a la red `KUONGSHUN-AD175`.

---

> **ADSO** - SENA CIMM - 2026
