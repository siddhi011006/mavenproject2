<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Retrieve potential error or success parameters
    String error = request.getParameter("error");
    String success = request.getParameter("success");
    
    // Check if session has active admin logged in, if so, redirect immediately
    HttpSession authSess = request.getSession(false);
    if (authSess != null && "ADMIN".equalsIgnoreCase((String) authSess.getAttribute("role"))) {
        response.sendRedirect("admin");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrative Portal Sign In | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;">

    <!-- Split Screen Auth Container -->
    <div class="auth-container">
        
        <!-- Left Side: Brand Splash (Admin Specific) -->
        <div class="auth-sidebar" style="background: linear-gradient(135deg, var(--burgundy), #3a000c); display: flex; flex-direction: column; justify-content: center;">
            <a href="index.jsp" class="logo">LuxeGlow</a>
            <h3 style="font-family:'Playfair Display', serif; color: var(--gold); margin-top:20px; font-size:1.6rem; letter-spacing:1px;">Operations Center</h3>
            <p style="margin-top: 15px; font-size: 0.9rem; line-height:1.6;">Secure administrative panel access for inventory tracking, customer orders, feedback analysis, and catalog management.</p>
            <div style="margin-top: 30px; font-size: 0.8rem; color: var(--gold); border: 1px solid var(--border-color); padding: 15px 25px; border-radius: 12px; background: rgba(0,0,0,0.3); text-align: left;">
                <i class="fas fa-shield-alt" style="margin-right:8px;"></i> Session Activity Logged Securely
            </div>
        </div>

        <!-- Right Side: Secure Login Form -->
        <div class="auth-form-box">
            
            <div style="margin-bottom: 25px;">
                <span class="badge" style="background: rgba(92, 13, 30, 0.08); color: var(--burgundy); font-weight:700;">Secure Portal</span>
            </div>

            <h2 style="font-family:'Playfair Display', serif; margin-bottom:5px; color:var(--text-primary);">Operations Sign In</h2>
            <p class="subtitle">Enter administrative credentials to gain server-level access.</p>

            <!-- Alerts for errors/success -->
            <% if (error != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 25px; padding: 12px 15px; font-size: 0.85rem; text-align: left;">
                    <i class="fas fa-exclamation-circle"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (success != null) { %>
                <div class="alert alert-success" style="margin-bottom: 25px; padding: 12px 15px; font-size: 0.85rem; text-align: left;">
                    <i class="fas fa-check-circle"></i>
                    <span><%= success %></span>
                </div>
            <% } %>

            <!-- Form submits to AdminLoginServlet -->
            <form action="admin-login" method="POST">
                
                <div class="form-group" style="text-align: left;">
                    <label for="email" style="font-weight:600; font-size:0.85rem;">Admin Email Address</label>
                    <input type="email" id="email" name="email" placeholder="admin@luxeglow.com" required style="width: 100%; border-radius: 30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none; margin-top:5px;">
                </div>

                <div class="form-group" style="text-align: left; margin-top: 20px;">
                    <label for="password" style="font-weight:600; font-size:0.85rem;">Access Password</label>
                    <div class="password-wrapper" style="position: relative; margin-top:5px;">
                        <input type="password" id="password" name="password" placeholder="••••••••" required style="padding-right: 40px; width: 100%; border-radius: 30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none;">
                        <i class="far fa-eye toggle-password-btn" id="togglePassword" style="position: absolute; right: 18px; top: 50%; transform: translateY(-50%); cursor: pointer; color: var(--text-muted); font-size: 0.95rem;"></i>
                    </div>
                </div>

                <button type="submit" class="btn-gold" style="width: 100%; border-radius: 30px; margin-top: 25px; padding: 14px; font-weight:700;">
                    REQUEST ENTRY
                </button>
            </form>

            <div style="text-align: center; margin-top: 40px; font-size: 0.8rem; color: var(--text-muted);">
                Authorized personnel only. Direct attempts to bypass will be logged.<br>
                <a href="index.jsp" style="text-decoration: underline; font-weight: 600; color: var(--gold); display: inline-block; margin-top: 10px;">Return to Front Store</a>
            </div>

        </div>

    </div>

    <script>
        // Toggle password visibility
        document.addEventListener('DOMContentLoaded', () => {
            const togglePassword = document.getElementById('togglePassword');
            const passwordInput = document.getElementById('password');
            if (togglePassword && passwordInput) {
                togglePassword.addEventListener('click', () => {
                    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                    passwordInput.setAttribute('type', type);
                    togglePassword.classList.toggle('fa-eye');
                    togglePassword.classList.toggle('fa-eye-slash');
                });
            }
        });
    </script>
</body>
</html>
