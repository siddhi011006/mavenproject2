package com.mycompany.mavenproject2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class CouponHelper {
    public static class CouponResult {
        public boolean valid;
        public String errorMsg;
        public String discountType; // 'PERCENTAGE', 'FIXED'
        public double discountAmount;
        
        public CouponResult(boolean valid, String errorMsg, String discountType, double discountAmount) {
            this.valid = valid;
            this.errorMsg = errorMsg;
            this.discountType = discountType;
            this.discountAmount = discountAmount;
        }
    }
    
    public static CouponResult validateCoupon(String code, double orderSubtotal) {
        if (code == null || code.trim().isEmpty()) {
            return new CouponResult(false, "", null, 0);
        }
        
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT id, discount_type, discount_amount, expiry_date, usage_limit, usage_count, minimum_purchase_amount, is_active "
                       + "FROM coupons WHERE code = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, code.trim().toUpperCase());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int isActive = rs.getInt("is_active");
                        if (isActive != 1) {
                            return new CouponResult(false, "Coupon is inactive.", null, 0);
                        }
                        
                        Timestamp expiry = rs.getTimestamp("expiry_date");
                        if (expiry != null && expiry.before(new java.util.Date())) {
                            return new CouponResult(false, "Coupon has expired.", null, 0);
                        }
                        
                        int usageLimit = rs.getInt("usage_limit");
                        boolean hasLimit = !rs.wasNull();
                        int usageCount = rs.getInt("usage_count");
                        if (hasLimit && usageCount >= usageLimit) {
                            return new CouponResult(false, "Coupon usage limit reached.", null, 0);
                        }
                        
                        double minPurchase = rs.getDouble("minimum_purchase_amount");
                        if (orderSubtotal < minPurchase) {
                            return new CouponResult(false, "Minimum purchase of " + String.format("%.2f", minPurchase) + " required for this coupon.", null, 0);
                        }
                        
                        String discType = rs.getString("discount_type");
                        double discAmt = rs.getDouble("discount_amount");
                        return new CouponResult(true, "Coupon applied successfully!", discType, discAmt);
                    } else {
                        return new CouponResult(false, "Invalid coupon code.", null, 0);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return new CouponResult(false, "Error validating coupon: " + e.getMessage(), null, 0);
        }
    }
    
    public static void incrementUsage(String code) {
        if (code == null || code.trim().isEmpty()) {
            return;
        }
        try (Connection con = DBConnection.getConnection()) {
            String sql = "UPDATE coupons SET usage_count = usage_count + 1 WHERE code = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, code.trim().toUpperCase());
                ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
