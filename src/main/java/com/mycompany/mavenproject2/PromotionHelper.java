package com.mycompany.mavenproject2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PromotionHelper {
    public static double getDiscountedPrice(int productId, String category, String brand, double originalPrice) {
        double maxDiscount = 0.0;
        double bestPrice = originalPrice;

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT discount_type, discount_amount, target_type, target_value "
                       + "FROM promotions "
                       + "WHERE is_active = 1 "
                       + "AND (start_date IS NULL OR start_date <= CURRENT_TIMESTAMP) "
                       + "AND (end_date IS NULL OR end_date >= CURRENT_TIMESTAMP)";
            
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                
                while (rs.next()) {
                    String discountType = rs.getString("discount_type");
                    double discountAmount = rs.getDouble("discount_amount");
                    String targetType = rs.getString("target_type");
                    String targetValue = rs.getString("target_value");

                    boolean applies = false;
                    if ("SITEWIDE".equalsIgnoreCase(targetType)) {
                        applies = true;
                    } else if ("PRODUCT".equalsIgnoreCase(targetType)) {
                        if (targetValue != null && Integer.parseInt(targetValue.trim()) == productId) {
                            applies = true;
                        }
                    } else if ("CATEGORY".equalsIgnoreCase(targetType)) {
                        if (targetValue != null && targetValue.equalsIgnoreCase(category)) {
                            applies = true;
                        }
                    } else if ("BRAND".equalsIgnoreCase(targetType)) {
                        if (targetValue != null && targetValue.equalsIgnoreCase(brand)) {
                            applies = true;
                        }
                    }

                    if (applies) {
                        double currentPrice = originalPrice;
                        if ("PERCENTAGE".equalsIgnoreCase(discountType)) {
                            currentPrice = originalPrice * (1.0 - (discountAmount / 100.0));
                        } else if ("FIXED".equalsIgnoreCase(discountType)) {
                            currentPrice = originalPrice - discountAmount;
                        }

                        if (currentPrice < 0) {
                            currentPrice = 0.0;
                        }

                        double discountValue = originalPrice - currentPrice;
                        if (discountValue > maxDiscount) {
                            maxDiscount = discountValue;
                            bestPrice = currentPrice;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bestPrice;
    }

    public static boolean hasPromotion(int productId, String category, String brand) {
        // Return true if any promotion applies to this product
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT target_type, target_value "
                       + "FROM promotions "
                       + "WHERE is_active = 1 "
                       + "AND (start_date IS NULL OR start_date <= CURRENT_TIMESTAMP) "
                       + "AND (end_date IS NULL OR end_date >= CURRENT_TIMESTAMP)";
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String targetType = rs.getString("target_type");
                    String targetValue = rs.getString("target_value");

                    if ("SITEWIDE".equalsIgnoreCase(targetType)) {
                        return true;
                    } else if ("PRODUCT".equalsIgnoreCase(targetType)) {
                        if (targetValue != null && Integer.parseInt(targetValue.trim()) == productId) {
                            return true;
                        }
                    } else if ("CATEGORY".equalsIgnoreCase(targetType)) {
                        if (targetValue != null && targetValue.equalsIgnoreCase(category)) {
                            return true;
                        }
                    } else if ("BRAND".equalsIgnoreCase(targetType)) {
                        if (targetValue != null && targetValue.equalsIgnoreCase(brand)) {
                            return true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
