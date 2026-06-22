package com.mycompany.mavenproject2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ProductImageHelper {
    public static String getProductImage(int productId) {
        String mainImage = null;
        String defaultVariantImage = null;
        String firstAvailableImage = null;
        String parentFallbackImage = null;

        try (Connection con = DBConnection.getConnection()) {
            // First, fetch the parent image_url from products table
            String sqlParent = "SELECT image_url FROM products WHERE id = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlParent)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        parentFallbackImage = rs.getString("image_url");
                    }
                }
            }

            // Priority 1: Product Main Image (is_primary = 1 AND variant_id IS NULL)
            String sql1 = "SELECT image_url FROM product_images WHERE product_id = ? AND is_primary = 1 AND variant_id IS NULL LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql1)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        mainImage = rs.getString("image_url");
                    }
                }
            }

            if (mainImage != null && !mainImage.trim().isEmpty()) {
                return mainImage;
            }

            // Fallback to parent image_url if not null and not a variant image
            if (parentFallbackImage != null && !parentFallbackImage.trim().isEmpty()) {
                return parentFallbackImage;
            }

            // Priority 2: Default Variant Image (variant's first image or is_primary = 1 for a variant)
            String sql2 = "SELECT image_url FROM product_images WHERE product_id = ? AND variant_id IS NOT NULL ORDER BY is_primary DESC, sort_order ASC, id ASC LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql2)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        defaultVariantImage = rs.getString("image_url");
                    }
                }
            }

            if (defaultVariantImage != null && !defaultVariantImage.trim().isEmpty()) {
                return defaultVariantImage;
            }

            // Priority 3: First Available Image in product_images
            String sql3 = "SELECT image_url FROM product_images WHERE product_id = ? ORDER BY sort_order ASC, id ASC LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql3)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        firstAvailableImage = rs.getString("image_url");
                    }
                }
            }

            if (firstAvailableImage != null && !firstAvailableImage.trim().isEmpty()) {
                return firstAvailableImage;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return (parentFallbackImage != null && !parentFallbackImage.trim().isEmpty()) 
               ? parentFallbackImage 
               : "image/default-product.jpg";
    }
}
