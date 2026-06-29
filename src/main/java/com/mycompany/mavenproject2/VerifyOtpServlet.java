package com.mycompany.mavenproject2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/verify-otp")
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String otp = request.getParameter("otp");

        // 1. Inputs validation
        if (email == null || email.trim().isEmpty() || otp == null || otp.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Email and OTP code are required.\"}");
            return;
        }

        email = email.trim().toLowerCase();
        otp = otp.trim();

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // 2. Fetch the latest unused OTP code sent to this email
            String sql = "SELECT id, otp_hash, expiry_time, is_used FROM email_otps WHERE email = ? ORDER BY created_at DESC LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int otpId = rs.getInt("id");
                        String storedHash = rs.getString("otp_hash");
                        Timestamp expiryTime = rs.getTimestamp("expiry_time");
                        int isUsed = rs.getInt("is_used");

                        // 3. Verify status, expiry, and match hash
                        if (isUsed == 1) {
                            response.getWriter().write("{\"success\":false,\"message\":\"This OTP has already been verified or invalidated. Please request a new one.\"}");
                            return;
                        }

                        if (expiryTime.before(new Timestamp(System.currentTimeMillis()))) {
                            response.getWriter().write("{\"success\":false,\"message\":\"The verification OTP code has expired. Please request a new one.\"}");
                            return;
                        }

                        String inputHash = PasswordHasher.hashOTP(otp);
                        if (!storedHash.equals(inputHash)) {
                            response.getWriter().write("{\"success\":false,\"message\":\"Invalid OTP passcode. Please verify the code and try again.\"}");
                            return;
                        }

                        // 4. Mark the verification OTP as successfully used
                        String updateSql = "UPDATE email_otps SET is_used = 1 WHERE id = ?";
                        try (PreparedStatement updatePs = con.prepareStatement(updateSql)) {
                            updatePs.setInt(1, otpId);
                            updatePs.executeUpdate();
                        }

                        // 5. Store verified status in session to secure register endpoint
                        request.getSession().setAttribute("verified_email", email);

                        response.getWriter().write("{\"success\":true,\"message\":\"Email address successfully verified.\"}");

                    } else {
                        response.getWriter().write("{\"success\":false,\"message\":\"No verification code was requested for this email address. Please send a new OTP first.\"}");
                    }
                }
            }

        } catch (Exception e) {
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
