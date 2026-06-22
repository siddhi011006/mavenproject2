package com.mycompany.mavenproject2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller/Servlet managing saved shipping addresses for registered users.
 * Supports adding an address, deleting, and setting an address as the default.
 * 
 * @author Siddhi Tiwari
 */
@WebServlet("/AddressServlet")
public class AddressServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("addresses.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp?error=Please sign in to manage your addresses.");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect("addresses.jsp?error=Missing action parameter.");
            return;
        }

        try {
            Connection con = DBConnection.getConnection();

            if ("add".equalsIgnoreCase(action)) {
                String addressLine = request.getParameter("addressLine");
                String city = request.getParameter("city");
                String zip = request.getParameter("zip");
                String country = request.getParameter("country");
                boolean isDefault = "true".equalsIgnoreCase(request.getParameter("isDefault")) || 
                                    request.getParameter("isDefault") != null;

                if (addressLine == null || city == null || zip == null || country == null ||
                    addressLine.trim().isEmpty() || city.trim().isEmpty() || zip.trim().isEmpty() || country.trim().isEmpty()) {
                    response.sendRedirect("addresses.jsp?error=All fields are required.");
                    con.close();
                    return;
                }

                if (isDefault) {
                    // Reset existing default addresses for this user
                    String resetSql = "UPDATE addresses SET is_default = FALSE WHERE user_id = ?";
                    PreparedStatement resetPs = con.prepareStatement(resetSql);
                    resetPs.setInt(1, userId);
                    resetPs.executeUpdate();
                    resetPs.close();
                }

                String insertSql = "INSERT INTO addresses (user_id, address_line, city, zip, country, is_default) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement insertPs = con.prepareStatement(insertSql);
                insertPs.setInt(1, userId);
                insertPs.setString(2, addressLine.trim());
                insertPs.setString(3, city.trim());
                insertPs.setString(4, zip.trim());
                insertPs.setString(5, country.trim());
                insertPs.setBoolean(6, isDefault);
                insertPs.executeUpdate();
                insertPs.close();

                response.sendRedirect("addresses.jsp?success=Address added successfully!");

            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));

                String deleteSql = "DELETE FROM addresses WHERE id = ? AND user_id = ?";
                PreparedStatement deletePs = con.prepareStatement(deleteSql);
                deletePs.setInt(1, id);
                deletePs.setInt(2, userId);
                deletePs.executeUpdate();
                deletePs.close();

                response.sendRedirect("addresses.jsp?success=Address deleted successfully!");

            } else if ("setDefault".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(request.getParameter("id"));

                // Reset existing defaults
                String resetSql = "UPDATE addresses SET is_default = FALSE WHERE user_id = ?";
                PreparedStatement resetPs = con.prepareStatement(resetSql);
                resetPs.setInt(1, userId);
                resetPs.executeUpdate();
                resetPs.close();

                // Set new default
                String updateSql = "UPDATE addresses SET is_default = TRUE WHERE id = ? AND user_id = ?";
                PreparedStatement updatePs = con.prepareStatement(updateSql);
                updatePs.setInt(1, id);
                updatePs.setInt(2, userId);
                updatePs.executeUpdate();
                updatePs.close();

                response.sendRedirect("addresses.jsp?success=Default address updated!");

            } else {
                response.sendRedirect("addresses.jsp?error=Unknown action: " + action);
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addresses.jsp?error=Operation failed: " + e.getMessage());
        }
    }
}
