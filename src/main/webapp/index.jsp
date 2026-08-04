<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="co.sena.cimm.robot.model.RobotConfig" %>
<%@ page import="co.sena.cimm.robot.servlet.RobotConfigServlet" %>
<%
    // Si ya hay una config en sesión, ir directamente al panel
    RobotConfig robotConfig = (RobotConfigServlet.getConfigFromSession(request));
    if (robotConfig != null && robotConfig.isConnected()) {
        response.sendRedirect(request.getContextPath() + "/control");
    } else {
        response.sendRedirect(request.getContextPath() + "/config");
    }
%>
