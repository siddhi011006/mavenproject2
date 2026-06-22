<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%
    // Ensure authentication
    HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) s.getAttribute("user_id");
    String orderIdStr = request.getParameter("orderId");
    if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdStr);

    double totalAmount = 0.0;
    Timestamp orderDate = null;
    String shippingAddress = "";
    String paymentMethod = "";
    String customerName = "";
    String customerEmail = "";
    boolean found = false;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = DBConnection.getConnection();
        String sql = "SELECT o.total_amount, o.order_date, o.shipping_address, o.payment_method, u.fullname, u.email "
                   + "FROM orders o JOIN users u ON o.user_id = u.id "
                   + "WHERE o.id = ? AND o.user_id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, orderId);
        ps.setInt(2, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            found = true;
            totalAmount = rs.getDouble("total_amount");
            orderDate = rs.getTimestamp("order_date");
            shippingAddress = rs.getString("shipping_address");
            paymentMethod = rs.getString("payment_method");
            customerName = rs.getString("fullname");
            customerEmail = rs.getString("email");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }

    if (!found) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Calculate delivery estimate: 4 days from order date
    java.util.Calendar cal = java.util.Calendar.getInstance();
    if (orderDate != null) {
        cal.setTimeInMillis(orderDate.getTime());
    }
    cal.add(java.util.Calendar.DAY_OF_YEAR, 4);
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy");
    String deliveryEstStr = sdf.format(cal.getTime());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thank You for Your Order | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <div class="page-container">
        
        <!-- Confirmation Summary Card -->
        <div class="confirmation-card">
            <i class="fas fa-check-circle"></i>
            <h1>Order Placed Successfully!</h1>
            <% if (com.mycompany.mavenproject2.EmailUtility.isConfigured()) { %>
            <p>Thank you for choosing LuxeGlow. We have sent an email confirmation to <strong><%= customerEmail %></strong> with order details and tracking updates.</p>
            <% } else { %>
            <p>Thank you for choosing LuxeGlow. Your order has been placed successfully. (Email confirmation is currently offline).</p>
            <% } %>

            <div class="order-details-summary">
                <h3 style="font-family:'Playfair Display', serif; font-size:1.15rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:15px;">
                    Receipt Invoice
                </h3>
                <div>
                    <span style="color: var(--text-muted);">Order Reference ID:</span>
                    <span style="font-weight:600; color:var(--gold);">#LXG-<%= orderId %></span>
                </div>
                <div>
                    <span style="color: var(--text-muted);">Order Date:</span>
                    <span><%= orderDate %></span>
                </div>
                <div>
                    <span style="color: var(--text-muted);">Estimated Delivery:</span>
                    <span style="font-weight:600; color:var(--success);"><i class="fas fa-truck" style="margin-right:5px; font-size:0.85rem;"></i><%= deliveryEstStr %></span>
                </div>
                <div>
                    <span style="color: var(--text-muted);">Customer Name:</span>
                    <span><%= customerName %></span>
                </div>
                <div>
                    <span style="color: var(--text-muted);">Shipping Address:</span>
                    <span style="max-width:250px; text-align:right;"><%= shippingAddress %></span>
                </div>
                <div>
                    <span style="color: var(--text-muted);">Payment Method:</span>
                    <span><%= paymentMethod %></span>
                </div>
                <div style="border-top:1px solid var(--border-light); padding-top:10px; margin-top:10px; font-weight:700; font-size:1.05rem;">
                    <span>Total Charged:</span>
                    <span style="color:var(--gold); font-size:1.2rem;"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(totalAmount, currentCountry) %></span>
                </div>
            </div>

            <div style="display:flex; justify-content:center; gap:20px;">
                <a href="orders.jsp" class="btn-outline" style="border-radius:12px; font-size:0.85rem; padding:12px 24px;">Track Order</a>
                <a href="product.jsp" class="btn-gold" style="border-radius:12px; font-size:0.85rem; padding:12px 24px;">Continue Shopping</a>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <footer>
        <div class="footer-logo">LuxeGlow</div>
        <p>&copy; <span id="year"></span> LuxeGlow. All Rights Reserved.</p>
    </footer>

    <script>
        document.getElementById('year').textContent = new Date().getFullYear();
    </script>
</body>
</html>

