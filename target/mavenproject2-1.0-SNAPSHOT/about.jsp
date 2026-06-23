<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%
    Map<String, String> cms = com.mycompany.mavenproject2.CMSHelper.getPageContent("about_");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Header -->
    <section class="hero" style="height: 35vh; min-height: 250px; background: linear-gradient(rgba(250, 248, 245, 0.82), rgba(250, 248, 245, 0.88)), url('<%= heroConfigProps.getProperty("about", "image/bc2.jpg") %>') no-repeat center center/cover;">
        <div class="hero-content">
            <h1 style="font-size: 2.8rem;"><%= cms.getOrDefault("about_hero_title", "About LuxeGlow") %></h1>
            <p><%= cms.getOrDefault("about_hero_subtitle", "We are a modern, minimal, skin-first beauty experience designed for a radiant future.") %></p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 850px; color: var(--text-secondary); font-size: 0.95rem;">
        
        <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 24px; padding: 45px; display: flex; flex-direction: column; gap: 30px; box-shadow: var(--shadow-lux);">
            <div>
                <h3 style="color: var(--burgundy); font-size: 1.4rem; font-family: 'Playfair Display', serif; margin-bottom: 12px;"><%= cms.getOrDefault("about_vision_title", "Our Vision") %></h3>
                <p><%= cms.getOrDefault("about_vision_text", "LuxeGlow was founded on a simple principle: beauty should make you feel confident, radiant, and comfortable in your own skin. We believe in minimal but premium cosmetics that highlight your natural beauty rather than cover it up.") %></p>
            </div>

            <div style="border-top: 1px solid var(--border-light); padding-top: 25px;">
                <h3 style="color: var(--burgundy); font-size: 1.4rem; font-family: 'Playfair Display', serif; margin-bottom: 12px;"><%= cms.getOrDefault("about_formula_title", "Skin-First Formulations") %></h3>
                <p><%= cms.getOrDefault("about_formula_text", "Every LuxeGlow lipstick, serum, and moisturizer is formulated with clean, vegan, and dermatologist-tested ingredients. We harvest skin-loving organic botanical extracts and blend them with cutting-edge active complexes (like hyaluronic acid and vitamin C) to provide long-lasting benefits.") %></p>
            </div>

            <div style="border-top: 1px solid var(--border-light); padding-top: 25px;">
                <h3 style="color: var(--burgundy); font-size: 1.4rem; font-family: 'Playfair Display', serif; margin-bottom: 12px;"><%= cms.getOrDefault("about_promise_title", "Our Ethical Promise") %></h3>
                <p><%= cms.getOrDefault("about_promise_text", "We are 100% certified cruelty-free. We never test on animals and are committed to sourcing sustainable packaging materials to protect our planet for future generations.") %></p>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


