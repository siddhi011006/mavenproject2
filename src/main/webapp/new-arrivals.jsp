<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Arrivals | LuxeGlow</title>
    <!-- Core & Specific Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .collection-hero {
            background: linear-gradient(rgba(92, 13, 30, 0.6), rgba(92, 13, 30, 0.8)), url('image/glowserum.jpg') no-repeat center center;
            background-size: cover;
            color: var(--bg-dark);
            text-align: center;
            padding: 80px 20px;
            margin-bottom: 40px;
            border-radius: 0 0 40px 40px;
            box-shadow: var(--shadow-lux);
        }
        .collection-hero h1 {
            font-size: 3rem;
            color: var(--bg-dark);
            margin-bottom: 10px;
            font-family: 'Playfair Display', serif;
        }
        .collection-hero p {
            font-size: 1.1rem;
            letter-spacing: 1px;
            opacity: 0.9;
        }
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
            margin-top: 20px;
        }
        /* Custom card additions to align with index.css standards */
        .card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: var(--shadow-lux);
            transition: var(--transition);
            position: relative;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(92, 13, 30, 0.08);
            border-color: rgba(197, 171, 87, 0.3);
        }
        .card-image-wrapper {
            height: 320px;
            overflow: hidden;
            position: relative;
            background: #faf8f5;
        }
        .card-image-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: var(--transition);
        }
        .card:hover .card-image-wrapper img {
            transform: scale(1.05);
        }
        .card-content {
            padding: 24px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        .card-category {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            color: var(--gold);
            letter-spacing: 1.5px;
            margin-bottom: 8px;
        }
        .card-content h3 {
            font-size: 1.15rem;
            color: var(--text-primary);
            margin-bottom: 8px;
            font-family: 'Playfair Display', serif;
            font-weight: 600;
        }
        .card-rating {
            color: var(--gold);
            font-size: 0.8rem;
            margin-bottom: 15px;
        }
        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
            padding-top: 15px;
            border-top: 1px solid var(--border-light);
        }
        .card-footer .price {
            font-weight: 700;
            font-size: 1.2rem;
            color: var(--burgundy);
        }
        .add-to-cart-btn {
            background: var(--burgundy);
            color: var(--bg-dark);
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: var(--transition);
        }
        .add-to-cart-btn:hover {
            background: var(--gold);
            color: var(--burgundy);
            transform: scale(1.1);
        }
        .new-badge {
            position: absolute;
            top: 20px;
            left: 20px;
            background: var(--gold);
            color: var(--burgundy);
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 6px 14px;
            border-radius: 30px;
            z-index: 10;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
<!-- Include Glassmorphic Header -->
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

    <!-- Hero Section -->
    <header class="collection-hero">
        <h1>New Arrivals</h1>
        <p>Be the first to experience our latest clinical formulations and runway shades.</p>
    </header>

    <div class="page-container">
        
        <section class="products-grid">
            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                int count = 0;
                
                try {
                    con = DBConnection.getConnection();
                    // Fetch top 8 newest products (ACTIVE only)
                    String sql = "SELECT id, name, description, price, category, rating FROM products WHERE status = 'ACTIVE' ORDER BY id DESC LIMIT 8";
                    ps = con.prepareStatement(sql);
                    rs = ps.executeQuery();
                    
                    while (rs.next()) {
                        count++;
                        int id = rs.getInt("id");
                        String name = rs.getString("name");
                        double price = rs.getDouble("price");
                        String category = rs.getString("category");
                        String imageUrl = com.mycompany.mavenproject2.ProductImageHelper.getProductImage(id);
                        int rating = rs.getInt("rating");
            %>
            <div class="card">
                <span class="new-badge">New Formula</span>
                <div class="card-image-wrapper">
                    <button class="wishlist-heart-btn <%= wishlistedIds.contains(id) ? "liked" : "" %>" 
                            data-product-id="<%= id %>" 
                            onclick="toggleWishlist(event, <%= id %>)" 
                            title="<%= wishlistedIds.contains(id) ? "Remove from Wishlist" : "Add to Wishlist" %>">
                        <i class="<%= wishlistedIds.contains(id) ? "fas" : "far" %> fa-heart"></i>
                    </button>
                    <a href="product-details.jsp?id=<%= id %>">
                        <img src="<%= imageUrl %>" alt="<%= name %>">
                    </a>
                </div>
                <div class="card-content">
                    <div class="card-category"><%= category %></div>
                    <a href="product-details.jsp?id=<%= id %>">
                        <h3><%= name %></h3>
                    </a>
                    <div class="card-rating">
                        <% for (int i = 0; i < 5; i++) { %>
                            <i class="<%= (i < rating) ? "fas" : "far" %> fa-star"></i>
                        <% } %>
                    </div>
                    <div class="card-footer">
                        <div class="price"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(price, currentCountry) %></div>
                        <button class="add-to-cart-btn" onclick="ajaxAddToCart(<%= id %>)" title="Add to Bag">
                            <i class="fas fa-shopping-bag"></i>
                        </button>
                    </div>
                </div>
            </div>
            <%
                    }
                } catch (Exception e) {
                    out.println("<p style='color:var(--danger); grid-column: 1/-1;'>Database Error: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                    if (ps != null) try { ps.close(); } catch (Exception e) {}
                    if (con != null) try { con.close(); } catch (Exception e) {}
                }
            %>
        </section>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>

    <script>


        // AJAX Add to Cart
        function ajaxAddToCart(productId) {
            const params = new URLSearchParams();
            params.append('action', 'add');
            params.append('productId', productId);
            params.append('quantity', 1);

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
                    showToast("Product added to your shopping bag.");
                } else {
                    showToast("Error adding product: " + data.error, "danger");
                }
            })
            .catch(err => {
                console.error(err);
                showToast("Please log in or try again.", "warning");
            });
        }
    </script>
</body>
</html>

