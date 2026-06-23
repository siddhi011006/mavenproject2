<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%
    Map<String, String> cms = com.mycompany.mavenproject2.CMSHelper.getPageContent("terms_");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms & Conditions | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Header -->
    <section class="hero" style="height: 30vh; min-height: 200px; background: linear-gradient(rgba(250, 248, 245, 0.82), rgba(250, 248, 245, 0.88)), url('<%= heroConfigProps.getProperty("terms", "image/bc2.jpg") %>') no-repeat center center/cover;">
        <div class="hero-content">
            <h1 style="font-size: 2.5rem;"><%= cms.getOrDefault("terms_hero_title", "Terms & Conditions") %></h1>
            <p><%= cms.getOrDefault("terms_hero_subtitle", "Please review our client usage guidelines and terms of service.") %></p>
        </div>
    </section>

    <!-- Page Content -->
    <div class="page-container" style="max-width: 850px; color: var(--text-secondary); font-size: 0.95rem;">
        
        <div style="background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 24px; padding: 45px; display: flex; flex-direction: column; gap: 25px; box-shadow: var(--shadow-lux);">
            <%= cms.getOrDefault("terms_content_html", 
                "<div>\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\">1. Usage of Platform</h3>\n" +
                "    <p>By registering an account and placing an order on LuxeGlow, you agree to submit accurate, current, and complete personal and billing information.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\">2. Prices & Catalog Details</h3>\n" +
                "    <p>We strive to represent colors and formulations accurately on our platform. We reserve the right to modify cosmetic specifications, inventory stock levels, or adjust pricing without prior notification.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\">3. Intellectual Property</h3>\n" +
                "    <p>All brand marks, editorial copy, product names, logos, custom illustrations, and graphics on this website are the property of LuxeGlow Cosmetics Inc. and may not be reproduced without written permission.</p>\n" +
                "</div>"
            ) %>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


