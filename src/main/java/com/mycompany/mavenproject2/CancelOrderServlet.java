package com.mycompany.mavenproject2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CancelOrderServlet")
public class CancelOrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp?error=Please sign in to manage orders.");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        String orderIdStr = request.getParameter("orderId");
        String reason = request.getParameter("reason");
        String customReason = request.getParameter("customReason");

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect("orders.jsp?error=Order ID is missing.");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("orders.jsp?error=Invalid Order ID format.");
            return;
        }

        String finalReason = reason;
        if ("Other".equalsIgnoreCase(reason)) {
            if (customReason != null && !customReason.trim().isEmpty()) {
                finalReason = "Other: " + customReason.trim();
            } else {
                finalReason = "Other: No explanation provided.";
            }
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Start transaction

            // 1. Verify order details (belongs to user and has eligible status)
            String verifySql = "SELECT status, user_id FROM orders WHERE id = ?";
            PreparedStatement verifyPs = con.prepareStatement(verifySql);
            verifyPs.setInt(1, orderId);
            ResultSet rs = verifyPs.executeQuery();

            if (rs.next()) {
                int orderOwnerId = rs.getInt("user_id");
                String status = rs.getString("status");

                if (orderOwnerId != userId) {
                    rs.close();
                    verifyPs.close();
                    con.rollback();
                    con.close();
                    response.sendRedirect("orders.jsp?error=Unauthorized to cancel this order.");
                    return;
                }

                if (!"PENDING".equalsIgnoreCase(status) && !"PROCESSING".equalsIgnoreCase(status)) {
                    rs.close();
                    verifyPs.close();
                    con.rollback();
                    con.close();
                    response.sendRedirect("orders.jsp?error=Order cannot be cancelled (current status: " + status + ").");
                    return;
                }
            } else {
                rs.close();
                verifyPs.close();
                con.rollback();
                con.close();
                response.sendRedirect("orders.jsp?error=Order not found.");
                return;
            }
            rs.close();
            verifyPs.close();

            // 2. Retrieve order items to restore stock
            String itemsSql = "SELECT product_id, variant_id, quantity FROM order_items WHERE order_id = ?";
            PreparedStatement itemsPs = con.prepareStatement(itemsSql);
            itemsPs.setInt(1, orderId);
            ResultSet itemsRs = itemsPs.executeQuery();

            String restoreProdStock = "UPDATE products SET stock = stock + ? WHERE id = ?";
            PreparedStatement restoreProdPs = con.prepareStatement(restoreProdStock);

            String restoreVarStock = "UPDATE product_variants SET stock = stock + ? WHERE id = ?";
            PreparedStatement restoreVarPs = con.prepareStatement(restoreVarStock);

            while (itemsRs.next()) {
                int prodId = itemsRs.getInt("product_id");
                int qty = itemsRs.getInt("quantity");
                int varId = itemsRs.getInt("variant_id");
                boolean isVariant = !itemsRs.wasNull();

                if (isVariant) {
                    restoreVarPs.setInt(1, qty);
                    restoreVarPs.setInt(2, varId);
                    restoreVarPs.addBatch();
                } else {
                    restoreProdPs.setInt(1, qty);
                    restoreProdPs.setInt(2, prodId);
                    restoreProdPs.addBatch();
                }
            }
            itemsRs.close();
            itemsPs.close();

            restoreProdPs.executeBatch();
            restoreVarPs.executeBatch();
            restoreProdPs.close();
            restoreVarPs.close();

            // 3. Update orders table
            String updateSql = "UPDATE orders SET status = 'CANCELLED', cancellation_reason = ?, cancellation_date = CURRENT_TIMESTAMP, cancelled_by = 'CUSTOMER' WHERE id = ?";
            PreparedStatement updatePs = con.prepareStatement(updateSql);
            updatePs.setString(1, finalReason);
            updatePs.setInt(2, orderId);
            updatePs.executeUpdate();
            updatePs.close();

            con.commit();
            con.close();

            response.sendRedirect("orders.jsp?success=Order #" + orderId + " has been cancelled successfully.");

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
            response.sendRedirect("orders.jsp?error=Cancellation failed: " + e.getMessage());
        }
    }
}
