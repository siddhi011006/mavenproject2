<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%
    // Process Recommendation if form is submitted
    String concern = request.getParameter("concern");
    String type = request.getParameter("type");
    String finish = request.getParameter("finish");
    
    boolean submitted = (concern != null && type != null && finish != null);
    
    java.util.List<Integer> recommendedProductIds = new java.util.ArrayList<>();
    String skinProfileTitle = "";
    String skinProfileDesc = "";

    if (submitted) {
        if ("dry".equals(type) || "hydration".equals(concern)) {
            skinProfileTitle = "The Dewy Hydration Routine";
            skinProfileDesc = "Your skin craves moisture, nourishment, and a high-shine finish. We recommend layering botanicals, rich overnight repair creams, and light-reflecting highlighters.";
            recommendedProductIds.add(1);  // Glow Serum
            recommendedProductIds.add(7);  // Hydra Moisturizer
            recommendedProductIds.add(8);  // Night Repair Cream
            recommendedProductIds.add(12); // Golden Highlighter
        } else if ("oily".equals(type) || "blemish".equals(concern)) {
            skinProfileTitle = "The Balanced Matte Clarifier";
            skinProfileDesc = "Your skin goals are oil control, pore refinement, and impurities removal. We recommend deep kaolin clay masking and gentle pH-balanced cleansers.";
            recommendedProductIds.add(14); // Gentle Cleanser
            recommendedProductIds.add(15); // Clay Face Mask
            recommendedProductIds.add(10); // Matte Compact
        } else if ("dullness".equals(concern) || "glow".equals(finish)) {
            skinProfileTitle = "The Radiance Boosting Regime";
            skinProfileDesc = "Focus on evening out skin texture, fading dark spots, and misting to refresh on-the-go.";
            recommendedProductIds.add(9);  // Vitamin C Serum
            recommendedProductIds.add(6);  // Face Mist
            recommendedProductIds.add(12); // Golden Highlighter
            recommendedProductIds.add(5);  // Lip Gloss
        } else {
            skinProfileTitle = "The Classic Velvet Editorial";
            skinProfileDesc = "A premium blend of nourishing prep and flawless satin velvet coverage. Perfect for daily wear.";
            recommendedProductIds.add(4);  // Silk Foundation
            recommendedProductIds.add(2);  // Velvet Lipstick
            recommendedProductIds.add(13); // Eyeshadow Palette
            recommendedProductIds.add(16); // Brow Definer
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beauty & Skincare Analysis Quiz | LuxeGlow</title>
    <!-- Core & Specific Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .quiz-hero {
            background: linear-gradient(rgba(92, 13, 30, 0.7), rgba(92, 13, 30, 0.9)), url('image/facemist.jpg') no-repeat center center;
            background-size: cover;
            color: var(--bg-dark);
            text-align: center;
            padding: 70px 20px;
            margin-bottom: 40px;
            border-radius: 0 0 40px 40px;
            box-shadow: var(--shadow-lux);
        }
        .quiz-hero h1 {
            font-size: 2.8rem;
            color: var(--bg-dark);
            margin-bottom: 10px;
            font-family: 'Playfair Display', serif;
        }
        .quiz-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            padding: 40px;
            box-shadow: var(--shadow-lux);
            max-width: 650px;
            margin: 0 auto 50px auto;
            transition: var(--transition);
        }
        .quiz-step {
            display: none;
        }
        .quiz-step.active {
            display: block;
            animation: fadeIn 0.5s ease forwards;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .quiz-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            color: var(--burgundy);
            margin-bottom: 25px;
            text-align: center;
        }
        .quiz-options {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 30px;
        }
        .quiz-option {
            display: flex;
            align-items: center;
            padding: 16px 24px;
            border: 1.5px solid var(--border-color);
            border-radius: 16px;
            cursor: pointer;
            transition: var(--transition);
            font-weight: 500;
        }
        .quiz-option:hover {
            border-color: var(--gold);
            background: var(--bg-surface);
            transform: translateX(5px);
        }
        .quiz-option.selected {
            border-color: var(--burgundy);
            background: rgba(92, 13, 30, 0.05);
            color: var(--burgundy);
        }
        .quiz-option input[type="radio"] {
            display: none;
        }
        .quiz-option i {
            margin-right: 15px;
            color: var(--gold);
            font-size: 1.1rem;
        }
        .step-indicators {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 30px;
        }
        .step-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--border-light);
            transition: var(--transition);
        }
        .step-dot.active {
            background: var(--burgundy);
            width: 25px;
            border-radius: 10px;
        }
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }
        .card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: var(--shadow-lux);
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(92, 13, 30, 0.05);
        }
        .card-image-wrapper {
            height: 250px;
            overflow: hidden;
            background: #faf8f5;
        }
        .card-image-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .card-content {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        .card-category {
            font-size: 0.7rem;
            font-weight: 600;
            color: var(--gold);
            letter-spacing: 1px;
            margin-bottom: 5px;
            text-transform: uppercase;
        }
        .card-content h3 {
            font-size: 1.05rem;
            color: var(--text-primary);
            margin-bottom: 10px;
        }
        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
            padding-top: 10px;
            border-top: 1px solid var(--border-light);
        }
    </style>
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>
    <%
        // Fetch user wishlist IDs to highlight liked items
        java.util.Set<Integer> wishlistedIds = new java.util.HashSet<>();
        if (navUserId != null) {
            Connection conWish = null;
            PreparedStatement psWish = null;
            ResultSet rsWish = null;
            try {
                conWish = DBConnection.getConnection();
                psWish = conWish.prepareStatement("SELECT product_id FROM wishlist WHERE user_id = ?");
                psWish.setInt(1, navUserId);
                rsWish = psWish.executeQuery();
                while (rsWish.next()) {
                    wishlistedIds.add(rsWish.getInt("product_id"));
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rsWish != null) try { rsWish.close(); } catch (Exception e) {}
                if (psWish != null) try { psWish.close(); } catch (Exception e) {}
                if (conWish != null) try { conWish.close(); } catch (Exception e) {}
            }
        } else {
            Object rawWish = session.getAttribute("guest_wishlist");
            if (rawWish instanceof java.util.Set) {
                for (Object idObj : (java.util.Set<?>) rawWish) {
                    if (idObj instanceof Number) {
                        wishlistedIds.add(((Number) idObj).intValue());
                    } else {
                        try {
                            wishlistedIds.add(Integer.parseInt(idObj.toString()));
                        } catch (Exception e) {}
                    }
                }
            }
        }
    %>

    <!-- Hero Header -->
    <header class="quiz-hero">
        <h1>Skin Analysis & Beauty Quiz</h1>
        <p>Find your custom skincare routine and perfect makeup pairings in under 60 seconds.</p>
    </header>

    <div class="page-container">
        
        <% if (!submitted) { %>
            <!-- Quiz Multi-Step Form Card -->
            <div class="quiz-card">
                
                <div class="step-indicators">
                    <div class="step-dot active" id="dot1"></div>
                    <div class="step-dot" id="dot2"></div>
                    <div class="step-dot" id="dot3"></div>
                </div>

                <form id="quizForm" action="quiz.jsp" method="POST">
                    
                    <!-- Step 1: Concern -->
                    <div class="quiz-step active" id="step1">
                        <h2 class="quiz-title">What is your primary skin concern?</h2>
                        <div class="quiz-options">
                            <label class="quiz-option" onclick="selectOption(this, 'step1')">
                                <input type="radio" name="concern" value="hydration" required>
                                <i class="fas fa-tint"></i>
                                Dryness & lack of hydration
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step1')">
                                <input type="radio" name="concern" value="blemish">
                                <i class="fas fa-shield-virus"></i>
                                Acne, excess shine, or blemishes
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step1')">
                                <input type="radio" name="concern" value="aging">
                                <i class="fas fa-hourglass-half"></i>
                                Fine lines & skin texture
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step1')">
                                <input type="radio" name="concern" value="dullness">
                                <i class="fas fa-sun"></i>
                                Dullness & uneven skin tone
                            </label>
                        </div>
                        <button type="button" class="btn-gold" style="width:100%; border-radius:12px;" onclick="nextStep(2)">Next Question &rarr;</button>
                    </div>

                    <!-- Step 2: Skin Feeling -->
                    <div class="quiz-step" id="step2">
                        <h2 class="quiz-title">How does your skin feel in the afternoon?</h2>
                        <div class="quiz-options">
                            <label class="quiz-option" onclick="selectOption(this, 'step2')">
                                <input type="radio" name="type" value="dry" required>
                                <i class="fas fa-snowflake"></i>
                                Tight, flaky, or dehydrated
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step2')">
                                <input type="radio" name="type" value="oily">
                                <i class="fas fa-water"></i>
                                Slick, shiny, or oily all over
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step2')">
                                <input type="radio" name="type" value="combination">
                                <i class="fas fa-adjust"></i>
                                Shiny on the forehead/nose (T-zone) only
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step2')">
                                <input type="radio" name="type" value="normal">
                                <i class="fas fa-leaf"></i>
                                Comfortable, balanced, and soft
                            </label>
                        </div>
                        <div style="display:flex; gap:15px;">
                            <button type="button" class="btn-outline" style="width:50%; border-radius:12px;" onclick="prevStep(1)">&larr; Back</button>
                            <button type="button" class="btn-gold" style="width:50%; border-radius:12px;" onclick="nextStep(3)">Next Question &rarr;</button>
                        </div>
                    </div>

                    <!-- Step 3: Finish Goal -->
                    <div class="quiz-step" id="step3">
                        <h2 class="quiz-title">What is your dream makeup finish?</h2>
                        <div class="quiz-options">
                            <label class="quiz-option" onclick="selectOption(this, 'step3')">
                                <input type="radio" name="finish" value="glow" required>
                                <i class="fas fa-magic"></i>
                                Ultra-dewy glass skin sheen
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step3')">
                                <input type="radio" name="finish" value="matte">
                                <i class="fas fa-palette"></i>
                                Blurred, oil-free soft matte finish
                            </label>
                            <label class="quiz-option" onclick="selectOption(this, 'step3')">
                                <input type="radio" name="finish" value="satin">
                                <i class="fas fa-feather-alt"></i>
                                Natural weightless satin coverage
                            </label>
                        </div>
                        <div style="display:flex; gap:15px;">
                            <button type="button" class="btn-outline" style="width:50%; border-radius:12px;" onclick="prevStep(2)">&larr; Back</button>
                            <button type="submit" class="btn-gold" style="width:50%; border-radius:12px;">Reveal Routine</button>
                        </div>
                    </div>

                </form>

            </div>
        <% } else { %>
            <!-- Recommendation Results Panel -->
            <div style="background:var(--bg-card); border:1px solid var(--border-light); border-radius:24px; padding:40px; box-shadow:var(--shadow-lux); max-width:850px; margin:0 auto 50px auto;">
                
                <div style="text-align:center; margin-bottom:40px;">
                    <i class="fas fa-award" style="color:var(--gold); font-size:3.5rem; margin-bottom:15px; text-shadow:0 0 20px rgba(197, 171, 87, 0.3);"></i>
                    <span style="font-size:0.75rem; text-transform:uppercase; color:var(--gold); font-weight:600; letter-spacing:1.5px;">Custom Beauty Profile</span>
                    <h2 style="font-family:'Playfair Display', serif; font-size:2.2rem; color:var(--burgundy); margin-bottom:15px; margin-top:5px;"><%= skinProfileTitle %></h2>
                    <p style="color:var(--text-secondary); line-height:1.7; font-size:1.05rem; max-width:650px; margin:0 auto;"><%= skinProfileDesc %></p>
                </div>

                <h3 style="font-family:'Playfair Display', serif; border-bottom:1px solid var(--border-light); padding-bottom:10px; margin-bottom:20px; font-size:1.3rem; color:var(--burgundy);">
                    <i class="fas fa-concierge-bell" style="margin-right:10px; color:var(--gold);"></i> Recommended Formulation Pairings
                </h3>

                <div class="products-grid">
                    <%
                        Connection con = null;
                        PreparedStatement ps = null;
                        ResultSet rs = null;
                        try {
                            con = DBConnection.getConnection();
                            // Query matching IDs
                            StringBuilder sqlBuilder = new StringBuilder("SELECT id, name, description, price, category, image_url, rating FROM products WHERE id IN (");
                            for (int i = 0; i < recommendedProductIds.size(); i++) {
                                sqlBuilder.append(recommendedProductIds.get(i));
                                if (i < recommendedProductIds.size() - 1) {
                                    sqlBuilder.append(",");
                                }
                            }
                            sqlBuilder.append(")");
                            
                            ps = con.prepareStatement(sqlBuilder.toString());
                            rs = ps.executeQuery();
                            while (rs.next()) {
                                int id = rs.getInt("id");
                                String name = rs.getString("name");
                                double price = rs.getDouble("price");
                                String category = rs.getString("category");
                                String imageUrl = rs.getString("image_url");
                                int rating = rs.getInt("rating");
                    %>
                    <div class="card">
                        <div class="card-image-wrapper">
                            <button class="wishlist-heart-btn <%= wishlistedIds.contains(id) ? "liked" : "" %>" 
                                    data-product-id="<%= id %>" 
                                    onclick="toggleWishlist(event, <%= id %>)" 
                                    title="<%= wishlistedIds.contains(id) ? "Remove from Wishlist" : "Add to Wishlist" %>">
                                <i class="<%= wishlistedIds.contains(id) ? "fas" : "far" %> fa-heart"></i>
                            </button>
                            <a href="product-details.jsp?id=<%= id %>">
                                <img src="<%= imageUrl %>" alt="<%= name %>">
                            </a>
                        </div>
                        <div class="card-content">
                            <span class="card-category"><%= category %></span>
                            <a href="product-details.jsp?id=<%= id %>">
                                <h3><%= name %></h3>
                            </a>
                            <div class="card-rating">
                                <% for (int i = 0; i < 5; i++) { %>
                                    <i class="<%= (i < rating) ? "fas" : "far" %> fa-star"></i>
                                <% } %>
                            </div>
                            <div class="card-footer">
                                <span style="font-weight:700; color:var(--burgundy); font-size:1.1rem;"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(price, currentCountry) %></span>
                                <button class="add-to-cart-btn" onclick="ajaxAddToCart(<%= id %>)" title="Add to Bag">
                                    <i class="fas fa-shopping-bag"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<p style='color:var(--danger);'>Error retrieving recommended items: " + e.getMessage() + "</p>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (Exception e) {}
                            if (ps != null) try { ps.close(); } catch (Exception e) {}
                            if (con != null) try { con.close(); } catch (Exception e) {}
                        }
                    %>
                </div>

                <div style="text-align:center; margin-top:40px;">
                    <a href="quiz.jsp" class="btn-outline" style="border-radius:12px; font-size:0.85rem; padding:12px 24px; margin-right:15px;">Retake Quiz</a>
                    <a href="product.jsp" class="btn-gold" style="border-radius:12px; font-size:0.85rem; padding:12px 24px;">Explore Catalog</a>
                </div>

            </div>
        <% } %>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>

    <script>


        // Radio Selection CSS Toggle helper
        function selectOption(label, stepId) {
            const options = document.getElementById(stepId).querySelectorAll('.quiz-option');
            options.forEach(o => o.classList.remove('selected'));
            label.classList.add('selected');
            label.querySelector('input[type="radio"]').checked = true;
        }

        // Navigation Steps
        function nextStep(stepNum) {
            // Validate that an option is selected in active step
            const activeStep = document.querySelector('.quiz-step.active');
            const checkedRadio = activeStep.querySelector('input[type="radio"]:checked');
            
            if (!checkedRadio) {
                showToast("Please choose an option to proceed.", "warning");
                return;
            }

            activeStep.classList.remove('active');
            document.getElementById('step' + stepNum).classList.add('active');

            // Dots update
            document.querySelectorAll('.step-dot').forEach(d => d.classList.remove('active'));
            document.getElementById('dot' + stepNum).classList.add('active');
        }

        function prevStep(stepNum) {
            document.querySelector('.quiz-step.active').classList.remove('active');
            document.getElementById('step' + stepNum).classList.add('active');

            // Dots update
            document.querySelectorAll('.step-dot').forEach(d => d.classList.remove('active'));
            document.getElementById('dot' + stepNum).classList.add('active');
        }

        // AJAX Add to Cart
        function ajaxAddToCart(productId) {
            const params = new URLSearchParams();
            params.append('action', 'add');
            params.append('productId', productId);
            params.append('quantity', 1);

            fetch('CartServlet', {
                method: 'POST',
                body: params,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    const el = document.getElementById('cartCount');
                    if (el) el.innerText = data.count;
                    showToast("Product added to your shopping bag.");
                } else {
                    showToast("Error adding product: " + data.error, "danger");
                }
            })
            .catch(err => {
                console.error(err);
                showToast("Please log in or try again.", "warning");
            });
        }
    </script>
</body>
</html>

