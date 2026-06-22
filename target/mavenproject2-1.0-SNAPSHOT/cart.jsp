<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%@ page import="com.mycompany.mavenproject2.CartItem" %>
<%
    // Verify session user details
    HttpSession s = request.getSession(false);
    Integer userId = null;
    if (s != null) {
        userId = (Integer) s.getAttribute("user_id");
    }

    java.util.List<CartItem> cartItems = new java.util.ArrayList<>();
    double subtotal = 0.0;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    if (userId != null) {
        // Logged-in: Fetch cart items from database joining variants
        try {
            con = DBConnection.getConnection();
            String sql = "SELECT c.product_id, c.variant_id, c.quantity, "
                       + "p.name, p.category, p.image_url, "
                       + "pv.variant_name, pv.color_code, "
                       + "COALESCE(pv.price, p.price) AS price, "
                       + "COALESCE(pv.stock, p.stock) AS stock "
                       + "FROM cart c "
                       + "JOIN products p ON c.product_id = p.id "
                       + "LEFT JOIN product_variants pv ON c.variant_id = pv.id "
                       + "WHERE c.user_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Integer vId = rs.getInt("variant_id");
                if (rs.wasNull()) {
                    vId = null;
                }
                CartItem item = new CartItem(
                    rs.getInt("product_id"),
                    rs.getString("name"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image_url"),
                    rs.getInt("quantity"),
                    rs.getInt("stock"),
                    vId,
                    rs.getString("variant_name"),
                    rs.getString("color_code")
                );
                cartItems.add(item);
                subtotal += item.price * item.quantity;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    } else {
        // Guest: Fetch cart items from session guest_cart safely
        Object rawCart = session.getAttribute("guest_cart");
        if (rawCart instanceof java.util.Map) {
            java.util.Map<?, ?> guestCart = (java.util.Map<?, ?>) rawCart;
            if (!guestCart.isEmpty()) {
                try {
                    con = DBConnection.getConnection();
                    String sql = "SELECT p.id, p.name, p.category, p.image_url, "
                               + "pv.variant_name, pv.color_code, "
                               + "COALESCE(pv.price, p.price) AS price, "
                               + "COALESCE(pv.stock, p.stock) AS stock "
                               + "FROM products p "
                               + "LEFT JOIN product_variants pv ON pv.id = ? "
                               + "WHERE p.id = ?";
                    ps = con.prepareStatement(sql);
                    for (java.util.Map.Entry<?, ?> entry : guestCart.entrySet()) {
                        String keyStr = entry.getKey().toString();
                        String[] parts = keyStr.split("_");
                        int prodId = Integer.parseInt(parts[0]);
                        Integer variantId = null;
                        if (parts.length > 1 && !"null".equalsIgnoreCase(parts[1])) {
                            variantId = Integer.parseInt(parts[1]);
                        }

                        int qty = 1;
                        if (entry.getValue() instanceof Number) {
                            qty = ((Number) entry.getValue()).intValue();
                        }

                        if (variantId != null) {
                            ps.setInt(1, variantId);
                        } else {
                            ps.setNull(1, java.sql.Types.INTEGER);
                        }
                        ps.setInt(2, prodId);
                        
                        rs = ps.executeQuery();
                        if (rs.next()) {
                            CartItem item = new CartItem(
                                rs.getInt("id"),
                                rs.getString("name"),
                                rs.getDouble("price"),
                                rs.getString("category"),
                                rs.getString("image_url"),
                                qty,
                                rs.getInt("stock"),
                                variantId,
                                rs.getString("variant_name"),
                                rs.getString("color_code")
                            );
                            cartItems.add(item);
                            subtotal += item.price * item.quantity;
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

    // Calculations
    double shipping = (subtotal >= 1500.0 || subtotal == 0) ? 0.0 : 9.99;
    double tax = subtotal * 0.08;
    double total = subtotal + tax + shipping;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Shopping Bag | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <div class="page-container">
        
        <!-- Action Alerts -->
        <%
            String errorMsg = (String) request.getAttribute("error");
            if (errorMsg != null) {
        %>
            <div class="alert alert-danger" style="margin-bottom: 30px;">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= errorMsg %></span>
            </div>
        <% } %>

        <h1 class="title-center" style="font-size: 2.5rem; margin-bottom: 40px;">Shopping Bag</h1>

        <% if (cartItems.isEmpty()) { %>
            <!-- Empty Bag State -->
            <div style="text-align: center; padding: 60px 20px; background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 20px; max-width: 600px; margin: 0 auto;">
                <i class="fas fa-shopping-bag" style="font-size: 4rem; color: var(--gold); margin-bottom: 20px; opacity: 0.6;"></i>
                <h3 style="font-size: 1.5rem; margin-bottom: 10px;">Your Shopping Bag is Empty</h3>
                <p style="color: var(--text-secondary); margin-bottom: 25px;">Browse our catalog and choose premium, dermatologist-tested beauty items.</p>
                <a href="product.jsp" class="btn-gold">Shop The Catalog</a>
            </div>
        <% } else { %>
            <!-- Cart Layout Grid -->
            <div class="cart-layout">
                
                <!-- Items list -->
                <div class="cart-items-panel">
                    <table class="cart-table">
                        <thead>
                            <tr>
                                <th>Product Details</th>
                                <th>Quantity</th>
                                <th style="text-align: right;">Total Price</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (CartItem item : cartItems) { %>
                            <tr class="cart-item-row" id="row-<%= item.productId %>-<%= item.variantId != null ? item.variantId : "null" %>" data-price="<%= item.price %>" data-qty="<%= item.quantity %>">
                                <!-- Details -->
                                <td class="cart-item-cell">
                                    <div class="cart-product-details">
                                        <a href="product-details.jsp?id=<%= item.productId %><%= item.variantId != null ? "&variantId=" + item.variantId : "" %>">
                                            <img src="<%= item.imageUrl %>" alt="<%= item.name %>">
                                        </a>
                                        <div>
                                            <div class="cart-product-name">
                                                <a href="product-details.jsp?id=<%= item.productId %><%= item.variantId != null ? "&variantId=" + item.variantId : "" %>" style="color:inherit; text-decoration:none;">
                                                    <%= item.name %>
                                                </a>
                                                <% if (item.variantName != null && !item.variantName.trim().isEmpty() && !"Standard".equalsIgnoreCase(item.variantName)) { %>
                                                    <span style="font-size: 0.8rem; font-weight: 550; color: var(--gold); display: flex; align-items: center; gap: 5px; margin-top: 5px;">
                                                        <% if (item.colorCode != null && item.colorCode.startsWith("#")) { %>
                                                            <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background-color:<%= item.colorCode %>; border:1px solid rgba(0,0,0,0.15);"></span>
                                                        <% } %>
                                                        Shade: <%= item.variantName %>
                                                    </span>
                                                <% } %>
                                            </div>
                                            <div class="cart-product-cat"><%= item.category %></div>
                                            <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 5px;">Unit price: <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(item.price, currentCountry) %></div>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Quantity Handler -->
                                <td class="cart-item-cell">
                                    <div class="qty-selector" style="width: 120px;">
                                        <button class="qty-btn" type="button" onclick="updateQty(<%= item.productId %>, <%= item.variantId != null ? item.variantId : null %>, <%= item.quantity - 1 %>, <%= item.stock %>)">-</button>
                                        <input class="qty-input" type="text" value="<%= item.quantity %>" readonly style="width: 30px;">
                                        <button class="qty-btn" type="button" onclick="updateQty(<%= item.productId %>, <%= item.variantId != null ? item.variantId : null %>, <%= item.quantity + 1 %>, <%= item.stock %>)">+</button>
                                    </div>
                                    <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 5px; text-align: center;">Stock: <%= item.stock %></div>
                                </td>

                                <!-- Total Price -->
                                <td class="cart-item-cell cart-item-total-price" style="text-align: right; font-weight: 600; font-size: 1.1rem; color: var(--text-primary);">
                                    <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(item.price * item.quantity, currentCountry) %>
                                </td>

                                <!-- Remove -->
                                <td class="cart-item-cell" style="text-align: right; width: 40px;">
                                    <button class="cart-remove-btn" onclick="removeFromCart(<%= item.productId %>, <%= item.variantId != null ? item.variantId : null %>)" title="Remove Item">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Checkout Summary Card -->
                <div class="summary-panel">
                    <h3 class="summary-title">Order Summary</h3>
                    
                    <div class="summary-row">
                        <span>Bag Subtotal</span>
                        <span id="cart-subtotal"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(subtotal, currentCountry) %></span>
                    </div>

                    <div class="summary-row">
                        <span>Estimated Shipping</span>
                        <span id="cart-shipping">
                            <% if (shipping == 0.0) { %>
                                <span style="color: var(--success); font-weight: 500;">Free Shipping</span>
                            <% } else { %>
                                <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(shipping, currentCountry) %>
                            <% } %>
                        </span>
                    </div>

                    <div class="summary-row">
                        <span>Estimated Tax (8%)</span>
                        <span id="cart-tax"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(tax, currentCountry) %></span>
                    </div>

                    <div id="free-shipping-prompt" style="font-size: 0.8rem; color: var(--gold); margin-bottom: 15px; text-align: right; <%= shipping == 0.0 ? "display: none;" : "" %>">
                        Add <strong><span id="free-shipping-needed"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(1500.0 - subtotal, currentCountry) %></span></strong> more for free shipping!
                    </div>

                    <div class="summary-row total">
                        <span>Estimated Total</span>
                        <span id="cart-total" style="color: var(--gold); font-size: 1.4rem;"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(total, currentCountry) %></span>
                    </div>

                    <a href="checkout.jsp" class="btn-gold" style="width: 100%; border-radius: 12px; margin-top: 15px; padding: 14px;">
                        Proceed to Checkout <i class="fas fa-arrow-right" style="margin-left: 8px;"></i>
                    </a>
                    
                    <div style="text-align: center; margin-top: 15px;">
                        <a href="product.jsp" style="font-size: 0.85rem; color: var(--text-muted); font-weight: 500; text-decoration: underline;">
                            Continue Shopping
                        </a>
                    </div>
                </div>

            </div>
        <% } %>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>

    <script>
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

        // Recalculate totals in frontend
        function recalculateCartTotals() {
            let subtotal = 0;
            const rows = document.querySelectorAll('.cart-item-row');
            rows.forEach(row => {
                const price = parseFloat(row.getAttribute('data-price'));
                const qtyInput = row.querySelector('.qty-input');
                const qty = parseInt(qtyInput.value);
                subtotal += price * qty;
            });

            const subtotalEl = document.getElementById('cart-subtotal');
            const shippingEl = document.getElementById('cart-shipping');
            const taxEl = document.getElementById('cart-tax');
            const totalEl = document.getElementById('cart-total');
            const freeShippingPrompt = document.getElementById('free-shipping-prompt');
            const freeShippingNeeded = document.getElementById('free-shipping-needed');

            let shipping = 0;
            if (subtotal < 1500.0 && subtotal > 0) {
                shipping = 9.99;
            }
            const tax = subtotal * 0.08;
            const total = subtotal + tax + shipping;

            if (subtotalEl) subtotalEl.innerText = formatCurrency(subtotal);
            if (taxEl) taxEl.innerText = formatCurrency(tax);
            if (totalEl) totalEl.innerText = formatCurrency(total);

            if (shippingEl) {
                if (shipping === 0) {
                    shippingEl.innerHTML = '<span style="color: var(--success); font-weight: 500;">Free Shipping</span>';
                } else {
                    shippingEl.innerText = formatCurrency(shipping);
                }
            }

            if (freeShippingPrompt) {
                if (shipping === 0 || subtotal === 0) {
                    freeShippingPrompt.style.display = 'none';
                } else {
                    freeShippingPrompt.style.display = 'block';
                    if (freeShippingNeeded) {
                        freeShippingNeeded.innerText = formatCurrency(1500.0 - subtotal);
                    }
                }
            }
            
            // If the cart has no rows left, show the empty state
            if (rows.length === 0) {
                const pageContainer = document.querySelector('.page-container');
                if (pageContainer) {
                    pageContainer.innerHTML = `
                        <h1 class="title-center" style="font-size: 2.5rem; margin-bottom: 40px;">Shopping Bag</h1>
                        <div style="text-align: center; padding: 60px 20px; background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 20px; max-width: 600px; margin: 0 auto;">
                            <i class="fas fa-shopping-bag" style="font-size: 4rem; color: var(--gold); margin-bottom: 20px; opacity: 0.6;"></i>
                            <h3 style="font-size: 1.5rem; margin-bottom: 10px;">Your Shopping Bag is Empty</h3>
                            <p style="color: var(--text-secondary); margin-bottom: 25px;">Browse our catalog and choose premium, dermatologist-tested beauty items.</p>
                            <a href="product.jsp" class="btn-gold">Shop The Catalog</a>
                        </div>
                    `;
                }
            }
        }

        // AJAX update quantity
        function updateQty(productId, variantId, newQty, maxStock) {
            if (newQty <= 0) {
                removeFromCart(productId, variantId);
                return;
            }
            if (maxStock !== undefined && newQty > maxStock) {
                showToast("Only " + maxStock + " units available in stock.", "warning");
                return;
            }

            const params = new URLSearchParams();
            params.append('action', 'update');
            params.append('productId', productId);
            if (variantId !== null && variantId !== undefined) {
                params.append('variantId', variantId);
            }
            params.append('quantity', newQty);

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
                    const rowId = 'row-' + productId + '-' + (variantId !== null ? variantId : 'null');
                    const row = document.getElementById(rowId);
                    if (row) {
                        row.setAttribute('data-qty', newQty);
                        const qtyInput = row.querySelector('.qty-input');
                        if (qtyInput) qtyInput.value = newQty;

                        const price = parseFloat(row.getAttribute('data-price'));
                        const totalCell = row.querySelector('.cart-item-total-price');
                        if (totalCell) {
                            totalCell.innerText = formatCurrency(price * newQty);
                        }

                        // update quantity buttons onclick properties
                        const qtyBtns = row.querySelectorAll('.qty-btn');
                        if (qtyBtns.length === 2) {
                            qtyBtns[0].setAttribute('onclick', `updateQty(${productId}, ${variantId}, ${newQty - 1}, ${maxStock})`);
                            qtyBtns[1].setAttribute('onclick', `updateQty(${productId}, ${variantId}, ${newQty + 1}, ${maxStock})`);
                        }
                    }
                    const badge = document.getElementById('cartCount');
                    if (badge) {
                        badge.innerText = data.count;
                        badge.style.display = data.count > 0 ? 'flex' : 'none';
                    }
                    recalculateCartTotals();
                } else {
                    showToast("Error updating cart: " + data.error, "danger");
                }
            })
            .catch(err => console.error(err));
        }

        // AJAX remove item
        function removeFromCart(productId, variantId) {
            const params = new URLSearchParams();
            params.append('action', 'remove');
            params.append('productId', productId);
            if (variantId !== null && variantId !== undefined) {
                params.append('variantId', variantId);
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
                    const badge = document.getElementById('cartCount');
                    if (badge) {
                        badge.innerText = data.count;
                        badge.style.display = data.count > 0 ? 'flex' : 'none';
                    }
                    
                    const rowId = 'row-' + productId + '-' + (variantId !== null ? variantId : 'null');
                    const row = document.getElementById(rowId);
                    if (row) {
                        row.style.opacity = '0';
                        row.style.transform = 'scale(0.9)';
                        row.style.transition = 'all 0.4s ease';
                        setTimeout(() => {
                            row.remove();
                            recalculateCartTotals();
                        }, 400);
                    } else {
                        recalculateCartTotals();
                    }
                    showToast("Item removed from Cart");
                } else {
                    showToast("Error: " + data.error, "danger");
                }
            })
            .catch(err => console.error(err));
        }
    </script>
</body>
</html>
