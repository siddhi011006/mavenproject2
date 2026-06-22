<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shipping Policy | LuxeGlow</title>
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
            <h1 style="font-size: 2.5rem;">Shipping Policy</h1>
            <p>Read about our global shipping times, standard rates, and courier partners.</p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 850px; color: var(--text-secondary); font-size: 0.95rem;">
        
        <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 24px; padding: 45px; display: flex; flex-direction: column; gap: 25px; box-shadow: var(--shadow-lux);">
            <div>
                <h3 style="color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;"><i class="fas fa-truck" style="margin-right:10px; color:var(--gold);"></i> Standard & Express Shipping</h3>
                <p>We provide complimentary standard shipping on all orders over <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(1500.0, currentCountry) %>. For orders below <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(1500.0, currentCountry) %>, standard shipping is charged at a flat rate of <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(9.99, currentCountry) %>. Express priority shipping is available during checkout at <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(19.99, currentCountry) %>.</p>
            </div>

            <div style="border-top: 1px solid var(--border-light); padding-top: 25px;">
                <h3 style="color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;"><i class="fas fa-history" style="margin-right:10px; color:var(--gold);"></i> Fulfillment Timeline</h3>
                <p>All orders are processed and packed at our fulfillment centers within 1-2 business days. Standard delivery takes 3-5 business days, and express delivery takes 1-2 business days. You will receive a tracking link via email once your order has shipped.</p>
            </div>

            <div style="border-top: 1px solid var(--border-light); padding-top: 25px;">
                <h3 style="color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;"><i class="fas fa-globe" style="margin-right:10px; color:var(--gold);"></i> International Delivery</h3>
                <p>Currently, LuxeGlow delivers products within North America and selected EU countries. International custom duties and local taxes are calculated and presented at checkout.</p>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


