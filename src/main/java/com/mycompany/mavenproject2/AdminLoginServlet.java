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

/**
 * Controller handling admin login form submissions.
 * Verifies credentials, ADMIN role permissions, and active status in the database.
 * 
 * @author Antigravity
 */
@WebServlet("/admin-login")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin-login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=All login fields are required.");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            String sql = "SELECT id, fullname, email, username, role, country_name, enabled, password FROM users WHERE email = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, email.trim());
            rs = ps.executeQuery();

            if (rs.next() && PasswordHasher.checkPassword(password.trim(), rs.getString("password"))) {
                String role = rs.getString("role");
                int enabled = rs.getInt("enabled");

                // Enforce ADMIN role restriction
                if (!"ADMIN".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Access Denied. Administrator role required.");
                    return;
                }

                // Enforce account activation status check
                if (enabled == 0) {
                    response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Account disabled. Contact administrator support.");
                    return;
                }

                // Bind administrative session properties
                HttpSession session = request.getSession(true);
                session.setAttribute("user_id", rs.getInt("id"));
                session.setAttribute("fullname", rs.getString("fullname"));
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("role", role);
                
                String dbCountry = rs.getString("country_name");
                session.setAttribute("selected_country", dbCountry != null ? dbCountry : "India");

                response.sendRedirect(request.getContextPath() + "/admin");

            } else {
                response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Invalid administrator email or password.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Authentication error: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    }
}
