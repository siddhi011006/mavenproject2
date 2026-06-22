<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Error | LuxeGlow</title>
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; background: radial-gradient(circle at center, #1a080c 0%, #0a0204 100%); font-family: 'Inter', sans-serif; color: #FFFFFF;">
    
    <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05); backdrop-filter: blur(25px); -webkit-backdrop-filter: blur(25px); padding: 50px; border-radius: 24px; max-width: 600px; text-align: center; box-shadow: var(--shadow-lux); width: 100%;">
        <div style="width: 80px; height: 80px; background: rgba(211, 47, 47, 0.15); border: 1px solid #d32f2f; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 25px;">
            <i class="fas fa-exclamation-triangle" style="font-size: 2.2rem; color: #f56c6c;"></i>
        </div>
        
        <h1 style="font-family: 'Playfair Display', serif; font-size: 1.8rem; font-weight: 600; color: var(--text-primary); margin-bottom: 15px; letter-spacing: 1px;">Something Went Wrong</h1>
        <p style="color: var(--text-secondary); font-size: 0.9rem; line-height: 1.6; margin-bottom: 25px;">
            An internal server error occurred while processing this request. Our technical staff has been notified.
        </p>

        <%-- Output error information safely in comments for developers, or check if active admin is in session to see it --%>
        <%
            HttpSession s = request.getSession(false);
            if (s != null && "ADMIN".equalsIgnoreCase((String) s.getAttribute("role"))) {
                Throwable exc = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
                String message = exc != null ? exc.getMessage() : "Unknown exception details.";
        %>
            <div style="text-align: left; background: rgba(0,0,0,0.4); border: 1px solid var(--border-color); border-radius: 12px; padding: 15px; font-family: monospace; font-size: 0.75rem; color: #f56c6c; margin-bottom: 30px; overflow-x: auto; max-height: 150px;">
                <strong>Developer Context:</strong><br>
                <%= message %>
                <br><br>
                <% 
                    if (exc != null) {
                        java.io.StringWriter sw = new java.io.StringWriter();
                        java.io.PrintWriter pw = new java.io.PrintWriter(sw);
                        exc.printStackTrace(pw);
                        out.print(sw.toString().replace("\n", "<br>").replace("\t", "&nbsp;&nbsp;&nbsp;&nbsp;"));
                    }
                %>
            </div>
        <% } %>
        
        <a href="index.jsp" class="btn-gold" style="text-decoration: none; border-radius: 30px; padding: 12px 35px; font-weight: 700; font-size: 0.85rem; letter-spacing: 1.5px; display: inline-flex; align-items: center; gap: 8px; text-transform: uppercase;">
            <i class="fas fa-home"></i> Back to Homepage
        </a>
    </div>

</body>
</html>
