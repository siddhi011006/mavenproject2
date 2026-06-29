package com.mycompany.mavenproject2;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/send-otp")
public class SendOtpServlet extends HttpServlet {

    private static final int OTP_EXPIRY_MINUTES = 5;
    private static final int RATE_LIMIT_MINUTES = 15;
    private static final int MAX_OTP_REQUESTS = 3;
    private static final int COOLDOWN_SECONDS = 60;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String ipAddress = request.getRemoteAddr();

        // 1. Validate email input
        if (email == null || email.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Email address is required.\"}");
            return;
        }
        email = email.trim().toLowerCase();

        if (!ValidationHelper.isValidEmail(email)) {
            response.getWriter().write("{\"success\":false,\"message\":\"Please enter a valid email address.\"}");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // 2. Check 60-second cooldown for this email (Timezone-safe UNIX_TIMESTAMP database-side calculation)
            String cooldownSql = "SELECT UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(MAX(request_time)) FROM otp_requests WHERE email = ?";
            try (PreparedStatement ps = con.prepareStatement(cooldownSql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long timePassed = rs.getLong(1);
                        if (!rs.wasNull()) {
                            // Retrieve the actual last timestamp from the DB for logging
                            Timestamp lastOtpTimestamp = null;
                            String lastTimeSql = "SELECT MAX(request_time) FROM otp_requests WHERE email = ?";
                            try (PreparedStatement ltPs = con.prepareStatement(lastTimeSql)) {
                                ltPs.setString(1, email);
                                try (ResultSet ltRs = ltPs.executeQuery()) {
                                    if (ltRs.next()) {
                                        lastOtpTimestamp = ltRs.getTimestamp(1);
                                    }
                                }
                            }

                            // If clock drift or skew returns negative elapsed time, log it and override
                            if (timePassed < 0) {
                                System.err.println("[OTP COOLDOWN WARNING] Negative elapsed time detected (" + timePassed + "s). Resetting elapsed time to 0.");
                                timePassed = 0;
                            }

                            long waitTime = COOLDOWN_SECONDS - timePassed;
                            if (waitTime < 0 || waitTime > COOLDOWN_SECONDS) {
                                // If an invalid cooldown value is detected, reset it to 60 seconds
                                System.err.println("[OTP COOLDOWN WARNING] Invalid cooldown value detected (" + waitTime + "s). Resetting to 60 seconds.");
                                waitTime = COOLDOWN_SECONDS;
                            }

                            // Detailed server logs
                            System.out.println("[OTP COOLDOWN LOG]");
                            System.out.println(" - Current timestamp (JVM): " + new java.util.Date());
                            System.out.println(" - Last OTP timestamp (DB): " + (lastOtpTimestamp != null ? lastOtpTimestamp.toString() : "null"));
                            System.out.println(" - Elapsed time (seconds): " + timePassed);
                            System.out.println(" - Remaining cooldown (seconds): " + waitTime);

                            if (timePassed < COOLDOWN_SECONDS) {
                                response.getWriter().write("{\"success\":false,\"message\":\"Please wait " + waitTime + " seconds before requesting another OTP.\"}");
                                return;
                            }
                        }
                    }
                }
            }

            // 3. Rate limiting check (max 3 OTP requests in last 15 minutes by IP or Email)
            String limitSql = "SELECT COUNT(*) FROM otp_requests WHERE (email = ? OR ip_address = ?) "
                            + "AND request_time > NOW() - INTERVAL ? MINUTE";
            try (PreparedStatement ps = con.prepareStatement(limitSql)) {
                ps.setString(1, email);
                ps.setString(2, ipAddress);
                ps.setInt(3, RATE_LIMIT_MINUTES);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) >= MAX_OTP_REQUESTS) {
                        response.getWriter().write("{\"success\":false,\"message\":\"Too many OTP requests. Please try again after 15 minutes.\"}");
                        return;
                    }
                }
            }

            // 4. Generate 6-digit random OTP
            SecureRandom random = new SecureRandom();
            int otpVal = 100000 + random.nextInt(900000);
            String otpCode = String.valueOf(otpVal);

            // 5. Invalidate older unused OTP codes for this email
            String invalidateSql = "UPDATE email_otps SET is_used = 1 WHERE email = ? AND is_used = 0";
            try (PreparedStatement ps = con.prepareStatement(invalidateSql)) {
                ps.setString(1, email);
                ps.executeUpdate();
            }

            // 6. Store new OTP securely (hashed)
            String otpHash = PasswordHasher.hashOTP(otpCode);
            long expiryMillis = System.currentTimeMillis() + (OTP_EXPIRY_MINUTES * 60 * 1000);
            Timestamp expiryTime = new Timestamp(expiryMillis);

            String storeSql = "INSERT INTO email_otps (email, otp_hash, expiry_time) VALUES (?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(storeSql)) {
                ps.setString(1, email);
                ps.setString(2, otpHash);
                ps.setTimestamp(3, expiryTime);
                ps.executeUpdate();
            }

            // 7. Save request log for rate limiting
            String logRequestSql = "INSERT INTO otp_requests (email, ip_address) VALUES (?, ?)";
            try (PreparedStatement ps = con.prepareStatement(logRequestSql)) {
                ps.setString(1, email);
                ps.setString(2, ipAddress);
                ps.executeUpdate();
            }

            // 8. Dispatch verification email synchronously
            String subject = "LuxeGlow - Confirm Your Email OTP Verification";
            String emailBody = "<!DOCTYPE html>"
                    + "<html>"
                    + "<head>"
                    + "    <style>"
                    + "        body { font-family: Arial, sans-serif; background-color: #FAF8F5; margin: 0; padding: 20px; color: #1F1C1C; }"
                    + "        .container { max-width: 600px; margin: 0 auto; background-color: #FFFFFF; border: 1px solid rgba(92, 13, 30, 0.1); border-radius: 16px; padding: 40px; box-shadow: 0 10px 30px rgba(92, 13, 30, 0.03); }"
                    + "        .logo { font-size: 24px; font-weight: bold; color: #5C0D1E; text-align: center; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 25px; }"
                    + "        .title { font-size: 20px; color: #5C0D1E; margin-bottom: 20px; text-align: center; font-weight: 600; }"
                    + "        .otp-box { text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #5C0D1E; background: #FAF8F5; padding: 15px; border-radius: 8px; border: 1px dashed #C5AB57; margin: 30px auto; max-width: 250px; }"
                    + "        .footer { text-align: center; font-size: 11px; color: #8F8486; border-top: 1px solid rgba(92, 13, 30, 0.04); padding-top: 20px; margin-top: 35px; }"
                    + "    </style>"
                    + "</head>"
                    + "<body>"
                    + "    <div class=\"container\">"
                    + "        <div class=\"logo\">LuxeGlow</div>"
                    + "        <div class=\"title\">Verify Your Email</div>"
                    + "        <p>Dear Valued Client,</p>"
                    + "        <p>Thank you for choosing LuxeGlow. To complete your registration and verify your email address, please use the following one-time passcode (OTP):</p>"
                    + "        <div class=\"otp-box\">" + otpCode + "</div>"
                    + "        <p>This passcode is highly secure and valid for the next <strong>5 minutes</strong>. Please do not share this passcode with anyone.</p>"
                    + "        <div class=\"footer\">&copy; " + java.time.Year.now().getValue() + " LuxeGlow. All Rights Reserved.</div>"
                    + "    </div>"
                    + "</body>"
                    + "</html>";

            EmailUtility.sendEmailSync(email, subject, emailBody);

            response.getWriter().write("{\"success\":true,\"message\":\"Verification OTP sent successfully.\"}");

        } catch (jakarta.mail.AuthenticationFailedException e) {
            System.err.println("[SMTP AUTH ERROR] Authentication failed. Check your environment variables (SMTP_USER/SMTP_PASS) or app password credentials.");
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Email dispatch failed: SMTP authentication error. Please contact the administrator to verify credentials.\"}");
        } catch (jakarta.mail.MessagingException e) {
            System.err.println("[SMTP MESSAGING ERROR] Messaging exception occurred while connecting/sending email: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Email dispatch failed: Mail server connection error (MessagingException). Please verify SMTP_HOST and SMTP_PORT.\"}");
        } catch (Exception e) {
            System.err.println("[OTP PROCESS ERROR] Exception in SendOtpServlet: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Failed to process request: " + e.getMessage() + "\"}");
        } finally {
            if (con != null) {
                try { con.close(); } catch (Exception e) {}
            }
        }
    }
}
