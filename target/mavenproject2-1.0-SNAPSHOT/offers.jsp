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
            <%@ page import="java.sql.*" %>
            <%@ page import="com.mycompany.mavenproject2.DBConnection" %>
            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                boolean hasOffers = false;
                try {
                    con = DBConnection.getConnection();
                    String sql = "SELECT * FROM offers WHERE is_enabled = 1 ORDER BY display_order ASC, id ASC";
                    ps = con.prepareStatement(sql);
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        hasOffers = true;
                        String title = rs.getString("title");
                        String desc = rs.getString("description");
                        String badge = rs.getString("badge");
                        String code = rs.getString("promo_code");
                        String btnText = rs.getString("button_text");
                        String actionUrl = rs.getString("action_url");
            %>
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px; border-bottom:1px solid var(--border-light); padding-bottom:20px; width: 100%;">
                <div style="flex: 1; min-width: 280px; text-align: left;">
                    <% if (badge != null && !badge.trim().isEmpty()) { %>
                        <span class="badge"><%= badge %></span>
                    <% } %>
                    <h3 style="color:var(--text-primary); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:5px; margin-top:5px;"><%= title %></h3>
                    <p style="margin: 0;"><%= desc %></p>
                </div>
                <div>
                    <% if (code != null && !code.trim().isEmpty()) { %>
                        <div style="border:1px dashed var(--gold); padding:8px 15px; font-weight:600; color:var(--gold); border-radius:6px; letter-spacing:1px; font-size:0.9rem; white-space: nowrap;"><%= code %></div>
                    <% } else if (btnText != null && !btnText.trim().isEmpty() && actionUrl != null && !actionUrl.trim().isEmpty()) { %>
                        <button class="btn-gold" onclick="location.href='<%= actionUrl %>'" style="padding:10px 20px; font-size:0.8rem; border-radius:8px; white-space: nowrap;"><%= btnText %></button>
                    <% } %>
                </div>
            </div>
            <%
                    }
                    if (!hasOffers) {
            %>
            <div style="text-align: center; color: var(--text-muted); padding: 20px 0;">No active promotions available at the moment. Please check back later.</div>
            <%
                    }
                } catch (Exception e) {
                    out.println("<p style='color:var(--danger);'>Error loading offers: " + e.getMessage() + "</p>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                    if (ps != null) try { ps.close(); } catch (Exception e) {}
                    if (con != null) try { con.close(); } catch (Exception e) {}
                }
            %>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>


