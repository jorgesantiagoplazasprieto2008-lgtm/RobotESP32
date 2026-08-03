<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Error | SENA CIMM Robot</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@700&family=Share+Tech+Mono&display=swap" rel="stylesheet">
    <style>
        body {
            background:#080808; color:#e8e8e8;
            font-family:'Share Tech Mono',monospace;
            display:flex; flex-direction:column;
            align-items:center; justify-content:center;
            min-height:100vh; gap:20px;
            text-align:center;
        }
        h1 { font-family:'Orbitron',monospace; color:#ff2244; font-size:48px; }
        p { color:#666; }
        a {
            color:#39A900; text-decoration:none;
            border:1px solid #39A900; padding:10px 24px; border-radius:8px;
            transition: all 0.2s;
        }
        a:hover { background: rgba(57,169,0,0.1); box-shadow: 0 0 15px rgba(57,169,0,0.3); }
    </style>
</head>
<body>
    <h1>ERROR</h1>
    <p>Código: <%= request.getAttribute("javax.servlet.error.status_code") %></p>
    <p>Mensaje: <%= request.getAttribute("javax.servlet.error.message") %></p>
    <a href="${pageContext.request.contextPath}/config">← Volver a configuración</a>
</body>
</html>
