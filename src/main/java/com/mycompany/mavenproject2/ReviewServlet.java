package com.mycompany.mavenproject2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ReviewServlet")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "create";
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            if ("edit".equalsIgnoreCase(action) || "delete".equalsIgnoreCase(action)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized action. Please sign in.");
                return;
            }
            String prodId = request.getParameter("productId");
            response.sendRedirect("product-details.jsp?id=" + prodId + "&error=Please sign in to manage reviews.");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        String productIdStr = request.getParameter("productId");
        
        try {
            Connection con = DBConnection.getConnection();

            if ("create".equalsIgnoreCase(action)) {
                String ratingStr = request.getParameter("rating");
                String reviewText = request.getParameter("reviewText");

                if (productIdStr == null || ratingStr == null || reviewText == null ||
                    productIdStr.trim().isEmpty() || ratingStr.trim().isEmpty() || reviewText.trim().isEmpty()) {
                    response.sendRedirect("product.jsp");
                    con.close();
                    return;
                }

                int productId = Integer.parseInt(productIdStr);
                
                // Check if reviews are enabled and require moderation from properties
                boolean reviewsEnabled = true;
                boolean requireModeration = false;
                try {
                    String rcPath = request.getServletContext().getRealPath("/WEB-INF/reviews_config.properties");
                    if (rcPath != null) {
                        java.io.File rcf = new java.io.File(rcPath);
                        if (rcf.exists()) {
                            java.util.Properties props = new java.util.Properties();
                            try (java.io.FileInputStream fis = new java.io.FileInputStream(rcf)) {
                                props.load(fis);
                            }
                            reviewsEnabled = !"false".equalsIgnoreCase(props.getProperty("reviews.enabled", "true"));
                            requireModeration = "true".equalsIgnoreCase(props.getProperty("reviews.require.moderation", "false"));
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (!reviewsEnabled) {
                    response.sendRedirect("product-details.jsp?id=" + productId + "&error=Reviews are currently disabled.");
                    con.close();
                    return;
                }

                int rating = Integer.parseInt(ratingStr);

                if (rating < 1 || rating > 5) {
                    response.sendRedirect("product-details.jsp?id=" + productId + "&error=Rating must be between 1 and 5 stars.");
                    con.close();
                    return;
                }

                int isHiddenVal = requireModeration ? 1 : 0;
                String sql = "INSERT INTO reviews (product_id, user_id, rating, review_text, is_hidden) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, productId);
                ps.setInt(2, userId);
                ps.setInt(3, rating);
                ps.setString(4, reviewText.trim());
                ps.setInt(5, isHiddenVal);
                ps.executeUpdate();
                ps.close();

                if (requireModeration) {
                    response.sendRedirect("product-details.jsp?id=" + productId + "&success=Thank you! Your review has been submitted and is awaiting administrator approval.");
                } else {
                    response.sendRedirect("product-details.jsp?id=" + productId + "&success=Thank you! Your review has been published.");
                }

            } else if ("edit".equalsIgnoreCase(action)) {
                String reviewIdStr = request.getParameter("reviewId");
                String ratingStr = request.getParameter("rating");
                String reviewText = request.getParameter("reviewText");

                if (reviewIdStr == null || ratingStr == null || reviewText == null ||
                    reviewIdStr.trim().isEmpty() || ratingStr.trim().isEmpty() || reviewText.trim().isEmpty()) {
                    response.sendRedirect("product-details.jsp?id=" + productIdStr + "&error=All fields are required to edit review.");
                    con.close();
                    return;
                }

                int reviewId = Integer.parseInt(reviewIdStr);
                int rating = Integer.parseInt(ratingStr);

                if (rating < 1 || rating > 5) {
                    response.sendRedirect("product-details.jsp?id=" + productIdStr + "&error=Rating must be between 1 and 5 stars.");
                    con.close();
                    return;
                }

                // Verify review ownership
                String checkSql = "SELECT user_id FROM reviews WHERE id = ?";
                PreparedStatement checkPs = con.prepareStatement(checkSql);
                checkPs.setInt(1, reviewId);
                ResultSet rs = checkPs.executeQuery();
                if (rs.next()) {
                    int ownerId = rs.getInt("user_id");
                    if (ownerId != userId) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized to edit this review.");
                        rs.close();
                        checkPs.close();
                        con.close();
                        return;
                    }
                } else {
                    response.sendRedirect("product-details.jsp?id=" + productIdStr + "&error=Review not found.");
                    rs.close();
                    checkPs.close();
                    con.close();
                    return;
                }
                rs.close();
                checkPs.close();

                String updateSql = "UPDATE reviews SET rating = ?, review_text = ? WHERE id = ?";
                PreparedStatement updatePs = con.prepareStatement(updateSql);
                updatePs.setInt(1, rating);
                updatePs.setString(2, reviewText.trim());
                updatePs.setInt(3, reviewId);
                updatePs.executeUpdate();
                updatePs.close();

                response.sendRedirect("product-details.jsp?id=" + productIdStr + "&success=Your review has been updated.");

            } else if ("delete".equalsIgnoreCase(action)) {
                String reviewIdStr = request.getParameter("reviewId");
                if (reviewIdStr == null || reviewIdStr.trim().isEmpty()) {
                    response.sendRedirect("product-details.jsp?id=" + productIdStr + "&error=Review ID missing.");
                    con.close();
                    return;
                }

                int reviewId = Integer.parseInt(reviewIdStr);

                // Verify review ownership
                String checkSql = "SELECT user_id FROM reviews WHERE id = ?";
                PreparedStatement checkPs = con.prepareStatement(checkSql);
                checkPs.setInt(1, reviewId);
                ResultSet rs = checkPs.executeQuery();
                if (rs.next()) {
                    int ownerId = rs.getInt("user_id");
                    if (ownerId != userId) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized to delete this review.");
                        rs.close();
                        checkPs.close();
                        con.close();
                        return;
                    }
                } else {
                    response.sendRedirect("product-details.jsp?id=" + productIdStr + "&error=Review not found.");
                    rs.close();
                    checkPs.close();
                    con.close();
                    return;
                }
                rs.close();
                checkPs.close();

                String deleteSql = "DELETE FROM reviews WHERE id = ?";
                PreparedStatement deletePs = con.prepareStatement(deleteSql);
                deletePs.setInt(1, reviewId);
                deletePs.executeUpdate();
                deletePs.close();

                response.sendRedirect("product-details.jsp?id=" + productIdStr + "&success=Your review has been deleted.");
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("product-details.jsp?id=" + productIdStr + "&error=Review operation failed: " + e.getMessage());
        }
    }
}
