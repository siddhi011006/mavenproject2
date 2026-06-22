<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Frequently Asked Questions | LuxeGlow</title>
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
            <h1 style="font-size: 2.5rem;">Client FAQs</h1>
            <p>Answers to your questions about our luxury formulas, order delivery, and shade matching.</p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 800px;">
        
        <div style="display:flex; flex-direction:column; gap:20px; margin-top:20px;">
            <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;">
                <h3 style="color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;"><i class="fas fa-question-circle" style="margin-right:10px; color:var(--gold);"></i> Are LuxeGlow products organic?</h3>
                <p style="color:var(--text-secondary); font-size:0.9rem;">Yes. All of our formulations are crafted from premium skin-loving, organic botanical extracts, and are completely free of sulfates, parabens, and synthetic fillers.</p>
            </div>

            <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;">
                <h3 style="color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;"><i class="fas fa-question-circle" style="margin-right:10px; color:var(--gold);"></i> How do I choose the correct foundation shade?</h3>
                <p style="color:var(--text-secondary); font-size:0.9rem;">Our beauty concierge offers free shade-matching advice. You can send us a message through our <a href="contact.jsp" style="text-decoration:underline;">Contact Page</a>, selecting "Product Shade Matching Advice", and our experts will reply within 24 hours.</p>
            </div>

            <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;">
                <h3 style="color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;"><i class="fas fa-question-circle" style="margin-right:10px; color:var(--gold);"></i> When will my order ship?</h3>
                <p style="color:var(--text-secondary); font-size:0.9rem;">Orders are typically processed and shipped within 1-2 business days. Once shipped, you will receive a tracking link via email. Standard shipping takes 3-5 business days.</p>
            </div>

            <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;">
                <h3 style="color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;"><i class="fas fa-question-circle" style="margin-right:10px; color:var(--gold);"></i> What is your return policy?</h3>
                <p style="color:var(--text-secondary); font-size:0.9rem;">We offer a 30-day hassle-free return and shade exchange policy. If a foundation or lipstick shade isn't perfect for you, we will send you an exchange free of shipping charges.</p>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


