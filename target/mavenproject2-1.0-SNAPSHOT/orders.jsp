<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%
    // Ensure authentication
    HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp?error=Please sign in to view your orders.");
        return;
    }

    int userId = (Integer) s.getAttribute("user_id");
    String fullname = (String) s.getAttribute("fullname");
    String email = (String) s.getAttribute("email");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Order History | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Custom Status Badge overrides */
        .status-badge.status-cancelled {
            background: rgba(245, 108, 108, 0.15) !important;
            color: #f56c6c !important;
            border: 1px solid rgba(245, 108, 108, 0.25) !important;
        }
        .status-badge.status-processing {
            background: rgba(230, 162, 60, 0.15) !important;
            color: #e6a23c !important;
            border: 1px solid rgba(230, 162, 60, 0.25) !important;
        }
    </style>
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <div class="page-container" style="max-width: 1000px;">
        
        <!-- Alerts for Operations (Success/Error) -->
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) {
        %>
            <div class="alert alert-success" style="margin-bottom:30px;">
                <i class="fas fa-check-circle"></i>
                <span><%= successMsg %></span>
            </div>
        <%
            }
            if (errorMsg != null) {
        %>
            <div class="alert alert-danger" style="margin-bottom:30px;">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= errorMsg %></span>
            </div>
        <%
            }
        %>

        <div style="margin-bottom: 40px; border-bottom: 1px solid var(--border-light); padding-bottom: 25px; display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h1 style="font-size: 2.2rem; font-family:'Playfair Display', serif; margin-bottom:5px;">My Account</h1>
                <p style="color: var(--text-muted); font-size: 0.9rem;">Manage and track your luxury cosmetic purchases.</p>
            </div>
            <div style="text-align: right; font-size:0.9rem; color:var(--text-secondary);">
                <div><strong><%= fullname %></strong></div>
                <div style="color: var(--gold);"><%= email %></div>
            </div>
        </div>

        <h2 style="font-size: 1.6rem; font-family:'Playfair Display', serif; margin-bottom: 25px; border-bottom:none;">Purchase History</h2>

        <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            int orderCount = 0;

            try {
                con = DBConnection.getConnection();
                String sql = "SELECT id, order_date, total_amount, status, shipping_address, payment_method FROM orders "
                           + "WHERE user_id = ? ORDER BY order_date DESC";
                ps = con.prepareStatement(sql);
                ps.setInt(1, userId);
                rs = ps.executeQuery();

                while (rs.next()) {
                    orderCount++;
                    int orderId = rs.getInt("id");
                    Timestamp orderDate = rs.getTimestamp("order_date");
                    double totalAmount = rs.getDouble("total_amount");
                    String status = rs.getString("status");
                    String shippingAddress = rs.getString("shipping_address");
                    String paymentMethod = rs.getString("payment_method");
                    
                    // Style status badge class
                    String statusClass = "status-pending";
                    if ("SHIPPED".equalsIgnoreCase(status)) {
                        statusClass = "status-shipped";
                    } else if ("COMPLETED".equalsIgnoreCase(status) || "DELIVERED".equalsIgnoreCase(status)) {
                        statusClass = "status-completed";
                    } else if ("CANCELLED".equalsIgnoreCase(status)) {
                        statusClass = "status-cancelled";
                    } else if ("PROCESSING".equalsIgnoreCase(status)) {
                        statusClass = "status-processing";
                    }
        %>
        <!-- Order Card -->
        <div class="order-row-card">
            
            <!-- Order Header Metadata -->
            <div class="order-header-info">
                <div>
                    <span class="order-id">#LXG-<%= orderId %></span>
                    <span style="color: var(--text-muted); font-size: 0.85rem; margin-left: 15px;"><%= orderDate %></span>
                </div>
                <div>
                    <span class="status-badge <%= statusClass %>"><%= status %></span>
                </div>
            </div>

            <!-- Order Items Grid -->
            <div class="order-items-list" style="margin-bottom: 20px;">
                <%
                    Connection itemCon = null;
                    PreparedStatement itemPs = null;
                    ResultSet itemRs = null;
                    try {
                        itemCon = DBConnection.getConnection();
                        String itemSql = "SELECT oi.quantity, oi.price, p.name, p.image_url, pv.variant_name, pv.color_code FROM order_items oi "
                                       + "JOIN products p ON oi.product_id = p.id "
                                       + "LEFT JOIN product_variants pv ON oi.variant_id = pv.id "
                                       + "WHERE oi.order_id = ?";
                        itemPs = itemCon.prepareStatement(itemSql);
                        itemPs.setInt(1, orderId);
                        itemRs = itemPs.executeQuery();
                        while (itemRs.next()) {
                            String prodName = itemRs.getString("name");
                            String prodImage = itemRs.getString("image_url");
                            int qty = itemRs.getInt("quantity");
                            double itemPrice = itemRs.getDouble("price");
                            String variantName = itemRs.getString("variant_name");
                            String colorCode = itemRs.getString("color_code");
                %>
                <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid rgba(255,255,255,0.03); padding:10px 0;">
                    <div style="display:flex; align-items:center; gap:15px;">
                        <img src="<%= prodImage %>" alt="<%= prodName %>" style="width:50px; height:50px; border-radius:8px; object-fit:cover; border:1px solid var(--border-light);">
                        <div>
                            <div style="font-weight:600; font-size:0.9rem; color:var(--text-primary);">
                                <%= prodName %>
                                <% if (variantName != null && !variantName.trim().isEmpty() && !"Standard".equalsIgnoreCase(variantName)) { %>
                                    <span style="font-size:0.75rem; color:var(--gold); font-weight:600; display:flex; align-items:center; gap:5px; margin-top:3px;">
                                        <% if (colorCode != null && colorCode.startsWith("#")) { %>
                                            <span style="display:inline-block; width:8px; height:8px; border-radius:50%; background-color:<%= colorCode %>; border:1px solid rgba(0,0,0,0.15);"></span>
                                        <% } %>
                                        Shade: <%= variantName %>
                                    </span>
                                <% } %>
                            </div>
                            <div style="font-size:0.75rem; color:var(--text-muted);">Qty: <%= qty %> &times; <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(itemPrice, currentCountry) %></div>
                        </div>
                    </div>
                    <div style="font-weight:600; font-size:0.9rem; color:var(--text-secondary);"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(itemPrice * qty, currentCountry) %></div>
                </div>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<p style='color:var(--danger);'>Error loading order items.</p>");
                    } finally {
                        if (itemRs != null) itemRs.close();
                        if (itemPs != null) itemPs.close();
                        if (itemCon != null) itemCon.close();
                    }
                %>
            </div>

            <!-- Shipping & Summary Details -->
            <div style="display:grid; grid-template-columns: 2fr 1fr; gap:20px; font-size:0.85rem; padding-top:15px; border-top:1px solid rgba(255,255,255,0.05);">
                <div style="color: var(--text-secondary);">
                    <div><strong>Shipping Address:</strong> <%= shippingAddress %></div>
                    <div style="margin-top:5px;"><strong>Payment Method:</strong> <%= paymentMethod %></div>
                </div>
                <div style="text-align:right;">
                    <div style="color: var(--text-muted);">Total Cost Charged:</div>
                    <div style="font-size: 1.25rem; font-weight:700; color:var(--gold); margin-top:5px;"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(totalAmount, currentCountry) %></div>
                </div>
            </div>

            <!-- Cancel order button if pending or processing -->
            <% if ("PENDING".equalsIgnoreCase(status) || "PROCESSING".equalsIgnoreCase(status)) { %>
                <div style="display:flex; justify-content:flex-end; margin-top:15px; padding-top:15px; border-top:1px dashed rgba(255,255,255,0.05);">
                    <button class="btn-outline" style="border-radius:20px; padding:8px 24px; font-size:0.8rem; border-color:var(--danger); color:var(--danger); background:transparent; text-transform:none; font-weight: 550;" onclick="openCancelModal(<%= orderId %>)">
                        <i class="fas fa-times-circle" style="margin-right:5px;"></i> Cancel Order
                    </button>
                </div>
            <% } %>

        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<p style='color:var(--danger);'>Database error loading purchase history: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            }

            if (orderCount == 0) {
        %>
            <div style="text-align:center; padding:60px 20px; background:var(--bg-card); border:1px solid var(--border-light); border-radius:20px;">
                <i class="fas fa-history" style="font-size:3rem; color:var(--gold); margin-bottom:20px; opacity:0.5;"></i>
                <h3 style="font-size:1.3rem; margin-bottom:10px;">No Orders Placed Yet</h3>
                <p style="color:var(--text-secondary); margin-bottom:20px;">You haven't placed any cosmetic orders on our platform.</p>
                <a href="product.jsp" class="btn-gold">Start Shopping</a>
            </div>
        <%
            }
        %>

    </div>

    <!-- Cancellation Confirmation Dialog -->
    <div id="cancelModal" class="modal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); z-index:2000; justify-content:center; align-items:center; backdrop-filter: blur(5px);">
        <div class="modal-content" style="background:var(--bg-card); border:1px solid var(--border-color); border-radius:24px; padding:35px; width:92%; max-width:480px; box-shadow:var(--shadow-lux); text-align:left; position:relative;">
            <span style="position:absolute; top:20px; right:20px; font-size:1.5rem; cursor:pointer; color:var(--text-muted);" onclick="closeCancelModal()">&times;</span>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.5rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:20px;">
                Cancel Order Request
            </h3>
            <p style="font-size:0.85rem; color:var(--text-secondary); margin-bottom:20px;">
                Are you sure you want to cancel order <strong id="cancel-order-ref" style="color:var(--gold);"></strong>? This action will refund your purchase and restock items back into inventory.
            </p>
            <form id="cancelForm" action="CancelOrderServlet" method="POST">
                <input type="hidden" name="orderId" id="cancel-order-id">
                
                <div class="form-group" style="margin-bottom:20px;">
                    <label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:8px; color:var(--text-primary);">Reason for Cancellation</label>
                    <select name="reason" id="cancel-reason-select" onchange="toggleCustomExplanation()" required style="width:100%; border-radius:12px; padding:12px 16px; border:1px solid var(--border-color); background:var(--bg-dark); color:var(--text-primary); font-size:0.9rem; outline:none;">
                        <option value="" disabled selected>Please select a reason...</option>
                        <option value="Ordered by mistake">Ordered by mistake</option>
                        <option value="Found a better alternative">Found a better alternative</option>
                        <option value="Delivery time too long">Delivery time too long</option>
                        <option value="Price issue">Price issue</option>
                        <option value="Changed my mind">Changed my mind</option>
                        <option value="Other">Other</option>
                    </select>
                </div>

                <div class="form-group" id="custom-explanation-group" style="display:none; margin-bottom:20px;">
                    <label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:8px; color:var(--text-primary);">Please explain</label>
                    <textarea name="customReason" id="cancel-custom-reason" rows="3" placeholder="Enter custom cancellation explanation..." style="width:100%; border-radius:12px; padding:12px; border:1px solid var(--border-color); background:var(--bg-dark); color:var(--text-primary); font-size:0.9rem; resize:vertical; outline:none;"></textarea>
                </div>

                <button type="submit" class="btn-gold" style="width:100%; border-radius:30px; padding:12px; font-size:0.9rem; font-weight:600; margin:0;">
                    Confirm Order Cancellation
                </button>
            </form>
        </div>
    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>

    <script>
        function openCancelModal(orderId) {
            document.getElementById('cancel-order-id').value = orderId;
            document.getElementById('cancel-order-ref').innerText = '#LXG-' + orderId;
            document.getElementById('cancel-reason-select').selectedIndex = 0;
            document.getElementById('custom-explanation-group').style.display = 'none';
            document.getElementById('cancel-custom-reason').value = '';
            document.getElementById('cancelModal').style.display = 'flex';
        }
        function closeCancelModal() {
            document.getElementById('cancelModal').style.display = 'none';
        }
        function toggleCustomExplanation() {
            const select = document.getElementById('cancel-reason-select');
            const group = document.getElementById('custom-explanation-group');
            const textarea = document.getElementById('cancel-custom-reason');
            if (select.value === 'Other') {
                group.style.display = 'block';
                textarea.setAttribute('required', 'required');
            } else {
                group.style.display = 'none';
                textarea.removeAttribute('required');
            }
        }

        // Close modal on outer clicks
        window.onclick = function(event) {
            const cancelM = document.getElementById('cancelModal');
            if (event.target == cancelM) {
                closeCancelModal();
            }
        }
    </script>
</body>
</html>
