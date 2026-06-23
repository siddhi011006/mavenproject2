<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Return & Refund Policy | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Header -->
    <section class="hero" style="height: 30vh; min-height: 200px; background: linear-gradient(rgba(250, 248, 245, 0.82), rgba(250, 248, 245, 0.88)), url('<%= heroConfigProps.getProperty("returns-policy", "image/bc2.jpg") %>') no-repeat center center/cover;">
        <div class="hero-content">
            <h1 style="font-size: 2.5rem;">Return & Refund Policy</h1>
            <p>Our commitment to your satisfaction. Free shade exchanges within 30 days.</p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 850px; color: var(--text-secondary); font-size: 0.95rem;">
        
        <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 24px; padding: 45px; display: flex; flex-direction: column; gap: 25px; box-shadow: var(--shadow-lux);">
            <div>
                <h3 style="color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;"><i class="fas fa-undo-alt" style="margin-right:10px; color:var(--gold);"></i> 30-Day Free Return & Exchange</h3>
                <p>We want you to love your skincare and makeup items. If a product shade is not perfect or does not suit your skin, you can request a return or free shade exchange within 30 days of receiving your package.</p>
            </div>

            <div style="border-top: 1px solid var(--border-light); padding-top: 25px;">
                <h3 style="color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;"><i class="fas fa-box-open" style="margin-right:10px; color:var(--gold);"></i> Condition Requirements</h3>
                <p>To qualify for a refund, products must be returned in their original packaging, gently used (less than 25% used), or unopened. Gift cards, promo samples, and clearance items are non-refundable.</p>
            </div>

            <div style="border-top: 1px solid var(--border-light); padding-top: 25px;">
                <h3 style="color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;"><i class="fas fa-receipt" style="margin-right:10px; color:var(--gold);"></i> Processing Refunds</h3>
                <p>Refunds are processed back to your original payment method (Credit Card, Net Banking, or UPI) within 5-7 business days after our fulfillment center receives and inspects the return package.</p>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


