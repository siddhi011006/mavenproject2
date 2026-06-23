<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shipping & Returns | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Header -->
    <section class="hero" style="height: 30vh; min-height: 200px; background: linear-gradient(rgba(250, 248, 245, 0.82), rgba(250, 248, 245, 0.88)), url('<%= heroConfigProps.getProperty("shipping", "image/bc2.jpg") %>') no-repeat center center/cover;">
        <div class="hero-content">
            <h1 style="font-size: 2.5rem;">Shipping & Returns</h1>
            <p>Read about our global shipping times and shade exchanges.</p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 800px; color:var(--text-secondary); font-size:0.95rem;">
        
        <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 20px; padding: 40px; display:flex; flex-direction:column; gap:25px;">
            <div>
                <h3 style="color:var(--gold); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;"><i class="fas fa-shipping-fast" style="margin-right:10px;"></i> Shipping Rates & Methods</h3>
                <p>We offer complimentary standard shipping on orders over <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(1500.0, currentCountry) %>. For orders below <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(1500.0, currentCountry) %>, standard shipping is charged at a flat rate of <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(9.99, currentCountry) %>. Processing takes 1-2 business days, and shipping takes 3-5 business days.</p>
            </div>

            <div>
                <h3 style="color:var(--gold); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;"><i class="fas fa-undo-alt" style="margin-right:10px;"></i> Hassle-Free Returns</h3>
                <p>If you are not completely satisfied with your luxury purchase or foundation shade match, we offer free returns and exchanges within 30 days of shipment. Contact our concierge mail desk for return slips.</p>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


