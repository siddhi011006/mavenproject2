<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%@ page import="java.util.*" %>
<%
    // Verify user ID
    HttpSession s = request.getSession(false);
    Integer userId = null;
    if (s != null) {
        userId = (Integer) s.getAttribute("user_id");
    }

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("product.jsp");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(idStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("product.jsp");
        return;
    }

    // Recently Viewed tracker
    java.util.List<Integer> recentlyViewed = (java.util.List<Integer>) session.getAttribute("recently_viewed");
    if (recentlyViewed == null) {
        recentlyViewed = new java.util.ArrayList<Integer>();
    }
    if (!recentlyViewed.contains(productId)) {
        recentlyViewed.add(0, productId); // add to beginning
        if (recentlyViewed.size() > 5) {
            recentlyViewed.remove(recentlyViewed.size() - 1);
        }
        session.setAttribute("recently_viewed", recentlyViewed);
    }

    String name = "";
    String description = "";
    double price = 0.0;
    String category = "";
    String imageUrl = "";
    int stock = 0;
    int rating = 5;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean found = false;

    try {
        con = DBConnection.getConnection();
        String sql = "SELECT name, description, price, category, image_url, stock, rating FROM products WHERE id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, productId);
        rs = ps.executeQuery();
        if (rs.next()) {
            found = true;
            name = rs.getString("name");
            description = rs.getString("description");
            price = rs.getDouble("price");
            category = rs.getString("category");
            imageUrl = rs.getString("image_url");
            stock = rs.getInt("stock");
            rating = rs.getInt("rating");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }

    if (!found) {
        response.sendRedirect("product.jsp?error=Product not found.");
        return;
    }

    // Check if liked in Wishlist
    boolean isLiked = false;
    if (userId != null) {
        Connection conWish = null;
        PreparedStatement psWish = null;
        ResultSet rsWish = null;
        try {
            conWish = DBConnection.getConnection();
            psWish = conWish.prepareStatement("SELECT id FROM wishlist WHERE user_id = ? AND product_id = ?");
            psWish.setInt(1, userId);
            psWish.setInt(2, productId);
            rsWish = psWish.executeQuery();
            if (rsWish.next()) {
                isLiked = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rsWish != null) try { rsWish.close(); } catch (Exception e) {}
            if (psWish != null) try { psWish.close(); } catch (Exception e) {}
            if (conWish != null) try { conWish.close(); } catch (Exception e) {}
        }
    } else {
        java.util.Set<Integer> guestWishlist = (java.util.Set<Integer>) session.getAttribute("guest_wishlist");
        if (guestWishlist != null && guestWishlist.contains(productId)) {
            isLiked = true;
        }
    }

    // Fetch product variants
    List<Map<String, Object>> variants = new ArrayList<>();
    Connection conVars = null;
    PreparedStatement psVars = null;
    ResultSet rsVars = null;
    try {
        conVars = DBConnection.getConnection();
        String sqlVars = "SELECT id, variant_name, color_code, stock, price FROM product_variants WHERE product_id = ?";
        psVars = conVars.prepareStatement(sqlVars);
        psVars.setInt(1, productId);
        rsVars = psVars.executeQuery();
        while (rsVars.next()) {
            Map<String, Object> v = new HashMap<>();
            v.put("id", rsVars.getInt("id"));
            v.put("variant_name", rsVars.getString("variant_name"));
            v.put("color_code", rsVars.getString("color_code"));
            v.put("stock", rsVars.getInt("stock"));
            double vPrice = rsVars.getDouble("price");
            if (rsVars.wasNull()) {
                v.put("price", null);
            } else {
                v.put("price", vPrice);
            }
            variants.add(v);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rsVars != null) try { rsVars.close(); } catch (Exception e) {}
        if (psVars != null) try { psVars.close(); } catch (Exception e) {}
        if (conVars != null) try { conVars.close(); } catch (Exception e) {}
    }

    // Fallback if no variants exist
    if (variants.isEmpty()) {
        Map<String, Object> defaultV = new HashMap<>();
        defaultV.put("id", null);
        defaultV.put("variant_name", "Standard");
        defaultV.put("color_code", "Standard");
        defaultV.put("stock", stock);
        defaultV.put("price", null); // fallbacks to parent price
        variants.add(defaultV);
    }

    // Fetch product images
    List<Map<String, Object>> productImages = new ArrayList<>();
    Connection conImgs = null;
    PreparedStatement psImgs = null;
    ResultSet rsImgs = null;
    try {
        conImgs = DBConnection.getConnection();
        String sqlImgs = "SELECT id, image_url, sort_order, is_primary, variant_id FROM product_images WHERE product_id = ? ORDER BY sort_order ASC";
        psImgs = conImgs.prepareStatement(sqlImgs);
        psImgs.setInt(1, productId);
        rsImgs = psImgs.executeQuery();
        while (rsImgs.next()) {
            Map<String, Object> img = new HashMap<>();
            img.put("id", rsImgs.getInt("id"));
            img.put("image_url", rsImgs.getString("image_url"));
            img.put("is_primary", rsImgs.getInt("is_primary"));
            int vId = rsImgs.getInt("variant_id");
            if (rsImgs.wasNull()) {
                img.put("variant_id", null);
            } else {
                img.put("variant_id", vId);
            }
            productImages.add(img);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rsImgs != null) try { rsImgs.close(); } catch (Exception e) {}
        if (psImgs != null) try { psImgs.close(); } catch (Exception e) {}
        if (conImgs != null) try { conImgs.close(); } catch (Exception e) {}
    }

    // Fallback if no gallery images exist in table
    if (productImages.isEmpty()) {
        Map<String, Object> defaultImg = new HashMap<>();
        defaultImg.put("id", 0);
        defaultImg.put("image_url", imageUrl);
        defaultImg.put("is_primary", 1);
        defaultImg.put("variant_id", null);
        productImages.add(defaultImg);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= name %> | LuxeGlow Luxury Beauty</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Modern swatch / gallery styles */
        .color-swatch {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 0 0 1px rgba(0,0,0,0.1);
            position: relative;
        }
        .color-swatch:hover {
            transform: scale(1.15);
        }
        .color-swatch.active {
            border-color: var(--burgundy);
            box-shadow: 0 0 0 2px var(--gold);
        }
        .variant-pill {
            padding: 8px 18px;
            border-radius: 20px;
            border: 1px solid var(--border-color);
            background: var(--bg-card);
            color: var(--text-primary);
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .variant-pill:hover {
            border-color: var(--gold);
            background: rgba(197, 171, 87, 0.05);
        }
        .variant-pill.active {
            background: var(--burgundy);
            color: white;
            border-color: var(--burgundy);
            box-shadow: var(--shadow-glow);
        }
        .thumbnail-gallery img {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .thumbnail-gallery img:hover {
            transform: scale(1.05);
        }
        .thumbnail-gallery img.active {
            border-color: var(--gold);
        }
    </style>
</head>
<body>
<!-- Dynamic Glassmorphic Navbar -->
    <%@ include file="navbar.jsp" %>
    <%
        // Fetch user wishlist IDs to highlight liked items
        java.util.Set<Integer> wishlistedIds = new java.util.HashSet<>();
        if (navUserId != null) {
            Connection conWish = null;
            PreparedStatement psWish = null;
            ResultSet rsWish = null;
            try {
                conWish = DBConnection.getConnection();
                psWish = conWish.prepareStatement("SELECT product_id FROM wishlist WHERE user_id = ?");
                psWish.setInt(1, navUserId);
                rsWish = psWish.executeQuery();
                while (rsWish.next()) {
                    wishlistedIds.add(rsWish.getInt("product_id"));
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rsWish != null) try { rsWish.close(); } catch (Exception e) {}
                if (psWish != null) try { psWish.close(); } catch (Exception e) {}
                if (conWish != null) try { conWish.close(); } catch (Exception e) {}
            }
        } else {
            Object rawWish = session.getAttribute("guest_wishlist");
            if (rawWish instanceof java.util.Set) {
                for (Object idObj : (java.util.Set<?>) rawWish) {
                    if (idObj instanceof Number) {
                        wishlistedIds.add(((Number) idObj).intValue());
                    } else {
                        try {
                            wishlistedIds.add(Integer.parseInt(idObj.toString()));
                        } catch (Exception e) {}
                    }
                }
            }
        }
    %>

    <!-- Page Content -->
    <div class="page-container" style="padding: 60px 8%; max-width: 1200px; margin: 0 auto;">
        
        <!-- Action Alerts -->
        <%
            String detailError = request.getParameter("error");
            String detailSuccess = request.getParameter("success");
            if (detailError != null) {
        %>
            <div class="alert alert-danger" style="margin-bottom: 25px;">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= detailError %></span>
            </div>
        <%
            }
            if (detailSuccess != null) {
        %>
            <div class="alert alert-success" style="margin-bottom: 25px;">
                <i class="fas fa-check-circle"></i>
                <span><%= detailSuccess %></span>
            </div>
        <%
            }
        %>

        <div class="product-detail-layout" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 50px; margin-bottom: 60px; align-items: start;">
            
            <!-- Gallery Panel (Dynamic Multi-Image Gallery) -->
            <div style="display: flex; flex-direction: column; gap: 15px; width: 100%;">
                <div class="detail-gallery" style="background: var(--bg-card); border-radius: 20px; overflow: hidden; border: 1px solid var(--border-light); box-shadow: var(--shadow-lux); display:flex; align-items:center; justify-content:center; padding: 20px;">
                    <img id="main-product-img" src="<%= imageUrl %>" alt="<%= name %>" style="width: 100%; max-height: 480px; object-fit: cover; border-radius: 12px; transition: var(--transition);">
                </div>
                <div class="thumbnail-gallery" id="thumbnail-gallery">
                    <!-- Populated dynamically by JS -->
                </div>
            </div>

            <!-- Details Info Panel -->
            <div class="detail-info" style="text-align: left;">
                <span class="detail-meta-category" style="font-size: 0.75rem; font-weight: 600; color: var(--gold); text-transform: uppercase; letter-spacing: 1.5px; display: inline-block; margin-bottom: 10px;"><%= category %></span>
                <h1 style="font-size: 2.4rem; font-family: 'Playfair Display', serif; color: var(--burgundy); font-weight: 700; line-height: 1.2; margin-bottom: 15px;"><%= name %></h1>
                
                <div class="detail-rating" style="color: var(--gold); font-size: 0.9rem; display: flex; align-items: center; gap: 8px; margin-bottom: 20px;">
                    <div>
                        <% for (int i = 0; i < 5; i++) { %>
                            <i class="<%= (i < rating) ? "fas" : "far" %> fa-star"></i>
                        <% } %>
                    </div>
                    <span style="color: var(--text-muted); font-size: 0.8rem; font-weight: 550;">(Dermatologist Clinically Tested)</span>
                </div>

                <div class="detail-price" id="detail-price-display" style="font-size: 1.8rem; font-weight: 700; color: var(--text-primary); margin-bottom: 20px;"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(price, currentCountry) %></div>

                <div class="detail-description" style="color: var(--text-secondary); font-size: 0.95rem; line-height: 1.6; margin-bottom: 25px;">
                    <p><%= description %></p>
                </div>

                <!-- Product Variants Section (Always displayed) -->
                <div class="variant-section" style="margin-bottom: 25px; text-align: left; border-top: 1px solid var(--border-light); padding-top: 20px;">
                    <label style="font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; color: var(--text-secondary); display: block; margin-bottom: 12px;">
                        Shade / Option: <span id="selected-shade-label" style="color: var(--gold); font-weight: 700; margin-left: 5px;">Standard</span>
                    </label>
                    <div id="variant-selectors-list" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
                        <!-- Populated dynamically by JS -->
                    </div>
                </div>

                <!-- Stock Status Indicator -->
                <div class="detail-stock-status" id="stock-status-display" style="font-size: 0.9rem; margin-bottom: 25px; font-weight: 500;">
                    <!-- Populated dynamically by JS -->
                </div>

                <!-- Add To Bag Actions container -->
                <div class="detail-actions" id="detail-actions-container" style="display: flex; gap: 15px; align-items: center; flex-wrap: wrap;">
                    <!-- Populated dynamically by JS -->
                </div>
                
                <div style="margin-top: 35px; border-top: 1px solid var(--border-light); padding-top: 20px;">
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 8px;">
                        <i class="fas fa-truck" style="margin-right: 8px; color: var(--gold); width:16px;"></i> Complimentary shipping on orders <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(75.0, currentCountry) %>+
                    </p>
                    <p style="font-size: 0.85rem; color: var(--text-muted);">
                        <i class="fas fa-undo" style="margin-right: 8px; color: var(--gold); width:16px;"></i> 30-Day Hassle-Free Returns & Shade Exchange
                    </p>
                </div>
            </div>

        </div>

        <!-- Related Products Section -->
        <section class="related-products" style="margin-top: 60px; border-top: 1px solid var(--border-light); padding-top: 40px; text-align:left;">
            <h2 style="font-size: 1.8rem; font-family:'Playfair Display', serif; color:var(--burgundy); margin-bottom: 25px; border-bottom: none;">You May Also Love</h2>
            <div class="products-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 25px;">
                <%
                    Connection conRel = null;
                    PreparedStatement psRel = null;
                    ResultSet rsRel = null;
                    int relCount = 0;
                    try {
                        conRel = DBConnection.getConnection();
                        String relSql = "SELECT id, name, price, category, image_url, rating FROM products WHERE category = ? AND id != ? LIMIT 4";
                        psRel = conRel.prepareStatement(relSql);
                        psRel.setString(1, category);
                        psRel.setInt(2, productId);
                        rsRel = psRel.executeQuery();
                        while (rsRel.next()) {
                            relCount++;
                            int relId = rsRel.getInt("id");
                            String relName = rsRel.getString("name");
                            double relPrice = rsRel.getDouble("price");
                            String relCat = rsRel.getString("category");
                            String relImg = rsRel.getString("image_url");
                            int relRate = rsRel.getInt("rating");
                %>
                <div class="card" style="background: var(--bg-card); border-radius: 12px; border: 1px solid var(--border-light); overflow: hidden; box-shadow: var(--shadow-lux); transition: var(--transition);">
                    <div class="card-image-wrapper" style="height: 220px; overflow: hidden; position: relative;">
                         <button class="wishlist-heart-btn <%= wishlistedIds.contains(relId) ? "liked" : "" %>" 
                                 data-product-id="<%= relId %>" 
                                 onclick="toggleWishlist(event, <%= relId %>)" 
                                 title="<%= wishlistedIds.contains(relId) ? "Remove from Wishlist" : "Add to Wishlist" %>"
                                 style="position: absolute; top: 10px; right: 10px; z-index: 2; border: none; background: rgba(255,255,255,0.8); border-radius: 50%; width: 32px; height: 32px; cursor: pointer; display: flex; align-items: center; justify-content: center;">
                             <i class="<%= wishlistedIds.contains(relId) ? "fas" : "far" %> fa-heart" style="color: var(--burgundy);"></i>
                         </button>
                        <a href="product-details.jsp?id=<%= relId %>">
                            <img src="<%= relImg %>" alt="<%= relName %>" style="width: 100%; height: 100%; object-fit: cover; transition: var(--transition);">
                        </a>
                    </div>
                    <div class="card-content" style="padding: 18px;">
                        <div style="font-size: 0.65rem; font-weight:600; color:var(--gold); text-transform:uppercase; letter-spacing:1px; margin-bottom:5px;"><%= relCat %></div>
                        <a href="product-details.jsp?id=<%= relId %>" style="text-decoration:none;">
                            <h3 style="font-size: 0.95rem; margin-bottom: 5px; font-family:'Playfair Display', serif; color: var(--burgundy); font-weight:600;"><%= relName %></h3>
                        </a>
                        <div style="color: var(--gold); font-size: 0.75rem; margin-bottom: 12px;">
                            <% for (int i = 0; i < 5; i++) { %>
                                <i class="<%= (i < relRate) ? "fas" : "far" %> fa-star"></i>
                            <% } %>
                        </div>
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <span style="font-weight: 700; font-size:0.95rem; color:var(--text-primary);"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(relPrice, currentCountry) %></span>
                            <button onclick="ajaxAddToCart(<%= relId %>)" style="background:var(--burgundy); border:none; color:white; width:32px; height:32px; border-radius:50%; display:flex; align-items:center; justify-content:center; cursor:pointer;"><i class="fas fa-shopping-bag" style="font-size:0.8rem;"></i></button>
                        </div>
                    </div>
                </div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rsRel != null) try { rsRel.close(); } catch (Exception e) {}
                        if (psRel != null) try { psRel.close(); } catch (Exception e) {}
                        if (conRel != null) try { conRel.close(); } catch (Exception e) {}
                    }
                    if (relCount == 0) {
                        out.println("<p style='color:var(--text-muted); grid-column:1/-1;'>Explore our shop for matching luxury cosmetics.</p>");
                    }
                %>
            </div>
        </section>

        <!-- Recently Viewed Section -->
        <%
            if (recentlyViewed != null && recentlyViewed.size() > 1) {
        %>
        <section class="recently-viewed" style="margin-top: 60px; border-top: 1px solid var(--border-light); padding-top: 40px; text-align:left;">
            <h2 style="font-size: 1.8rem; font-family:'Playfair Display', serif; color:var(--burgundy); margin-bottom: 25px; border-bottom: none;">Recently Viewed</h2>
            <div class="products-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 25px;">
                <%
                    Connection conRec = null;
                    PreparedStatement psRec = null;
                    ResultSet rsRec = null;
                    try {
                        conRec = DBConnection.getConnection();
                        // Build string of IDs like (id1, id2, ...) excluding current product
                        StringBuilder sb = new StringBuilder("(");
                        int added = 0;
                        for (int rId : recentlyViewed) {
                            if (rId != productId) {
                                    if (added > 0) sb.append(",");
                                    sb.append(rId);
                                    added++;
                            }
                        }
                        sb.append(")");
                        
                        if (added > 0) {
                            String recSql = "SELECT id, name, price, category, image_url, rating FROM products WHERE id IN " + sb.toString() + " LIMIT 4";
                            psRec = conRec.prepareStatement(recSql);
                            rsRec = psRec.executeQuery();
                            while (rsRec.next()) {
                                int recId = rsRec.getInt("id");
                                String recName = rsRec.getString("name");
                                double recPrice = rsRec.getDouble("price");
                                String recCat = rsRec.getString("category");
                                String recImg = rsRec.getString("image_url");
                                int recRate = rsRec.getInt("rating");
                %>
                <div class="card" style="background: var(--bg-card); border-radius: 12px; border: 1px solid var(--border-light); overflow: hidden; box-shadow: var(--shadow-lux); transition: var(--transition);">
                    <div class="card-image-wrapper" style="height: 180px; overflow: hidden; position: relative;">
                          <button class="wishlist-heart-btn <%= wishlistedIds.contains(recId) ? "liked" : "" %>" 
                                  data-product-id="<%= recId %>" 
                                  onclick="toggleWishlist(event, <%= recId %>)" 
                                  title="<%= wishlistedIds.contains(recId) ? "Remove from Wishlist" : "Add to Wishlist" %>"
                                  style="position: absolute; top: 10px; right: 10px; z-index: 2; border: none; background: rgba(255,255,255,0.8); border-radius: 50%; width: 32px; height: 32px; cursor: pointer; display: flex; align-items: center; justify-content: center;">
                              <i class="<%= wishlistedIds.contains(recId) ? "fas" : "far" %> fa-heart" style="color: var(--burgundy);"></i>
                          </button>
                        <a href="product-details.jsp?id=<%= recId %>">
                            <img src="<%= recImg %>" alt="<%= recName %>" style="width: 100%; height: 100%; object-fit: cover;">
                        </a>
                    </div>
                    <div class="card-content" style="padding: 15px;">
                        <div style="font-size: 0.65rem; font-weight:600; color:var(--gold); text-transform:uppercase; letter-spacing:1px; margin-bottom:5px;"><%= recCat %></div>
                        <a href="product-details.jsp?id=<%= recId %>" style="text-decoration:none;">
                            <h3 style="font-size: 0.9rem; margin-bottom: 5px; font-family:'Playfair Display', serif; color:var(--burgundy); font-weight:600;"><%= recName %></h3>
                        </a>
                        <div style="color: var(--gold); font-size: 0.75rem; margin-bottom: 10px;">
                            <% for (int i = 0; i < 5; i++) { %>
                                <i class="<%= (i < recRate) ? "fas" : "far" %> fa-star"></i>
                            <% } %>
                        </div>
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <span style="font-weight: 700; font-size:0.9rem; color:var(--text-primary);"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(recPrice, currentCountry) %></span>
                            <button onclick="ajaxAddToCart(<%= recId %>)" style="background:var(--burgundy); border:none; color:white; width:30px; height:30px; border-radius:50%; display:flex; align-items:center; justify-content:center; cursor:pointer;"><i class="fas fa-shopping-bag" style="font-size:0.75rem;"></i></button>
                        </div>
                    </div>
                </div>
                <%
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rsRec != null) try { rsRec.close(); } catch (Exception e) {}
                        if (psRec != null) try { psRec.close(); } catch (Exception e) {}
                        if (conRec != null) try { conRec.close(); } catch (Exception e) {}
                    }
                %>
            </div>
        </section>
        <%
            }
        %>

        <!-- Dynamic Reviews Section -->
        <div class="reviews-container" style="margin-top: 60px; border-top: 1px solid var(--border-light); padding-top: 40px; text-align:left;">
            <h2 style="font-size: 1.8rem; font-family:'Playfair Display', serif; color:var(--burgundy); margin-bottom: 25px; border-bottom:none;">Customer Reviews</h2>
            
            <%
                Connection conRev = null;
                PreparedStatement psRev = null;
                ResultSet rsRev = null;
                int revCount = 0;
                try {
                    conRev = DBConnection.getConnection();
                    String revSql = "SELECT r.id, r.user_id, r.rating, r.review_text, r.created_at, u.fullname FROM reviews r "
                                  + "JOIN users u ON r.user_id = u.id WHERE r.product_id = ? ORDER BY r.created_at DESC";
                    psRev = conRev.prepareStatement(revSql);
                    psRev.setInt(1, productId);
                    rsRev = psRev.executeQuery();
                    while (rsRev.next()) {
                        revCount++;
                        int revId = rsRev.getInt("id");
                        int revUserId = rsRev.getInt("user_id");
                        int revRating = rsRev.getInt("rating");
                        String revText = rsRev.getString("review_text");
                        String revAuthor = rsRev.getString("fullname");
                        Timestamp revDate = rsRev.getTimestamp("created_at");
            %>
            <div class="review-item" id="review-<%= revId %>" style="border-bottom: 1px solid var(--border-light); padding: 25px 0;">
                <div class="review-header" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                    <div>
                        <span class="review-author" style="font-weight: 600; font-size: 0.95rem; color: var(--text-primary);"><%= revAuthor %></span>
                        <span class="review-rating" style="color: var(--gold); font-size: 0.8rem; margin-left: 10px;">
                            <% for (int i = 0; i < 5; i++) { %>
                                <i class="<%= (i < revRating) ? "fas" : "far" %> fa-star"></i>
                            <% } %>
                        </span>
                    </div>
                    <% if (userId != null && userId.equals(revUserId)) { %>
                        <div style="display: flex; gap: 15px;">
                            <button onclick="toggleEditReview(<%= revId %>)" style="background:none; border:none; color:var(--gold); cursor:pointer; font-size:0.8rem; font-weight:600;"><i class="fas fa-edit"></i> Edit</button>
                            <form action="ReviewServlet" method="POST" style="margin:0;" onsubmit="return confirm('Are you sure you want to delete this review?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="reviewId" value="<%= revId %>">
                                <input type="hidden" name="productId" value="<%= productId %>">
                                <button type="submit" style="background:none; border:none; color:var(--danger); cursor:pointer; font-size:0.8rem; font-weight:600;"><i class="fas fa-trash"></i> Delete</button>
                            </form>
                        </div>
                    <% } %>
                </div>
                <div class="review-text" style="margin-top: 10px; font-size: 0.9rem; color: var(--text-secondary);"><%= revText %></div>
                <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 8px;"><%= revDate %></div>

                <% if (userId != null && userId.equals(revUserId)) { %>
                    <!-- Hidden edit form -->
                    <div id="edit-form-<%= revId %>" style="display:none; margin-top:15px; padding:20px; border:1px solid var(--border-color); border-radius:12px; background:rgba(0,0,0,0.01);">
                        <form action="ReviewServlet" method="POST">
                            <input type="hidden" name="action" value="edit">
                            <input type="hidden" name="reviewId" value="<%= revId %>">
                            <input type="hidden" name="productId" value="<%= productId %>">
                            <div class="form-group" style="margin-bottom:15px;">
                                <label style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Rating</label>
                                <select name="rating" style="padding:8px 16px; border-radius:30px; border: 1px solid var(--border-color); font-size:0.8rem; outline:none;">
                                    <option value="5" <%= revRating == 5 ? "selected" : "" %>>5 Stars</option>
                                    <option value="4" <%= revRating == 4 ? "selected" : "" %>>4 Stars</option>
                                    <option value="3" <%= revRating == 3 ? "selected" : "" %>>3 Stars</option>
                                    <option value="2" <%= revRating == 2 ? "selected" : "" %>>2 Stars</option>
                                    <option value="1" <%= revRating == 1 ? "selected" : "" %>>1 Star</option>
                                </select>
                            </div>
                            <div class="form-group" style="margin-bottom:15px;">
                                <label style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Your Review</label>
                                <textarea name="reviewText" rows="3" style="width:100%; padding:12px 18px; border-radius:12px; font-size:0.85rem; border:1px solid var(--border-color); outline:none;" required><%= revText %></textarea>
                            </div>
                            <button type="submit" class="btn-gold" style="padding:8px 20px; font-size:0.75rem; border-radius:20px; margin:0;">Update</button>
                            <button type="button" onclick="toggleEditReview(<%= revId %>)" class="btn-outline" style="padding:7px 18px; font-size:0.75rem; border-radius:20px; margin-left:10px;">Cancel</button>
                        </form>
                    </div>
                <% } %>
            </div>
            <%
                    }
                } catch (Exception e) {
                    out.println("<p style='color:var(--danger);'>Error loading reviews: " + e.getMessage() + "</p>");
                } finally {
                    if (rsRev != null) try { rsRev.close(); } catch (Exception e) {}
                    if (psRev != null) try { psRev.close(); } catch (Exception e) {}
                    if (conRev != null) try { conRev.close(); } catch (Exception e) {}
                }

                if (revCount == 0) {
            %>
                <p style="color:var(--text-secondary); margin-bottom: 25px;">No reviews yet. Be the first to review this formula!</p>
            <% } %>

            <!-- Add Review Form -->
            <% if (userId != null) { %>
                <div style="background:var(--bg-card); border:1px solid var(--border-light); border-radius:24px; padding:30px; margin-top:35px; box-shadow:var(--shadow-lux);">
                    <h3 style="font-family:'Playfair Display', serif; color:var(--burgundy); font-size:1.3rem; margin-bottom:20px;">Write a Review</h3>
                    <form action="ReviewServlet" method="POST">
                        <input type="hidden" name="productId" value="<%= productId %>">
                        
                        <div class="form-group" style="margin-bottom: 20px;">
                            <label style="font-size: 0.85rem; font-weight: 600; display:block; margin-bottom: 8px;">Select Rating</label>
                            <select name="rating" required style="width:160px; border-radius:30px; padding: 10px 18px; border: 1px solid var(--border-color); outline:none;">
                                <option value="5">5 Stars</option>
                                <option value="4">4 Stars</option>
                                <option value="3">3 Stars</option>
                                <option value="2">2 Stars</option>
                                <option value="1">1 Star</option>
                            </select>
                        </div>
                        
                        <div class="form-group" style="margin-bottom: 20px;">
                            <label style="font-size: 0.85rem; font-weight: 600; display:block; margin-bottom: 8px;">Review Comments</label>
                            <textarea name="reviewText" rows="4" placeholder="How did this luxury beauty formula perform? Shade match, texture, wear-time..." required style="width: 100%; border-radius: 12px; padding: 15px; border: 1px solid var(--border-color); outline:none; font-size:0.9rem;"></textarea>
                        </div>
                        
                        <button type="submit" class="btn-gold" style="border-radius:30px; font-size:0.85rem; padding:12px 30px; margin: 0;">Submit Review</button>
                    </form>
                </div>
            <% } else { %>
                <div style="background:var(--bg-card); border:1px solid var(--border-light); border-radius:24px; padding:30px; margin-top:35px; text-align:center; box-shadow:var(--shadow-lux);">
                    <p style="color:var(--text-secondary); font-size:0.95rem;">
                        Please <a href="login.jsp" style="text-decoration:underline; font-weight:600; color:var(--burgundy);">Sign In</a> to write a review.
                    </p>
                </div>
            <% } %>
        </div>

    </div>

    <!-- Include Reusable Footer -->
    <%@ include file="footer.jsp" %>

    <script>
        // JS variables containing dynamic variant and image datasets
        const defaultProductImage = "<%= imageUrl %>";
        const parentPrice = <%= price %>;
        
        const productVariants = [
            <% for (Map<String, Object> v : variants) { %>
            {
                id: <%= v.get("id") != null ? v.get("id") : "null" %>,
                name: "<%= v.get("variant_name").toString().replace("\"", "\\\"") %>",
                colorCode: "<%= v.get("color_code").toString().replace("\"", "\\\"") %>",
                stock: <%= v.get("stock") %>,
                price: <%= v.get("price") != null ? v.get("price") : "null" %>
            },
            <% } %>
        ];

        const productImages = [
            <% for (Map<String, Object> img : productImages) { %>
            {
                id: <%= img.get("id") %>,
                imageUrl: "<%= img.get("image_url").toString().replace("\"", "\\\"") %>",
                isPrimary: <%= img.get("is_primary") %>,
                variantId: <%= img.get("variant_id") != null ? img.get("variant_id") : "null" %>
            },
            <% } %>
        ];

        let selectedVariantId = null;
        let selectedVariantStock = 0;

        function toggleEditReview(revId) {
            const el = document.getElementById('edit-form-' + revId);
            if (el.style.display === 'none') {
                el.style.display = 'block';
            } else {
                el.style.display = 'none';
            }
        }

        // Dynamic JS Localization settings
        const currentCountry = "<%= currentCountry %>";
        const currencySymbol = "<%= com.mycompany.mavenproject2.CurrencyHelper.getCurrencySymbol(currentCountry) %>";
        const conversionRate = <%= com.mycompany.mavenproject2.CurrencyHelper.convert(1.0, currentCountry) %>;
        
        function formatCurrency(valInInr) {
            const converted = valInInr * conversionRate;
            if (currencySymbol === "د.إ") {
                return currencySymbol + " " + converted.toFixed(2);
            }
            return currencySymbol + converted.toFixed(2);
        }

        // Initialize selectors and gallery on load
        document.addEventListener('DOMContentLoaded', () => {
            renderVariants();
            // Automatically select first variant
            if (productVariants.length > 0) {
                selectVariant(productVariants[0].id, productVariants[0].colorCode);
            }
        });

        function renderVariants() {
            const container = document.getElementById('variant-selectors-list');
            container.innerHTML = '';
            
            productVariants.forEach(v => {
                const isColor = v.colorCode.startsWith('#');
                let el;
                if (isColor) {
                    el = document.createElement('div');
                    el.className = 'color-swatch';
                    el.style.backgroundColor = v.colorCode;
                    el.setAttribute('title', v.name);
                    el.setAttribute('id', 'variant-selector-' + (v.id !== null ? v.id : 'default'));
                    el.addEventListener('click', () => selectVariant(v.id, v.colorCode));
                } else {
                    el = document.createElement('button');
                    el.className = 'variant-pill';
                    el.innerText = v.name;
                    el.setAttribute('id', 'variant-selector-' + (v.id !== null ? v.id : 'default'));
                    el.addEventListener('click', () => selectVariant(v.id, v.colorCode));
                }
                container.appendChild(el);
            });
        }

        function selectVariant(id, colorCode) {
            // Update active states
            const swatches = document.querySelectorAll('.color-swatch');
            swatches.forEach(s => s.classList.remove('active'));
            const pills = document.querySelectorAll('.variant-pill');
            pills.forEach(p => p.classList.remove('active'));

            const targetId = 'variant-selector-' + (id !== null ? id : 'default');
            const targetEl = document.getElementById(targetId);
            if (targetEl) {
                targetEl.classList.add('active');
            }

            // Find selected variant object
            const variant = productVariants.find(v => (v.id === id) || (v.id === null && id === null));
            if (!variant) return;

            selectedVariantId = variant.id;
            selectedVariantStock = variant.stock;

            // 1. Update shade name label
            document.getElementById('selected-shade-label').innerText = variant.name;

            // 2. Update price override
            const activePrice = variant.price !== null ? variant.price : parentPrice;
            document.getElementById('detail-price-display').innerText = formatCurrency(activePrice);

            // 3. Update stock display & action buttons
            const stockDisplay = document.getElementById('stock-status-display');
            const actionContainer = document.getElementById('detail-actions-container');

            if (selectedVariantStock > 10) {
                stockDisplay.innerHTML = `Availability: <span class="stock-in" style="color: var(--success); font-weight: 600;"><i class="fas fa-check-circle" style="margin-right:5px;"></i> In Stock (${selectedVariantStock} available)</span>`;
            } else if (selectedVariantStock > 0) {
                stockDisplay.innerHTML = `Availability: <span class="stock-low" style="color: var(--warning); font-weight: 600;"><i class="fas fa-exclamation-circle" style="margin-right:5px;"></i> Low Stock (Only ${selectedVariantStock} left)</span>`;
            } else {
                stockDisplay.innerHTML = `Availability: <span class="stock-out" style="color: var(--danger); font-weight: 600;"><i class="fas fa-times-circle" style="margin-right:5px;"></i> Out of Stock</span>`;
            }

            // Re-render Qty selector and buttons
            if (selectedVariantStock > 0) {
                actionContainer.innerHTML = `
                    <div class="qty-selector" style="display: flex; align-items: center; border: 1px solid var(--border-color); border-radius: 30px; background: var(--bg-card); overflow: hidden; height: 48px;">
                        <button class="qty-btn" type="button" onclick="decrementQty()" style="border: none; background: transparent; padding: 0 16px; font-size: 1.1rem; cursor: pointer; color: var(--text-secondary); height: 100%;">&minus;</button>
                        <input class="qty-input" type="text" id="qtyInput" value="1" readonly style="border: none; background: transparent; text-align: center; width: 40px; font-weight: 600; font-size: 0.9rem; color: var(--text-primary);">
                        <button class="qty-btn" type="button" onclick="incrementQty(${selectedVariantStock})" style="border: none; background: transparent; padding: 0 16px; font-size: 1.1rem; cursor: pointer; color: var(--text-secondary); height: 100%;">&plus;</button>
                    </div>
                    <button class="btn-gold" style="border-radius:30px; font-size:0.85rem; padding: 14px 35px; min-width: 160px; margin:0;" onclick="addSelectedToCart()">
                        <i class="fas fa-shopping-bag" style="margin-right:8px;"></i> Add To Bag
                    </button>
                    <button class="wishlist-heart-btn <%= isLiked ? "liked" : "" %>" data-product-id="<%= productId %>" onclick="toggleWishlist(event, <%= productId %>)" title="<%= isLiked ? "Remove from Wishlist" : "Add to Wishlist" %>" 
                            style="position: relative !important; top: auto !important; right: auto !important; width: 48px; height: 48px; border: 1px solid var(--border-color); border-radius: 50%; display: flex; align-items: center; justify-content: center; background: var(--bg-card); cursor: pointer; transition: var(--transition);">
                        <i class="<%= isLiked ? "fas" : "far" %> fa-heart" style="font-size:1.2rem; color: var(--burgundy);"></i>
                    </button>
                `;
            } else {
                actionContainer.innerHTML = `
                    <button class="btn-outline" style="border-radius:30px; cursor:not-allowed; opacity: 0.6; padding: 14px 35px; min-width: 160px; margin:0;" disabled>
                        Sold Out
                    </button>
                    <button class="wishlist-heart-btn <%= isLiked ? "liked" : "" %>" data-product-id="<%= productId %>" onclick="toggleWishlist(event, <%= productId %>)" title="<%= isLiked ? "Remove from Wishlist" : "Add to Wishlist" %>" 
                            style="position: relative !important; top: auto !important; right: auto !important; width: 48px; height: 48px; border: 1px solid var(--border-color); border-radius: 50%; display: flex; align-items: center; justify-content: center; background: var(--bg-card); cursor: pointer; transition: var(--transition);">
                        <i class="<%= isLiked ? "fas" : "far" %> fa-heart" style="font-size:1.2rem; color: var(--burgundy);"></i>
                    </button>
                `;
            }

            // 4. Update image gallery
            updateGallery(id);
        }

        function updateGallery(variantId) {
            // Filter images: matching variantId
            let filtered = productImages.filter(img => img.variantId === variantId);
            
            // Fallback: If variant has no specific images, display images where variantId is NULL
            if (filtered.length === 0) {
                filtered = productImages.filter(img => img.variantId === null);
            }

            // If still empty, display default product photo
            if (filtered.length === 0) {
                filtered = [{ id: 0, imageUrl: defaultProductImage }];
            }

            // Render thumbnails
            const thumbContainer = document.getElementById('thumbnail-gallery');
            thumbContainer.innerHTML = '';
            
            if (filtered.length > 1) {
                filtered.forEach((img, index) => {
                    const imgEl = document.createElement('img');
                    imgEl.src = img.imageUrl;
                    imgEl.alt = 'Product view';
                    if (index === 0) imgEl.className = 'active';
                    imgEl.addEventListener('click', () => {
                        // Update main image
                        document.getElementById('main-product-img').src = img.imageUrl;
                        // Update active class
                        const thumbs = thumbContainer.querySelectorAll('img');
                        thumbs.forEach(t => t.classList.remove('active'));
                        imgEl.className = 'active';
                    });
                    thumbContainer.appendChild(imgEl);
                });
            }

            // Update main image to first filtered image
            document.getElementById('main-product-img').src = filtered[0].imageUrl;
        }

        // Qty Increment & Decrement Handlers
        function incrementQty(maxStock) {
            const input = document.getElementById('qtyInput');
            let current = parseInt(input.value);
            if (current < maxStock) {
                input.value = current + 1;
            } else {
                showToast("Maximum available stock reached.", "warning");
            }
        }

        function decrementQty() {
            const input = document.getElementById('qtyInput');
            let current = parseInt(input.value);
            if (current > 1) {
                input.value = current - 1;
            }
        }

        // AJAX Add to Cart
        function addSelectedToCart() {
            const qty = parseInt(document.getElementById('qtyInput').value);
            const params = new URLSearchParams();
            params.append('action', 'add');
            params.append('productId', '<%= productId %>');
            params.append('quantity', qty);
            if (selectedVariantId !== null) {
                params.append('variantId', selectedVariantId);
            }

            fetch('CartServlet', {
                method: 'POST',
                body: params,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    const el = document.getElementById('cartCount');
                    if (el) el.innerText = data.count;
                    showToast(qty + " item(s) added to your shopping bag.");
                } else {
                    showToast("Error: " + data.error, "danger");
                }
            })
            .catch(err => {
                console.error(err);
                showToast("Please log in or try again.", "warning");
            });
        }

        document.addEventListener('click', function(e) {
            const dropdowns = document.querySelectorAll('.profile-menu .dropdown');
            dropdowns.forEach(d => {
                if (d.previousElementSibling && !d.previousElementSibling.contains(e.target) && !d.contains(e.target)) {
                    d.style.display = 'none';
                }
            });
        });
    </script>
</body>
</html>
