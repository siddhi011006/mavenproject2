<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%
    // Ensure authentication & admin privileges
    HttpSession s = request.getSession(false);
    if (s == null || !"ADMIN".equalsIgnoreCase((String) s.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
        return;
    }

    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.trim().isEmpty()) {
        activeTab = "dashboard";
    }

    // Retrieve variables from request attributes set by AdminDashboardServlet
    Double totalRevenueAttr = (Double) request.getAttribute("totalRevenue");
    Integer totalOrdersAttr = (Integer) request.getAttribute("totalOrdersCount");
    Integer totalUsersAttr = (Integer) request.getAttribute("totalUsersCount");
    Integer totalProductsAttr = (Integer) request.getAttribute("totalProductsCount");
    Integer newUsersThisMonthAttr = (Integer) request.getAttribute("newUsersThisMonth");

    double totalRevenue = totalRevenueAttr != null ? totalRevenueAttr : 0.0;
    int totalOrdersCount = totalOrdersAttr != null ? totalOrdersAttr : 0;
    int totalUsersCount = totalUsersAttr != null ? totalUsersAttr : 0;
    int totalProductsCount = totalProductsAttr != null ? totalProductsAttr : 0;
    int newUsersThisMonth = newUsersThisMonthAttr != null ? newUsersThisMonthAttr : 0;

    List<String> categoriesList = (List<String>) request.getAttribute("categoriesList");
    if (categoriesList == null) {
        categoriesList = new ArrayList<>();
    }
    List<Map<String, Object>> recentOrdersList = (List<Map<String, Object>>) request.getAttribute("recentOrdersList");
    if (recentOrdersList == null) {
        recentOrdersList = new ArrayList<>();
    }
    List<Map<String, Object>> monthlySalesList = (List<Map<String, Object>>) request.getAttribute("monthlySalesList");
    List<Map<String, Object>> bestSellersList = (List<Map<String, Object>>) request.getAttribute("bestSellersList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Operations Control Panel | LuxeGlow Admin</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <!-- Chart.js for High-End Interactive Widgets -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .admin-sidebar button {
            cursor: pointer;
        }
        .variants-sub-table th, .variants-sub-table td {
            padding: 8px 12px;
            font-size: 0.8rem;
        }
        .variants-sub-table th {
            border-bottom: 1px solid var(--border-light);
            color: var(--text-muted);
            font-weight: 600;
        }
        .variant-color-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            border: 1px solid rgba(0,0,0,0.15);
            margin-right: 6px;
            vertical-align: middle;
        }
    </style>
</head>
<body>

    <div class="announcement-bar">
        <p>LuxeGlow Operations Center — Secure Administrator Area</p>
    </div>

    <!-- Include Glassmorphic Header -->
    <%@ include file="../navbar.jsp" %>

    <div class="page-container" style="max-width:1350px;">
        
        <!-- Alerts for Operation Messages -->
        <%
            String errorMsg = request.getParameter("error");
            String successMsg = request.getParameter("success");
            if (errorMsg != null) {
        %>
            <div class="alert alert-danger" style="margin-bottom:30px;">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= errorMsg %></span>
            </div>
        <%
            }
            if (successMsg != null) {
        %>
            <div class="alert alert-success" style="margin-bottom:30px;">
                <i class="fas fa-check-circle"></i>
                <span><%= successMsg %></span>
            </div>
        <%
            }
        %>

        <h1 style="font-size:2.2rem; font-family:'Playfair Display', serif; margin-bottom:45px; border-bottom:1px solid var(--border-light); padding-bottom:15px; text-align:left;">
            <i class="fas fa-sliders-h" style="color:var(--gold); margin-right:12px;"></i> Operations Control Panel
        </h1>

        <!-- Sidebar + View Layout -->
        <div class="admin-grid">
            
            <!-- Side Navigation Menu -->
            <aside class="admin-sidebar">
                <ul>
                    <li>
                        <button class="<%= "dashboard".equals(activeTab) ? "active" : "" %>" onclick="location.href='admin?tab=dashboard'">
                            <i class="fas fa-chart-line"></i> Dashboard
                        </button>
                    </li>
                    <li>
                        <button class="<%= "products".equals(activeTab) ? "active" : "" %>" onclick="location.href='admin?tab=products'">
                            <i class="fas fa-box"></i> Catalog Manager
                        </button>
                    </li>
                    <li>
                        <button class="<%= "orders".equals(activeTab) ? "active" : "" %>" onclick="location.href='admin?tab=orders'">
                            <i class="fas fa-receipt"></i> Order Fulfillment
                        </button>
                    </li>
                    <li>
                        <button class="<%= "users".equals(activeTab) ? "active" : "" %>" onclick="location.href='admin?tab=users'">
                            <i class="fas fa-users-cog"></i> User Management
                        </button>
                    </li>
                    <li>
                        <button class="<%= "reports".equals(activeTab) ? "active" : "" %>" onclick="location.href='admin?tab=reports'">
                            <i class="fas fa-file-invoice-dollar"></i> Sales Reports
                        </button>
                    </li>
                    <li>
                        <button class="<%= "settings".equals(activeTab) ? "active" : "" %>" onclick="location.href='admin?tab=settings'">
                            <i class="fas fa-cogs"></i> System Settings
                        </button>
                    </li>
                    <li style="margin-top:20px; border-top:1px solid var(--border-light); padding-top:15px;">
                        <button style="color:var(--danger);" onclick="if(confirm('Sign out of Admin Session?')) location.href='admin-logout';">
                            <i class="fas fa-sign-out-alt" style="color:var(--danger);"></i> Log Out
                        </button>
                    </li>
                </ul>
            </aside>

            <!-- Main Panel View -->
            <main>
                
                <% if ("dashboard".equalsIgnoreCase(activeTab)) { %>
                    <!-- ==========================================
                         DASHBOARD SUMMARY TAB
                         ========================================== -->
                    <!-- Stats Counter Cards Row -->
                    <section class="admin-stats-row">
                        <div class="stat-card">
                            <i class="fas fa-wallet"></i>
                            <div class="num">₹<%= String.format("%.2f", totalRevenue) %></div>
                            <div class="label">Total Revenue</div>
                        </div>
                        <div class="stat-card">
                            <i class="fas fa-shopping-bag"></i>
                            <div class="num"><%= totalOrdersCount %></div>
                            <div class="label">Total Orders</div>
                        </div>
                        <div class="stat-card">
                            <i class="fas fa-users"></i>
                            <div class="num"><%= totalUsersCount %></div>
                            <div class="label">Registered Users</div>
                        </div>
                        <div class="stat-card">
                            <i class="fas fa-box"></i>
                            <div class="num"><%= totalProductsCount %></div>
                            <div class="label">Total Products</div>
                        </div>
                    </section>

                    <div style="display:grid; grid-template-columns:1.5fr 1fr; gap:30px; margin-top:20px; text-align:left;">
                        <!-- Recent Orders Column -->
                        <div>
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                                <h3 style="font-size:1.3rem; border-bottom:none; margin:0;">Recent Client Transactions</h3>
                                <a href="admin?tab=orders" style="font-size:0.8rem; font-weight:600; text-transform:uppercase; color:var(--gold);">View All Orders</a>
                            </div>

                            <table class="admin-table" style="margin-top:0;">
                                <thead>
                                    <tr>
                                        <th>Ref</th>
                                        <th>Customer</th>
                                        <th>Date</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                        <th style="text-align:right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (recentOrdersList.isEmpty()) {
                                    %>
                                    <tr>
                                        <td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">No recent orders recorded.</td>
                                    </tr>
                                    <%
                                        } else {
                                            for (Map<String, Object> order : recentOrdersList) {
                                                int id = (Integer) order.get("id");
                                                java.util.Date date = (java.util.Date) order.get("date");
                                                double amt = (Double) order.get("total");
                                                String status = (String) order.get("status");
                                                String customer = (String) order.get("customer");
                                                String address = (String) order.get("address");

                                                String badgeClass = "status-pending";
                                                if ("PROCESSING".equalsIgnoreCase(status)) badgeClass = "status-processing";
                                                else if ("SHIPPED".equalsIgnoreCase(status)) badgeClass = "status-shipped";
                                                else if ("DELIVERED".equalsIgnoreCase(status)) badgeClass = "status-completed";
                                                else if ("CANCELLED".equalsIgnoreCase(status)) badgeClass = "status-cancelled";
                                    %>
                                    <tr>
                                        <td style="font-weight:600; color:var(--gold);">#LXG-<%= id %></td>
                                        <td><%= customer %></td>
                                        <td style="font-size:0.75rem;"><%= date %></td>
                                        <td style="font-weight:600;">₹<%= String.format("%.2f", amt) %></td>
                                        <td><span class="status-badge <%= badgeClass %>"><%= status %></span></td>
                                        <td style="text-align:right;">
                                            <button class="btn-outline" style="border-radius:6px; padding:6px 12px; font-size:0.75rem; text-transform:none;" onclick="showOrderDetails(<%= id %>)">
                                                View Items
                                            </button>

                                            <!-- Render Hidden Container for JavaScript Modal Extraction -->
                                            <div id="orderDetails-<%= id %>" style="display:none;">
                                                <div style="margin-bottom:15px; font-size: 0.85rem; line-height: 1.5;">
                                                    <strong>Order Ref:</strong> #LXG-<%= id %><br>
                                                    <strong>Customer:</strong> <%= customer %><br>
                                                    <strong>Order Date:</strong> <%= date %><br>
                                                    <strong>Shipping Address:</strong> <%= address %>
                                                </div>
                                                <h4 style="font-family:'Playfair Display', serif; border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:12px; font-size:1.1rem; color:var(--burgundy);">Purchased Cosmetics</h4>
                                                <div style="max-height:220px; overflow-y:auto; margin-bottom:15px;">
                                                <%
                                                    try (Connection con = DBConnection.getConnection();
                                                         PreparedStatement ps = con.prepareStatement(
                                                             "SELECT oi.quantity, oi.price, p.name, p.image_url, pv.variant_name FROM order_items oi " +
                                                             "JOIN products p ON oi.product_id = p.id " +
                                                             "LEFT JOIN product_variants pv ON oi.variant_id = pv.id " +
                                                             "WHERE oi.order_id = ?")) {
                                                        ps.setInt(1, id);
                                                        try (ResultSet rs = ps.executeQuery()) {
                                                            while (rs.next()) {
                                                                String vName = rs.getString("variant_name");
                                                %>
                                                    <div style="display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-bottom:1px solid rgba(0,0,0,0.03);">
                                                        <div style="display:flex; align-items:center; gap:10px;">
                                                            <img src="<%= rs.getString("image_url") %>" style="width:40px; height:40px; border-radius:6px; object-fit:cover; border:1px solid var(--border-light);">
                                                            <div>
                                                                <div style="font-weight:600; font-size:0.85rem;">
                                                                    <%= rs.getString("name") %>
                                                                    <% if (vName != null && !vName.isEmpty()) { %>
                                                                        <span style="font-size:0.7rem; color:var(--gold); font-weight:600;">(Shade: <%= vName %>)</span>
                                                                    <% } %>
                                                                </div>
                                                                <div style="font-size:0.75rem; color:var(--text-muted);">Qty: <%= rs.getInt("quantity") %> &times; ₹<%= String.format("%.2f", rs.getDouble("price")) %></div>
                                                            </div>
                                                        </div>
                                                        <div style="font-weight:600; font-size:0.85rem;">₹<%= String.format("%.2f", rs.getDouble("price") * rs.getInt("quantity")) %></div>
                                                    </div>
                                                <%
                                                            }
                                                        }
                                                    } catch (Exception ex) {
                                                        out.println("<p style='color:var(--danger);'>Error loading details: " + ex.getMessage() + "</p>");
                                                    }
                                                %>
                                                </div>
                                                <div style="display:flex; justify-content:space-between; font-weight:700; font-size:1.05rem; padding-top:12px; border-top:1px solid var(--border-color); color:var(--burgundy);">
                                                    <span>Total Charges:</span>
                                                    <span>₹<%= String.format("%.2f", amt) %></span>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>

                        <!-- Mini Charts Widget Column -->
                        <div style="background:var(--bg-card); border:1px solid var(--border-color); border-radius:24px; padding:30px; box-shadow:var(--shadow-lux);">
                            <h3 style="font-size:1.3rem; margin-bottom:20px; border:none;">Sales Distributions</h3>
                            
                            <div style="position:relative; height:240px; margin-bottom:30px;">
                                <canvas id="miniSalesChart"></canvas>
                            </div>
                            <div style="font-size:0.8rem; color:var(--text-secondary); text-align:center; border-top:1px solid var(--border-light); padding-top:15px;">
                                <i class="fas fa-info-circle" style="color:var(--gold); margin-right:5px;"></i> Visualized monthly revenue trajectories.
                            </div>
                        </div>
                    </div>

                <% } else if ("products".equalsIgnoreCase(activeTab)) { %>
                    <!-- ==========================================
                         CATALOG MANAGER TAB
                         ========================================== -->
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:25px; text-align:left;">
                        <div>
                            <h2 style="font-size:1.6rem; border-bottom:none; margin:0; padding-bottom:0;">Beauty Inventory</h2>
                            <p style="color:var(--text-muted); font-size:0.85rem; margin-top:5px;">Configure catalog entries, stocks, variants, and cosmetic imaging.</p>
                        </div>
                        <button class="btn-gold" style="border-radius:12px; padding:10px 24px;" onclick="openAddModal()">
                            <i class="fas fa-plus" style="margin-right:8px;"></i> Add Product
                        </button>
                    </div>

                    <!-- Search Catalog Input -->
                    <div class="search-input-wrapper" style="margin-bottom:25px; text-align:left;">
                        <i class="fas fa-search"></i>
                        <input type="text" id="catalogSearch" onkeyup="searchCatalog()" placeholder="Search catalog by name or category...">
                    </div>

                    <table class="admin-table" id="catalogTable">
                        <thead>
                            <tr>
                                <th>Thumbnail</th>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Stock Qty (Main)</th>
                                <th>Quick Stock Update</th>
                                <th style="text-align:right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    Statement st = con.createStatement();
                                    ResultSet rs = st.executeQuery("SELECT id, name, description, price, category, image_url, stock, rating FROM products ORDER BY id DESC");
                                    while (rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("name");
                                        String desc = rs.getString("description").replace("'", "\\'").replace("\n", " ").replace("\r", " ");
                                        double price = rs.getDouble("price");
                                        String cat = rs.getString("category");
                                        String img = rs.getString("image_url");
                                        int stock = rs.getInt("stock");
                                        int rating = rs.getInt("rating");
                            %>
                            <tr class="product-row" style="border-bottom:none;">
                                <td><img src="<%= img %>" alt="" style="width:50px; height:50px; border-radius:8px; object-fit:cover; border:1px solid var(--border-light);"></td>
                                <td style="font-weight:600; color:var(--text-primary);" class="prod-name"><%= name %></td>
                                <td style="text-transform:uppercase; font-size:0.75rem; color:var(--gold); font-weight:600;" class="prod-cat"><%= cat %></td>
                                <td>₹<%= String.format("%.2f", price) %></td>
                                <td style="font-weight:600; color: <%= (stock < 10) ? "var(--danger)" : "var(--text-secondary)" %>"><%= stock %></td>
                                <td>
                                    <!-- Quick Stock Update Form -->
                                    <form action="AdminServlet" method="POST" style="display:inline-flex; align-items:center; gap:8px;">
                                        <input type="hidden" name="action" value="updateStock">
                                        <input type="hidden" name="id" value="<%= id %>">
                                        <input type="number" name="stock" value="<%= stock %>" required min="0" style="width:70px; padding:6px 10px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-dark); color:var(--text-primary); text-align:center; font-size:0.8rem;">
                                        <button type="submit" class="btn-gold" style="border-radius:8px; padding:6px 10px; font-size:0.75rem;">
                                            <i class="fas fa-check"></i>
                                        </button>
                                    </form>
                                </td>
                                <td style="text-align:right;">
                                    <button class="btn-outline" style="border-radius:6px; padding:6px 12px; font-size:0.75rem; margin-right:5px; text-transform:none;"
                                            onclick="openEditModal(<%= id %>, '<%= name.replace("'", "\\'") %>', '<%= desc %>', <%= price %>, '<%= cat %>', '<%= img %>', <%= stock %>, <%= rating %>)">
                                        Edit Product
                                    </button>
                                    <form action="AdminServlet" method="POST" style="display:inline-block;" onsubmit="return confirm('Delete product <%= name %>?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= id %>">
                                        <button type="submit" class="btn-outline" style="border-radius:6px; padding:6px 12px; font-size:0.75rem; color:var(--danger); border-color:var(--danger); background:transparent; text-transform:none;">
                                            Delete
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <!-- Nested Variants Table Row -->
                            <tr style="background: rgba(197, 171, 87, 0.015);">
                                <td colspan="7" style="padding: 12px 30px; border-top:none; border-bottom: 2px solid var(--border-light);">
                                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                                        <span style="font-size:0.8rem; font-weight:700; color:var(--gold);"><i class="fas fa-tags" style="margin-right:5px;"></i> Variants of <%= name %></span>
                                        <div style="display:flex; gap:8px;">
                                            <button class="btn-gold" style="padding:5px 12px; font-size:0.7rem; border-radius:6px; text-transform:none;" onclick="openAddVariantModal(<%= id %>, '<%= name.replace("'", "\\'") %>')">
                                                <i class="fas fa-plus-circle"></i> Add Shade / Size
                                            </button>
                                            <button class="btn-outline" style="padding:5px 12px; font-size:0.7rem; border-radius:6px; text-transform:none; font-weight:600;" onclick="openManageGalleryModal(<%= id %>, '<%= name.replace("'", "\\'") %>')">
                                                <i class="fas fa-images"></i> Manage Gallery
                                            </button>
                                        </div>
                                    </div>
                                    
                                    <table class="variants-sub-table" style="width:100%; border-collapse:collapse; background:var(--bg-card); border-radius:10px; overflow:hidden; border:1px solid var(--border-light); margin-bottom:5px;">
                                        <thead>
                                            <tr>
                                                <th>Shade / Variant Name</th>
                                                <th>Color Code / Label</th>
                                                <th>Stock Quantity</th>
                                                <th>Price Override</th>
                                                <th style="text-align:right;">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                try (PreparedStatement psVars = con.prepareStatement(
                                                        "SELECT id, variant_name, color_code, stock, price FROM product_variants WHERE product_id = ? ORDER BY id ASC")) {
                                                    psVars.setInt(1, id);
                                                    try (ResultSet rsVars = psVars.executeQuery()) {
                                                        boolean hasVars = false;
                                                        while (rsVars.next()) {
                                                            hasVars = true;
                                                            int vId = rsVars.getInt("id");
                                                            String vName = rsVars.getString("variant_name");
                                                            String vColor = rsVars.getString("color_code");
                                                            int vStock = rsVars.getInt("stock");
                                                            double vPrice = rsVars.getDouble("price");
                                                            boolean hasOverride = !rsVars.wasNull();
                                            %>
                                            <tr style="border-bottom:1px solid rgba(0,0,0,0.03);">
                                                <td style="font-weight:600; color:var(--text-primary);"><%= vName %></td>
                                                <td>
                                                    <% if (vColor.startsWith("#")) { %>
                                                        <span class="variant-color-indicator" style="background-color:<%= vColor %>;"></span>
                                                    <% } %>
                                                    <code><%= vColor %></code>
                                                </td>
                                                <td style="font-weight:600; color:<%= vStock < 5 ? "var(--danger)" : "var(--text-secondary)" %>"><%= vStock %> units</td>
                                                <td><%= hasOverride ? "₹" + String.format("%.2f", vPrice) : "<span style='color:var(--text-muted); font-size:0.75rem;'>(Inherit Parent Price)</span>" %></td>
                                                <td style="text-align:right;">
                                                    <button class="btn-outline" style="padding:4px 8px; font-size:0.65rem; border-radius:4px; text-transform:none; margin-right:4px;" 
                                                            onclick="openEditVariantModal(<%= vId %>, <%= id %>, '<%= vName.replace("'", "\\'") %>', '<%= vColor.replace("'", "\\'") %>', <%= vStock %>, '<%= hasOverride ? vPrice : "" %>')">
                                                        Edit
                                                    </button>
                                                    <form action="AdminServlet" method="POST" style="display:inline-block;" onsubmit="return confirm('Delete variant <%= vName %>?');">
                                                        <input type="hidden" name="action" value="deleteVariant">
                                                        <input type="hidden" name="variantId" value="<%= vId %>">
                                                        <button type="submit" class="btn-outline" style="padding:4px 8px; font-size:0.65rem; border-radius:4px; color:var(--danger); border-color:var(--danger); background:transparent; text-transform:none;">
                                                            Delete
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                            <%
                                                        }
                                                        if (!hasVars) {
                                            %>
                                            <tr>
                                                <td colspan="5" style="text-align:center; padding:12px; color:var(--text-muted); font-size:0.75rem;">No variants configured. (Uses main product stock/price by default)</td>
                                            </tr>
                                            <%
                                                        }
                                                    }
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    st.close();
                                    con.close();
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='7' style='color:var(--danger);'>Error: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>

                    <!-- Categories Section inside Products tab -->
                    <div style="margin-top:50px; background:var(--bg-card); border:1px solid var(--border-color); border-radius:24px; padding:35px; box-shadow:var(--shadow-lux); text-align:left;">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:15px;">
                            <div>
                                <h3 style="font-size:1.3rem; margin:0; border:none;">Cosmetic Categories</h3>
                                <p style="color:var(--text-muted); font-size:0.8rem; margin-top:5px;">Add or delete catalog category divisions.</p>
                            </div>
                            
                            <form action="AdminServlet" method="POST" style="display:flex; align-items:center; gap:10px;">
                                <input type="hidden" name="action" value="addCategory">
                                <input type="text" name="name" placeholder="Category Name" required style="padding:8px 12px; font-size:0.85rem; border-radius:8px; background:var(--bg-dark); border:1px solid var(--border-color); color:var(--text-primary); width:200px;">
                                <button type="submit" class="btn-gold" style="border-radius:8px; padding:8px 16px; font-size:0.85rem; white-space:nowrap;">
                                    <i class="fas fa-plus" style="margin-right:5px;"></i> Add Category
                                </button>
                            </form>
                        </div>

                        <div style="display:flex; gap:10px; flex-wrap:wrap;">
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    Statement st = con.createStatement();
                                    ResultSet rs = st.executeQuery("SELECT id, name FROM categories ORDER BY name ASC");
                                    while (rs.next()) {
                                        int catId = rs.getInt("id");
                                        String catName = rs.getString("name");
                            %>
                            <div style="display:inline-flex; align-items:center; gap:10px; background:var(--bg-surface); padding:8px 16px; border-radius:30px; border:1px solid var(--border-color); font-size:0.8rem; font-weight:600; color:var(--text-primary);">
                                <span><%= catName %></span>
                                <form action="AdminServlet" method="POST" style="display:inline-block;" onsubmit="return confirm('Delete category <%= catName %>? All products referencing it will remain but won\'t match search filters.');">
                                    <input type="hidden" name="action" value="deleteCategory">
                                    <input type="hidden" name="id" value="<%= catId %>">
                                    <button type="submit" style="background:transparent; border:none; cursor:pointer; color:var(--danger); font-size:0.85rem; display:inline-flex; align-items:center;"><i class="fas fa-times-circle"></i></button>
                                </form>
                            </div>
                            <%
                                    }
                                    rs.close();
                                    st.close();
                                    con.close();
                                } catch (Exception e) {
                                    out.println("<p style='color:var(--danger);'>Error: " + e.getMessage() + "</p>");
                                }
                            %>
                        </div>
                    </div>

                <% } else if ("orders".equalsIgnoreCase(activeTab)) { %>
                    <!-- ==========================================
                         ORDER FULFILLMENT TAB
                         ========================================== -->
                    <div style="text-align:left; margin-bottom:25px;">
                        <h2 style="font-size:1.6rem; border-bottom:none; margin:0; padding-bottom:0;">Order Fulfillment</h2>
                        <p style="color:var(--text-muted); font-size:0.85rem; margin-top:5px;">Examine transaction histories, delivery details, and alter order progress status.</p>
                    </div>

                    <!-- Search and Filter Row -->
                    <div style="display:flex; justify-content:space-between; align-items:center; gap:20px; margin-bottom:25px; flex-wrap:wrap;">
                        <div class="search-input-wrapper" style="max-width:350px; text-align:left;">
                            <i class="fas fa-search"></i>
                            <input type="text" id="orderSearch" onkeyup="searchOrders()" placeholder="Search by customer name or reference...">
                        </div>
                        <div>
                            <select id="statusFilter" onchange="filterOrders()" style="padding:10px 20px; border-radius:12px; background:var(--bg-card); font-size:0.85rem; min-width:180px;">
                                <option value="ALL">All Statuses</option>
                                <option value="PENDING">Pending</option>
                                <option value="PROCESSING">Processing</option>
                                <option value="SHIPPED">Shipped</option>
                                <option value="DELIVERED">Delivered</option>
                                <option value="CANCELLED">Cancelled</option>
                            </select>
                        </div>
                    </div>

                    <table class="admin-table" id="ordersTable">
                        <thead>
                            <tr>
                                <th>Order Ref</th>
                                <th>Customer</th>
                                <th>Date</th>
                                <th>Address</th>
                                <th>Total Cost</th>
                                <th>Status Badge</th>
                                <th>Update Fulfillment Status</th>
                                <th style="text-align:right;">Fulfillment Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    Statement st = con.createStatement();
                                    ResultSet rs = st.executeQuery(
                                        "SELECT o.id, o.order_date, o.total_amount, o.status, o.shipping_address, o.cancellation_reason, o.cancellation_date, o.cancelled_by, u.fullname FROM orders o " +
                                        "JOIN users u ON o.user_id = u.id ORDER BY o.order_date DESC"
                                    );
                                    while (rs.next()) {
                                        int id = rs.getInt("id");
                                        Timestamp date = rs.getTimestamp("order_date");
                                        double amt = rs.getDouble("total_amount");
                                        String status = rs.getString("status");
                                        String addr = rs.getString("shipping_address");
                                        String cust = rs.getString("fullname");
                                        
                                        String cancelReason = rs.getString("cancellation_reason");
                                        Timestamp cancelDate = rs.getTimestamp("cancellation_date");
                                        String cancelledBy = rs.getString("cancelled_by");

                                        String badgeClass = "status-pending";
                                        if ("PROCESSING".equalsIgnoreCase(status)) badgeClass = "status-processing";
                                        else if ("SHIPPED".equalsIgnoreCase(status)) badgeClass = "status-shipped";
                                        else if ("DELIVERED".equalsIgnoreCase(status)) badgeClass = "status-completed";
                                        else if ("CANCELLED".equalsIgnoreCase(status)) badgeClass = "status-cancelled";
                            %>
                            <tr class="order-row" data-status="<%= status %>">
                                <td style="font-weight:600; color:var(--gold);" class="order-ref">#LXG-<%= id %></td>
                                <td class="order-customer" style="font-weight:600;"><%= cust %></td>
                                <td style="font-size:0.75rem;"><%= date %></td>
                                <td style="font-size:0.8rem; max-width:180px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><%= addr %></td>
                                <td style="font-weight:600; color:var(--text-primary);">₹<%= String.format("%.2f", amt) %></td>
                                <td><span class="status-badge <%= badgeClass %>"><%= status %></span></td>
                                <td>
                                    <!-- Status Update Dropdown Form -->
                                    <form action="AdminServlet" method="POST" style="display:inline-flex; align-items:center; gap:5px;">
                                        <input type="hidden" name="action" value="updateOrder">
                                        <input type="hidden" name="orderId" value="<%= id %>">
                                        <select name="status" style="padding:6px 12px; font-size:0.75rem; border-radius:8px; min-width:110px; background:var(--bg-dark); border:1px solid var(--border-color); color:var(--text-primary); height:auto;">
                                            <option value="PENDING" <%= "PENDING".equals(status) ? "selected" : "" %>>Pending</option>
                                            <option value="PROCESSING" <%= "PROCESSING".equals(status) ? "selected" : "" %>>Processing</option>
                                            <option value="SHIPPED" <%= "SHIPPED".equals(status) ? "selected" : "" %>>Shipped</option>
                                            <option value="DELIVERED" <%= "DELIVERED".equals(status) ? "selected" : "" %>>Delivered</option>
                                            <option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>Cancelled</option>
                                        </select>
                                        <button type="submit" class="btn-gold" style="border-radius:8px; padding:6px 10px; font-size:0.75rem;">
                                            <i class="fas fa-check"></i>
                                        </button>
                                    </form>
                                </td>
                                <td style="text-align:right;">
                                    <div style="display:flex; align-items:center; justify-content:flex-end; gap:5px;">
                                        <button class="btn-outline" style="border-radius:6px; padding:6px 12px; font-size:0.75rem; text-transform:none;" onclick="showOrderDetails(<%= id %>)">
                                            Items
                                        </button>
                                        <% if (!"DELIVERED".equalsIgnoreCase(status) && !"CANCELLED".equalsIgnoreCase(status)) { %>
                                            <form action="AdminServlet" method="POST" style="display:inline-block;" onsubmit="return confirm('Cancel order #LXG-<%= id %>?');">
                                                <input type="hidden" name="action" value="cancelOrder">
                                                <input type="hidden" name="orderId" value="<%= id %>">
                                                <button type="submit" class="btn-outline" style="border-radius:6px; padding:6px 12px; font-size:0.75rem; color:var(--danger); border-color:var(--danger); background:transparent; text-transform:none;">
                                                    Cancel
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>

                                    <!-- Render Hidden Details Block -->
                                    <div id="orderDetails-<%= id %>" style="display:none;">
                                        <div style="margin-bottom:15px; font-size:0.85rem; line-height:1.5;">
                                            <strong>Order Reference:</strong> #LXG-<%= id %><br>
                                            <strong>Customer Name:</strong> <%= cust %><br>
                                            <strong>Fulfillment Status:</strong> <span class="status-badge <%= badgeClass %>" style="font-size:0.65rem; padding:3px 8px;"><%= status %></span><br>
                                            <strong>Order Date:</strong> <%= date %><br>
                                            <strong>Shipping Address:</strong> <%= addr %>
                                        </div>
                                        
                                        <% if ("CANCELLED".equalsIgnoreCase(status) && cancelReason != null) { %>
                                            <div style="margin-bottom:15px; padding:12px; background:rgba(245,108,108,0.1); border:1px solid rgba(245,108,108,0.2); border-radius:10px; font-size:0.8rem; text-align:left; color:#f56c6c; line-height:1.4;">
                                                <i class="fas fa-info-circle"></i> <strong>Cancellation Details:</strong><br>
                                                <strong>Initiated By:</strong> <%= cancelledBy != null ? cancelledBy.toUpperCase() : "UNKNOWN" %><br>
                                                <strong>Date:</strong> <%= cancelDate %><br>
                                                <strong>Reason:</strong> <%= cancelReason %>
                                            </div>
                                        <% } %>

                                        <h4 style="font-family:'Playfair Display', serif; border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:12px; font-size:1.1rem; color:var(--burgundy);">Purchased Cosmetics</h4>
                                        <div style="max-height:220px; overflow-y:auto; margin-bottom:15px;">
                                        <%
                                            try (Connection innerCon = DBConnection.getConnection();
                                                 PreparedStatement innerPs = innerCon.prepareStatement(
                                                     "SELECT oi.quantity, oi.price, p.name, p.image_url, pv.variant_name FROM order_items oi " +
                                                     "JOIN products p ON oi.product_id = p.id " +
                                                     "LEFT JOIN product_variants pv ON oi.variant_id = pv.id " +
                                                     "WHERE oi.order_id = ?")) {
                                                innerPs.setInt(1, id);
                                                try (ResultSet innerRs = innerPs.executeQuery()) {
                                                    while (innerRs.next()) {
                                                        String vName = innerRs.getString("variant_name");
                                        %>
                                            <div style="display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-bottom:1px solid rgba(0,0,0,0.03);">
                                                <div style="display:flex; align-items:center; gap:10px;">
                                                    <img src="<%= innerRs.getString("image_url") %>" style="width:40px; height:40px; border-radius:6px; object-fit:cover; border:1px solid var(--border-light);">
                                                    <div>
                                                        <div style="font-weight:600; font-size:0.85rem;">
                                                            <%= innerRs.getString("name") %>
                                                            <% if (vName != null && !vName.isEmpty()) { %>
                                                                <span style="font-size:0.7rem; color:var(--gold); font-weight:600;">(Shade: <%= vName %>)</span>
                                                            <% } %>
                                                        </div>
                                                        <div style="font-size:0.75rem; color:var(--text-muted);">Qty: <%= innerRs.getInt("quantity") %> &times; ₹<%= String.format("%.2f", innerRs.getDouble("price")) %></div>
                                                    </div>
                                                </div>
                                                <div style="font-weight:600; font-size:0.85rem;">₹<%= String.format("%.2f", innerRs.getDouble("price") * innerRs.getInt("quantity")) %></div>
                                            </div>
                                        <%
                                                    }
                                                }
                                            } catch (Exception innerEx) {
                                                out.println("<p style='color:var(--danger);'>Error details: " + innerEx.getMessage() + "</p>");
                                            }
                                        %>
                                        </div>
                                        <div style="display:flex; justify-content:space-between; font-weight:700; font-size:1.05rem; padding-top:12px; border-top:1px solid var(--border-color); color:var(--burgundy);">
                                            <span>Amount Paid:</span>
                                            <span>₹<%= String.format("%.2f", amt) %></span>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    st.close();
                                    con.close();
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='8' style='color:var(--danger);'>Error: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>

                <% } else if ("users".equalsIgnoreCase(activeTab)) { %>
                    <!-- ==========================================
                         USER MANAGEMENT TAB
                         ========================================== -->
                    <div style="text-align:left; margin-bottom:25px;">
                        <h2 style="font-size:1.6rem; border-bottom:none; margin:0; padding-bottom:0;">User Management</h2>
                        <p style="color:var(--text-muted); font-size:0.85rem; margin-top:5px;">Track registered customer details, alter status toggles, or grant administrative roles.</p>
                    </div>

                    <!-- Search Bar for Users -->
                    <div class="search-input-wrapper" style="margin-bottom:25px; text-align:left;">
                        <i class="fas fa-search"></i>
                        <input type="text" id="userSearch" onkeyup="searchUsersList()" placeholder="Search users by name, username, email, or country...">
                    </div>

                    <table class="admin-table" id="usersTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Full Name</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Country</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th style="text-align:right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    int currentAdminId = (Integer) s.getAttribute("user_id");
                                    Connection con = DBConnection.getConnection();
                                    Statement st = con.createStatement();
                                    ResultSet rs = st.executeQuery("SELECT id, fullname, username, email, phone, country_name, role, enabled FROM users ORDER BY id DESC");
                                    while (rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("fullname");
                                        String username = rs.getString("username");
                                        String email = rs.getString("email");
                                        String phone = rs.getString("phone");
                                        String country = rs.getString("country_name");
                                        String role = rs.getString("role");
                                        int enabled = rs.getInt("enabled");
                            %>
                            <tr class="user-row">
                                <td style="font-weight:600; color:var(--gold);">#<%= id %></td>
                                <td style="font-weight:600;" class="user-fullname"><%= name %></td>
                                <td class="user-username"><%= username %></td>
                                <td class="user-email"><%= email %></td>
                                <td><%= (phone != null) ? phone : "-" %></td>
                                <td class="user-country"><%= (country != null) ? country : "-" %></td>
                                <td>
                                    <span style="font-size:0.75rem; font-weight:700; color: <%= "ADMIN".equalsIgnoreCase(role) ? "var(--gold)" : "var(--text-secondary)" %>; background: <%= "ADMIN".equalsIgnoreCase(role) ? "var(--burgundy-glow)" : "rgba(0,0,0,0.03)" %>; padding: 4px 10px; border-radius:10px; border: 1px solid <%= "ADMIN".equalsIgnoreCase(role) ? "var(--border-color)" : "rgba(0,0,0,0.05)" %>">
                                        <%= role %>
                                    </span>
                                </td>
                                <td>
                                    <span class="status-badge <%= enabled == 1 ? "status-completed" : "status-cancelled" %>">
                                        <%= enabled == 1 ? "Active" : "Disabled" %>
                                    </span>
                                </td>
                                <td style="text-align:right;">
                                    <% if (id != currentAdminId) { %>
                                        <form action="AdminServlet" method="POST" style="display:inline-block;" onsubmit="return confirm('Toggle status for <%= name %>?');">
                                            <input type="hidden" name="action" value="toggleUser">
                                            <input type="hidden" name="userId" value="<%= id %>">
                                            <button type="submit" class="btn-outline" style="border-radius:6px; padding:6px 12px; font-size:0.75rem; text-transform:none;">
                                                Toggle Status
                                            </button>
                                        </form>
                                        <form action="AdminServlet" method="POST" style="display:inline-block;" onsubmit="return confirm('Toggle administrator privileges for <%= name %>?');">
                                            <input type="hidden" name="action" value="toggleRole">
                                            <input type="hidden" name="userId" value="<%= id %>">
                                            <button type="submit" class="btn-outline" style="border-radius:6px; padding:6px 12px; font-size:0.75rem; color:var(--gold); border-color:var(--gold); background:transparent; text-transform:none; margin-left:4px;">
                                                Toggle Admin Privilege
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <span style="font-size:0.75rem; color:var(--text-muted); font-style:italic; padding-right:15px;">Self Account</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    st.close();
                                    con.close();
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='9' style='color:var(--danger);'>Error: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>

                <% } else if ("reports".equalsIgnoreCase(activeTab)) { %>
                    <!-- ==========================================
                         SALES REPORTS TAB
                         ========================================== -->
                    <div style="text-align:left; margin-bottom:25px;">
                        <h2 style="font-size:1.6rem; border-bottom:none; margin:0; padding-bottom:0;">Revenue Analytics Report</h2>
                        <p style="color:var(--text-muted); font-size:0.85rem; margin-top:5px;">Detailed metrics on revenue channels and sales performance.</p>
                    </div>

                    <div style="display:grid; grid-template-columns:1.5fr 1fr; gap:30px; margin-top:20px; text-align:left;">
                        
                        <!-- Monthly trends charts -->
                        <div style="background:var(--bg-card); border:1px solid var(--border-color); border-radius:24px; padding:30px; box-shadow:var(--shadow-lux);">
                            <h3 style="font-size:1.3rem; margin-bottom:20px; border:none;">Sales Revenue Trajectories</h3>
                            <div style="position:relative; height:320px;">
                                <canvas id="monthlySalesChart"></canvas>
                            </div>
                        </div>

                        <!-- Best selling products chart -->
                        <div style="background:var(--bg-card); border:1px solid var(--border-color); border-radius:24px; padding:30px; box-shadow:var(--shadow-lux);">
                            <h3 style="font-size:1.3rem; margin-bottom:20px; border:none;">Top-Selling Beauty Formulas</h3>
                            <div style="position:relative; height:320px;">
                                <canvas id="bestSellersChart"></canvas>
                            </div>
                        </div>

                    </div>

                    <!-- Detailed monthly sales table breakdown -->
                    <div style="margin-top:40px; text-align:left;">
                        <h3 style="font-size:1.3rem; margin-bottom:15px; border:none;">Historical Revenue Matrix</h3>
                        <table class="admin-table" style="margin-top:0;">
                            <thead>
                                <tr>
                                    <th>Reporting Month</th>
                                    <th>Transaction Orders</th>
                                    <th>Total Gross Sales (₹)</th>
                                    <th>Average Order Value</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (monthlySalesList != null && !monthlySalesList.isEmpty()) {
                                        for (Map<String, Object> stat : monthlySalesList) {
                                            String month = (String) stat.get("month");
                                            int count = (Integer) stat.get("orders");
                                            double sales = (Double) stat.get("sales");
                                            double aov = count > 0 ? sales / count : 0.0;
                                %>
                                <tr>
                                    <td style="font-weight:600; color:var(--burgundy);"><%= month %></td>
                                    <td><%= count %> orders</td>
                                    <td style="font-weight:600;">₹<%= String.format("%.2f", sales) %></td>
                                    <td>₹<%= String.format("%.2f", aov) %></td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="4" style="text-align:center; padding:20px; color:var(--text-muted);">No monthly data registered yet.</td>
                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>

                <% } else if ("settings".equalsIgnoreCase(activeTab)) { %>
                    <!-- ==========================================
                         SYSTEM SETTINGS TAB
                         ========================================== -->
                    <div style="text-align:left; margin-bottom:25px;">
                        <h2 style="font-size:1.6rem; border-bottom:none; margin:0; padding-bottom:0;">System Settings</h2>
                        <p style="color:var(--text-muted); font-size:0.85rem; margin-top:5px;">Configure variables, database credentials, and review user inquiries.</p>
                    </div>

                    <div style="display:grid; grid-template-columns:1.5fr 1fr; gap:30px; text-align:left;">
                        
                        <!-- Client Communications Log -->
                        <div>
                            <h3 style="font-size:1.3rem; margin-bottom:15px; border:none;">Client Communications Log</h3>
                            <table class="admin-table" style="margin-top:0;">
                                <thead>
                                    <tr>
                                        <th>Sender</th>
                                        <th>Email</th>
                                        <th>Subject</th>
                                        <th>Date Submitted</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection con = DBConnection.getConnection();
                                             Statement st = con.createStatement();
                                             ResultSet rs = st.executeQuery("SELECT name, email, subject, message, created_at FROM contact_messages ORDER BY created_at DESC LIMIT 6")) {
                                            
                                            boolean hasMsgs = false;
                                            while (rs.next()) {
                                                hasMsgs = true;
                                                String name = rs.getString("name");
                                                String email = rs.getString("email");
                                                String subject = rs.getString("subject");
                                                String message = rs.getString("message");
                                                Timestamp date = rs.getTimestamp("created_at");
                                    %>
                                    <tr>
                                        <td style="font-weight:600;"><%= name %></td>
                                        <td><a href="mailto:<%= email %>" style="text-decoration:underline; color:var(--burgundy);"><%= email %></a></td>
                                        <td style="color:var(--gold); font-weight:600; cursor:pointer;" onclick="alert('Message details:\n\n<%= message.replace("'", "\\'") %>')"><%= subject %> <i class="far fa-eye" style="margin-left:5px; font-size:0.8rem;"></i></td>
                                        <td style="font-size:0.75rem;"><%= date %></td>
                                    </tr>
                                    <%
                                             }
                                             if (!hasMsgs) {
                                    %>
                                    <tr>
                                        <td colspan="4" style="text-align:center; padding:30px; color:var(--text-muted);">No concierge inquiries in mailbox.</td>
                                    </tr>
                                    <%
                                             }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='4' style='color:var(--danger);'>Error: " + e.getMessage() + "</td></tr>");
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>

                        <!-- System Parameters -->
                        <div style="background:var(--bg-card); border:1px solid var(--border-color); border-radius:24px; padding:30px; box-shadow:var(--shadow-lux); height:fit-content;">
                            <h3 style="font-size:1.3rem; margin-bottom:20px; border:none;">Portal Configurations</h3>
                            
                            <div style="font-size:0.85rem; display:flex; flex-direction:column; gap:15px; color:var(--text-secondary);">
                                <div>
                                    <strong>E-commerce Brand:</strong> LuxeGlow Premium
                                </div>
                                <div style="border-top:1px solid var(--border-light); padding-top:10px;">
                                    <strong>Active Database:</strong> MySQL (luxeglow)
                                </div>
                                <div style="border-top:1px solid var(--border-light); padding-top:10px;">
                                    <strong>Connection Host:</strong> localhost:3306
                                </div>
                                <div style="border-top:1px solid var(--border-light); padding-top:10px;">
                                    <strong>Application Version:</strong> 1.0.0-SNAPSHOT
                                </div>
                                <div style="border-top:1px solid var(--border-light); padding-top:10px;">
                                    <strong>Server Gateway:</strong> Tomcat 10.1
                                </div>
                                <div style="border-top:1px solid var(--border-light); padding-top:10px;">
                                    <strong>Logged Security ID:</strong> #<%= s.getAttribute("user_id") %>
                                </div>
                                <div style="border-top:1px solid var(--border-light); padding-top:15px; display:flex; gap:10px;">
                                    <a href="email-diagnostics.jsp" class="btn-gold" style="border-radius:8px; padding:8px 16px; font-size:0.75rem; text-decoration:none; flex-grow:1;">
                                        <i class="fas fa-toolbox"></i> Email Diagnostics
                                    </a>
                                </div>
                            </div>
                        </div>

                    </div>
                <% } %>

            </main>
        </div>

    </div>

    <!-- ==========================================
         MODAL 1: ADD PRODUCT
         ========================================== -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <span class="modal-close" onclick="closeAddModal()">&times;</span>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.5rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:25px; text-align:left;">
                Add Cosmetic Masterpiece
            </h3>
            
            <form action="AdminServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="add">
                
                <div class="form-group">
                    <label>Product Name</label>
                    <input type="text" name="name" placeholder="Glow Moisturizer" required>
                </div>
                
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" rows="3" placeholder="Describe the luxury beauty formula..." required style="resize:vertical;"></textarea>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-group">
                        <label>Price (₹)</label>
                        <input type="number" step="0.01" name="price" placeholder="1500.00" required>
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select name="category" required>
                            <% for (String catName : categoriesList) { %>
                                <option value="<%= catName %>"><%= catName %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label>Upload Product Photo</label>
                    <input type="file" name="imageFile" accept="image/*" style="padding:8px 12px; background:transparent; border:1px dashed var(--border-color); cursor:pointer;">
                    <div style="font-size:0.7rem; color:var(--text-muted); margin-top:2px;">Optional. Overrides the text path field below if selected.</div>
                </div>

                <div class="form-group">
                    <label>Image Resource Path (Fallback)</label>
                    <input type="text" name="imageUrl" placeholder="image/glowserum.jpg" value="image/glowserum.jpg" required>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-group">
                        <label>Initial Stock Qty</label>
                        <input type="number" name="stock" placeholder="50" required min="0">
                    </div>
                    <div class="form-group">
                        <label>Default Star Rating</label>
                        <input type="number" name="rating" min="1" max="5" value="5" required>
                    </div>
                </div>

                <button type="submit" class="btn-gold" style="width:100%; border-radius:12px; padding:12px; margin-top:10px;">
                    Create Inventory Item
                </button>
            </form>
        </div>
    </div>

    <!-- ==========================================
         MODAL 2: EDIT PRODUCT
         ========================================== -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <span class="modal-close" onclick="closeEditModal()">&times;</span>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.5rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:25px; text-align:left;">
                Update Cosmetic Specifications
            </h3>
            
            <form action="AdminServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editId">
                
                <div class="form-group">
                    <label>Product Name</label>
                    <input type="text" name="name" id="editName" required>
                </div>
                
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" id="editDescription" rows="3" required style="resize:vertical;"></textarea>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-group">
                        <label>Price (₹)</label>
                        <input type="number" step="0.01" name="price" id="editPrice" required>
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select name="category" id="editCategory" required>
                            <% for (String catName : categoriesList) { %>
                                <option value="<%= catName %>"><%= catName %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label>Upload New Product Photo</label>
                    <input type="file" name="imageFile" accept="image/*" style="padding:8px 12px; background:transparent; border:1px dashed var(--border-color); cursor:pointer;">
                    <div style="font-size:0.7rem; color:var(--text-muted); margin-top:2px;">Optional. Leave empty to retain current photo path.</div>
                </div>

                <div class="form-group">
                    <label>Image Resource Path</label>
                    <input type="text" name="imageUrl" id="editImageUrl" required>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-group">
                        <label>Stock Qty</label>
                        <input type="number" name="stock" id="editStock" required min="0">
                    </div>
                    <div class="form-group">
                        <label>Star Rating</label>
                        <input type="number" name="rating" id="editRating" min="1" max="5" required>
                    </div>
                </div>

                <button type="submit" class="btn-gold" style="width:100%; border-radius:12px; padding:12px; margin-top:10px;">
                    Apply Spec Updates
                </button>
            </form>
        </div>
    </div>

    <!-- ==========================================
         MODAL 3: VIEW ORDER DETAILS
         ========================================== -->
    <div id="orderDetailsModal" class="modal">
        <div class="modal-content" style="max-width:550px;">
            <span class="modal-close" onclick="closeOrderDetailsModal()">&times;</span>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.5rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:20px; text-align:left;">
                Transaction Invoice Details
            </h3>
            <div id="orderDetailsModalBody" style="text-align:left;">
                <!-- Dynamically loaded content -->
            </div>
            <button class="btn-gold" style="width:100%; border-radius:12px; padding:12px; margin-top:20px; text-transform:none;" onclick="closeOrderDetailsModal()">
                Close Invoice
            </button>
        </div>
    </div>

    <!-- ==================================================
         MODAL 4: ADD VARIANT (NEW)
         ================================================== -->
    <div id="addVariantModal" class="modal">
        <div class="modal-content" style="max-width: 480px;">
            <span class="modal-close" onclick="closeAddVariantModal()">&times;</span>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.4rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:20px; text-align:left;">
                Add Product Variant
            </h3>
            <form action="AdminServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="addVariant">
                <input type="hidden" name="productId" id="addVarProductId">
                
                <div class="form-group">
                    <label>Variant / Shade Name</label>
                    <input type="text" name="name" placeholder="e.g. Ruby Red or 50ml" required>
                </div>

                <div class="form-group">
                    <label>Color Code / Custom Label</label>
                    <input type="text" name="colorCode" placeholder="e.g. #E0115F or Standard" required>
                    <div style="font-size:0.7rem; color:var(--text-muted); margin-top:2px;">Use standard hex code starting with # for color swatch, or any text label for pills.</div>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px;">
                    <div class="form-group">
                        <label>Stock Quantity</label>
                        <input type="number" name="stock" placeholder="50" min="0" required>
                    </div>
                    <div class="form-group">
                        <label>Price Override (Optional)</label>
                        <input type="number" step="0.01" name="price" placeholder="Leave blank to use default">
                    </div>
                </div>

                <div class="form-group">
                    <label>Upload Variant-Specific Photos</label>
                    <input type="file" name="variantImages" accept="image/*" multiple style="padding:8px; border: 1px dashed var(--border-color); width: 100%;">
                    <div style="font-size:0.7rem; color:var(--text-muted); margin-top:2px;">Select one or multiple photos for this shade/variant.</div>
                </div>

                <button type="submit" class="btn-gold" style="width:100%; border-radius:12px; padding:12px; margin-top:10px;">
                    Save Product Variant
                </button>
            </form>
        </div>
    </div>

    <!-- ==================================================
         MODAL 5: EDIT VARIANT (NEW)
         ================================================== -->
    <div id="editVariantModal" class="modal">
        <div class="modal-content" style="max-width: 480px;">
            <span class="modal-close" onclick="closeEditVariantModal()">&times;</span>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.4rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:20px; text-align:left;">
                Edit Product Variant
            </h3>
            <form action="AdminServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="editVariant">
                <input type="hidden" name="variantId" id="editVarVariantId">
                <input type="hidden" name="productId" id="editVarProductId">
                
                <div class="form-group">
                    <label>Variant / Shade Name</label>
                    <input type="text" name="name" id="editVarName" required>
                </div>

                <div class="form-group">
                    <label>Color Code / Custom Label</label>
                    <input type="text" name="colorCode" id="editVarColor" required>
                    <div style="font-size:0.7rem; color:var(--text-muted); margin-top:2px;">E.g. #E0115F or Standard.</div>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px;">
                    <div class="form-group">
                        <label>Stock Quantity</label>
                        <input type="number" name="stock" id="editVarStock" min="0" required>
                    </div>
                    <div class="form-group">
                        <label>Price Override (Optional)</label>
                        <input type="number" step="0.01" name="price" id="editVarPrice" placeholder="Default price">
                    </div>
                </div>

                <div class="form-group">
                    <label>Upload More Variant-Specific Photos</label>
                    <input type="file" name="variantImages" accept="image/*" multiple style="padding:8px; border: 1px dashed var(--border-color); width: 100%;">
                    <div style="font-size:0.7rem; color:var(--text-muted); margin-top:2px;">Add more variant-specific images.</div>
                </div>

                <button type="submit" class="btn-gold" style="width:100%; border-radius:12px; padding:12px; margin-top:10px;">
                    Apply Variant Updates
                </button>
            </form>
        </div>
    </div>

    <!-- ==================================================
         MODAL 6: MANAGE GALLERY (NEW)
         ================================================== -->
    <div id="manageGalleryModal" class="modal">
        <div class="modal-content" style="max-width: 650px;">
            <span class="modal-close" onclick="closeManageGalleryModal()">&times;</span>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.4rem; color:var(--gold); border-bottom:1px solid var(--border-light); padding-bottom:8px; margin-bottom:20px; text-align:left;">
                Image Gallery: <span id="galleryProductName" style="color:var(--burgundy);"></span>
            </h3>
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px; text-align:left;">
                <!-- Left: Upload Form -->
                <div>
                    <h4 style="margin-top:0; border:none; font-size:1rem; margin-bottom:10px; color:var(--text-primary);">Upload New Images</h4>
                    <form action="AdminServlet" method="POST" enctype="multipart/form-data" style="background:rgba(0,0,0,0.01); border:1px solid var(--border-light); padding:15px; border-radius:12px;">
                        <input type="hidden" name="action" value="uploadProductImages">
                        <input type="hidden" name="productId" id="galleryProductId">
                        
                        <div class="form-group">
                            <label style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Select Photos</label>
                            <input type="file" name="productImages" accept="image/*" multiple required style="padding:5px; border:1px dashed var(--border-color); width:100%;">
                            <div style="font-size:0.65rem; color:var(--text-muted); margin-top:2px;">Select one or multiple images to add to the general product gallery.</div>
                        </div>

                        <button type="submit" class="btn-gold" style="width:100%; padding:10px; font-size:0.8rem; border-radius:8px; margin-top:10px;">
                            Upload to Gallery
                        </button>
                    </form>
                </div>
                
                <!-- Right: Active Images List -->
                <div>
                    <h4 style="margin-top:0; border:none; font-size:1rem; margin-bottom:10px; color:var(--text-primary);">Gallery Image Assets</h4>
                    <div id="galleryImagesList" style="max-height: 280px; overflow-y: auto; display:flex; flex-direction:column; gap:10px; padding-right:5px;">
                        <!-- Populate dynamically via Ajax or rendered content -->
                    </div>
                </div>
            </div>
            
            <button class="btn-gold" style="width:100%; border-radius:12px; padding:12px; margin-top:25px;" onclick="closeManageGalleryModal()">
                Close Gallery
            </button>
        </div>
    </div>

    <!-- Footer -->
    <%@ include file="../footer.jsp" %>

    <script>
        // Modal toggles
        function openAddModal() {
            document.getElementById('addModal').style.display = 'flex';
        }
        function closeAddModal() {
            document.getElementById('addModal').style.display = 'none';
        }

        function openEditModal(id, name, desc, price, category, imageUrl, stock, rating) {
            document.getElementById('editId').value = id;
            document.getElementById('editName').value = name;
            document.getElementById('editDescription').value = desc;
            document.getElementById('editPrice').value = price;
            document.getElementById('editCategory').value = category;
            document.getElementById('editImageUrl').value = imageUrl;
            document.getElementById('editStock').value = stock;
            document.getElementById('editRating').value = rating;

            document.getElementById('editModal').style.display = 'flex';
        }
        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }

        function showOrderDetails(orderId) {
            const content = document.getElementById('orderDetails-' + orderId).innerHTML;
            document.getElementById('orderDetailsModalBody').innerHTML = content;
            document.getElementById('orderDetailsModal').style.display = 'flex';
        }
        function closeOrderDetailsModal() {
            document.getElementById('orderDetailsModal').style.display = 'none';
        }

        // --- NEW MODAL CONTROLLERS ---
        function openAddVariantModal(productId, productName) {
            document.getElementById('addVarProductId').value = productId;
            document.getElementById('addVariantModal').style.display = 'flex';
        }
        function closeAddVariantModal() {
            document.getElementById('addVariantModal').style.display = 'none';
        }

        function openEditVariantModal(variantId, productId, name, color, stock, price) {
            document.getElementById('editVarVariantId').value = variantId;
            document.getElementById('editVarProductId').value = productId;
            document.getElementById('editVarName').value = name;
            document.getElementById('editVarColor').value = color;
            document.getElementById('editVarStock').value = stock;
            document.getElementById('editVarPrice').value = price;
            document.getElementById('editVariantModal').style.display = 'flex';
        }
        function closeEditVariantModal() {
            document.getElementById('editVariantModal').style.display = 'none';
        }

        function openManageGalleryModal(productId, productName) {
            document.getElementById('galleryProductId').value = productId;
            document.getElementById('galleryProductId').value = productId;
            document.getElementById('galleryProductName').innerText = productName;
            
            // Query current images from database dynamically
            fetchGalleryImages(productId);
            document.getElementById('manageGalleryModal').style.display = 'flex';
        }
        function closeManageGalleryModal() {
            document.getElementById('manageGalleryModal').style.display = 'none';
        }

        function fetchGalleryImages(productId) {
            const listEl = document.getElementById('galleryImagesList');
            listEl.innerHTML = '<p style="color:var(--text-muted); text-align:center; font-size:0.85rem;">Loading gallery assets...</p>';
            
            // Build temporary query elements using simple servlet or query products
            // To make it simple, we can call a lightweight custom AJAX query or pass them in a JSON payload.
            // Let's execute a fetch request to a custom helper or load them.
            // Wait, we can fetch all product images by implementing a simple helper block.
            // Since we need to query product_images, we can call fetch('admin?action=getGallery&productId=' + productId)
            // But instead of complex APIs, we can create a lightweight servlet handler or fetch it from a simple backend call!
            // Let's implement an action `getGallery` in AdminServlet that returns JSON!
            // Let's write a simple servlet API in AdminDashboardServlet, or call a direct query.
            // Wait! Can we call a JSP that prints a clean HTML fragment of images?
            // Yes! We can create a simple file `getGalleryImages.jsp` in webapp that takes `productId` and prints the images!
            // That is incredibly easy, J2EE-native, requires no servlet rebuild, and loads instantly.
            // Let's do that! That is extremely clever.
            fetch('getGalleryImages.jsp?productId=' + productId)
                .then(res => res.text())
                .then(html => {
                    listEl.innerHTML = html;
                })
                .catch(err => {
                    listEl.innerHTML = '<p style="color:var(--danger); font-size:0.8rem;">Failed to load images.</p>';
                    console.error(err);
                });
        }

        // Close modal on outer clicks
        window.onclick = function(event) {
            const addM = document.getElementById('addModal');
            const editM = document.getElementById('editModal');
            const detailsM = document.getElementById('orderDetailsModal');
            const addVarM = document.getElementById('addVariantModal');
            const editVarM = document.getElementById('editVariantModal');
            const galleryM = document.getElementById('manageGalleryModal');
            if (event.target == addM) addM.style.display = 'none';
            if (event.target == editM) editM.style.display = 'none';
            if (event.target == detailsM) detailsM.style.display = 'none';
            if (event.target == addVarM) addVarM.style.display = 'none';
            if (event.target == editVarM) editVarM.style.display = 'none';
            if (event.target == galleryM) galleryM.style.display = 'none';
        }

        // Search inputs filtering functions
        function searchCatalog() {
            const input = document.getElementById('catalogSearch').value.toLowerCase();
            const rows = document.querySelectorAll('.product-row');
            rows.forEach(row => {
                const name = row.querySelector('.prod-name').textContent.toLowerCase();
                const cat = row.querySelector('.prod-cat').textContent.toLowerCase();
                const nextRow = row.nextElementSibling; // the variants row
                if (name.includes(input) || cat.includes(input)) {
                    row.style.display = '';
                    if (nextRow && nextRow.classList.contains('variants-row') === false) {
                        nextRow.style.display = '';
                    }
                } else {
                    row.style.display = 'none';
                    if (nextRow && nextRow.classList.contains('variants-row') === false) {
                        nextRow.style.display = 'none';
                    }
                }
            });
        }

        function searchOrders() {
            const input = document.getElementById('orderSearch').value.toLowerCase();
            const rows = document.querySelectorAll('.order-row');
            rows.forEach(row => {
                const ref = row.querySelector('.order-ref').textContent.toLowerCase();
                const cust = row.querySelector('.order-customer').textContent.toLowerCase();
                if (ref.includes(input) || cust.includes(input)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        function filterOrders() {
            const filter = document.getElementById('statusFilter').value;
            const rows = document.querySelectorAll('.order-row');
            rows.forEach(row => {
                const status = row.getAttribute('data-status');
                if (filter === 'ALL' || status === filter) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        function searchUsersList() {
            const input = document.getElementById('userSearch').value.toLowerCase();
            const rows = document.querySelectorAll('.user-row');
            rows.forEach(row => {
                const name = row.querySelector('.user-fullname').textContent.toLowerCase();
                const user = row.querySelector('.user-username').textContent.toLowerCase();
                const email = row.querySelector('.user-email').textContent.toLowerCase();
                const country = row.querySelector('.user-country').textContent.toLowerCase();
                if (name.includes(input) || user.includes(input) || email.includes(input) || country.includes(input)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        // Chart.js integrations
        document.addEventListener('DOMContentLoaded', () => {
            <%
                // Prepare analytical data from request parameters
                StringBuilder monthLabels = new StringBuilder("[");
                StringBuilder salesValues = new StringBuilder("[");
                StringBuilder orderValues = new StringBuilder("[");
                if (monthlySalesList != null) {
                    for (int i = 0; i < monthlySalesList.size(); i++) {
                        Map<String, Object> stat = monthlySalesList.get(i);
                        monthLabels.append("\"").append(stat.get("month")).append("\"");
                        salesValues.append(stat.get("sales"));
                        orderValues.append(stat.get("orders"));
                        if (i < monthlySalesList.size() - 1) {
                            monthLabels.append(",");
                            salesValues.append(",");
                            orderValues.append(",");
                        }
                    }
                }
                monthLabels.append("]");
                salesValues.append("]");
                orderValues.append("]");

                StringBuilder bestProductLabels = new StringBuilder("[");
                StringBuilder bestProductQty = new StringBuilder("[");
                if (bestSellersList != null) {
                    for (int i = 0; i < bestSellersList.size(); i++) {
                        Map<String, Object> stat = bestSellersList.get(i);
                        bestProductLabels.append("\"").append(stat.get("name").toString().replace("\"", "\\\"")).append("\"");
                        bestProductQty.append(stat.get("sold"));
                        if (i < bestSellersList.size() - 1) {
                            bestProductLabels.append(",");
                            bestProductQty.append(",");
                        }
                    }
                }
                bestProductLabels.append("]");
                bestProductQty.append("]");
            %>

            const months = <%= monthLabels.toString() %>;
            const sales = <%= salesValues.toString() %>;
            const orders = <%= orderValues.toString() %>;
            const bestProducts = <%= bestProductLabels.toString() %>;
            const bestQuantities = <%= bestProductQty.toString() %>;

            // Mini dashboard chart
            const miniCtx = document.getElementById('miniSalesChart');
            if (miniCtx) {
                new Chart(miniCtx, {
                    type: 'line',
                    data: {
                        labels: months,
                        datasets: [{
                            label: 'Monthly Sales (₹)',
                            data: sales,
                            backgroundColor: 'rgba(92, 13, 30, 0.05)',
                            borderColor: '#5C0D1E',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            y: { grid: { color: 'rgba(0,0,0,0.05)' } },
                            x: { grid: { display: false } }
                        }
                    }
                });
            }

            // Full analytics - sales trends
            const trendsCtx = document.getElementById('monthlySalesChart');
            if (trendsCtx) {
                new Chart(trendsCtx, {
                    type: 'bar',
                    data: {
                        labels: months,
                        datasets: [
                            {
                                label: 'Revenue (₹)',
                                data: sales,
                                backgroundColor: 'rgba(92, 13, 30, 0.85)',
                                borderColor: '#5C0D1E',
                                borderWidth: 1,
                                yAxisID: 'y'
                            },
                            {
                                label: 'Orders Count',
                                data: orders,
                                type: 'line',
                                borderColor: '#C5AB57',
                                backgroundColor: 'transparent',
                                borderWidth: 2,
                                tension: 0.3,
                                yAxisID: 'y1'
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                type: 'linear',
                                display: true,
                                position: 'left',
                                grid: { color: 'rgba(0,0,0,0.05)' }
                            },
                            y1: {
                                type: 'linear',
                                display: true,
                                position: 'right',
                                grid: { drawOnChartArea: false }
                            },
                            x: { grid: { display: false } }
                        }
                    }
                });
            }

            // Full analytics - best sellers
            const sellersCtx = document.getElementById('bestSellersChart');
            if (sellersCtx) {
                new Chart(sellersCtx, {
                    type: 'doughnut',
                    data: {
                        labels: bestProducts,
                        datasets: [{
                            data: bestQuantities,
                            backgroundColor: [
                                '#5C0D1E',
                                '#C5AB57',
                                '#8F8486',
                                '#4E4748',
                                '#E23E57'
                            ],
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'right',
                                labels: { boxWidth: 12, font: { size: 10 } }
                            }
                        }
                    }
                });
            }
        });
    </script>
</body>
</html>
