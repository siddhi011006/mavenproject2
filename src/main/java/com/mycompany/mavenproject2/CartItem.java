package com.mycompany.mavenproject2;

/**
 * Shared Model Bean representing a product item in the shopping cart or wishlist.
 * Fields are kept public for direct compatibility with JSP templates.
 * 
 * @author Siddhi Tiwari
 */
public class CartItem {
    public int productId;
    public String name;
    public double price;
    public String category;
    public String imageUrl;
    public int quantity;
    public int stock;
    
    // Variant fields
    public Integer variantId;
    public String variantName;
    public String colorCode;

    public CartItem(int productId, String name, double price, String category, String imageUrl, int quantity, int stock) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.category = category;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.stock = stock;
        this.variantId = null;
        this.variantName = null;
        this.colorCode = null;
    }

    public CartItem(int productId, String name, double price, String category, String imageUrl, int quantity, int stock, Integer variantId, String variantName, String colorCode) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.category = category;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.stock = stock;
        this.variantId = variantId;
        this.variantName = variantName;
        this.colorCode = colorCode;
    }
}
