<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Header -->
    <section class="hero" style="height: 30vh; min-height: 200px;">
        <div class="hero-content">
            <h1 style="font-size: 2.5rem;">Privacy Policy</h1>
            <p>Your privacy and safety are extremely important to us. Learn how we secure your data.</p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 800px; color:var(--text-secondary); font-size:0.95rem;">
        
        <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 24px; padding: 40px; display:flex; flex-direction:column; gap:25px; box-shadow: var(--shadow-lux);">
            <div>
                <h3 style="color:var(--burgundy); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;">1. Information We Collect</h3>
                <p>We collect personal details (such as your name, email address, delivery address, and payment method options) during checkout or account registration to fulfill your orders and provide account features.</p>
            </div>

            <div>
                <h3 style="color:var(--burgundy); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;">2. How We Secure Your Data</h3>
                <p>All database connections and transactions are encrypted. We do not store cardholder credentials on our local servers; payments are processed securely through certified gateways.</p>
            </div>

            <div>
                <h3 style="color:var(--burgundy); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;">3. Cookie Utilization</h3>
                <p>Our website utilizes local cookies to manage active shopping sessions, preserve guest shopping bag selections, and remember login preferences.</p>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


