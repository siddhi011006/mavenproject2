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
        String action = request.getParameter("action");
        if ("deleteBlog".equalsIgnoreCase(action)) {
            String blogIdStr = request.getParameter("blogId");
            if (blogIdStr != null && !blogIdStr.trim().isEmpty()) {
                int blogId = Integer.parseInt(blogIdStr);
                Connection con = null;
                try {
                    con = DBConnection.getConnection();
                    // Server-side ownership verification
                    try (PreparedStatement psCheck = con.prepareStatement("SELECT user_id FROM blog_submissions WHERE id = ?")) {
                        psCheck.setInt(1, blogId);
                        try (ResultSet rsCheck = psCheck.executeQuery()) {
                            if (rsCheck.next()) {
                                Object ownerObj = rsCheck.getObject("user_id");
                                Integer postOwnerId = ownerObj != null ? ((Number) ownerObj).intValue() : null;
                                boolean isAdmin = s != null && "ADMIN".equalsIgnoreCase((String) s.getAttribute("role"));
                                if (isAdmin || (userId != null && userId.equals(postOwnerId))) {
                                    // Proceed with deletion
                                    try (PreparedStatement psDel = con.prepareStatement("DELETE FROM blog_submissions WHERE id = ?")) {
                                        psDel.setInt(1, blogId);
                                        psDel.executeUpdate();
                                    }
                                    success = "Routine tip deleted successfully!";
                                } else {
                                    error = "Access Denied. You do not own this blog post.";
                                }
                            } else {
                                error = "Blog post not found.";
                            }
                        }
                    }
                } catch (Exception e) {
                    error = "Deletion failed: " + e.getMessage();
                } finally {
                    if (con != null) try { con.close(); } catch (Exception e) {}
                }
            } else {
                error = "Missing blog ID.";
            }
        } else if ("editBlog".equalsIgnoreCase(action)) {
            String blogIdStr = request.getParameter("blogId");
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            if (blogIdStr != null && !blogIdStr.trim().isEmpty() && title != null && content != null) {
                int blogId = Integer.parseInt(blogIdStr);
                Connection con = null;
                try {
                    con = DBConnection.getConnection();
                    // Server-side ownership verification
                    try (PreparedStatement psCheck = con.prepareStatement("SELECT user_id FROM blog_submissions WHERE id = ?")) {
                        psCheck.setInt(1, blogId);
                        try (ResultSet rsCheck = psCheck.executeQuery()) {
                            if (rsCheck.next()) {
                                Object ownerObj = rsCheck.getObject("user_id");
                                Integer postOwnerId = ownerObj != null ? ((Number) ownerObj).intValue() : null;
                                boolean isAdmin = s != null && "ADMIN".equalsIgnoreCase((String) s.getAttribute("role"));
                                if (isAdmin || (userId != null && userId.equals(postOwnerId))) {
                                    // Proceed with update
                                    try (PreparedStatement psUpd = con.prepareStatement("UPDATE blog_submissions SET title = ?, content = ? WHERE id = ?")) {
                                        psUpd.setString(1, title.trim());
                                        psUpd.setString(2, content.trim());
                                        psUpd.setInt(3, blogId);
                                        psUpd.executeUpdate();
                                    }
                                    success = "Routine tip updated successfully!";
                                } else {
                                    error = "Access Denied. You do not own this blog post.";
                                }
                            } else {
                                error = "Blog post not found.";
                            }
                        }
                    }
                } catch (Exception e) {
                    error = "Update failed: " + e.getMessage();
                } finally {
                    if (con != null) try { con.close(); } catch (Exception e) {}
                }
            } else {
                error = "Please fill in all submission fields.";
            }
        } else {
            // Normal creation
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
                    ps = con.prepareStatement("INSERT INTO blog_submissions (title, content, author, user_id) VALUES (?, ?, ?, ?)");
                    ps.setString(1, title.trim());
                    ps.setString(2, content.trim());
                    ps.setString(3, author.trim());
                    if (userId != null) {
                        ps.setInt(4, userId);
                    } else {
                        ps.setNull(4, java.sql.Types.INTEGER);
                    }
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
                <%
                    Connection conList = null;
                    PreparedStatement psList = null;
                    ResultSet rsList = null;
                    try {
                        conList = DBConnection.getConnection();
                        psList = conList.prepareStatement("SELECT id, title, content, author, user_id, created_at FROM blog_submissions WHERE is_hidden = 0 ORDER BY created_at DESC");
                        rsList = psList.executeQuery();
                        boolean hasBlogs = false;
                        while (rsList.next()) {
                            hasBlogs = true;
                            int id = rsList.getInt("id");
                            String bTitle = rsList.getString("title");
                            String bContent = rsList.getString("content");
                            String bAuthor = rsList.getString("author");
                            Timestamp bDate = rsList.getTimestamp("created_at");
                            Object ownerObj = rsList.getObject("user_id");
                            Integer postOwnerId = ownerObj != null ? ((Number) ownerObj).intValue() : null;

                            boolean isExpert = (postOwnerId == null);
                            boolean isOwner = (userId != null && userId.equals(postOwnerId));
                            boolean isAdmin = (s != null && "ADMIN".equalsIgnoreCase((String) s.getAttribute("role")));

                            String category = "Community Routine Tip";
                            if (isExpert) {
                                if (bTitle.toLowerCase().contains("lipstick") || bTitle.toLowerCase().contains("shade")) {
                                    category = "Makeup";
                                } else {
                                    category = "Skincare";
                                }
                            }

                            String authorHtml = "";
                            if (isExpert) {
                                if (bAuthor.contains("Verified")) {
                                    authorHtml = "By " + bAuthor.replace("•", "• <i class='fas fa-user-shield'></i>");
                                } else {
                                    authorHtml = "By " + bAuthor;
                                }
                            } else {
                                authorHtml = "Submitted by: <strong>" + bAuthor + "</strong> <i class='fas fa-magic' style='color:var(--gold); margin-left:5px;'></i>";
                            }
                %>
                <article class="blog-card" <%= isExpert ? "" : "style='border-left: 3px solid var(--gold);'" %>>
                    <div class="blog-meta"><%= category %> • <%= bDate %></div>
                    <h2><%= bTitle %></h2>
                    <p><%= bContent %></p>
                    <div class="author-tag"><%= authorHtml %></div>
                    
                    <% if (isOwner || isAdmin) { %>
                    <div style="margin-top: 15px; display: flex; gap: 10px;">
                        <button class="btn-outline" style="border-radius: 8px; padding: 6px 14px; font-size: 0.75rem;" 
                                data-id="<%= id %>" 
                                data-title="<%= bTitle.replace("\"", "&quot;").replace("'", "&#39;") %>" 
                                data-content="<%= bContent.replace("\"", "&quot;").replace("'", "&#39;") %>"
                                onclick="openEditBlogModal(this)">
                            Edit
                        </button>
                        <form action="blog.jsp" method="POST" style="margin:0;" onsubmit="return confirm('Delete this tip permanently?');">
                            <input type="hidden" name="action" value="deleteBlog">
                            <input type="hidden" name="blogId" value="<%= id %>">
                            <button type="submit" class="btn-outline" style="border-radius: 8px; padding: 6px 14px; font-size: 0.75rem; color: var(--danger); border-color: var(--danger); background: transparent;">
                                Delete
                            </button>
                        </form>
                    </div>
                    <% } %>
                </article>
                <%
                        }
                        if (!hasBlogs) {
                %>
                <div style="text-align: center; color: var(--text-muted); padding: 40px; background: var(--bg-card); border-radius: 24px; border: 1px solid var(--border-light);">
                    No routine tips published yet. Be the first to share!
                </div>
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

    <!-- Edit Blog Modal -->
    <div id="editBlogModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; justify-content:center; align-items:center; backdrop-filter: blur(8px);">
        <div style="background:var(--bg-card); border:1px solid var(--border-light); border-radius:24px; padding:35px; width:100%; max-width:550px; box-shadow:var(--shadow-lux); text-align:left; position:relative;">
            <button onclick="closeEditBlogModal()" style="position:absolute; top:20px; right:20px; background:none; border:none; color:var(--text-muted); font-size:1.2rem; cursor:pointer;"><i class="fas fa-times"></i></button>
            <h3 style="font-family:'Playfair Display', serif; font-size:1.5rem; color:var(--burgundy); margin-top:0; margin-bottom:20px; border-bottom:1px solid var(--border-light); padding-bottom:12px;">Edit Your Routine Tip</h3>
            
            <form action="blog.jsp" method="POST" class="routine-tip-form" style="margin:0;">
                <input type="hidden" name="action" value="editBlog">
                <input type="hidden" id="editBlogId" name="blogId">
                
                <label for="editTitleInput" style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Tip Title</label>
                <input type="text" id="editTitleInput" name="title" required style="width:100%; padding:12px 18px; border:1px solid var(--border-color); border-radius:12px; background:var(--bg-dark); color:var(--text-primary); font-size:0.9rem; margin-bottom:15px;">
                
                <label for="editContentInput" style="font-size:0.8rem; font-weight:600; display:block; margin-bottom:5px;">Your Tip & Steps</label>
                <textarea id="editContentInput" name="content" rows="6" required style="width:100%; padding:12px 18px; border:1px solid var(--border-color); border-radius:12px; background:var(--bg-dark); color:var(--text-primary); font-size:0.9rem; margin-bottom:15px;"></textarea>
                
                <button type="submit" class="btn-gold" style="width:100%; border-radius:12px; font-size:0.8rem; padding:12px; margin-top:10px;">Save Changes</button>
            </form>
        </div>
    </div>

    <script>
        function openEditBlogModal(button) {
            const id = button.getAttribute('data-id');
            const title = button.getAttribute('data-title');
            const content = button.getAttribute('data-content');
            
            document.getElementById('editBlogId').value = id;
            document.getElementById('editTitleInput').value = title;
            document.getElementById('editContentInput').value = content;
            document.getElementById('editBlogModal').style.display = 'flex';
        }

        function closeEditBlogModal() {
            document.getElementById('editBlogModal').style.display = 'none';
        }
    </script>

    <!-- Footer -->
    <%@ include file="footer.jsp" %>
</body>
</html>

