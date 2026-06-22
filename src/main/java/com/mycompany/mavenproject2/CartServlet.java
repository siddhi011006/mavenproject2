package com.mycompany.mavenproject2;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    // Action types
    private static final String ACTION_ADD = "add";
    private static final String ACTION_UPDATE = "update";
    private static final String ACTION_REMOVE = "remove";
    private static final String ACTION_COUNT = "count";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("user_id");
        String action = request.getParameter("action");

        if (action == null) {
            out.write("{\"error\": \"Action parameter missing\"}");
            return;
        }

        try {
            if (ACTION_COUNT.equalsIgnoreCase(action)) {
                int count = getCartItemCount(userId, session);
                out.write("{\"count\": " + count + "}");
                return;
            }

            String productIdStr = request.getParameter("productId");
            if (productIdStr == null) {
                out.write("{\"error\": \"Product ID parameter missing\"}");
                return;
            }
            int productId = Integer.parseInt(productIdStr);

            String variantIdStr = request.getParameter("variantId");
            Integer variantId = null;
            if (variantIdStr != null && !variantIdStr.trim().isEmpty() && !"null".equalsIgnoreCase(variantIdStr.trim())) {
                variantId = Integer.parseInt(variantIdStr.trim());
            }

            if (ACTION_ADD.equalsIgnoreCase(action)) {
                String qtyStr = request.getParameter("quantity");
                int qty = (qtyStr != null) ? Integer.parseInt(qtyStr) : 1;
                
                addToCart(userId, session, productId, variantId, qty);
                int count = getCartItemCount(userId, session);
                out.write("{\"success\": true, \"message\": \"Product added to cart\", \"count\": " + count + "}");
                
            } else if (ACTION_UPDATE.equalsIgnoreCase(action)) {
                String qtyStr = request.getParameter("quantity");
                if (qtyStr == null) {
                    out.write("{\"error\": \"Quantity parameter missing\"}");
                    return;
                }
                int qty = Integer.parseInt(qtyStr);
                
                updateCartQuantity(userId, session, productId, variantId, qty);
                int count = getCartItemCount(userId, session);
                out.write("{\"success\": true, \"message\": \"Cart updated\", \"count\": " + count + "}");
                
            } else if (ACTION_REMOVE.equalsIgnoreCase(action)) {
                removeFromCart(userId, session, productId, variantId);
                int count = getCartItemCount(userId, session);
                out.write("{\"success\": true, \"message\": \"Product removed from cart\", \"count\": " + count + "}");
            } else {
                out.write("{\"error\": \"Unknown action: " + action + "\"}");
            }

        } catch (NumberFormatException e) {
            out.write("{\"error\": \"Invalid parameters: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage();
            if (msg != null && msg.startsWith("StockError:")) {
                out.write("{\"error\": \"" + msg.substring(11) + "\"}");
            } else {
                out.write("{\"error\": \"Server error: " + (msg != null ? msg : "Unknown error") + "\"}");
            }
        }
    }

    private void addToCart(Integer userId, HttpSession session, int productId, Integer variantId, int qty) throws Exception {
        verifyStock(userId, session, productId, variantId, qty, false);
        if (userId != null) {
            // DB-backed cart
            Connection con = DBConnection.getConnection();
            // Check if item already exists in cart (matching product AND variant)
            String checkSql = "SELECT id, quantity FROM cart WHERE user_id = ? AND product_id = ? AND (variant_id = ? OR (variant_id IS NULL AND ? IS NULL))";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setInt(1, userId);
            checkPs.setInt(2, productId);
            if (variantId != null) {
                checkPs.setInt(3, variantId);
                checkPs.setInt(4, variantId);
            } else {
                checkPs.setNull(3, java.sql.Types.INTEGER);
                checkPs.setNull(4, java.sql.Types.INTEGER);
            }
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                int cartId = rs.getInt("id");
                String updateSql = "UPDATE cart SET quantity = quantity + ? WHERE id = ?";
                PreparedStatement updatePs = con.prepareStatement(updateSql);
                updatePs.setInt(1, qty);
                updatePs.setInt(2, cartId);
                updatePs.executeUpdate();
                updatePs.close();
            } else {
                String insertSql = "INSERT INTO cart (user_id, product_id, quantity, variant_id) VALUES (?, ?, ?, ?)";
                PreparedStatement insertPs = con.prepareStatement(insertSql);
                insertPs.setInt(1, userId);
                insertPs.setInt(2, productId);
                insertPs.setInt(3, qty);
                if (variantId != null) {
                    insertPs.setInt(4, variantId);
                } else {
                    insertPs.setNull(4, java.sql.Types.INTEGER);
                }
                insertPs.executeUpdate();
                insertPs.close();
            }
            rs.close();
            checkPs.close();
            con.close();
        } else {
            // Session-backed cart for guest
            Map<String, Integer> cart = getSessionCart(session);
            String key = productId + "_" + (variantId != null ? variantId : "null");
            cart.put(key, cart.getOrDefault(key, 0) + qty);
        }
    }

    private void updateCartQuantity(Integer userId, HttpSession session, int productId, Integer variantId, int qty) throws Exception {
        if (qty <= 0) {
            removeFromCart(userId, session, productId, variantId);
            return;
        }

        verifyStock(userId, session, productId, variantId, qty, true);

        if (userId != null) {
            Connection con = DBConnection.getConnection();
            String sql = "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ? AND (variant_id = ? OR (variant_id IS NULL AND ? IS NULL))";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, qty);
            ps.setInt(2, userId);
            ps.setInt(3, productId);
            if (variantId != null) {
                ps.setInt(4, variantId);
                ps.setInt(5, variantId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.executeUpdate();
            ps.close();
            con.close();
        } else {
            Map<String, Integer> cart = getSessionCart(session);
            String key = productId + "_" + (variantId != null ? variantId : "null");
            cart.put(key, qty);
        }
    }

    private void removeFromCart(Integer userId, HttpSession session, int productId, Integer variantId) throws Exception {
        if (userId != null) {
            Connection con = DBConnection.getConnection();
            String sql = "DELETE FROM cart WHERE user_id = ? AND product_id = ? AND (variant_id = ? OR (variant_id IS NULL AND ? IS NULL))";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            if (variantId != null) {
                ps.setInt(3, variantId);
                ps.setInt(4, variantId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.executeUpdate();
            ps.close();
            con.close();
        } else {
            Map<String, Integer> cart = getSessionCart(session);
            String key = productId + "_" + (variantId != null ? variantId : "null");
            cart.remove(key);
        }
    }

    private int getCartItemCount(Integer userId, HttpSession session) throws Exception {
        int count = 0;
        if (userId != null) {
            Connection con = DBConnection.getConnection();
            String sql = "SELECT SUM(quantity) FROM cart WHERE user_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
            rs.close();
            ps.close();
            con.close();
        } else {
            Map<String, Integer> cart = getSessionCart(session);
            for (int qty : cart.values()) {
                count += qty;
            }
        }
        return count;
    }

    private int getCartItemQuantity(int userId, int productId, Integer variantId) throws Exception {
        int qty = 0;
        Connection con = DBConnection.getConnection();
        String sql = "SELECT quantity FROM cart WHERE user_id = ? AND product_id = ? AND (variant_id = ? OR (variant_id IS NULL AND ? IS NULL))";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        ps.setInt(2, productId);
        if (variantId != null) {
            ps.setInt(3, variantId);
            ps.setInt(4, variantId);
        } else {
            ps.setNull(3, java.sql.Types.INTEGER);
            ps.setNull(4, java.sql.Types.INTEGER);
        }
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            qty = rs.getInt("quantity");
        }
        rs.close();
        ps.close();
        con.close();
        return qty;
    }

    private void verifyStock(Integer userId, HttpSession session, int productId, Integer variantId, int additionalQty, boolean isAbsolute) throws Exception {
        int stock = 0;
        String name = "";
        Connection con = DBConnection.getConnection();
        
        if (variantId != null) {
            String sql = "SELECT pv.stock, pv.variant_name, p.name FROM product_variants pv JOIN products p ON pv.product_id = p.id WHERE pv.id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stock = rs.getInt("stock");
                name = rs.getString("name") + " (" + rs.getString("variant_name") + ")";
            } else {
                rs.close();
                ps.close();
                con.close();
                throw new Exception("StockError:Variant not found.");
            }
            rs.close();
            ps.close();
        } else {
            String sql = "SELECT stock, name FROM products WHERE id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stock = rs.getInt("stock");
                name = rs.getString("name");
            } else {
                rs.close();
                ps.close();
                con.close();
                throw new Exception("StockError:Product not found.");
            }
            rs.close();
            ps.close();
        }
        con.close();

        int existingQty = 0;
        if (!isAbsolute) {
            if (userId != null) {
                existingQty = getCartItemQuantity(userId, productId, variantId);
            } else {
                Map<String, Integer> cart = getSessionCart(session);
                String key = productId + "_" + (variantId != null ? variantId : "null");
                existingQty = cart.getOrDefault(key, 0);
            }
        }

        int targetQty = isAbsolute ? additionalQty : (existingQty + additionalQty);

        if (targetQty > stock) {
            throw new Exception("StockError:Only " + stock + " units of " + name + " are available in stock.");
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Integer> getSessionCart(HttpSession session) {
        Object rawCart = session.getAttribute("guest_cart");
        Map<String, Integer> cart = new HashMap<>();
        if (rawCart instanceof Map) {
            Map<?, ?> rawMap = (Map<?, ?>) rawCart;
            // Migrates old Map<Integer, Integer> structure to Map<String, Integer> on the fly if needed
            for (Map.Entry<?, ?> entry : rawMap.entrySet()) {
                String keyStr;
                if (entry.getKey() instanceof Integer) {
                    keyStr = entry.getKey().toString() + "_null";
                } else {
                    keyStr = entry.getKey().toString();
                }
                int qty = 1;
                if (entry.getValue() instanceof Number) {
                    qty = ((Number) entry.getValue()).intValue();
                }
                cart.put(keyStr, qty);
            }
        }
        session.setAttribute("guest_cart", cart);
        return cart;
    }
}
