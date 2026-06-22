<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied | LuxeGlow</title>
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; background: radial-gradient(circle at center, #1c0207 0%, #0c0003 100%); font-family: 'Inter', sans-serif; color: #FFFFFF;">
    
    <div style="background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.07); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); padding: 50px; border-radius: 24px; max-width: 500px; text-align: center; box-shadow: var(--shadow-lux);">
        <div style="width: 80px; height: 80px; background: rgba(92, 13, 30, 0.2); border: 1px solid var(--burgundy); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 30px;">
            <i class="fas fa-shield-alt" style="font-size: 2.2rem; color: #E23E57;"></i>
        </div>
        
        <h1 style="font-family: 'Playfair Display', serif; font-size: 2.2rem; font-weight: 700; color: var(--gold); margin-bottom: 15px; letter-spacing: 1px;">Access Denied</h1>
        <p style="color: var(--text-secondary); font-size: 0.95rem; line-height: 1.6; margin-bottom: 35px;">
            Your account does not possess the administrative privileges required to access this portal. All restricted attempts are securely logged.
        </p>
        
        <div style="display: flex; gap: 15px; justify-content: center;">
            <a href="index.jsp" class="btn-outline" style="text-decoration: none; border-radius: 30px; padding: 12px 30px; font-weight: 600; font-size: 0.85rem; letter-spacing: 1px; display: inline-flex; align-items: center; gap: 8px; color: var(--text-primary); border-color: var(--border-color);">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="login.jsp" class="btn-gold" style="text-decoration: none; border-radius: 30px; padding: 12px 30px; font-weight: 700; font-size: 0.85rem; letter-spacing: 1px; display: inline-flex; align-items: center; gap: 8px;">
                <i class="fas fa-sign-in-alt"></i> Sign In
            </a>
        </div>
    </div>

</body>
</html>
