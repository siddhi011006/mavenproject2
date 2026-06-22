<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%
    // Enforce authentication & admin privileges
    HttpSession sess = request.getSession(false);
    if (sess == null || !"ADMIN".equalsIgnoreCase((String) sess.getAttribute("role"))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
        return;
    }

    String prodIdStr = request.getParameter("productId");
    if (prodIdStr == null || prodIdStr.trim().isEmpty()) {
        out.println("<p style='color:var(--danger);'>Error: Missing Product ID</p>");
        return;
    }

    int productId = Integer.parseInt(prodIdStr.trim());

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT pi.id, pi.image_url, pi.sort_order, pi.is_primary, pi.variant_id, pv.variant_name FROM product_images pi " +
             "LEFT JOIN product_variants pv ON pi.variant_id = pv.id " +
             "WHERE pi.product_id = ? ORDER BY pi.sort_order ASC, pi.id ASC")) {
        
        ps.setInt(1, productId);
        try (ResultSet rs = ps.executeQuery()) {
            boolean hasImages = false;
            while (rs.next()) {
                hasImages = true;
                int imgId = rs.getInt("id");
                String url = rs.getString("image_url");
                int sortOrder = rs.getInt("sort_order");
                int isPrimary = rs.getInt("is_primary");
                String vName = rs.getString("variant_name");
%>
<div style="display:flex; justify-content:space-between; align-items:center; background:var(--bg-surface); padding:10px; border-radius:10px; border:1px solid var(--border-light);">
    <div style="display:flex; align-items:center; gap:12px; text-align:left;">
        <img src="<%= url %>" style="width:50px; height:50px; object-fit:cover; border-radius:6px; border:1px solid var(--border-color);">
        <div>
            <div style="font-size:0.75rem; color:var(--text-muted);"><%= vName != null ? "Variant: " + vName : "General Image" %></div>
            <div style="margin-top:4px;">
                <!-- Reorder Form -->
                <form action="AdminServlet" method="POST" style="display:inline-flex; align-items:center; gap:5px;">
                    <input type="hidden" name="action" value="reorderProductImages">
                    <input type="hidden" name="imageOrder" value="<%= imgId %>">
                    <span style="font-size:0.7rem; color:var(--text-secondary);">Sort:</span>
                    <input type="number" name="sort_order_val" value="<%= sortOrder %>" style="width:45px; padding:3px; font-size:0.7rem; border-radius:4px; border:1px solid var(--border-color); text-align:center; background:var(--bg-dark); color:var(--text-primary);"
                           onchange="submitReorder(<%= imgId %>, this.value)">
                </form>
            </div>
        </div>
    </div>
    
    <div style="display:flex; align-items:center; gap:6px;">
        <% if (isPrimary == 1) { %>
            <span style="font-size:0.65rem; font-weight:700; color:var(--gold); border:1px solid var(--gold); padding:3px 8px; border-radius:12px; background:rgba(197,171,87,0.05);">Primary</span>
        <% } else if (vName == null) { %>
            <form action="AdminServlet" method="POST" style="margin:0;">
                <input type="hidden" name="action" value="setPrimaryProductImage">
                <input type="hidden" name="imageId" value="<%= imgId %>">
                <input type="hidden" name="productId" value="<%= productId %>">
                <button type="submit" class="btn-outline" style="padding:4px 8px; font-size:0.65rem; border-radius:6px; text-transform:none;">Set Primary</button>
            </form>
        <% } %>
        
        <form action="AdminServlet" method="POST" style="margin:0;" onsubmit="return confirm('Delete this image from gallery?');">
            <input type="hidden" name="action" value="deleteProductImage">
            <input type="hidden" name="imageId" value="<%= imgId %>">
            <button type="submit" style="background:transparent; border:none; color:var(--danger); cursor:pointer; font-size:1.1rem; padding:4px 8px; display:inline-flex; align-items:center;"><i class="fas fa-trash-alt"></i></button>
        </form>
    </div>
</div>
<%
            }
            if (!hasImages) {
                out.println("<p style='color:var(--text-muted); text-align:center; font-size:0.8rem; padding:20px;'>No images uploaded yet.</p>");
            }
        }
    } catch (Exception e) {
        out.println("<p style='color:var(--danger); font-size:0.8rem;'>Error loading gallery: " + e.getMessage() + "</p>");
    }
%>

<script>
    function submitReorder(imgId, val) {
        // Post reorder asynchronously or submit a quick action
        const params = new URLSearchParams();
        params.append('action', 'reorderProductImages');
        params.append('imageOrder', imgId);
        
        // Wait, to support reordering single item to a specific sort order, let's make sure
        // we can submit it or trigger form. Let's do it via fetch:
        fetch('AdminServlet', {
            method: 'POST',
            body: new URLSearchParams({
                action: 'reorderProductImages',
                imageOrder: imgId + '',
                sort_order_val: val
            }),
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        }).then(() => {
            // refresh
            if (typeof fetchGalleryImages === 'function') {
                fetchGalleryImages(document.getElementById('galleryProductId').value);
            }
        });
    }
</script>
