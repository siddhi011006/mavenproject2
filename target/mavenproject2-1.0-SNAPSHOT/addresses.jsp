<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%
    // Authenticate user
    HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp?error=Please sign in to manage your addresses.&redirect=addresses.jsp");
        return;
    }

    int userId = (Integer) s.getAttribute("user_id");
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    java.util.List<String[]> addressList = new java.util.ArrayList<>();

    try {
        con = DBConnection.getConnection();
        String sql = "SELECT id, address_line, city, zip, country, is_default FROM addresses WHERE user_id = ? ORDER BY is_default DESC, id DESC";
        ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        while (rs.next()) {
            addressList.add(new String[]{
                rs.getString("id"),
                rs.getString("address_line"),
                rs.getString("city"),
                rs.getString("zip"),
                rs.getString("country"),
                rs.getString("is_default")
            });
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saved Addresses | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <div class="page-container" style="padding: 60px 8%; max-width: 1200px; margin: 0 auto; text-align: left;">
        
        <!-- Action Alerts -->
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) {
        %>
            <div class="alert alert-success" style="margin-bottom: 25px;">
                <i class="fas fa-check-circle"></i>
                <span><%= successMsg %></span>
            </div>
        <%
            }
            if (errorMsg != null) {
        %>
            <div class="alert alert-danger" style="margin-bottom: 25px;">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= errorMsg %></span>
            </div>
        <%
            }
        %>

        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-light); padding-bottom: 15px; margin-bottom: 30px;">
            <h1 style="font-family:'Playfair Display', serif; font-size: 2.2rem; color: var(--burgundy); margin: 0;">Saved Addresses</h1>
            <button onclick="toggleAddressForm()" class="btn-gold" style="border-radius: 30px; font-size: 0.8rem; padding: 10px 24px; margin: 0;">
                <i class="fas fa-plus" style="margin-right: 8px;"></i> Add New Address
            </button>
        </div>

        <!-- Add Address Form Panel (hidden by default) -->
        <div id="addAddressPanel" style="display: none; background: var(--bg-card); border-radius: 20px; border: 1px solid var(--border-color); padding: 30px; margin-bottom: 35px; box-shadow: var(--shadow-lux); animation: fadeIn 0.4s ease;">
            <h3 style="font-family:'Playfair Display', serif; font-size: 1.3rem; color: var(--burgundy); margin-bottom: 20px;">Enter Shipping Address</h3>
            
            <form action="AddressServlet" method="POST">
                <input type="hidden" name="action" value="add">

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: 600; font-size: 0.85rem; display: block; margin-bottom: 5px;">Street Address</label>
                    <input type="text" name="addressLine" placeholder="123 Beauty Blvd, Suite 10" required style="width: 100%; border-radius: 30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none;">
                </div>

                <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                    <div class="form-group">
                        <label style="font-weight: 600; font-size: 0.85rem; display: block; margin-bottom: 5px;">City</label>
                        <input type="text" name="city" placeholder="Los Angeles" required style="width: 100%; border-radius: 30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none;">
                    </div>
                    <div class="form-group">
                        <label style="font-weight: 600; font-size: 0.85rem; display: block; margin-bottom: 5px;">Zip Code</label>
                        <input type="text" name="zip" placeholder="90001" required style="width: 100%; border-radius: 30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none;">
                    </div>
                    <div class="form-group">
                        <label style="font-weight: 600; font-size: 0.85rem; display: block; margin-bottom: 5px;">Country</label>
                        <select name="country" required style="width: 100%; border-radius: 30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none; background: var(--bg-card); color: var(--text-primary); font-size: 0.85rem; box-sizing: border-box; height: 45px;">
                            <option value="India">India</option>
                            <option value="United States">United States</option>
                            <option value="United Kingdom">United Kingdom</option>
                            <option value="Canada">Canada</option>
                            <option value="Australia">Australia</option>
                            <option value="UAE">UAE</option>
                            <option value="Germany">Germany</option>
                            <option value="France">France</option>
                        </select>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 25px; display: flex; align-items: center; gap: 8px;">
                    <input type="checkbox" name="isDefault" id="isDefaultCheck" style="cursor: pointer; width: 16px; height: 16px;">
                    <label for="isDefaultCheck" style="font-size: 0.85rem; font-weight: 550; cursor: pointer; color: var(--text-secondary);">Set as default shipping address</label>
                </div>

                <button type="submit" class="btn-gold" style="border-radius: 30px; font-size: 0.8rem; padding: 12px 26px; margin: 0;">Save Shipping Address</button>
                <button type="button" onclick="toggleAddressForm()" class="btn-outline" style="border-radius: 30px; font-size: 0.8rem; padding: 11px 24px; margin-left: 10px;">Cancel</button>
            </form>
        </div>

        <% if (addressList.isEmpty()) { %>
            <div style="text-align: center; padding: 60px 20px; background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 20px; max-width: 600px; margin: 0 auto;">
                <i class="fas fa-map-marker-alt" style="font-size: 4rem; color: var(--gold); margin-bottom: 20px; opacity: 0.6;"></i>
                <h3 style="font-size: 1.5rem; margin-bottom: 10px;">No Saved Addresses</h3>
                <p style="color: var(--text-secondary); margin-bottom: 25px;">You haven't saved any shipping addresses yet. Save one now for a faster secure checkout experience!</p>
                <button onclick="toggleAddressForm()" class="btn-gold">Create Saved Address</button>
            </div>
        <% } else { %>
            <!-- Addresses Grid -->
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 25px;">
                <% for (String[] addr : addressList) { %>
                    <div style="background: var(--bg-card); border-radius: 20px; border: 1px solid <%= "true".equals(addr[5]) ? "var(--gold)" : "var(--border-light)" %>; padding: 25px; box-shadow: var(--shadow-lux); display: flex; flex-direction: column; justify-content: space-between; position: relative;">
                        
                        <!-- Default Flag tag -->
                        <% if ("true".equals(addr[5])) { %>
                            <span style="position: absolute; top: 15px; right: 15px; font-size: 0.65rem; background: var(--burgundy); color: white; padding: 4px 10px; border-radius: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;">Default</span>
                        <% } %>

                        <div>
                            <div style="font-size: 0.8rem; font-weight: 600; color: var(--gold); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px;">
                                <i class="fas fa-home" style="margin-right: 5px;"></i> Shipping Address
                            </div>
                            <p style="font-size: 0.95rem; font-weight: 550; color: var(--text-primary); margin-bottom: 5px;"><%= addr[1] %></p>
                            <p style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 20px;"><%= addr[2] %>, <%= addr[3] %>, <%= addr[4] %></p>
                        </div>

                        <div style="display: flex; gap: 10px; border-top: 1px solid var(--border-light); padding-top: 15px; margin-top: 10px; align-items: center;">
                            <% if (!"true".equals(addr[5])) { %>
                                <form action="AddressServlet" method="POST" style="margin: 0;">
                                    <input type="hidden" name="action" value="setDefault">
                                    <input type="hidden" name="id" value="<%= addr[0] %>">
                                    <button type="submit" style="background: none; border: none; color: var(--gold); font-size: 0.8rem; font-weight: 600; cursor: pointer; padding: 0;">Set Default</button>
                                </form>
                                <span style="color: var(--border-light);">|</span>
                            <% } %>
                            
                            <form action="AddressServlet" method="POST" style="margin: 0;" onsubmit="return confirm('Remove this address?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= addr[0] %>">
                                <button type="submit" style="background: none; border: none; color: var(--danger); font-size: 0.8rem; font-weight: 600; cursor: pointer; padding: 0;">Delete</button>
                            </form>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>

        <div style="margin-top: 40px; text-align: center;">
            <a href="profile.jsp" style="font-size: 0.85rem; color: var(--text-muted); font-weight: 600; text-decoration: underline;">
                &larr; Back to Dashboard
            </a>
        </div>

    </div>

    <!-- Include Reusable Footer -->
    <%@ include file="footer.jsp" %>

    <script>
        function toggleAddressForm() {
            const panel = document.getElementById('addAddressPanel');
            if (panel.style.display === 'none') {
                panel.style.display = 'block';
                window.scrollTo({ top: panel.offsetTop - 100, behavior: 'smooth' });
            } else {
                panel.style.display = 'none';
            }
        }
    </script>
</body>
</html>

