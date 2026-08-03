# 🤖 RobotESP32 — Proyecto NetBeans
## SENA CIMM · ADSO 228118 · Regional Boyacá

Aplicación Java Web para controlar el **KUONGSHUN AD175 ESP32 WiFi Camera 2WD**.
Configurada para **NetBeans IDE 12+** con **Apache Tomcat 8.5** y **JDK 14/17/21**.

---

## 📁 Estructura del Proyecto NetBeans

```
RobotESP32-NetBeans/
├── build.xml                          ← Ant build principal
├── nbproject/
│   ├── project.xml                    ← Metadata del proyecto
│   ├── project.properties             ← Configuración de build
│   ├── build-impl.xml                 ← Tareas Ant generadas
│   ├── genfiles.properties
│   └── private/
│       └── private.properties         ← ⚠️ Ajustar ruta de Tomcat aquí
├── src/
│   └── java/
│       └── co/sena/cimm/robot/
│           ├── model/
│           │   ├── RobotConfig.java
│           │   └── ComandoRobot.java
│           ├── servlet/
│           │   ├── RobotConfigServlet.java
│           │   ├── RobotControlServlet.java
│           │   ├── CameraProxyServlet.java
│           │   ├── RobotStatusServlet.java
│           │   ├── FotoCapturaServlet.java
│           │   └── ModoAutonomoServlet.java
│           └── util/
│               └── RobotHttpClient.java
├── web/
│   ├── WEB-INF/
│   │   └── web.xml
│   ├── index.jsp
│   ├── config.jsp
│   ├── control.jsp
│   └── error.jsp
└── lib/                               ← ⚠️ Agregar JARs aquí (ver paso 3)
```

---

## 🚀 Pasos de Configuración en NetBeans

### Paso 1 — Abrir el proyecto

1. Abre **NetBeans IDE**
2. Menú `File` → `Open Project`
3. Navega hasta la carpeta `RobotESP32-NetBeans`
4. Haz clic en **Open Project**

> NetBeans detectará automáticamente el `build.xml` como proyecto Ant Web.

---

### Paso 2 — Configurar el servidor Tomcat

1. Ve a `Tools` → `Servers`
2. Clic en **Add Server...**
3. Selecciona **Apache Tomcat or TomEE**
4. En **Server Location**, apunta a tu carpeta de Tomcat:

| Sistema | Ruta típica |
|---------|------------|
| Windows + XAMPP | `C:\xampp\tomcat` |
| Windows standalone | `C:\Program Files\Apache Software Foundation\Tomcat 8.5` |
| Linux | `/opt/tomcat8.5` o `/usr/share/tomcat8.5` |

5. Clic en **Finish**

---

### Paso 3 — Agregar librerías (JARs)

Descarga estos JARs y colócalos en la carpeta `lib/` del proyecto:

| JAR | Descarga |
|-----|----------|
| `servlet-api.jar` | Ya está en `[TOMCAT]/lib/servlet-api.jar` — copiar de ahí |
| `jstl-1.2.jar` | [Maven Central](https://repo1.maven.org/maven2/javax/servlet/jstl/1.2/jstl-1.2.jar) |
| `json-simple-1.1.1.jar` | [Maven Central](https://repo1.maven.org/maven2/com/googlecode/json-simple/json-simple/1.1.1/json-simple-1.1.1.jar) |

**En NetBeans**, agregar los JARs al proyecto:
1. Clic derecho en el proyecto → `Properties`
2. Sección `Libraries`
3. Clic en `Add JAR/Folder`
4. Selecciona los JARs descargados

> **Nota**: `servlet-api.jar` debe marcarse como **scope=Compile Only** (no se incluye en el WAR porque lo provee Tomcat).

---

### Paso 4 — Configurar Java Platform

1. Clic derecho en el proyecto → `Properties`
2. Sección `Build` → `Compiling`
3. **Source/Binary Format**: `JDK 14` (o el que tengas)

---

### Paso 5 — Ejecutar el proyecto

```
Clic derecho en el proyecto → Run
```

O con el botón ▶ en la barra de herramientas.

NetBeans compilará, empaquetará y desplegará en Tomcat automáticamente.
Se abrirá el navegador en:
```
http://localhost:8080/RobotESP32
```

---

### Paso 6 — Generar el WAR manualmente

```
Clic derecho en el proyecto → Clean and Build
```

El WAR se genera en:
```
dist/RobotESP32.war
```

Para desplegar manualmente:
```bash
cp dist/RobotESP32.war [TOMCAT_HOME]/webapps/
```

---

## 🔧 Solución de Problemas Comunes

### ❌ "Cannot find javax.servlet.HttpServlet"
→ Falta `servlet-api.jar` en las librerías del proyecto.
→ Copiar de `[TOMCAT]/lib/servlet-api.jar` y agregar en `Properties` → `Libraries`.

### ❌ "Source level 14 is not supported"
→ Ir a `Project Properties` → `Build` → `Compiling` → cambiar Source/Binary a `JDK 11` o la versión instalada.

### ❌ Tomcat no aparece en "Run"
→ Verificar en `Tools` → `Servers` que Tomcat está registrado y apunta al directorio correcto.

### ❌ Error 404 al abrir la app
→ Verificar que Tomcat esté corriendo: `http://localhost:8080`
→ Verificar que el contexto sea `/RobotESP32`

### ❌ Cámara no carga
→ El robot debe estar encendido y en la misma red WiFi que el servidor.
→ Verificar IP en la página de configuración (`/config`).

---

## 📡 Uso con el Robot

1. **Enciende el robot** (conecta la batería)
2. **Conéctate al WiFi del robot** (ej: `ESP32-Robot-AD175`)
3. Abre la app: `http://localhost:8080/RobotESP32`
4. En la pantalla de **Configuración**, ingresa:
   - IP: `192.168.4.1`
   - Puerto control: `80`
   - Puerto cámara: `81`
5. Clic en **Conectar y Guardar**
6. ¡A controlar el robot! 🤖

---

## 🎓 Contexto SENA ADSO 228118

Este proyecto integra competencias de:
- Java Servlets / JSP (API 3.1)
- Patrón MVC en JavaEE
- Protocolo HTTP / REST
- IoT — Comunicación con ESP32
- Gestión de sesiones HTTP
- Programación concurrente (ExecutorService)
- Streaming de video MJPEG

**SENA — Centro Industrial de Mantenimiento y Manufactura (CIMM)**
**Regional Boyacá — Sogamoso, Colombia**
