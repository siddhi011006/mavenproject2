package com.mycompany.mavenproject2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CheckoutServlet")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp?error=Please sign in to place an order.");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        String street = request.getParameter("address");
        String city = request.getParameter("city");
        String zip = request.getParameter("zip");
        String country = request.getParameter("country");
        String paymentMethod = request.getParameter("paymentMethod");

        if (street == null || city == null || zip == null || country == null || paymentMethod == null ||
            street.trim().isEmpty() || city.trim().isEmpty() || zip.trim().isEmpty() || country.trim().isEmpty()) {
            request.setAttribute("error", "Please complete all shipping and payment fields.");
            request.getRequestDispatcher("checkout.jsp").forward(request, response);
            return;
        }

        String fullAddress = street.trim() + ", " + city.trim() + ", " + zip.trim() + ", " + country.trim();
        String couponCode = request.getParameter("couponCode");

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Begin transaction

            // 1. Fetch user's cart items, joining variants if present
            String cartSql = "SELECT c.product_id, c.variant_id, c.quantity, "
                           + "COALESCE(pv.price, p.price) AS price, "
                           + "COALESCE(pv.stock, p.stock) AS stock, "
                           + "IF(pv.id IS NOT NULL, CONCAT(p.name, ' - ', pv.variant_name), p.name) AS name "
                           + "FROM cart c "
                           + "JOIN products p ON c.product_id = p.id "
                           + "LEFT JOIN product_variants pv ON c.variant_id = pv.id "
                           + "WHERE c.user_id = ?";
            PreparedStatement cartPs = con.prepareStatement(cartSql);
            cartPs.setInt(1, userId);
            ResultSet rs = cartPs.executeQuery();

            double subtotal = 0;
            boolean hasItems = false;
            
            // Temporary structures to hold order items data
            java.util.List<CartItemTemp> itemsToOrder = new java.util.ArrayList<>();

            while (rs.next()) {
                hasItems = true;
                int prodId = rs.getInt("product_id");
                Integer variantId = rs.getInt("variant_id");
                if (rs.wasNull()) {
                    variantId = null;
                }
                int qty = rs.getInt("quantity");
                double price = rs.getDouble("price");
                int stock = rs.getInt("stock");
                String name = rs.getString("name");

                if (qty > stock) {
                    con.rollback();
                    request.setAttribute("error", "Insufficient stock for product: " + name + " (Only " + stock + " left).");
                    request.getRequestDispatcher("cart.jsp").forward(request, response);
                    con.close();
                    return;
                }

                subtotal += price * qty;
                itemsToOrder.add(new CartItemTemp(prodId, variantId, qty, price, name));
            }

            if (!hasItems) {
                con.rollback();
                response.sendRedirect("product.jsp?error=Your cart is empty.");
                con.close();
                return;
            }

            // Calculate discount, shipping, tax, and total
            double discount = 0.0;
            if ("GLOW15".equalsIgnoreCase(couponCode)) {
                discount = 0.15;
            }
            double discountedSubtotal = subtotal * (1 - discount);
            double shipping = (discountedSubtotal >= 1500.0) ? 0.0 : 9.99;
            double tax = discountedSubtotal * 0.08;
            double finalTotal = discountedSubtotal + tax + shipping;

            // 2. Insert into orders table
            String orderSql = "INSERT INTO orders (user_id, total_amount, status, shipping_address, payment_method) "
                             + "VALUES (?, ?, 'PENDING', ?, ?)";
            PreparedStatement orderPs = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, userId);
            orderPs.setDouble(2, finalTotal);
            orderPs.setString(3, fullAddress);
            orderPs.setString(4, paymentMethod);
            orderPs.executeUpdate();

            ResultSet genKeys = orderPs.getGeneratedKeys();
            int orderId = 0;
            if (genKeys.next()) {
                orderId = genKeys.getInt(1);
            } else {
                throw new SQLException("Creating order failed, no ID obtained.");
            }

            // 3. Insert into order_items and update product/variant stock
            String itemSql = "INSERT INTO order_items (order_id, product_id, quantity, price, variant_id) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement itemPs = con.prepareStatement(itemSql);

            String updateProdStockSql = "UPDATE products SET stock = stock - ? WHERE id = ?";
            PreparedStatement prodStockPs = con.prepareStatement(updateProdStockSql);

            String updateVarStockSql = "UPDATE product_variants SET stock = stock - ? WHERE id = ?";
            PreparedStatement varStockPs = con.prepareStatement(updateVarStockSql);

            for (CartItemTemp item : itemsToOrder) {
                // Order item
                itemPs.setInt(1, orderId);
                itemPs.setInt(2, item.productId);
                itemPs.setInt(3, item.quantity);
                itemPs.setDouble(4, item.price);
                if (item.variantId != null) {
                    itemPs.setInt(5, item.variantId);
                } else {
                    itemPs.setNull(5, java.sql.Types.INTEGER);
                }
                itemPs.addBatch();

                // Stock update
                if (item.variantId != null) {
                    varStockPs.setInt(1, item.quantity);
                    varStockPs.setInt(2, item.variantId);
                    varStockPs.addBatch();
                } else {
                    prodStockPs.setInt(1, item.quantity);
                    prodStockPs.setInt(2, item.productId);
                    prodStockPs.addBatch();
                }
            }
            itemPs.executeBatch();
            prodStockPs.executeBatch();
            varStockPs.executeBatch();

            // 4. Clear the cart
            String clearCartSql = "DELETE FROM cart WHERE user_id = ?";
            PreparedStatement clearPs = con.prepareStatement(clearCartSql);
            clearPs.setInt(1, userId);
            clearPs.executeUpdate();

            // Commit transaction
            con.commit();
            con.close();

            // Trigger order confirmation email asynchronously (fails gracefully)
            try {
                String customerName = (String) session.getAttribute("fullname");
                String customerEmail = (String) session.getAttribute("email");
                
                StringBuilder productsHtml = new StringBuilder();
                for (CartItemTemp item : itemsToOrder) {
                    productsHtml.append("<tr style=\"border-bottom:1px solid rgba(92,13,30,0.05);\">")
                                .append("<td style=\"padding:10px 0;\">").append(item.name).append("</td>")
                                .append("<td style=\"padding:10px 0; text-align:center;\">").append(item.quantity).append("</td>")
                                .append("<td style=\"padding:10px 0; text-align:right;\">$").append(String.format("%.2f", item.price)).append("</td>")
                                .append("</tr>");
                }
                
                String orderDateStr = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
                String estDeliveryStr = java.time.LocalDate.now().plusDays(5).format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy"));
                double discountAmount = subtotal * discount;

                EmailUtility.sendOrderConfirmationEmail(
                    customerEmail, customerName, orderId, orderDateStr,
                    productsHtml.toString(), subtotal, discountAmount,
                    shipping, tax, finalTotal, fullAddress, paymentMethod, estDeliveryStr
                );
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            // Redirect to success
            response.sendRedirect("order-confirmation.jsp?orderId=" + orderId);

        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try {
                    con.rollback();
                    con.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            request.setAttribute("error", "Checkout transaction failed: " + e.getMessage());
            request.getRequestDispatcher("checkout.jsp").forward(request, response);
        }
    }

    // Helper class
    private static class CartItemTemp {
        int productId;
        Integer variantId;
        int quantity;
        double price;
        String name;

        public CartItemTemp(int productId, Integer variantId, int quantity, double price, String name) {
            this.productId = productId;
            this.variantId = variantId;
            this.quantity = quantity;
            this.price = price;
            this.name = name;
        }
    }
}
