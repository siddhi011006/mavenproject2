package com.mycompany.mavenproject2;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/WishlistServlet")
public class WishlistServlet extends HttpServlet {

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
        String productIdStr = request.getParameter("productId");

        if (action == null || productIdStr == null) {
            out.write("{\"error\": \"Missing action or productId parameters\"}");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);

            if (userId != null) {
                // Database-backed wishlist
                Connection con = null;
                PreparedStatement ps = null;
                try {
                    con = DBConnection.getConnection();
                    int wishlistCount = 0;
                    if ("add".equalsIgnoreCase(action)) {
                        String sql = "INSERT INTO wishlist (user_id, product_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE product_id=product_id";
                        ps = con.prepareStatement(sql);
                        ps.setInt(1, userId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                        ps.close();
                        
                        ps = con.prepareStatement("SELECT COUNT(*) FROM wishlist WHERE user_id = ?");
                        ps.setInt(1, userId);
                        ResultSet rsCount = ps.executeQuery();
                        if (rsCount.next()) {
                            wishlistCount = rsCount.getInt(1);
                        }
                        rsCount.close();
                        
                        out.write("{\"success\": true, \"message\": \"Added to wishlist\", \"count\": " + wishlistCount + "}");
                    } else if ("remove".equalsIgnoreCase(action)) {
                        String sql = "DELETE FROM wishlist WHERE user_id = ? AND product_id = ?";
                        ps = con.prepareStatement(sql);
                        ps.setInt(1, userId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                        ps.close();
                        
                        ps = con.prepareStatement("SELECT COUNT(*) FROM wishlist WHERE user_id = ?");
                        ps.setInt(1, userId);
                        ResultSet rsCount = ps.executeQuery();
                        if (rsCount.next()) {
                            wishlistCount = rsCount.getInt(1);
                        }
                        rsCount.close();
                        
                        out.write("{\"success\": true, \"message\": \"Removed from wishlist\", \"count\": " + wishlistCount + "}");
                    } else {
                        out.write("{\"error\": \"Invalid action\"}");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception e) {}
                    if (con != null) try { con.close(); } catch (Exception e) {}
                }
            } else {
                // Session-backed wishlist for guests
                Set<Integer> guestWishlist = getGuestWishlist(session);
                if ("add".equalsIgnoreCase(action)) {
                    guestWishlist.add(productId);
                    out.write("{\"success\": true, \"message\": \"Added to session wishlist\", \"count\": " + guestWishlist.size() + "}");
                } else if ("remove".equalsIgnoreCase(action)) {
                    guestWishlist.remove(productId);
                    out.write("{\"success\": true, \"message\": \"Removed from session wishlist\", \"count\": " + guestWishlist.size() + "}");
                } else {
                    out.write("{\"error\": \"Invalid action\"}");
                }
            }

        } catch (NumberFormatException e) {
            out.write("{\"error\": \"Invalid product ID format\"}");
        }
    }

    @SuppressWarnings("unchecked")
    private Set<Integer> getGuestWishlist(HttpSession session) {
        Set<Integer> wishlist = (Set<Integer>) session.getAttribute("guest_wishlist");
        if (wishlist == null) {
            wishlist = new HashSet<>();
            session.setAttribute("guest_wishlist", wishlist);
        }
        return wishlist;
    }
}
