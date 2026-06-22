<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Check for success or error attributes/parameters
    String error = (String) request.getAttribute("error");
    if (error == null) {
        error = request.getParameter("error");
    }

    String success = request.getParameter("success");
    String redirectVal = request.getParameter("redirect");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In to Your Account | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;">

    <!-- Split Screen Auth Container -->
    <div class="auth-container">
        
        <!-- Left Side: Brand Splash -->
        <div class="auth-sidebar">
            <a href="index.jsp" class="logo">LuxeGlow</a>
            <p>"Indulge in a blend of radiance and luxury through curated skincare, premium cosmetics, and holistic wellness."</p>
            <div style="margin-top: 30px; font-size: 0.8rem; color: var(--gold); border: 1px solid var(--border-color); padding: 15px 25px; border-radius: 12px; background: rgba(0,0,0,0.2);">
                <i class="fas fa-sparkles" style="margin-right:8px;"></i> Certified Cruelty-Free & Vegan
            </div>
        </div>

        <!-- Right Side: Forms -->
        <div class="auth-form-box">
            
            <div class="auth-toggle-links">
                <a href="login.jsp" class="active">Sign In</a>
                <a href="register.jsp">Register</a>
            </div>

            <h2>Welcome Back</h2>
            <p class="subtitle">Please enter your credentials to access your profile.</p>

            <!-- Alerts for errors/success -->
            <% if (error != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 25px; padding: 12px 15px; font-size: 0.85rem;">
                    <i class="fas fa-exclamation-circle"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (success != null) { %>
                <div class="alert alert-success" style="margin-bottom: 25px; padding: 12px 15px; font-size: 0.85rem;">
                    <i class="fas fa-check-circle"></i>
                    <span><%= success %></span>
                </div>
            <% } %>

            <!-- Form submits to alogin -->
            <form action="alogin" method="POST">
                <% if (redirectVal != null && !redirectVal.trim().isEmpty()) { %>
                    <input type="hidden" name="redirect" value="<%= redirectVal %>">
                <% } %>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" placeholder="name@example.com" value="<%= (request.getAttribute("email") != null) ? request.getAttribute("email") : "" %>" required>
                </div>

                <div class="form-group">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 8px;">
                        <label style="margin-bottom:0;">Password</label>
                        <a href="reset-password.jsp" style="font-size:0.75rem; font-weight:600; text-transform:uppercase; letter-spacing:0.5px; color:var(--gold);">Forgot Password?</a>
                    </div>
                    <div class="password-wrapper">
                        <input type="password" id="password" name="password" placeholder="••••••••" required style="padding-right: 40px; width: 100%;">
                        <i class="far fa-eye toggle-password-btn" id="togglePassword"></i>
                    </div>
                </div>

                <button type="submit" class="btn-gold" style="width: 100%; border-radius: 12px; margin-top: 15px; padding: 14px;">
                    SIGN IN
                </button>

                <div style="text-align: center; margin: 25px 0; font-size: 0.75rem; color: var(--text-muted); position: relative;">
                    <span style="background: var(--bg-surface); padding: 0 10px; z-index: 1; position: relative; text-transform: uppercase; letter-spacing: 1px;">Or Continue With</span>
                    <div style="position: absolute; top: 50%; left: 0; width: 100%; height: 1px; background: var(--border-light); z-index: 0;"></div>
                </div>

                <!-- Mock OAuth links -->
                <div style="display:flex; gap:12px;">
                    <button type="button" class="btn-outline" style="flex:1; font-size:0.8rem; border-radius:12px; padding:10px;" onclick="showToast('Google login is a demo feature.', 'warning')">
                        <i class="fab fa-google" style="margin-right:8px;"></i> Google
                    </button>
                    <button type="button" class="btn-outline" style="flex:1; font-size:0.8rem; border-radius:12px; padding:10px;" onclick="showToast('Apple ID is a demo feature.', 'warning')">
                        <i class="fab fa-apple" style="margin-right:8px;"></i> Apple
                    </button>
                </div>
            </form>

            <div style="text-align: center; margin-top: 35px; font-size: 0.85rem; color: var(--text-muted);">
                Don't have an account? 
                <a href="register.jsp" style="text-decoration: underline; font-weight: 600;">Create Account</a>
            </div>

        </div>

    </div>

    <!-- Dynamic Toast Notification Hook -->
    <div id="toast-container" style="position: fixed; bottom: 25px; right: 25px; z-index: 10000; display: flex; flex-direction: column; gap: 10px; pointer-events: none;"></div>
    <script>
        function showToast(message, type = 'success') {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.style.cssText = 'pointer-events: auto; display: flex; align-items: center; gap: 12px; padding: 16px 24px; border-radius: 12px; font-weight: 500; font-size: 0.9rem; border: 1px solid var(--border-color); background: rgba(20, 14, 16, 0.95); backdrop-filter: blur(10px); box-shadow: var(--shadow-lux); color: white; min-width: 280px; transform: translateY(20px); opacity: 0; transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);';
            let icon = 'fa-check-circle';
            let iconColor = 'var(--gold)';
            if (type === 'danger') { icon = 'fa-exclamation-circle'; iconColor = '#f56c6c'; }
            else if (type === 'warning') { icon = 'fa-exclamation-triangle'; iconColor = '#e6a23c'; }
            toast.innerHTML = `<i class="fas ${icon}" style="color: ${iconColor}; font-size: 1.1rem;"></i><span>${message}</span>`;
            container.appendChild(toast);
            setTimeout(() => { toast.style.transform = 'translateY(0)'; toast.style.opacity = '1'; }, 50);
            setTimeout(() => {
                toast.style.transform = 'translateY(-20px)';
                toast.style.opacity = '0';
                setTimeout(() => toast.remove(), 400);
            }, 3500);
        }

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
