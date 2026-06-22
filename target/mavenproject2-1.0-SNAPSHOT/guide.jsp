<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Skin Type & Routine Guide | LuxeGlow</title>
    <!-- Core & Specific Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .guide-hero {
            background: linear-gradient(rgba(92, 13, 30, 0.7), rgba(92, 13, 30, 0.9)), url('image/facemist.jpg') no-repeat center center;
            background-size: cover;
            color: var(--bg-dark);
            text-align: center;
            padding: 75px 20px;
            margin-bottom: 40px;
            border-radius: 0 0 40px 40px;
            box-shadow: var(--shadow-lux);
        }
        .guide-hero h1 {
            font-size: 2.8rem;
            color: var(--bg-dark);
            margin-bottom: 10px;
            font-family: 'Playfair Display', serif;
        }
        .guide-tabs {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 40px;
            flex-wrap: wrap;
        }
        .guide-tab-btn {
            background: var(--bg-card);
            border: 1.5px solid var(--border-color);
            border-radius: 30px;
            color: var(--burgundy);
            padding: 12px 28px;
            font-weight: 600;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            cursor: pointer;
            transition: var(--transition);
        }
        .guide-tab-btn:hover, .guide-tab-btn.active {
            background: var(--burgundy);
            color: var(--bg-dark);
            border-color: var(--burgundy);
            box-shadow: var(--shadow-lux);
        }
        .guide-content-panel {
            display: none;
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            padding: 40px;
            box-shadow: var(--shadow-lux);
            animation: fadeIn 0.4s ease forwards;
        }
        .guide-content-panel.active {
            display: block;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .guide-layout {
            display: grid;
            grid-template-columns: 1.2fr 1.8fr;
            gap: 40px;
        }
        @media (max-width: 850px) {
            .guide-layout {
                grid-template-columns: 1fr;
            }
        }
        .guide-info-left h2 {
            font-family: 'Playfair Display', serif;
            font-size: 2rem;
            color: var(--burgundy);
            margin-bottom: 15px;
            display: block;
            padding-bottom: 0;
        }
        .guide-info-left h2::after {
            display: none;
        }
        .guide-info-left p {
            color: var(--text-secondary);
            font-size: 0.95rem;
            line-height: 1.7;
            margin-bottom: 25px;
        }
        .guide-steps-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        .guide-step-card {
            background: var(--bg-surface);
            border-radius: 16px;
            padding: 18px 22px;
            border-left: 3px solid var(--gold);
        }
        .guide-step-card h4 {
            font-family: 'Montserrat', sans-serif;
            font-weight: 700;
            color: var(--burgundy);
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }
        .guide-step-card p {
            margin-bottom: 0;
            font-size: 0.85rem;
            color: var(--text-secondary);
        }
        .products-showcase-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
        }
        .mini-product-card {
            background: var(--bg-dark);
            border: 1px solid var(--border-light);
            border-radius: 16px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 100%;
            transition: var(--transition);
        }
        .mini-product-card:hover {
            transform: translateY(-4px);
            border-color: var(--gold);
        }
        .mini-img-wrapper {
            height: 180px;
            overflow: hidden;
            background: #ffffff;
        }
        .mini-img-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .mini-content {
            padding: 15px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        .mini-content h4 {
            font-family: 'Playfair Display', serif;
            font-size: 0.95rem;
            color: var(--text-primary);
            margin-bottom: 8px;
            font-weight: 600;
        }
        .mini-content .price {
            font-weight: 700;
            color: var(--burgundy);
            font-size: 1rem;
            margin-top: auto;
        }
    </style>
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Header -->
    <header class="guide-hero">
        <h1>Skin Type & Routine Guide</h1>
        <p>Discover expert-backed beauty advice and matched formulas custom tailored to your skin's daily needs.</p>
    </header>

    <div class="page-container">
        
        <!-- Guide Tabs -->
        <div class="guide-tabs">
            <button class="guide-tab-btn active" onclick="switchTab(this, 'dry-skin')">Dry Skin</button>
            <button class="guide-tab-btn" onclick="switchTab(this, 'oily-skin')">Oily Skin</button>
            <button class="guide-tab-btn" onclick="switchTab(this, 'combination-skin')">Combination</button>
            <button class="guide-tab-btn" onclick="switchTab(this, 'sensitive-skin')">Sensitive Skin</button>
        </div>

        <!-- 1. Dry Skin Panel -->
        <div class="guide-content-panel active" id="dry-skin">
            <div class="guide-layout">
                <div class="guide-info-left">
                    <h2>Dry Skin Routine</h2>
                    <p>
                        Dry skin suffers from a lack of oil production, leading to flakiness, tightness, and fine lines. Your focus should be restoring moisture, reinforcing the natural skin barrier, and locking in hydration with rich moisturizers and replenishing active botanical serums.
                    </p>
                    <div class="guide-steps-list">
                        <div class="guide-step-card">
                            <h4>Step 1: Gentle Cleanse</h4>
                            <p>Wash morning and night using a pH-balanced cleanser that doesn't strip skin lipids.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 2: Hydrate Deeply</h4>
                            <p>Apply our Glow Serum onto damp skin to draw water molecules deep into skin cells.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 3: Seal & Repair</h4>
                            <p>Finish with Hydra Moisturizer or Night Repair Cream to lock hydration in all day.</p>
                        </div>
                    </div>
                </div>
                <div class="guide-products-right">
                    <h3 style="font-family:'Playfair Display', serif; color:var(--burgundy); margin-bottom:20px; font-size:1.25rem;">Matched Dry Skin Formulas</h3>
                    <div class="products-showcase-grid">
                        <!-- Fetch Dry Skin matching products: Glow Serum (1), Hydra Moist (7), Night Cream (8) -->
                        <% fetchAndRenderMiniProducts(out, new int[]{1, 7, 8}); %>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Oily Skin Panel -->
        <div class="guide-content-panel" id="oily-skin">
            <div class="guide-layout">
                <div class="guide-info-left">
                    <h2>Oily Skin Routine</h2>
                    <p>
                        Oily skin produces excess sebum, leading to enlarged pores, blackheads, and breakouts. Your goal is balancing sebum levels without over-stripping, purifying pores weekly, and selecting lightweight, non-comedogenic formulas.
                    </p>
                    <div class="guide-steps-list">
                        <div class="guide-step-card">
                            <h4>Step 1: Clarifying Cleanse</h4>
                            <p>Use a sulfate-free daily gentle cleanser to break down oils without activating sebum glands.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 2: Clay Masking</h4>
                            <p>Once or twice a week, apply a mineral clay mask to draw out deep-seated impurities.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 3: Lightweight Prep</h4>
                            <p>Set makeup with our micro-fine Matte Compact setting powder to absorb oil and reduce pore shine.</p>
                        </div>
                    </div>
                </div>
                <div class="guide-products-right">
                    <h3 style="font-family:'Playfair Display', serif; color:var(--burgundy); margin-bottom:20px; font-size:1.25rem;">Matched Oily Skin Formulas</h3>
                    <div class="products-showcase-grid">
                        <!-- Gentle Cleanser (14), Clay Mask (15), Matte Compact (10) -->
                        <% fetchAndRenderMiniProducts(out, new int[]{14, 15, 10}); %>
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. Combination Skin Panel -->
        <div class="guide-content-panel" id="combination-skin">
            <div class="guide-layout">
                <div class="guide-info-left">
                    <h2>Combination Skin Routine</h2>
                    <p>
                        Combination skin features an oily T-zone (forehead, nose, chin) and dry or normal patches on the cheeks. This requires "multi-mapping"—using targeted treatments on oily areas and intensive moisture on drier sections.
                    </p>
                    <div class="guide-steps-list">
                        <div class="guide-step-card">
                            <h4>Step 1: Balancing Prep</h4>
                            <p>Mist with Rosewater Face Mist to instantly soothe dry spots and balance hydration.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 2: Target Shine</h4>
                            <p>Apply kaolin clay mask only on the oily T-zone sections during weekly treatments.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 3: Nourish Cheeks</h4>
                            <p>Gently press Vitamin C or Glow Serum on the cheeks to fade texture and add brightness.</p>
                        </div>
                    </div>
                </div>
                <div class="guide-products-right">
                    <h3 style="font-family:'Playfair Display', serif; color:var(--burgundy); margin-bottom:20px; font-size:1.25rem;">Matched Balance Formulas</h3>
                    <div class="products-showcase-grid">
                        <!-- Vitamin C Serum (9), Face Mist (6), Clay Mask (15) -->
                        <% fetchAndRenderMiniProducts(out, new int[]{9, 6, 15}); %>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. Sensitive Skin Panel -->
        <div class="guide-content-panel" id="sensitive-skin">
            <div class="guide-layout">
                <div class="guide-info-left">
                    <h2>Sensitive Skin Routine</h2>
                    <p>
                        Sensitive skin reacts easily to environmental changes and harsh chemicals, showing redness, stinging, or heat. Keep your regime minimal, soothing, and strictly clean (free of artificial fragrance, parabens, and sulfates).
                    </p>
                    <div class="guide-steps-list">
                        <div class="guide-step-card">
                            <h4>Step 1: Soothing Cleansing</h4>
                            <p>Cleanse with a minimalist, pH-balanced gentle cleanser. Avoid aggressive scrubbing.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 2: Refreshing Calm</h4>
                            <p>Mist lightly with our aloe-infused facial mist throughout the day to calm sudden redness.</p>
                        </div>
                        <div class="guide-step-card">
                            <h4>Step 3: Daily Defense</h4>
                            <p>Apply our organic Glow Serum to reinforce the skin lipid barrier against irritation.</p>
                        </div>
                    </div>
                </div>
                <div class="guide-products-right">
                    <h3 style="font-family:'Playfair Display', serif; color:var(--burgundy); margin-bottom:20px; font-size:1.25rem;">Soothing Sensitive Skin Formulas</h3>
                    <div class="products-showcase-grid">
                        <!-- Glow Serum (1), Face Mist (6), Gentle Cleanser (14) -->
                        <% fetchAndRenderMiniProducts(out, new int[]{1, 6, 14}); %>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>

    <script>


        // Switch Tab Panels
        function switchTab(btn, panelId) {
            document.querySelectorAll('.guide-tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.guide-content-panel').forEach(p => p.classList.remove('active'));

            btn.classList.add('active');
            document.getElementById(panelId).classList.add('active');
        }
    </script>
</body>
</html>

<%!
    // JSP Declaration method to load and display mini cards safely
    private void fetchAndRenderMiniProducts(JspWriter out, int[] productIds) throws java.io.IOException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            StringBuilder sql = new StringBuilder("SELECT id, name, price, image_url FROM products WHERE id IN (");
            for (int i = 0; i < productIds.length; i++) {
                sql.append(productIds[i]);
                if (i < productIds.length - 1) {
                    sql.append(",");
                }
            }
            sql.append(")");

            ps = con.prepareStatement(sql.toString());
            rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                double price = rs.getDouble("price");
                String imageUrl = rs.getString("image_url");

                out.println("<div class='mini-product-card'>");
                out.println("  <div class='mini-img-wrapper'>");
                out.println("    <a href='product-details.jsp?id=" + id + "'><img src='" + imageUrl + "' alt='" + name + "'></a>");
                out.println("  </div>");
                out.println("  <div class='mini-content'>");
                out.println("    <h4><a href='product-details.jsp?id=" + id + "'>" + name + "</a></h4>");
                out.println("    <div class='price'>$" + String.format("%.2f", price) + "</div>");
                out.println("  </div>");
                out.println("</div>");
            }
        } catch (Exception e) {
            out.println("<p style='color:var(--danger);'>Error loading: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    }
%>

