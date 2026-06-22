<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%@ page import="com.mycompany.mavenproject2.CartItem" %>
<%
    // Check authentication
    HttpSession s = request.getSession(false);
    Integer userId = null;
    if (s != null) {
        userId = (Integer) s.getAttribute("user_id");
    }

    java.util.List<CartItem> wishlistItems = new java.util.ArrayList<>();
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    if (userId != null) {
        try {
            con = DBConnection.getConnection();
            String sql = "SELECT p.id, p.name, p.price, p.category, p.stock, p.rating "
                       + "FROM wishlist w JOIN products p ON w.product_id = p.id WHERE w.user_id = ? AND p.status = 'ACTIVE'";
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                int itemId = rs.getInt("id");
                CartItem item = new CartItem(
                    itemId,
                    rs.getString("name"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    com.mycompany.mavenproject2.ProductImageHelper.getProductImage(itemId),
                    1, // quantity placeholder
                    rs.getInt("stock")
                );
                // Borrow stock or rating property
                item.stock = rs.getInt("rating"); // save rating temporarily here to display stars
                wishlistItems.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    } else {
        // Session-backed guest wishlist
        Object rawWishlist = session.getAttribute("guest_wishlist");
        if (rawWishlist instanceof java.util.Set) {
            java.util.Set<?> guestWishlist = (java.util.Set<?>) rawWishlist;
            if (!guestWishlist.isEmpty()) {
                try {
                    con = DBConnection.getConnection();
                    String sql = "SELECT id, name, price, category, stock, rating FROM products WHERE id = ? AND status = 'ACTIVE'";
                    ps = con.prepareStatement(sql);
                    for (Object idObj : guestWishlist) {
                        int prodId = 0;
                        try {
                            prodId = Integer.parseInt(idObj.toString());
                        } catch (Exception e) {
                            continue;
                        }
                        ps.setInt(1, prodId);
                        rs = ps.executeQuery();
                        if (rs.next()) {
                            CartItem item = new CartItem(
                                prodId,
                                rs.getString("name"),
                                rs.getDouble("price"),
                                rs.getString("category"),
                                com.mycompany.mavenproject2.ProductImageHelper.getProductImage(prodId),
                                1,
                                rs.getInt("stock")
                            );
                            item.stock = rs.getInt("rating"); // store rating
                            wishlistItems.add(item);
                        }
                        rs.close();
                        rs = null;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                    if (ps != null) try { ps.close(); } catch (Exception e) {}
                    if (con != null) try { con.close(); } catch (Exception e) {}
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Wishlist | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <div class="page-container">
        
        <h1 class="title-center" style="font-size: 2.5rem; margin-bottom: 40px;">My Wishlist</h1>

        <% if (wishlistItems.isEmpty()) { %>
            <!-- Empty Wishlist State -->
            <div style="text-align: center; padding: 60px 20px; background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 24px; max-width: 600px; margin: 0 auto; box-shadow: var(--shadow-lux);">
                <i class="far fa-heart" style="font-size: 4rem; color: var(--gold); margin-bottom: 20px; opacity: 0.6;"></i>
                <h3 style="font-size: 1.5rem; margin-bottom: 10px;">Your Wishlist is Empty</h3>
                <p style="color: var(--text-secondary); margin-bottom: 25px;">Keep track of products you love. Click the heart icon on any card to add them here.</p>
                <a href="product.jsp" class="btn-gold">Explore Products</a>
            </div>
        <% } else { %>
            <!-- Wishlist Products Grid -->
            <div class="products-grid">
                <% for (CartItem item : wishlistItems) { %>
                <div class="card" id="card-<%= item.productId %>">
                    <button class="wishlist-heart-btn liked" onclick="removeFromWishlist(<%= item.productId %>)" title="Remove from Wishlist">
                        <i class="fas fa-heart"></i>
                    </button>
                    
                    <div class="card-image-wrapper">
                        <a href="product-details.jsp?id=<%= item.productId %>">
                            <img src="<%= item.imageUrl %>" alt="<%= item.name %>">
                        </a>
                    </div>
                    
                    <div class="card-content">
                        <div class="card-category"><%= item.category %></div>
                        <a href="product-details.jsp?id=<%= item.productId %>">
                            <h3><%= item.name %></h3>
                        </a>
                        <div class="card-rating">
                            <% for (int i = 0; i < 5; i++) { %>
                                <i class="<%= (i < item.stock) ? "fas" : "far" %> fa-star"></i>
                            <% } %>
                        </div>
                        <div class="card-footer">
                            <div class="price"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(item.price, currentCountry) %></div>
                            <div style="display: flex; gap: 8px;">
                                <button class="wishlist-remove-btn" onclick="removeFromWishlist(<%= item.productId %>)" title="Remove from Wishlist">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                                <button class="add-to-cart-btn" onclick="moveToBag(event, <%= item.productId %>)" title="Move to Bag">
                                    <i class="fas fa-shopping-bag"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        <% } %>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>

    <script>


        // AJAX Remove from Wishlist
        function removeFromWishlist(productId) {
            const params = new URLSearchParams();
            params.append('action', 'remove');
            params.append('productId', productId);

            fetch('WishlistServlet', {
                method: 'POST',
                body: params,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    // Update wishlist count badge
                    const wlCountEl = document.getElementById('wishlistCount');
                    if (wlCountEl && data.count !== undefined) {
                        wlCountEl.innerText = data.count;
                        wlCountEl.style.display = data.count > 0 ? 'flex' : 'none';
                    }

                    const card = document.getElementById('card-' + productId);
                    if (card) {
                        card.style.opacity = '0';
                        card.style.transform = 'scale(0.9)';
                        card.style.transition = 'all 0.4s ease';
                        setTimeout(() => {
                            card.remove();
                            // If wishlist is empty, reload to show empty state
                            const remainingCards = document.querySelectorAll('.products-grid .card');
                            if (remainingCards.length === 0) {
                                location.reload();
                            }
                        }, 400);
                    } else {
                        location.reload();
                    }
                    showToast("Item removed from Wishlist");
                } else {
                    showToast("Error: " + data.error, "danger");
                }
            })
            .catch(err => console.error(err));
        }

        // AJAX Move to Bag
        function moveToBag(event, productId) {
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

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
            .then(cartData => {
                if (cartData.success) {
                    // Update cart count
                    const cartCountEl = document.getElementById('cartCount');
                    if (cartCountEl) cartCountEl.innerText = cartData.count;

                    // Remove from wishlist
                    const wishParams = new URLSearchParams();
                    wishParams.append('action', 'remove');
                    wishParams.append('productId', productId);

                    return fetch('WishlistServlet', {
                        method: 'POST',
                        body: wishParams,
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        }
                    });
                } else {
                    throw new Error(cartData.error || "Failed to add to bag");
                }
            })
            .then(res => res.json())
            .then(wishData => {
                if (wishData.success) {
                    // Update wishlist count
                    const wishCountEl = document.getElementById('wishlistCount');
                    if (wishCountEl && wishData.count !== undefined) {
                        wishCountEl.innerText = wishData.count;
                        wishCountEl.style.display = wishData.count > 0 ? 'flex' : 'none';
                    }

                    showToast("Moved to Bag Successfully", "success");

                    // Animate card removal
                    const card = document.getElementById('card-' + productId);
                    if (card) {
                        card.style.opacity = '0';
                        card.style.transform = 'scale(0.9)';
                        card.style.transition = 'all 0.4s ease';
                        setTimeout(() => {
                            card.remove();
                            // If wishlist is empty, reload to show empty state
                            const remainingCards = document.querySelectorAll('.products-grid .card');
                            if (remainingCards.length === 0) {
                                location.reload();
                            }
                        }, 400);
                    } else {
                        setTimeout(() => location.reload(), 500);
                    }
                } else {
                    showToast("Error: " + (wishData.error || "Failed to remove from wishlist"), "danger");
                }
            })
            .catch(err => {
                console.error(err);
                showToast(err.message || "Please log in or try again.", "warning");
            });
        }
    </script>
</body>
</html>

