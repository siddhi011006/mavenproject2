package com.mycompany.mavenproject2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/oauth-login")
public class OAuthLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String fullname = request.getParameter("fullname");
        String uid = request.getParameter("uid");
        String provider = request.getParameter("provider");
        String redirectVal = request.getParameter("redirect");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "OAuth login failed: Email is required from authentication provider.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        if (fullname == null || fullname.trim().isEmpty()) {
            fullname = email.contains("@") ? email.substring(0, email.indexOf("@")) : "OAuth User";
        }

        try {
            Connection con = DBConnection.getConnection();

            // Check if user exists
            String sql = "SELECT id, fullname, email, username, role, country_name, enabled FROM users WHERE email=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email.trim().toLowerCase());
            ResultSet rs = ps.executeQuery();

            int userId = -1;
            String dbFullname = "";
            String dbEmail = "";
            String dbUsername = "";
            String role = "USER";
            String country = "India";
            boolean isNewUser = false;

            if (rs.next()) {
                int enabled = rs.getInt("enabled");
                if (enabled == 0) {
                    rs.close();
                    ps.close();
                    con.close();
                    request.setAttribute("error", "Your account has been disabled. Please contact support.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
                userId = rs.getInt("id");
                dbFullname = rs.getString("fullname");
                dbEmail = rs.getString("email");
                dbUsername = rs.getString("username");
                role = rs.getString("role");
                String dbCountry = rs.getString("country_name");
                if (dbCountry != null) {
                    country = dbCountry;
                }
            } else {
                // Register a new user
                isNewUser = true;
                dbEmail = email.trim().toLowerCase();
                dbFullname = fullname.trim();
                dbUsername = dbEmail.contains("@") ? dbEmail.substring(0, dbEmail.indexOf("@")) : dbEmail;
                
                // Add unique suffix to username if it already exists to prevent duplicate username constraints
                String checkUserSql = "SELECT id FROM users WHERE username = ?";
                PreparedStatement checkUserPs = con.prepareStatement(checkUserSql);
                checkUserPs.setString(1, dbUsername);
                ResultSet checkUserRs = checkUserPs.executeQuery();
                if (checkUserRs.next()) {
                    dbUsername = dbUsername + "_" + UUID.randomUUID().toString().substring(0, 5);
                }
                checkUserRs.close();
                checkUserPs.close();

                // Hash a random secure password since they login via Google/Apple
                String randomPassword = UUID.randomUUID().toString();
                String hashedPassword = PasswordHasher.hashPassword(randomPassword);

                String insertSql = "INSERT INTO users(fullname, email, password, username, role, phone, country_name, email_verified) VALUES(?, ?, ?, ?, 'USER', ?, ?, 1)";
                PreparedStatement insertPs = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                insertPs.setString(1, dbFullname);
                insertPs.setString(2, dbEmail);
                insertPs.setString(3, hashedPassword);
                insertPs.setString(4, dbUsername);
                insertPs.setString(5, ""); // empty phone
                insertPs.setString(6, country);
                insertPs.executeUpdate();

                ResultSet keys = insertPs.getGeneratedKeys();
                if (keys.next()) {
                    userId = keys.getInt(1);
                }
                keys.close();
                insertPs.close();
            }

            rs.close();
            ps.close();

            // Set up Session
            HttpSession session = request.getSession();
            session.setAttribute("user_id", userId);
            session.setAttribute("fullname", dbFullname);
            session.setAttribute("email", dbEmail);
            session.setAttribute("username", dbUsername);
            session.setAttribute("role", role);
            session.setAttribute("selected_country", country);

            // 1. Merge Guest Cart to DB Cart
            Object guestCartObj = session.getAttribute("guest_cart");
            if (guestCartObj instanceof java.util.Map) {
                java.util.Map<?, ?> guestCart = (java.util.Map<?, ?>) guestCartObj;
                if (!guestCart.isEmpty()) {
                    String mergeCartSql = "INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?) "
                                        + "ON DUPLICATE KEY UPDATE quantity = quantity + ?";
                    PreparedStatement mergeCartPs = con.prepareStatement(mergeCartSql);
                    for (java.util.Map.Entry<?, ?> entry : guestCart.entrySet()) {
                        try {
                            int prodId = Integer.parseInt(entry.getKey().toString());
                            int qty = Integer.parseInt(entry.getValue().toString());
                            mergeCartPs.setInt(1, userId);
                            mergeCartPs.setInt(2, prodId);
                            mergeCartPs.setInt(3, qty);
                            mergeCartPs.setInt(4, qty);
                            mergeCartPs.executeUpdate();
                        } catch (Exception ex) {
                            // Ignore invalid items
                        }
                    }
                    session.removeAttribute("guest_cart");
                }
            }

            // 2. Merge Guest Wishlist to DB Wishlist
            Object guestWishObj = session.getAttribute("guest_wishlist");
            if (guestWishObj instanceof java.util.Set) {
                java.util.Set<?> guestWish = (java.util.Set<?>) guestWishObj;
                if (!guestWish.isEmpty()) {
                    String mergeWishSql = "INSERT INTO wishlist (user_id, product_id) VALUES (?, ?) "
                                        + "ON DUPLICATE KEY UPDATE product_id = product_id";
                    PreparedStatement mergeWishPs = con.prepareStatement(mergeWishSql);
                    for (Object prodIdObj : guestWish) {
                        try {
                            int prodId = Integer.parseInt(prodIdObj.toString());
                            mergeWishPs.setInt(1, userId);
                            mergeWishPs.setInt(2, prodId);
                            mergeWishPs.executeUpdate();
                        } catch (Exception ex) {
                            // Ignore invalid items
                        }
                    }
                    session.removeAttribute("guest_wishlist");
                }
            }

            con.close();

            // Trigger welcome email asynchronously for new users (fails gracefully)
            if (isNewUser) {
                try {
                    EmailUtility.sendWelcomeEmail(dbEmail, dbFullname);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            // Redirect based on role and parameters
            if (redirectVal != null && !redirectVal.trim().isEmpty()) {
                response.sendRedirect(redirectVal.trim());
            } else if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect("admin");
            } else {
                response.sendRedirect("index.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred during OAuth login: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
