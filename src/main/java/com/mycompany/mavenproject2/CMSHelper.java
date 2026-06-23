package com.mycompany.mavenproject2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

public class CMSHelper {
    
    public static Map<String, String> getPageContent(String prefix) {
        Map<String, String> content = new HashMap<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT content_key, content_value FROM cms_content WHERE content_key LIKE ?")) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    content.put(rs.getString("content_key"), rs.getString("content_value"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return content;
    }

    public static String getContent(String key, String defaultValue) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT content_value FROM cms_content WHERE content_key = ?")) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("content_value");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return defaultValue;
    }
}
