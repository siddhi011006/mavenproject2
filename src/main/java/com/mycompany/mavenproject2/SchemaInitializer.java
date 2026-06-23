package com.mycompany.mavenproject2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class SchemaInitializer {
    private static boolean schemaInitialized = false;

    public static synchronized void initializeSchema(Connection con) {
        if (schemaInitialized) {
            return;
        }

        try {
            // 1. Update products table columns
            ensureColumn(con, "products", "brand", "VARCHAR(100) DEFAULT 'LuxeGlow'");
            ensureColumn(con, "products", "sku", "VARCHAR(100) DEFAULT NULL");
            ensureColumn(con, "products", "status", "VARCHAR(50) DEFAULT 'ACTIVE'");
            ensureColumn(con, "products", "meta_title", "VARCHAR(255) DEFAULT NULL");
            ensureColumn(con, "products", "meta_description", "TEXT DEFAULT NULL");
            ensureColumn(con, "products", "meta_keywords", "VARCHAR(255) DEFAULT NULL");

            // 2. Update reviews table columns
            ensureColumn(con, "reviews", "is_hidden", "TINYINT(1) DEFAULT 0");

            // 2b. Update product_variants table columns
            ensureColumn(con, "product_variants", "custom_label", "VARCHAR(255) DEFAULT NULL");
            ensureColumn(con, "product_variants", "is_visible", "TINYINT(1) DEFAULT 1");

            // 3. Create announcements table
            if (!tableExists(con, "announcements")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE announcements ("
                               + "id INT AUTO_INCREMENT PRIMARY KEY, "
                               + "text VARCHAR(500) NOT NULL, "
                               + "is_active TINYINT(1) DEFAULT 1, "
                               + "start_date TIMESTAMP NULL DEFAULT NULL, "
                               + "end_date TIMESTAMP NULL DEFAULT NULL"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);
                    
                    // Insert default announcement
                    st.executeUpdate("INSERT INTO announcements (text, is_active) VALUES ('Complimentary Standard Shipping on Orders Over ₹1500.00', 1)");
                }
            }

            // 4. Create promotions table
            if (!tableExists(con, "promotions")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE promotions ("
                               + "id INT AUTO_INCREMENT PRIMARY KEY, "
                               + "name VARCHAR(255) NOT NULL, "
                               + "discount_type VARCHAR(50) NOT NULL, "
                               + "discount_amount DECIMAL(10,2) NOT NULL, "
                               + "target_type VARCHAR(50) NOT NULL, "
                               + "target_value VARCHAR(255) DEFAULT NULL, "
                               + "start_date TIMESTAMP NULL DEFAULT NULL, "
                               + "end_date TIMESTAMP NULL DEFAULT NULL, "
                               + "is_active TINYINT(1) DEFAULT 1"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);
                }
            }

            // 5. Create coupons table
            if (!tableExists(con, "coupons")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE coupons ("
                               + "id INT AUTO_INCREMENT PRIMARY KEY, "
                               + "code VARCHAR(50) NOT NULL UNIQUE, "
                               + "discount_type VARCHAR(50) NOT NULL, "
                               + "discount_amount DECIMAL(10,2) NOT NULL, "
                               + "expiry_date TIMESTAMP NULL DEFAULT NULL, "
                               + "usage_limit INT DEFAULT NULL, "
                               + "usage_count INT DEFAULT 0, "
                               + "minimum_purchase_amount DECIMAL(10,2) DEFAULT 0.00, "
                               + "is_active TINYINT(1) DEFAULT 1"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);

                    // Insert sample coupons
                    st.executeUpdate("INSERT INTO coupons (code, discount_type, discount_amount, is_active) VALUES ('WELCOME10', 'PERCENTAGE', 10.00, 1)");
                    st.executeUpdate("INSERT INTO coupons (code, discount_type, discount_amount, is_active) VALUES ('FESTIVE15', 'PERCENTAGE', 15.00, 1)");
                    st.executeUpdate("INSERT INTO coupons (code, discount_type, discount_amount, is_active) VALUES ('LUXEGLOW20', 'PERCENTAGE', 20.00, 1)");
                }
            }

            // 6. Create featured_masterpieces table
            if (!tableExists(con, "featured_masterpieces")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE featured_masterpieces ("
                               + "id INT AUTO_INCREMENT PRIMARY KEY, "
                               + "title VARCHAR(255) NOT NULL, "
                               + "description VARCHAR(500) NOT NULL, "
                               + "image_url VARCHAR(255) NOT NULL, "
                               + "badge VARCHAR(255) DEFAULT 'Fresh Selections', "
                               + "link_url VARCHAR(255) DEFAULT 'product.jsp', "
                               + "display_order INT DEFAULT 0, "
                               + "is_enabled TINYINT(1) DEFAULT 1"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);

                    // Insert sample cards
                    st.executeUpdate("INSERT INTO featured_masterpieces (title, description, image_url, badge, link_url, display_order, is_enabled) VALUES "
                                   + "('New Arrivals', 'Be the first to experience our latest clinical formulas', 'image/silkfoundation.jpg', 'Fresh Selections', 'new-arrivals.jsp', 1, 1)");
                    st.executeUpdate("INSERT INTO featured_masterpieces (title, description, image_url, badge, link_url, display_order, is_enabled) VALUES "
                                   + "('Best Sellers', 'Explore our community\\'s favorite beauty essentials', 'image/velvetLipstick.jpg', 'Dermatologist Choice', 'best-sellers.jsp', 2, 1)");
                }
            }

            // 7. Create testimonials table
            if (!tableExists(con, "testimonials")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE testimonials ("
                               + "id INT AUTO_INCREMENT PRIMARY KEY, "
                               + "client_name VARCHAR(255) NOT NULL, "
                               + "review_text TEXT NOT NULL, "
                               + "client_image VARCHAR(255) DEFAULT NULL, "
                               + "rating INT DEFAULT 5, "
                               + "display_order INT DEFAULT 0, "
                               + "is_enabled TINYINT(1) DEFAULT 1"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);

                    // Insert sample testimonials
                    st.executeUpdate("INSERT INTO testimonials (client_name, review_text, rating, display_order, is_enabled) VALUES "
                                   + "('Elena R., New York', '\"The Glow Serum is an absolute game-changer. My skin has never looked this radiant and hydrated. Truly luxury in a bottle!\"', 5, 1, 1)");
                    st.executeUpdate("INSERT INTO testimonials (client_name, review_text, rating, display_order, is_enabled) VALUES "
                                   + "('Sophia T., Los Angeles', '\"I love the Velvet Lipstick. The pigmentation is incredibly rich, and it doesn\\'t dry out my lips at all. Worth every single penny.\"', 5, 2, 1)");
                    st.executeUpdate("INSERT INTO testimonials (client_name, review_text, rating, display_order, is_enabled) VALUES "
                                   + "('Clara M., Chicago', '\"Customer service is outstanding, and standard shipping was fast and free. LuxeGlow has won a customer for life.\"', 5, 3, 1)");
                }
            }

            // 8. Create new_arrivals table
            if (!tableExists(con, "new_arrivals")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE new_arrivals ("
                               + "product_id INT PRIMARY KEY, "
                               + "display_order INT DEFAULT 0, "
                               + "is_enabled TINYINT(1) DEFAULT 1, "
                               + "FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);

                    // Seed default new arrivals (e.g. latest 8 active products)
                    try (Statement selSt = con.createStatement();
                         ResultSet rsSel = selSt.executeQuery("SELECT id FROM products WHERE status = 'ACTIVE' ORDER BY id DESC LIMIT 8")) {
                        int order = 1;
                        try (PreparedStatement insPs = con.prepareStatement("INSERT INTO new_arrivals (product_id, display_order, is_enabled) VALUES (?, ?, 1)")) {
                            while (rsSel.next()) {
                                insPs.setInt(1, rsSel.getInt("id"));
                                insPs.setInt(2, order++);
                                insPs.executeUpdate();
                            }
                        }
                    }
                }
            }

            // 9. Create best_sellers table
            if (!tableExists(con, "best_sellers")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE best_sellers ("
                               + "product_id INT PRIMARY KEY, "
                               + "display_order INT DEFAULT 0, "
                               + "is_enabled TINYINT(1) DEFAULT 1, "
                               + "FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);

                    // Seed default best sellers (e.g. top 8 highest-rated active products)
                    try (Statement selSt = con.createStatement();
                         ResultSet rsSel = selSt.executeQuery("SELECT id FROM products WHERE status = 'ACTIVE' ORDER BY rating DESC, price DESC LIMIT 8")) {
                        int order = 1;
                        try (PreparedStatement insPs = con.prepareStatement("INSERT INTO best_sellers (product_id, display_order, is_enabled) VALUES (?, ?, 1)")) {
                            while (rsSel.next()) {
                                insPs.setInt(1, rsSel.getInt("id"));
                                insPs.setInt(2, order++);
                                insPs.executeUpdate();
                            }
                        }
                    }
                }
            }

            // 10. Create offers table
            if (!tableExists(con, "offers")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE offers ("
                               + "id INT AUTO_INCREMENT PRIMARY KEY, "
                               + "title VARCHAR(255) NOT NULL, "
                               + "description TEXT NOT NULL, "
                               + "badge VARCHAR(255) DEFAULT NULL, "
                               + "promo_code VARCHAR(255) DEFAULT NULL, "
                               + "button_text VARCHAR(255) DEFAULT NULL, "
                               + "action_url VARCHAR(255) DEFAULT NULL, "
                               + "display_order INT DEFAULT 0, "
                               + "is_enabled TINYINT(1) DEFAULT 1"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);

                    // Seed default offers
                    try (PreparedStatement insPs = con.prepareStatement(
                            "INSERT INTO offers (title, description, badge, promo_code, button_text, action_url, display_order, is_enabled) VALUES (?, ?, ?, ?, ?, ?, ?, 1)")) {
                        
                        // Offer 1
                        insPs.setString(1, "The Glow Bundle");
                        insPs.setString(2, "Buy 1 Get 1 50% Off on all skincare serums and moisturizers. Applied automatically at checkout.");
                        insPs.setString(3, "BOGO 50%");
                        insPs.setNull(4, java.sql.Types.VARCHAR);
                        insPs.setString(5, "Claim Bundle");
                        insPs.setString(6, "product.jsp?category=serums");
                        insPs.setInt(7, 1);
                        insPs.executeUpdate();

                        // Offer 2
                        insPs.setString(1, "First Order Welcome");
                        insPs.setString(2, "Use code GLOW15 at checkout to take 15% off your very first luxury beauty order.");
                        insPs.setString(3, "Promo Code");
                        insPs.setString(4, "GLOW15");
                        insPs.setNull(5, java.sql.Types.VARCHAR);
                        insPs.setNull(6, java.sql.Types.VARCHAR);
                        insPs.setInt(7, 2);
                        insPs.executeUpdate();

                        // Offer 3
                        insPs.setString(1, "Deluxe Skincare Minis");
                        insPs.setString(2, "Receive a complimentary travel-size glow serum with any purchase over $60. Added automatically to qualified orders.");
                        insPs.setString(3, "Free Gift");
                        insPs.setNull(4, java.sql.Types.VARCHAR);
                        insPs.setString(5, "Shop Catalog");
                        insPs.setString(6, "product.jsp");
                        insPs.setInt(7, 3);
                        insPs.executeUpdate();
                    }
                }
            }

            // 11. Create blog_submissions table
            if (!tableExists(con, "blog_submissions")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE blog_submissions ("
                               + "id INT AUTO_INCREMENT PRIMARY KEY, "
                               + "title VARCHAR(150) NOT NULL, "
                               + "content TEXT NOT NULL, "
                               + "author VARCHAR(100) NOT NULL, "
                               + "user_id INT DEFAULT NULL, "
                               + "is_hidden TINYINT(1) DEFAULT 0, "
                               + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                               + "FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);

                    // Seed default expert blog posts
                    try (PreparedStatement insPs = con.prepareStatement(
                            "INSERT INTO blog_submissions (title, content, author, user_id, is_hidden, created_at) VALUES (?, ?, ?, NULL, 0, ?)")) {
                        
                        // Post 1
                        insPs.setString(1, "Skincare Routine 101: How to Layer Your Serums");
                        insPs.setString(2, "Layering active ingredients can be confusing, but the rules are simple: apply products from thinnest consistency to thickest. Start with your Vitamin C Serum to clean skin for maximum antioxidant absorption, follow with Hydrating Glow Serum, and seal everything with a replenishing Hydra Moisturizer. Never mix retinol directly with acids; alternate days to keep the skin barrier radiant.");
                        insPs.setString(3, "LuxeGlow Skin Team • Expert Verified");
                        insPs.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis() - 86400000L)); // 1 day ago
                        insPs.executeUpdate();

                        // Post 2
                        insPs.setString(1, "Finding Your Perfect Velvet Matte Lipstick Shade");
                        insPs.setString(2, "Finding the perfect lip shade depends on your skin undertone. Cool undertones with blue or pink veins look radiant in berry-toned plums and cherry-red pigments. Warm undertones match golden, terracotta, peachy brick shades. Neutral tones can carry off almost anything, especially a premium toasted velvet nude.");
                        insPs.setString(3, "Siddhi Tiwari, Beauty Lead");
                        insPs.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis() - 172800000L)); // 2 days ago
                        insPs.executeUpdate();
                    }
                }
            } else {
                // Table exists, ensure columns exist
                ensureColumn(con, "blog_submissions", "user_id", "INT DEFAULT NULL");
                ensureColumn(con, "blog_submissions", "is_hidden", "TINYINT(1) DEFAULT 0");
            }
            
            // 12. Create cms_content table
            if (!tableExists(con, "cms_content")) {
                try (Statement st = con.createStatement()) {
                    String sql = "CREATE TABLE cms_content ("
                               + "content_key VARCHAR(255) PRIMARY KEY, "
                               + "content_value TEXT NOT NULL"
                               + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
                    st.executeUpdate(sql);
                }
            }

            // Seed default cms contents
            seedCMSContent(con, "about_hero_title", "About LuxeGlow");
            seedCMSContent(con, "about_hero_subtitle", "We are a modern, minimal, skin-first beauty experience designed for a radiant future.");
            seedCMSContent(con, "about_vision_title", "Our Vision");
            seedCMSContent(con, "about_vision_text", "LuxeGlow was founded on a simple principle: beauty should make you feel confident, radiant, and comfortable in your own skin. We believe in minimal but premium cosmetics that highlight your natural beauty rather than cover it up.");
            seedCMSContent(con, "about_formula_title", "Skin-First Formulations");
            seedCMSContent(con, "about_formula_text", "Every LuxeGlow lipstick, serum, and moisturizer is formulated with clean, vegan, and dermatologist-tested ingredients. We harvest skin-loving organic botanical extracts and blend them with cutting-edge active complexes (like hyaluronic acid and vitamin C) to provide long-lasting benefits.");
            seedCMSContent(con, "about_promise_title", "Our Ethical Promise");
            seedCMSContent(con, "about_promise_text", "We are 100% certified cruelty-free. We never test on animals and are committed to sourcing sustainable packaging materials to protect our planet for future generations.");

            seedCMSContent(con, "contact_hero_title", "Get In Touch");
            seedCMSContent(con, "contact_hero_subtitle", "Have questions about shade matching, orders, or shipping? Our experts are here to assist you.");
            seedCMSContent(con, "contact_concierge_title", "Luxury Concierge");
            seedCMSContent(con, "contact_concierge_subtitle", "Reach out to our beauty concierge through the channels below, or submit the digital contact form.");
            seedCMSContent(con, "contact_email_title", "Email Us");
            seedCMSContent(con, "contact_email_value", "concierge@luxeglow.com");
            seedCMSContent(con, "contact_email_desc", "24/7 client response desk");
            seedCMSContent(con, "contact_call_title", "Call Us");
            seedCMSContent(con, "contact_call_value", "+1 (800) 555-GLOW");
            seedCMSContent(con, "contact_call_desc", "Mon - Fri, 9 AM - 6 PM EST");
            seedCMSContent(con, "contact_hq_title", "Headquarters");
            seedCMSContent(con, "contact_hq_value", "5th Avenue, Luxury District\nNew York, NY 10011");
            seedCMSContent(con, "contact_form_title", "Send Us a Message");

            seedCMSContent(con, "faq_hero_title", "Client FAQs");
            seedCMSContent(con, "faq_hero_subtitle", "Answers to your questions about our luxury formulas, order delivery, and shade matching.");
            seedCMSContent(con, "faq_content_html", 
                "<div style=\"background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;\">\n" +
                "    <h3 style=\"color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;\"><i class=\"fas fa-question-circle\" style=\"margin-right:10px; color:var(--gold);\"></i> Are LuxeGlow products organic?</h3>\n" +
                "    <p style=\"color:var(--text-secondary); font-size:0.9rem;\">Yes. All of our formulations are crafted from premium skin-loving, organic botanical extracts, and are completely free of sulfates, parabens, and synthetic fillers.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;\">\n" +
                "    <h3 style=\"color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;\"><i class=\"fas fa-question-circle\" style=\"margin-right:10px; color:var(--gold);\"></i> How do I choose the correct foundation shade?</h3>\n" +
                "    <p style=\"color:var(--text-secondary); font-size:0.9rem;\">Our beauty concierge offers free shade-matching advice. You can send us a message through our <a href=\"contact.jsp\" style=\"text-decoration:underline;\">Contact Page</a>, selecting \"Product Shade Matching Advice\", and our experts will reply within 24 hours.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;\">\n" +
                "    <h3 style=\"color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;\"><i class=\"fas fa-question-circle\" style=\"margin-right:10px; color:var(--gold);\"></i> When will my order ship?</h3>\n" +
                "    <p style=\"color:var(--text-secondary); font-size:0.9rem;\">Orders are typically processed and shipped within 1-2 business days. Once shipped, you will receive a tracking link via email. Standard shipping takes 3-5 business days.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 16px; padding: 25px;\">\n" +
                "    <h3 style=\"color:var(--burgundy); font-size:1.15rem; margin-bottom:10px;\"><i class=\"fas fa-question-circle\" style=\"margin-right:10px; color:var(--gold);\"></i> What is your return policy?</h3>\n" +
                "    <p style=\"color:var(--text-secondary); font-size:0.9rem;\">We offer a 30-day hassle-free return and shade exchange policy. If a foundation or lipstick shade isn't perfect for you, we will send you an exchange free of shipping charges.</p>\n" +
                "</div>"
            );

            seedCMSContent(con, "privacy_hero_title", "Privacy Policy");
            seedCMSContent(con, "privacy_hero_subtitle", "Your privacy and safety are extremely important to us. Learn how we secure your data.");
            seedCMSContent(con, "privacy_content_html", 
                "<div>\n" +
                "    <h3 style=\"color:var(--burgundy); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;\">1. Information We Collect</h3>\n" +
                "    <p>We collect personal details (such as your name, email address, delivery address, and payment method options) during checkout or account registration to fulfill your orders and provide account features.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div>\n" +
                "    <h3 style=\"color:var(--burgundy); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;\">2. How We Secure Your Data</h3>\n" +
                "    <p>All database connections and transactions are encrypted. We do not store cardholder credentials on our local servers; payments are processed securely through certified gateways.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div>\n" +
                "    <h3 style=\"color:var(--burgundy); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;\">3. Cookie Utilization</h3>\n" +
                "    <p>Our website utilizes local cookies to manage active shopping sessions, preserve guest shopping bag selections, and remember login preferences.</p>\n" +
                "</div>"
            );

            seedCMSContent(con, "terms_hero_title", "Terms & Conditions");
            seedCMSContent(con, "terms_hero_subtitle", "Please review our client usage guidelines and terms of service.");
            seedCMSContent(con, "terms_content_html", 
                "<div>\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\">1. Usage of Platform</h3>\n" +
                "    <p>By registering an account and placing an order on LuxeGlow, you agree to submit accurate, current, and complete personal and billing information.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\">2. Prices & Catalog Details</h3>\n" +
                "    <p>We strive to represent colors and formulations accurately on our platform. We reserve the right to modify cosmetic specifications, inventory stock levels, or adjust pricing without prior notification.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\">3. Intellectual Property</h3>\n" +
                "    <p>All brand marks, editorial copy, product names, logos, custom illustrations, and graphics on this website are the property of LuxeGlow Cosmetics Inc. and may not be reproduced without written permission.</p>\n" +
                "</div>"
            );

            seedCMSContent(con, "shipping_hero_title", "Shipping & Returns");
            seedCMSContent(con, "shipping_hero_subtitle", "Read about our global shipping times and shade exchanges.");
            seedCMSContent(con, "shipping_content_html", 
                "<div>\n" +
                "    <h3 style=\"color:var(--gold); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;\"><i class=\"fas fa-shipping-fast\" style=\"margin-right:10px;\"></i> Shipping Rates & Methods</h3>\n" +
                "    <p>We offer complimentary standard shipping on orders over the threshold. For orders below standard shipping is charged at a flat rate. Processing takes 1-2 business days, and shipping takes 3-5 business days.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div>\n" +
                "    <h3 style=\"color:var(--gold); font-size:1.3rem; font-family:'Playfair Display', serif; margin-bottom:10px;\"><i class=\"fas fa-undo-alt\" style=\"margin-right:10px;\"></i> Hassle-Free Returns</h3>\n" +
                "    <p>If you are not completely satisfied with your luxury purchase or foundation shade match, we offer free returns and exchanges within 30 days of shipment. Contact our concierge mail desk for return slips.</p>\n" +
                "</div>"
            );

            seedCMSContent(con, "shipping_policy_hero_title", "Shipping Policy");
            seedCMSContent(con, "shipping_policy_hero_subtitle", "Read about our global shipping times, standard rates, and courier partners.");
            seedCMSContent(con, "shipping_policy_content_html", 
                "<div>\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\"><i class=\"fas fa-truck\" style=\"margin-right:10px; color:var(--gold);\"></i> Standard & Express Shipping</h3>\n" +
                "    <p>We provide complimentary standard shipping on all orders over the threshold. Standard shipping is charged at a flat rate below it. Express priority shipping is available during checkout.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\"><i class=\"fas fa-history\" style=\"margin-right:10px; color:var(--gold);\"></i> Fulfillment Timeline</h3>\n" +
                "    <p>All orders are processed and packed at our fulfillment centers within 1-2 business days. Standard delivery takes 3-5 business days, and express delivery takes 1-2 business days. You will receive a tracking link via email once your order has shipped.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\"><i class=\"fas fa-globe\" style=\"margin-right:10px; color:var(--gold);\"></i> International Delivery</h3>\n" +
                "    <p>Currently, LuxeGlow delivers products within North America and selected EU countries. International custom duties and local taxes are calculated and presented at checkout.</p>\n" +
                "</div>"
            );

            seedCMSContent(con, "returns_policy_hero_title", "Return & Refund Policy");
            seedCMSContent(con, "returns_policy_hero_subtitle", "Our commitment to your satisfaction. Free shade exchanges within 30 days.");
            seedCMSContent(con, "returns_policy_content_html", 
                "<div>\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\"><i class=\"fas fa-undo-alt\" style=\"margin-right:10px; color:var(--gold);\"></i> 30-Day Free Return & Exchange</h3>\n" +
                "    <p>We want you to love your skincare and makeup items. If a product shade is not perfect or does not suit your skin, you can request a return or free shade exchange within 30 days of receiving your package.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\"><i class=\"fas fa-box-open\" style=\"margin-right:10px; color:var(--gold);\"></i> Condition Requirements</h3>\n" +
                "    <p>To qualify for a refund, products must be returned in their original packaging, gently used (less than 25% used), or unopened. Gift cards, promo samples, and clearance items are non-refundable.</p>\n" +
                "</div>\n" +
                "\n" +
                "<div style=\"border-top: 1px solid var(--border-light); padding-top: 25px;\">\n" +
                "    <h3 style=\"color: var(--burgundy); font-size: 1.3rem; font-family: 'Playfair Display', serif; margin-bottom: 10px;\"><i class=\"fas fa-receipt\" style=\"margin-right:10px; color:var(--gold);\"></i> Processing Refunds</h3>\n" +
                "    <p>Refunds are processed back to your original payment method (Credit Card, Net Banking, or UPI) within 5-7 business days after our fulfillment center receives and inspects the return package.</p>\n" +
                "</div>"
            );

            schemaInitialized = true;
        } catch (SQLException e) {
            System.err.println("Schema initialization failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void seedCMSContent(Connection con, String key, String value) throws SQLException {
        String checkSql = "SELECT COUNT(*) FROM cms_content WHERE content_key = ?";
        try (PreparedStatement ps = con.prepareStatement(checkSql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return; // Already exists
                }
            }
        }
        String insertSql = "INSERT INTO cms_content (content_key, content_value) VALUES (?, ?)";
        try (PreparedStatement ps = con.prepareStatement(insertSql)) {
            ps.setString(1, key);
            ps.setString(2, value);
            ps.executeUpdate();
        }
    }

    private static boolean tableExists(Connection con, String tableName) throws SQLException {
        try (ResultSet rs = con.getMetaData().getTables(null, null, tableName, null)) {
            return rs.next();
        }
    }

    private static boolean columnExists(Connection con, String tableName, String columnName) throws SQLException {
        try (ResultSet rs = con.getMetaData().getColumns(null, null, tableName, columnName)) {
            return rs.next();
        }
    }

    private static void ensureColumn(Connection con, String tableName, String columnName, String columnDefinition) throws SQLException {
        if (!columnExists(con, tableName, columnName)) {
            try (Statement st = con.createStatement()) {
                st.executeUpdate("ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + columnDefinition);
            }
        }
    }
}
