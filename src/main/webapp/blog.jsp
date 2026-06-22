<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%
    // Verify user ID
    HttpSession s = request.getSession(false);
    Integer userId = null;
    String fullname = "";
    if (s != null) {
        userId = (Integer) s.getAttribute("user_id");
        fullname = (String) s.getAttribute("username"); // fallback to username
    }

    // Self-healing database check & create table
    Connection initCon = null;
    Statement initStmt = null;
    try {
        initCon = DBConnection.getConnection();
        initStmt = initCon.createStatement();
        initStmt.execute("CREATE TABLE IF NOT EXISTS blog_submissions (" +
                         "id INT AUTO_INCREMENT PRIMARY KEY," +
                         "title VARCHAR(150) NOT NULL," +
                         "content TEXT NOT NULL," +
                         "author VARCHAR(100) NOT NULL," +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                         ")");
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (initStmt != null) try { initStmt.close(); } catch (Exception e) {}
        if (initCon != null) try { initCon.close(); } catch (Exception e) {}
    }

    // Process Submission
    String error = null;
    String success = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String author = request.getParameter("author");

        if (title == null || content == null || author == null ||
            title.trim().isEmpty() || content.trim().isEmpty() || author.trim().isEmpty()) {
            error = "Please fill in all submission fields.";
        } else {
            Connection con = null;
            PreparedStatement ps = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("INSERT INTO blog_submissions (title, content, author) VALUES (?, ?, ?)");
                ps.setString(1, title.trim());
                ps.setString(2, content.trim());
                ps.setString(3, author.trim());
                ps.executeUpdate();
                success = "Your routine tip has been published successfully!";
            } catch (Exception e) {
                error = "Submission failed: " + e.getMessage();
            } finally {
                if (ps != null) try { ps.close(); } catch (Exception e) {}
                if (con != null) try { con.close(); } catch (Exception e) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The LuxeJournal | LuxeGlow</title>
    <!-- Core & Specific Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .blog-hero {
            background: linear-gradient(rgba(92, 13, 30, 0.7), rgba(92, 13, 30, 0.9)), url('image/facemist.jpg') no-repeat center center;
            background-size: cover;
            color: var(--bg-dark);
            text-align: center;
            padding: 90px 20px;
            margin-bottom: 40px;
            border-radius: 0 0 40px 40px;
            box-shadow: var(--shadow-lux);
        }
        .blog-hero h1 {
            font-size: 3rem;
            color: var(--bg-dark);
            margin-bottom: 10px;
            font-family: 'Playfair Display', serif;
        }
        .blog-hero p {
            font-size: 1.1rem;
            letter-spacing: 1px;
            opacity: 0.9;
        }
        .blog-container {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 40px;
        }
        @media (max-width: 900px) {
            .blog-container {
                grid-template-columns: 1fr;
            }
        }
        .blog-posts-list {
            display: flex;
            flex-direction: column;
            gap: 30px;
        }
        .blog-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            padding: 30px;
            box-shadow: var(--shadow-lux);
            transition: var(--transition);
        }
        .blog-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 35px rgba(92, 13, 30, 0.06);
            border-color: rgba(197, 171, 87, 0.2);
        }
        .blog-meta {
            font-size: 0.75rem;
            color: var(--gold);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 10px;
        }
        .blog-card h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.6rem;
            color: var(--burgundy);
            margin-bottom: 15px;
            display: block;
            padding-bottom: 0;
        }
        .blog-card h2::after {
            display: none;
        }
        .blog-card p {
            color: var(--text-secondary);
            font-size: 0.95rem;
            line-height: 1.7;
            margin-bottom: 20px;
        }
        .blog-card .author-tag {
            font-size: 0.8rem;
            color: var(--text-muted);
            font-weight: 500;
        }
        .sidebar-widget {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            padding: 30px;
            box-shadow: var(--shadow-lux);
            margin-bottom: 30px;
        }
        .sidebar-widget h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.25rem;
            color: var(--burgundy);
            border-bottom: 1px solid var(--border-light);
            padding-bottom: 12px;
            margin-bottom: 20px;
        }
        .routine-tip-form input, .routine-tip-form textarea {
            width: 100%;
            padding: 12px 18px;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            background: var(--bg-dark);
            color: var(--text-primary);
            font-size: 0.9rem;
            margin-bottom: 15px;
            transition: var(--transition);
        }
        .routine-tip-form input:focus, .routine-tip-form textarea:focus {
            outline: none;
            border-color: var(--gold);
            box-shadow: 0 0 0 3px var(--gold-glow);
        }
        .quick-guide-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px dashed var(--border-light);
            font-weight: 550;
            font-size: 0.9rem;
        }
        .quick-guide-link:last-child {
            border-bottom: none;
        }
        .quick-guide-link i {
            color: var(--gold);
        }
    </style>
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Section -->
    <header class="blog-hero">
        <h1>The LuxeJournal</h1>
        <p>Skincare routines, shade guides, and cosmetic ingredients breakdown by clean beauty experts.</p>
    </header>

    <div class="page-container">
        
        <!-- Messages -->
        <% if (error != null) { %>
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
        <% } %>
        <% if (success != null) { %>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= success %></div>
        <% } %>

        <div class="blog-container">
            
            <!-- Left Side: Blog Posts list -->
            <div class="blog-posts-list">
                
                <!-- Static Expert Post 1 -->
                <article class="blog-card">
                    <div class="blog-meta">Skincare • June 15, 2026</div>
                    <h2>Skincare Routine 101: How to Layer Your Serums</h2>
                    <p>
                        Layering active ingredients can be confusing, but the rules are simple: apply products from thinnest consistency to thickest. Start with your Vitamin C Serum to clean skin for maximum antioxidant absorption, follow with Hydrating Glow Serum, and seal everything with a replenishing Hydra Moisturizer. Never mix retinol directly with acids; alternate days to keep the skin barrier radiant.
                    </p>
                    <div class="author-tag">By LuxeGlow Skin Team • <i class="fas fa-user-shield"></i> Expert Verified</div>
                </article>

                <!-- Static Expert Post 2 -->
                <article class="blog-card">
                    <div class="blog-meta">Makeup • June 10, 2026</div>
                    <h2>Finding Your Perfect Velvet Matte Lipstick Shade</h2>
                    <p>
                        Finding the perfect lip shade depends on your skin undertone. Cool undertones with blue or pink veins look radiant in berry-toned plums and cherry-red pigments. Warm undertones match golden, terracotta, and peachy brick shades. Neutral tones can carry off almost anything, especially a premium toasted velvet nude.
                    </p>
                    <div class="author-tag">By Siddhi Tiwari, Beauty Lead</div>
                </article>

                <!-- Dynamic User Submitted Tips -->
                <%
                    Connection conList = null;
                    PreparedStatement psList = null;
                    ResultSet rsList = null;
                    try {
                        conList = DBConnection.getConnection();
                        psList = conList.prepareStatement("SELECT title, content, author, created_at FROM blog_submissions ORDER BY created_at DESC");
                        rsList = psList.executeQuery();
                        while (rsList.next()) {
                            String bTitle = rsList.getString("title");
                            String bContent = rsList.getString("content");
                            String bAuthor = rsList.getString("author");
                            Timestamp bDate = rsList.getTimestamp("created_at");
                %>
                <article class="blog-card" style="border-left: 3px solid var(--gold);">
                    <div class="blog-meta">Community Routine Tip • <%= bDate %></div>
                    <h2><%= bTitle %></h2>
                    <p><%= bContent %></p>
                    <div class="author-tag">Submitted by: <strong><%= bAuthor %></strong> <i class="fas fa-magic" style="color:var(--gold); margin-left:5px;"></i></div>
                </article>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<p style='color:var(--danger);'>Could not load community tips.</p>");
                    } finally {
                        if (rsList != null) try { rsList.close(); } catch (Exception e) {}
                        if (psList != null) try { psList.close(); } catch (Exception e) {}
                        if (conList != null) try { conList.close(); } catch (Exception e) {}
                    }
                %>
            </div>

            <!-- Right Side: Sidebar Widgets -->
            <div class="blog-sidebar">
                
                <!-- Share your routine widget -->
                <div class="sidebar-widget">
                    <h3>Share Your Routine</h3>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-bottom:20px;">
                        Have a luxury beauty tip or custom routine step that works? Publish it in our community feed!
                    </p>
                    <form action="blog.jsp" method="POST" class="routine-tip-form">
                        <label for="authorInput" style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Your Name</label>
                        <input type="text" id="authorInput" name="author" placeholder="e.g. Siddhi" value="<%= fullname %>" required>

                        <label for="titleInput" style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Tip Title</label>
                        <input type="text" id="titleInput" name="title" placeholder="e.g. Ice Rolling Before Glow Serum" required>

                        <label for="contentInput" style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Your Tip & Steps</label>
                        <textarea id="contentInput" name="content" rows="5" placeholder="Step-by-step description..." required></textarea>

                        <button type="submit" class="btn-gold" style="width:100%; border-radius:12px; font-size:0.8rem; padding:12px;">Publish Tip</button>
                    </form>
                </div>

                <!-- Helpful Links Widget -->
                <div class="sidebar-widget">
                    <h3>Skin Resources</h3>
                    <div class="quick-guide-links">
                        <a href="quiz.jsp" class="quick-guide-link">
                            <i class="fas fa-sparkles"></i>
                            <span>Take the Skin Analysis Quiz &rarr;</span>
                        </a>
                        <a href="guide.jsp" class="quick-guide-link">
                            <i class="fas fa-book-open"></i>
                            <span>Skin Type Reference Guide &rarr;</span>
                        </a>
                        <a href="product.jsp" class="quick-guide-link">
                            <i class="fas fa-shopping-bag"></i>
                            <span>Shop Skin Formulations &rarr;</span>
                        </a>
                    </div>
                </div>

            </div>

        </div>

    </div>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>

