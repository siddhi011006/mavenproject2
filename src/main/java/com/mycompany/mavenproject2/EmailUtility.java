package com.mycompany.mavenproject2;

import java.io.InputStream;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtility {
    private static final Logger LOGGER = Logger.getLogger(EmailUtility.class.getName());
    private static final Properties PROPERTIES = new Properties();
    private static final ExecutorService EXECUTOR_SERVICE = Executors.newFixedThreadPool(5);

    static {
        try (InputStream input = EmailUtility.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (input == null) {
                LOGGER.severe("Unable to find mail.properties. E-mail utility is unconfigured.");
            } else {
                PROPERTIES.load(input);
                LOGGER.info("Successfully loaded mail.properties config.");
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Failed to load mail.properties file", ex);
        }
    }

    /**
     * Resolves property value checking Environment Variables first, then System
     * Properties, then mail.properties file.
     */
    public static String getProperty(String key, String defaultValue) {
        // Explicit mappings for exact environment variables requested by user
        if ("mail.smtp.host".equals(key)) {
            String val = System.getenv("SMTP_HOST");
            if (val != null && !val.trim().isEmpty()) return val.trim();
        }
        if ("mail.smtp.port".equals(key)) {
            String val = System.getenv("SMTP_PORT");
            if (val != null && !val.trim().isEmpty()) return val.trim();
        }
        if ("mail.smtp.username".equals(key)) {
            String val = System.getenv("SMTP_USER");
            if (val != null && !val.trim().isEmpty()) return val.trim();
        }
        if ("mail.smtp.password".equals(key)) {
            String val = System.getenv("SMTP_PASS");
            if (val != null && !val.trim().isEmpty()) return val.trim();
        }
        if ("mail.from".equals(key)) {
            String val = System.getenv("SMTP_FROM");
            if (val != null && !val.trim().isEmpty()) return val.trim();
        }

        String envKey = key.toUpperCase().replace('.', '_');
        if (envKey.equals("MAIL_SMTP_STARTTLS_ENABLE")) {
            envKey = "SMTP_STARTTLS";
        } else if (envKey.startsWith("MAIL_")) {
            envKey = envKey.substring(5);
        }

        // 1. Environment variables lookup
        String val = System.getenv(envKey);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

        // 2. System properties lookup
        val = System.getProperty(key);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

        // 3. mail.properties lookup
        val = PROPERTIES.getProperty(key);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

        return defaultValue;
    }

    public static String getAdminEmail() {
        return getProperty("mail.admin.email", "admin@luxeglow.com");
    }

    /**
     * Checks if the SMTP mail settings are properly configured (i.e. not empty and
     * not defaults).
     */
    public static boolean isConfigured() {
        String host = getProperty("mail.smtp.host", "");
        String port = getProperty("mail.smtp.port", "");
        String username = getProperty("mail.smtp.username", "");
        String password = getProperty("mail.smtp.password", "");
        String from = getProperty("mail.from", "");

        return !host.isEmpty() && !port.isEmpty() &&
                !username.isEmpty() && !username.equals("placeholder@gmail.com") &&
                !password.isEmpty() && !password.equals("your_app_password") &&
                !from.isEmpty() && !from.equals("placeholder@gmail.com");
    }

    /**
     * Send email synchronously, throwing exceptions on failure.
     */
    public static void sendEmailSync(final String toEmail, final String subject, final String bodyHtml)
            throws Exception {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            throw new IllegalArgumentException("E-mail 'to' address is empty.");
        }

        Properties smtpProps = new Properties();
        // Load all mail.smtp properties from loaded properties file first
        for (String name : PROPERTIES.stringPropertyNames()) {
            if (name.startsWith("mail.smtp.")) {
                smtpProps.put(name, getProperty(name, PROPERTIES.getProperty(name)));
            }
        }
        // Apply default/override properties if not already set
        smtpProps.putIfAbsent("mail.smtp.host", getProperty("mail.smtp.host", "smtp.gmail.com"));
        smtpProps.putIfAbsent("mail.smtp.port", getProperty("mail.smtp.port", "587"));
        smtpProps.putIfAbsent("mail.smtp.auth", getProperty("mail.smtp.auth", "true"));
        smtpProps.putIfAbsent("mail.smtp.starttls.enable", getProperty("mail.smtp.starttls.enable", "true"));
        smtpProps.putIfAbsent("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");

        final String username = getProperty("mail.smtp.username", "sidti0110@gmail.com");
        final String rawPassword = getProperty("mail.smtp.password", "aghmjawoltmlworh");
        final String password = rawPassword != null ? rawPassword.replace(" ", "") : "";
        final String from = getProperty("mail.from", "sidti0110@gmail.com");

        if (username.isEmpty() || password.isEmpty() || from.isEmpty()) {
            throw new IllegalStateException("SMTP credentials (username, password, from address) are not configured.");
        }

        Session session = Session.getInstance(smtpProps, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        // Detailed logging before SMTP sending
        System.out.println("[SMTP DIAGNOSTIC PRE-SEND LOG]");
        System.out.println(" - SMTP Host: " + smtpProps.getProperty("mail.smtp.host"));
        System.out.println(" - SMTP Port: " + smtpProps.getProperty("mail.smtp.port"));
        System.out.println(" - SMTP Auth (mail.smtp.auth): " + smtpProps.getProperty("mail.smtp.auth"));
        System.out.println(" - STARTTLS Enabled (mail.smtp.starttls.enable): " + smtpProps.getProperty("mail.smtp.starttls.enable"));
        System.out.println(" - SMTP Username: " + username);
        System.out.println(" - SMTP Password Length: " + (password != null ? password.length() : 0));
        System.out.println(" - From Address: " + from);

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail.trim()));
        message.setSubject(subject);
        message.setContent(bodyHtml, "text/html; charset=utf-8");

        try {
            Transport.send(message);
        } catch (jakarta.mail.MessagingException mex) {
            System.err.println("[SMTP MESSAGING EXCEPTION]");
            System.err.println("Exception message: " + mex.getMessage());
            mex.printStackTrace();
            
            Exception nextEx = mex.getNextException();
            if (nextEx != null) {
                System.err.println("[SMTP NESTED EXCEPTION ROOT CAUSE]");
                nextEx.printStackTrace();
            }
            throw mex;
        }
    }

    /**
     * Send email asynchronously using a thread pool.
     */
    public static void sendEmailAsync(final String toEmail, final String subject, final String bodyHtml) {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            LOGGER.warning("E-mail 'to' address is empty. Aborting send.");
            return;
        }

        EXECUTOR_SERVICE.submit(() -> {
            try {
                sendEmailSync(toEmail, subject, bodyHtml);
                LOGGER.log(Level.INFO, "Email sent successfully to {0} with subject: {1}",
                        new Object[] { toEmail, subject });
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to send email to " + toEmail + " with subject: " + subject, e);
            }
        });
    }

    /**
     * Helper to wrap HTML content in a styled template.
     */
    private static String getBaseTemplate(String title, String contentHtml) {
        return "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "    <meta charset=\"utf-8\">"
                + "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
                + "    <style>"
                + "        body { font-family: 'Outfit', 'Montserrat', Arial, sans-serif; background-color: #FAF8F5; margin: 0; padding: 20px; color: #1F1C1C; }"
                + "        .container { max-width: 600px; margin: 0 auto; background-color: #FFFFFF; border: 1px solid rgba(92, 13, 30, 0.1); border-radius: 16px; padding: 40px; box-shadow: 0 10px 30px rgba(92, 13, 30, 0.03); }"
                + "        .logo { font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: bold; color: #5C0D1E; text-align: center; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 25px; }"
                + "        .title { font-family: 'Playfair Display', Georgia, serif; font-size: 20px; color: #5C0D1E; margin-bottom: 20px; text-align: center; font-weight: 600; }"
                + "        .text { font-size: 14px; line-height: 1.6; color: #4E4748; margin-bottom: 20px; }"
                + "        .button-container { text-align: center; margin: 30px 0; }"
                + "        .button { display: inline-block; background-color: #5C0D1E; color: #FFFFFF !important; text-decoration: none; padding: 12px 30px; border-radius: 30px; font-weight: bold; font-size: 13px; text-transform: uppercase; letter-spacing: 1px; }"
                + "        .footer { text-align: center; font-size: 11px; color: #8F8486; border-top: 1px solid rgba(92, 13, 30, 0.04); padding-top: 20px; margin-top: 35px; line-height: 1.5; }"
                + "    </style>"
                + "</head>"
                + "<body>"
                + "    <div class=\"container\">"
                + "        <div class=\"logo\">LuxeGlow</div>"
                + "        <div class=\"title\">" + title + "</div>"
                + "        " + contentHtml
                + "        <div class=\"footer\">"
                + "            &copy; " + java.time.Year.now().getValue()
                + " LuxeGlow Luxury Beauty. All Rights Reserved.<br>"
                + "            Dermatologist-Tested • Cruelty-Free • Vegan Formulations"
                + "        </div>"
                + "    </div>"
                + "</body>"
                + "</html>";
    }

    /**
     * 1. Send Welcome Email
     */
    public static void sendWelcomeEmail(String toEmail, String userName) {
        String content = "<p class=\"text\">Dear " + userName + ",</p>"
                + "<p class=\"text\">Welcome to LuxeGlow! We are absolutely thrilled to welcome you to our exclusive beauty community.</p>"
                + "<p class=\"text\">Your LuxeGlow account has been successfully created. You now have access to explore our dermatologist-tested, cruelty-free cosmetic formulations designed to make you feel radiant, confident, and beautiful every single day.</p>"
                + "<p class=\"text\">To start exploring our collections of skincare, makeup, and curated masterpieces, click the button below:</p>"
                + "<div class=\"button-container\">"
                + "    <a href=\"http://localhost:8080/mavenproject2/product.jsp\" class=\"button\">Browse The Collection</a>"
                + "</div>"
                + "<p class=\"text\">Thank you for joining our journey to clean and radiant self-care.</p>";

        String body = getBaseTemplate("Welcome to LuxeGlow", content);
        sendEmailAsync(toEmail, "Welcome to LuxeGlow", body);
    }

    /**
     * 2. Send Password Reset Email
     */
    public static void sendPasswordResetEmail(String toEmail, String userName, String resetLink,
            String expirationTime) {
        String content = "<p class=\"text\">Dear " + userName + ",</p>"
                + "<p class=\"text\">We received a request to reset the password associated with your LuxeGlow account.</p>"
                + "<p class=\"text\">Please click the button below to establish a new password. This reset request will expire in <strong>"
                + expirationTime + "</strong> for security reasons.</p>"
                + "<div class=\"button-container\">"
                + "    <a href=\"" + resetLink + "\" class=\"button\">Reset My Password</a>"
                + "</div>"
                + "<p class=\"text\">If you did not make this request, you can safely ignore this email; your credentials will remain completely secure.</p>";

        String body = getBaseTemplate("Password Reset Request", content);
        sendEmailAsync(toEmail, "Password Reset Request", body);
    }

    /**
     * 3. Send Order Confirmation Email
     */
    public static void sendOrderConfirmationEmail(String toEmail, String customerName, int orderId, String orderDate,
            String purchasedProductsHtml, double subtotal, double discount,
            double shipping, double tax, double total,
            String shippingAddress, String paymentMethod, String deliveryDate) {
        String content = "<p class=\"text\">Dear " + customerName + ",</p>"
                + "<p class=\"text\">Thank you for your order! We are preparing your selection of LuxeGlow beauty masterpieces.</p>"
                + "<div style=\"border: 1px solid rgba(92,13,30,0.05); padding: 20px; border-radius: 12px; margin-bottom: 25px;\">"
                + "    <h4 style=\"margin-top:0; color:#5C0D1E; border-bottom:1px solid rgba(92,13,30,0.05); padding-bottom:8px;\">Order Details</h4>"
                + "    <p style=\"font-size:13px; margin:4px 0;\"><strong>Order ID:</strong> #LXG-" + orderId + "</p>"
                + "    <p style=\"font-size:13px; margin:4px 0;\"><strong>Order Date:</strong> " + orderDate + "</p>"
                + "    <p style=\"font-size:13px; margin:4px 0;\"><strong>Payment Method:</strong> " + paymentMethod
                + "</p>"
                + "    <p style=\"font-size:13px; margin:4px 0;\"><strong>Est. Delivery:</strong> " + deliveryDate
                + "</p>"
                + "</div>"
                + "<div style=\"margin-bottom: 25px;\">"
                + "    <h4 style=\"color:#5C0D1E; margin-bottom:10px;\">Selected Formulas</h4>"
                + "    <table style=\"width:100%; border-collapse:collapse; font-size:13px;\">"
                + "        <thead>"
                + "            <tr style=\"border-bottom:1.5px solid #5C0D1E; text-align:left;\">"
                + "                <th style=\"padding:8px 0;\">Product</th>"
                + "                <th style=\"padding:8px 0; text-align:center;\">Qty</th>"
                + "                <th style=\"padding:8px 0; text-align:right;\">Price</th>"
                + "            </tr>"
                + "        </thead>"
                + "        <tbody>"
                + "            " + purchasedProductsHtml
                + "        </tbody>"
                + "    </table>"
                + "</div>"
                + "<div style=\"border-top:1px solid rgba(92,13,30,0.05); padding-top:15px; margin-bottom:25px; text-align:right; font-size:13px; line-height:1.5;\">"
                + "    <p style=\"margin:3px 0;\">Subtotal: $" + String.format("%.2f", subtotal) + "</p>"
                + "    <p style=\"margin:3px 0;\">Discount: -$" + String.format("%.2f", discount) + "</p>"
                + "    <p style=\"margin:3px 0;\">Shipping: $" + String.format("%.2f", shipping) + "</p>"
                + "    <p style=\"margin:3px 0;\">Tax (8%): $" + String.format("%.2f", tax) + "</p>"
                + "    <p style=\"margin:4px 0; font-size:15px; font-weight:bold; color:#5C0D1E;\">Order Total: $"
                + String.format("%.2f", total) + "</p>"
                + "</div>"
                + "<div style=\"border:1px solid rgba(92,13,30,0.05); padding:20px; border-radius:12px; margin-bottom:20px;\">"
                + "    <h4 style=\"margin-top:0; color:#5C0D1E; border-bottom:1px solid rgba(92,13,30,0.05); padding-bottom:8px;\">Shipping Address</h4>"
                + "    <p style=\"font-size:13px; line-height:1.4; margin:0;\">" + shippingAddress + "</p>"
                + "</div>"
                + "<div class=\"button-container\">"
                + "    <a href=\"http://localhost:8080/mavenproject2/orders.jsp\" class=\"button\">Track My Order</a>"
                + "</div>";

        String body = getBaseTemplate("Order Confirmation - Order #LXG-" + orderId, content);
        sendEmailAsync(toEmail, "Order Confirmation - Order #LXG-" + orderId, body);
    }

    /**
     * 4. Send Contact Us Form Notification
     */
    public static void sendContactNotificationEmail(String senderName, String senderEmail, String subject,
            String message) {
        String content = "<p class=\"text\">Administrator Notice: A client has submitted a contact request form.</p>"
                + "<div style=\"border: 1px solid rgba(92,13,30,0.05); padding: 20px; border-radius: 12px; margin-bottom: 20px;\">"
                + "    <h4 style=\"margin-top:0; color:#5C0D1E; border-bottom:1px solid rgba(92,13,30,0.05); padding-bottom:8px;\">Client Details</h4>"
                + "    <p style=\"font-size:13px; margin:4px 0;\"><strong>Client Name:</strong> " + senderName + "</p>"
                + "    <p style=\"font-size:13px; margin:4px 0;\"><strong>Client Email:</strong> " + senderEmail
                + "</p>"
                + "    <p style=\"font-size:13px; margin:4px 0;\"><strong>Subject:</strong> " + subject + "</p>"
                + "</div>"
                + "<div style=\"border: 1px solid rgba(92,13,30,0.05); padding: 20px; border-radius: 12px;\">"
                + "    <h4 style=\"margin-top:0; color:#5C0D1E; border-bottom:1px solid rgba(92,13,30,0.05); padding-bottom:8px;\">Message Content</h4>"
                + "    <p style=\"font-size:13px; line-height:1.5; white-space:pre-wrap; margin:0;\">" + message
                + "</p>"
                + "</div>";

        String body = getBaseTemplate("Contact Form Notification", content);
        sendEmailAsync(getAdminEmail(), "Contact Form Notification: " + subject, body);
    }
}
