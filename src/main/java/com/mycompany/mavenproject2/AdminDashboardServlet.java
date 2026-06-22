package com.mycompany.mavenproject2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Secure route controller for /admin.
 * Enforces authentication and authorization (role = ADMIN) before forwarding to the protected dashboard view.
 * Exposes database-driven KPI counters and report objects to the JSP view.
 * 
 * @author Antigravity
 */
@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Please sign in to access the Admin Panel.");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }

        // Fetch KPI Metrics and Analytics Data
        double totalRevenue = 0.0;
        int totalOrdersCount = 0;
        int totalUsersCount = 0;
        int totalProductsCount = 0;
        int newUsersThisMonth = 0;

        List<String> categoriesList = new ArrayList<>();
        List<Map<String, Object>> recentOrdersList = new ArrayList<>();
        List<Map<String, Object>> monthlySalesList = new ArrayList<>();
        List<Map<String, Object>> bestSellersList = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            
            // 1. KPI Counters
            try (Statement st = con.createStatement()) {
                // Revenue (excluding cancelled orders)
                try (ResultSet rs = st.executeQuery("SELECT SUM(total_amount) FROM orders WHERE status != 'CANCELLED'")) {
                    if (rs.next()) {
                        totalRevenue = rs.getDouble(1);
                    }
                }
                
                // Total Orders
                try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM orders")) {
                    if (rs.next()) {
                        totalOrdersCount = rs.getInt(1);
                    }
                }
                
                // Total Users
                try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users")) {
                    if (rs.next()) {
                        totalUsersCount = rs.getInt(1);
                    }
                }
                
                // Total Products
                try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM products")) {
                    if (rs.next()) {
                        totalProductsCount = rs.getInt(1);
                    }
                }
                
                // Categories list for product creation
                try (ResultSet rs = st.executeQuery("SELECT name FROM categories ORDER BY name ASC")) {
                    while (rs.next()) {
                        categoriesList.add(rs.getString("name"));
                    }
                }
            }

            // 2. New Users this Month
            String newUsersSql = "SELECT COUNT(*) FROM users WHERE MONTH(created_at) = MONTH(CURRENT_DATE()) AND YEAR(created_at) = YEAR(CURRENT_DATE())";
            try (PreparedStatement ps = con.prepareStatement(newUsersSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    newUsersThisMonth = rs.getInt(1);
                }
            }

            // 3. Recent Orders List (Top 5)
            String recentOrdersSql = "SELECT o.id, o.order_date, o.total_amount, o.status, o.shipping_address, u.fullname " +
                                     "FROM orders o JOIN users u ON o.user_id = u.id " +
                                     "ORDER BY o.order_date DESC LIMIT 5";
            try (PreparedStatement ps = con.prepareStatement(recentOrdersSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> order = new HashMap<>();
                    order.put("id", rs.getInt("id"));
                    order.put("date", rs.getTimestamp("order_date"));
                    order.put("total", rs.getDouble("total_amount"));
                    order.put("status", rs.getString("status"));
                    order.put("address", rs.getString("shipping_address"));
                    order.put("customer", rs.getString("fullname"));
                    recentOrdersList.add(order);
                }
            }

            // 4. Orders and Sales per Month (Analytics)
            String monthlySalesSql = "SELECT MONTHNAME(order_date) as month_name, COUNT(*) as order_count, SUM(total_amount) as sales_amount " +
                                      "FROM orders WHERE status != 'CANCELLED' " +
                                      "GROUP BY MONTH(order_date), MONTHNAME(order_date) " +
                                      "ORDER BY MONTH(order_date)";
            try (PreparedStatement ps = con.prepareStatement(monthlySalesSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> monthStat = new HashMap<>();
                    monthStat.put("month", rs.getString("month_name"));
                    monthStat.put("orders", rs.getInt("order_count"));
                    monthStat.put("sales", rs.getDouble("sales_amount"));
                    monthlySalesList.add(monthStat);
                }
            }

            // 5. Best-Selling Products (Top 5)
            String bestSellersSql = "SELECT p.name, SUM(oi.quantity) as total_sold " +
                                    "FROM order_items oi JOIN products p ON oi.product_id = p.id " +
                                    "GROUP BY oi.product_id, p.name " +
                                    "ORDER BY total_sold DESC LIMIT 5";
            try (PreparedStatement ps = con.prepareStatement(bestSellersSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("name", rs.getString("name"));
                    item.put("sold", rs.getInt("total_sold"));
                    bestSellersList.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            // Store query exception inside attribute so we can alert in view
            request.setAttribute("query_error", e.getMessage());
        }

        // Set variables as attributes for JSP page
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalOrdersCount", totalOrdersCount);
        request.setAttribute("totalUsersCount", totalUsersCount);
        request.setAttribute("totalProductsCount", totalProductsCount);
        request.setAttribute("newUsersThisMonth", newUsersThisMonth);
        request.setAttribute("categoriesList", categoriesList);
        request.setAttribute("recentOrdersList", recentOrdersList);
        request.setAttribute("monthlySalesList", monthlySalesList);
        request.setAttribute("bestSellersList", bestSellersList);

        // Forward to the protected JSP page in WEB-INF
        request.getRequestDispatcher("/WEB-INF/admin-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
