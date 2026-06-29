<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%@ page import="com.mycompany.mavenproject2.EmailUtility" %>
<%
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);

    pw.println("LuxeGlow Diagnostics Log");
    pw.println("=======================");

    pw.println("1. Database Connection & Users");
    Connection con = null;
    try {
        con = DBConnection.getConnection();
        pw.println("Database connection successful!");
        String sql = "SELECT id, fullname, email, username, role, enabled FROM users";
        try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                pw.printf("ID: %d | Name: %s | Email: %s | Username: %s | Role: %s | Enabled: %d%n",
                    rs.getInt("id"), rs.getString("fullname"), rs.getString("email"),
                    rs.getString("username"), rs.getString("role"), rs.getInt("enabled"));
            }
        }
    } catch (Exception e) {
        pw.println("Database connection failed: " + e.getMessage());
        e.printStackTrace(pw);
    } finally {
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
        }
    }

    pw.println("\n2. Email Configuration Audit");
    pw.println("Is Email Configured? " + EmailUtility.isConfigured());
    pw.println("SMTP Host (resolved): " + EmailUtility.getProperty("mail.smtp.host", "N/A"));
    pw.println("SMTP Port (resolved): " + EmailUtility.getProperty("mail.smtp.port", "N/A"));
    pw.println("SMTP Username (resolved): " + EmailUtility.getProperty("mail.smtp.username", "N/A"));
    pw.println("SMTP Password (resolved): " + EmailUtility.getProperty("mail.smtp.password", "N/A"));
    pw.println("SMTP From (resolved): " + EmailUtility.getProperty("mail.from", "N/A"));

    pw.println("\nEnvironment Variables:");
    pw.println("SMTP_HOST: " + System.getenv("SMTP_HOST"));
    pw.println("SMTP_PORT: " + System.getenv("SMTP_PORT"));
    pw.println("SMTP_USER: " + System.getenv("SMTP_USER"));
    pw.println("SMTP_PASS: " + System.getenv("SMTP_PASS"));
    pw.println("SMTP_FROM: " + System.getenv("SMTP_FROM"));

    pw.println("\nSystem Properties:");
    pw.println("mail.smtp.host: " + System.getProperty("mail.smtp.host"));
    pw.println("mail.smtp.port: " + System.getProperty("mail.smtp.port"));
    pw.println("mail.smtp.username: " + System.getProperty("mail.smtp.username"));
    pw.println("mail.smtp.password: " + System.getProperty("mail.smtp.password"));
    pw.println("mail.from: " + System.getProperty("mail.from"));

    pw.println("\n3. Triggering test emails to sidti0110@gmail.com");
    String recipient = "sidti0110@gmail.com";
    
    // A. Send OTP Email
    try {
        pw.println("Sending simulated OTP email to " + recipient + "...");
        String otpCode = "543210";
        String otpSubject = "LuxeGlow - Confirm Your Email OTP Verification [Dry Run]";
        String otpBody = "OTP: " + otpCode;
        
        EmailUtility.sendEmailSync(recipient, otpSubject, otpBody);
        pw.println("OTP email sent successfully!");
    } catch (Exception e) {
        pw.println("Failed to send OTP email: " + e.getMessage());
        e.printStackTrace(pw);
    }

    // B. Send Order Confirmation Email
    try {
        pw.println("Sending simulated Order Confirmation email to " + recipient + "...");
        String purchasedProductsHtml = "Product List";
        EmailUtility.sendOrderConfirmationEmail(
                recipient, 
                "Siddhi Tiwari", 
                1024, 
                "Jun 29, 2026 18:30", 
                purchasedProductsHtml, 
                137.00, 
                10.00, 
                0.00, 
                10.16, 
                137.16, 
                "123 Luxe St, New York, NY 10001", 
                "Credit Card", 
                "Jul 04, 2026"
        );
        pw.println("Order confirmation email queued successfully!");
    } catch (Exception e) {
        pw.println("Failed to send order confirmation email: " + e.getMessage());
        e.printStackTrace(pw);
    }

    // Write log to file in the target directory
    String filePath = "c:\\Users\\Siddhi Tiwari\\OneDrive\\Documents\\NetBeansProjects\\mavenproject2\\target\\mavenproject2-1.0-SNAPSHOT\\diag_output.txt";
    try (FileWriter fw = new FileWriter(filePath)) {
        fw.write(sw.toString());
    } catch (IOException e) {
        // Ignored
    }
%>
Diagnostics run complete! Results written to <%= filePath %>.
<%= sw.toString() %>
