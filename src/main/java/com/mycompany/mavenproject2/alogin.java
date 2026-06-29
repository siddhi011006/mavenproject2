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

@WebServlet("/alogin")
public class alogin extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and Password are required.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            Connection con = DBConnection.getConnection();

            // SQL Query to verify credentials and select user metadata
            String sql = "SELECT id, fullname, email, username, role, country_name, enabled, password FROM users WHERE email=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email.trim());

            ResultSet rs = ps.executeQuery();

            if (rs.next() && PasswordHasher.checkPassword(password.trim(), rs.getString("password"))) {
                int enabled = rs.getInt("enabled");
                if (enabled == 0) {
                    rs.close();
                    ps.close();
                    con.close();
                    request.setAttribute("error", "Your account has been disabled. Please contact support.");
                    request.setAttribute("email", email);
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }

                HttpSession session = request.getSession();
                int userId = rs.getInt("id");
                
                // Store complete user object properties in session
                session.setAttribute("user_id", userId);
                session.setAttribute("fullname", rs.getString("fullname"));
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("username", rs.getString("username"));
                
                String role = rs.getString("role");
                session.setAttribute("role", role);
                
                String dbCountry = rs.getString("country_name");
                session.setAttribute("selected_country", dbCountry != null ? dbCountry : "India");

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

                // Redirect based on role
                if ("ADMIN".equalsIgnoreCase(role)) {
                    response.sendRedirect("admin");
                } else {
                    response.sendRedirect("index.jsp");
                }

            } else {
                con.close();
                request.setAttribute("error", "Invalid Email or Password.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}