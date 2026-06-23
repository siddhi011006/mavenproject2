<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exclusive Offers | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Header -->
    <section class="hero" style="height: 30vh; min-height: 200px; background: linear-gradient(rgba(250, 248, 245, 0.82), rgba(250, 248, 245, 0.88)), url('<%= heroConfigProps.getProperty("offers", "image/bc2.jpg") %>') no-repeat center center/cover;">
        <div class="hero-content">
            <h1 style="font-size: 2.5rem;">LuxeGlow Offers</h1>
            <p>Unlock limited-time discounts on luxury cosmetics, bundle deals, and free gifts.</p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 800px; color:var(--text-secondary); font-size:0.95rem;">
        
        <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 20px; padding: 40px; display:flex; flex-direction:column; gap:30px;">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px; border-bottom:1px solid var(--border-light); padding-bottom:20px;">
                <div>
                    <span class="badge">BOGO 50%</span>
                    <h3 style="color:var(--text-primary); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:5px; margin-top:5px;">The Glow Bundle</h3>
                    <p>Buy 1 Get 1 50% Off on all skincare serums and moisturizers. Applied automatically at checkout.</p>
                </div>
                <button class="btn-gold" onclick="location.href='product.jsp?category=serums'" style="padding:10px 20px; font-size:0.8rem; border-radius:8px;">Claim Bundle</button>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px; border-bottom:1px solid var(--border-light); padding-bottom:20px;">
                <div>
                    <span class="badge">Promo Code</span>
                    <h3 style="color:var(--text-primary); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:5px; margin-top:5px;">First Order Welcome</h3>
                    <p>Use code <strong>GLOW15</strong> at checkout to take 15% off your very first luxury beauty order.</p>
                </div>
                <div style="border:1px dashed var(--gold); padding:8px 15px; font-weight:600; color:var(--gold); border-radius:6px; letter-spacing:1px; font-size:0.9rem;">GLOW15</div>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px; padding-bottom:10px;">
                <div>
                    <span class="badge">Free Gift</span>
                    <h3 style="color:var(--text-primary); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:5px; margin-top:5px;">Deluxe Skincare Minis</h3>
                    <p>Receive a complimentary travel-size glow serum with any purchase over $60. Added automatically to qualified orders.</p>
                </div>
                <button class="btn-gold" onclick="location.href='product.jsp'" style="padding:10px 20px; font-size:0.8rem; border-radius:8px;">Shop Catalog</button>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


