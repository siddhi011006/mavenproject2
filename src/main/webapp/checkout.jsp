<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.mavenproject2.DBConnection" %>
<%
    // Authenticate user
    HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp?error=Please sign in to complete your purchase.&redirect=checkout.jsp");
        return;
    }

    int userId = (Integer) s.getAttribute("user_id");
    
    // Check cart contents & calculate aggregates
    double subtotal = 0.0;
    boolean hasItems = false;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    java.util.List<String[]> savedAddresses = new java.util.ArrayList<>();

    try {
        con = DBConnection.getConnection();
        
        // Check Cart
        String sql = "SELECT c.quantity, p.price FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        while (rs.next()) {
            hasItems = true;
            subtotal += rs.getDouble("price") * rs.getInt("quantity");
        }
        rs.close();
        ps.close();

        // Fetch Saved Addresses
        String addrSql = "SELECT id, address_line, city, zip, country, is_default FROM addresses WHERE user_id = ? ORDER BY is_default DESC";
        ps = con.prepareStatement(addrSql);
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        while (rs.next()) {
            savedAddresses.add(new String[]{
                rs.getString("id"),
                rs.getString("address_line"),
                rs.getString("city"),
                rs.getString("zip"),
                rs.getString("country"),
                rs.getString("is_default")
            });
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }

    if (!hasItems) {
        response.sendRedirect("product.jsp?error=Your shopping bag is empty.");
        return;
    }

    double shipping = (subtotal >= 1500.0) ? 0.0 : 9.99;
    double tax = subtotal * 0.08;
    double total = subtotal + tax + shipping;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Checkout | LuxeGlow</title>
    <!-- Core Styling -->
    <link rel="stylesheet" href="index.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<!-- Include Glassmorphic Header -->
    <%@ include file="navbar.jsp" %>

    <div class="page-container" style="padding: 60px 8%; max-width: 1200px; margin: 0 auto;">
        
        <!-- Action feedback alerts -->
        <%
            String errorMsg = (String) request.getAttribute("error");
            if (errorMsg != null) {
        %>
            <div class="alert alert-danger" style="margin-bottom: 30px;">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= errorMsg %></span>
            </div>
        <% } %>

        <h1 class="title-center" style="font-size: 2.5rem; margin-bottom: 40px; text-align: center; font-family:'Playfair Display', serif;">Secure Checkout</h1>

        <!-- Checkout Layout Grid -->
        <div class="cart-layout" style="display: grid; grid-template-columns: 1.6fr 1fr; gap: 40px; align-items: start;">
            
            <!-- Left Panel: Address & Payment Forms -->
            <div class="cart-items-panel" style="background: var(--bg-card); padding: 35px; border-radius: 24px; border: 1px solid var(--border-light); box-shadow: var(--shadow-lux); text-align: left;">
                <form action="CheckoutServlet" method="POST" id="checkoutForm">
                    <input type="hidden" name="couponCode" id="hiddenCouponCode" value="">
                    
                    <h3 style="font-family:'Playfair Display', serif; font-size:1.4rem; color:var(--burgundy); border-bottom:1px solid var(--border-light); padding-bottom:10px; margin-bottom:25px; font-weight:600;">
                        <i class="fas fa-truck" style="margin-right:10px; color: var(--gold);"></i> Shipping Information
                    </h3>

                    <!-- Saved Address Selector -->
                    <% if (!savedAddresses.isEmpty()) { %>
                        <div class="form-group" style="margin-bottom: 25px;">
                            <label for="addressSelector" style="font-weight: 600; font-size: 0.85rem; color: var(--text-primary);">Use a Saved Address</label>
                            <select id="addressSelector" onchange="autoFillAddress()" style="width:100%; border-radius:30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none; font-size:0.85rem;">
                                <option value="">-- Choose saved address --</option>
                                <% for (String[] addr : savedAddresses) { %>
                                    <option value="<%= addr[1] %>|<%= addr[2] %>|<%= addr[3] %>|<%= addr[4] %>">
                                        <%= addr[1] %>, <%= addr[2] %> (<%= "true".equals(addr[5]) ? "Default" : "Secondary" %>)
                                    </option>
                                <% } %>
                            </select>
                        </div>
                    <% } %>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label for="address" style="font-weight: 600; font-size: 0.85rem;">Street Address</label>
                        <input type="text" id="address" name="address" placeholder="123 Luxury Way, Apt 4B" required style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                    </div>

                    <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 15px; margin-bottom: 25px;">
                        <div class="form-group">
                            <label for="city" style="font-weight: 600; font-size: 0.85rem;">City</label>
                            <input type="text" id="city" name="city" placeholder="New York" required style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                        </div>
                        <div class="form-group">
                            <label for="zip" style="font-weight: 600; font-size: 0.85rem;">Zip Code</label>
                            <input type="text" id="zip" name="zip" placeholder="10011" required style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                        </div>
                        <div class="form-group">
                            <label for="country" style="font-weight: 600; font-size: 0.85rem;">Country</label>
                            <select id="country" name="country" required style="width: 100%; border-radius: 30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none; background: var(--bg-card); color: var(--text-primary); font-size: 0.85rem; box-sizing: border-box; height: 45px;">
                                <option value="India">India</option>
                                <option value="United States">United States</option>
                                <option value="United Kingdom">United Kingdom</option>
                                <option value="Canada">Canada</option>
                                <option value="Australia">Australia</option>
                                <option value="UAE">UAE</option>
                                <option value="Germany">Germany</option>
                                <option value="France">France</option>
                            </select>
                        </div>
                    </div>

                    <h3 style="font-family:'Playfair Display', serif; font-size:1.4rem; color:var(--burgundy); border-bottom:1px solid var(--border-light); padding-bottom:10px; margin-top:35px; margin-bottom:25px; font-weight:600;">
                        <i class="fas fa-credit-card" style="margin-right:10px; color: var(--gold);"></i> Payment Details
                    </h3>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label for="paymentMethod" style="font-weight: 600; font-size: 0.85rem;">Payment Method</label>
                        <select id="paymentMethod" name="paymentMethod" onchange="togglePaymentPanels()" required style="width:100%; border-radius:30px; padding: 12px 18px; border: 1px solid var(--border-color); outline:none;">
                            <option value="CARD">Credit Card / Debit Card</option>
                            <option value="UPI">UPI (Unified Payments Interface)</option>
                            <option value="NET_BANKING">Net Banking</option>
                            <option value="COD">Cash On Delivery (COD)</option>
                        </select>
                    </div>

                    <!-- Card details panel -->
                    <div id="cardDetailsPanel" class="payment-panel" style="margin-bottom: 25px;">
                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="cardname" style="font-weight: 600; font-size: 0.85rem;">Cardholder Name</label>
                            <input type="text" id="cardname" placeholder="Siddhi Tiwari" style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="cardnumber" style="font-weight: 600; font-size: 0.85rem;">Card Number</label>
                            <input type="text" id="cardnumber" placeholder="•••• •••• •••• ••••" maxlength="19" style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                            <div class="form-group">
                                <label for="cardexp" style="font-weight: 600; font-size: 0.85rem;">Expiration Date</label>
                                <input type="text" id="cardexp" placeholder="MM/YY" maxlength="5" style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                            </div>
                            <div class="form-group">
                                <label for="cardcvv" style="font-weight: 600; font-size: 0.85rem;">CVV</label>
                                <input type="password" id="cardcvv" placeholder="•••" maxlength="3" style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                            </div>
                        </div>
                    </div>

                    <!-- UPI Details Panel -->
                    <div id="upiDetailsPanel" class="payment-panel" style="display:none; margin-bottom: 25px;">
                        <div class="form-group">
                            <label for="upiId" style="font-weight: 600; font-size: 0.85rem;">Enter UPI ID / Virtual Payment Address</label>
                            <input type="text" id="upiId" name="upiId" placeholder="username@okaxis" pattern="[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}" style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                            <small style="color:var(--text-muted); font-size:0.75rem; display:block; margin-top:5px; margin-left:10px;">Example: mobileNumber@upi or name@okicici</small>
                        </div>
                    </div>

                    <!-- Net Banking Details Panel -->
                    <div id="netbankingDetailsPanel" class="payment-panel" style="display:none; margin-bottom: 25px;">
                        <div class="form-group">
                            <label for="bankSelect" style="font-weight: 600; font-size: 0.85rem;">Select Your Bank</label>
                            <select id="bankSelect" name="bankName" style="width:100%; border-radius:30px; padding:12px 18px; border:1px solid var(--border-color); outline:none;">
                                <option value="HDFC">HDFC Bank</option>
                                <option value="SBI">State Bank of India</option>
                                <option value="ICICI">ICICI Bank</option>
                                <option value="AXIS">Axis Bank</option>
                                <option value="KOTAK">Kotak Mahindra Bank</option>
                            </select>
                        </div>
                    </div>

                    <!-- COD Details Panel -->
                    <div id="codDetailsPanel" class="payment-panel" style="display:none; margin-bottom: 25px;">
                        <div style="background: rgba(92, 13, 30, 0.04); border:1px solid var(--border-color); border-radius:16px; padding:20px; font-size:0.85rem; color:var(--text-secondary); line-height:1.6;">
                            <i class="fas fa-money-bill-wave" style="color:var(--gold); font-size:1.1rem; margin-right:8px;"></i>
                            <strong>Cash On Delivery Selected:</strong> Pay with cash when your luxury parcel is safely delivered to your doorstep. No extra handling fee applied.
                        </div>
                    </div>

                    <button type="submit" class="btn-gold" style="width:100%; border-radius:30px; margin-top:25px; padding:15px; font-size:1rem; margin-bottom:0;">
                        <i class="fas fa-lock" style="margin-right:8px;"></i> Place Secure Order (<span id="btnTotalText"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(total, currentCountry) %></span>)
                    </button>
                </form>
            </div>

            <!-- Right Panel: Aggregated Summary -->
            <div class="summary-panel" style="background: var(--bg-card); padding: 35px; border-radius: 24px; border: 1px solid var(--border-light); box-shadow: var(--shadow-lux); text-align: left;">
                <h3 class="summary-title" style="font-family:'Playfair Display', serif; font-size:1.4rem; color:var(--burgundy); border-bottom:1px solid var(--border-light); padding-bottom:10px; margin-bottom:25px; font-weight:600;">Order Summary</h3>
                
                <div class="summary-row" style="display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 0.9rem; color: var(--text-secondary);">
                    <span>Bag Subtotal</span>
                    <span id="subtotalVal"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(subtotal, currentCountry) %></span>
                </div>

                <!-- Coupon discount row (hidden by default) -->
                <div class="summary-row" id="couponRow" style="display: none; justify-content: space-between; margin-bottom: 12px; font-size: 0.9rem; color: var(--success); font-weight: 600;">
                    <span>Coupon Discount (15%)</span>
                    <span id="discountVal">-$0.00</span>
                </div>

                <div class="summary-row" style="display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 0.9rem; color: var(--text-secondary);">
                    <span>Shipping Fee</span>
                    <span id="shippingVal">
                        <% if (shipping == 0.0) { %>
                            <span style="color: var(--success); font-weight: 600;">Free Shipping</span>
                        <% } else { %>
                            <%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(shipping, currentCountry) %>
                        <% } %>
                    </span>
                </div>

                <div class="summary-row" style="display: flex; justify-content: space-between; margin-bottom: 20px; font-size: 0.9rem; color: var(--text-secondary);">
                    <span>Sales Tax (8%)</span>
                    <span id="taxVal"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(tax, currentCountry) %></span>
                </div>

                <!-- Coupon input form inside summary -->
                <div style="border-top: 1px solid var(--border-light); padding-top: 20px; margin-bottom: 25px;">
                    <label style="font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); display: block; margin-bottom: 8px;">Promo / Gift Coupon</label>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" id="couponInput" placeholder="Enter coupon..." style="flex: 1; padding: 10px 15px; border-radius: 30px; border: 1px solid var(--border-color); outline:none; font-size:0.8rem; text-transform: uppercase;">
                        <button type="button" onclick="applyCoupon()" class="btn-gold" style="margin:0; padding: 10px 20px; font-size:0.75rem; border-radius: 30px;">Apply</button>
                    </div>
                    <small id="couponMessage" style="font-size: 0.75rem; display: block; margin-top: 5px; font-weight: 550;"></small>
                </div>

                <div class="summary-row total" style="display: flex; justify-content: space-between; border-top: 1px solid var(--border-light); padding-top: 20px; font-size: 1.15rem; font-weight: 700; color: var(--text-primary);">
                    <span>Total Cost</span>
                    <span id="totalVal" style="color: var(--gold); font-size: 1.4rem;"><%= com.mycompany.mavenproject2.CurrencyHelper.formatPrice(total, currentCountry) %></span>
                </div>

                <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid var(--border-light); font-size: 0.8rem; color: var(--text-muted); text-align: center;">
                    <i class="fas fa-shield-alt" style="color: var(--gold); font-size: 1.2rem; display: block; margin-bottom: 8px;"></i>
                    Your checkout connection is encrypted. LuxeGlow never stores full credit card details.
                </div>
            </div>

        </div>
    </div>

    <!-- Include Reusable Footer -->
    <%@ include file="footer.jsp" %>

    <script>
        // Auto-fill address fields based on saved address selection
        function autoFillAddress() {
            const selector = document.getElementById('addressSelector');
            if (!selector) return;
            const val = selector.value;
            if (!val) {
                document.getElementById('address').value = '';
                document.getElementById('city').value = '';
                document.getElementById('zip').value = '';
                document.getElementById('country').value = 'India';
                return;
            }
            const parts = val.split('|');
            document.getElementById('address').value = parts[0];
            document.getElementById('city').value = parts[1];
            document.getElementById('zip').value = parts[2];
            
            let countryVal = parts[3] ? parts[3].trim() : 'India';
            if (countryVal === 'USA' || countryVal === 'US') countryVal = 'United States';
            if (countryVal === 'UK') countryVal = 'United Kingdom';
            document.getElementById('country').value = countryVal;
        }

        // Dynamic JS Localization settings
        const currentCountry = "<%= currentCountry %>";
        const currencySymbol = "<%= com.mycompany.mavenproject2.CurrencyHelper.getCurrencySymbol(currentCountry) %>";
        const conversionRate = <%= com.mycompany.mavenproject2.CurrencyHelper.convert(1.0, currentCountry) %>;
        
        function formatCurrency(valInInr) {
            const converted = valInInr * conversionRate;
            if (currencySymbol === "د.إ") {
                return currencySymbol + " " + converted.toFixed(2);
            }
            return currencySymbol + converted.toFixed(2);
        }

        // Live calculation metrics
        let subtotal = <%= subtotal %>;
        let appliedCoupon = {
            code: "",
            valid: false,
            discountType: null,
            discountAmount: 0.0
        };

        function applyCoupon() {
            const code = document.getElementById('couponInput').value.trim().toUpperCase();
            const msg = document.getElementById('couponMessage');
            
            if (code === "") {
                appliedCoupon = { code: "", valid: false, discountType: null, discountAmount: 0.0 };
                document.getElementById('hiddenCouponCode').value = "";
                msg.innerText = "";
                recalculateTotals();
                return;
            }

            fetch(`CheckoutServlet?couponCode=${encodeURIComponent(code)}&subtotal=${subtotal}`)
                .then(res => res.json())
                .then(data => {
                    if (data.valid) {
                        appliedCoupon = {
                            code: code,
                            valid: true,
                            discountType: data.discountType,
                            discountAmount: data.discountAmount
                        };
                        document.getElementById('hiddenCouponCode').value = code;
                        msg.style.color = "var(--success)";
                        
                        let label = "";
                        if (data.discountType === "PERCENTAGE") {
                            label = `${data.discountAmount}%`;
                        } else {
                            label = formatCurrency(data.discountAmount);
                        }
                        msg.innerText = `Coupon ${code} applied! (${label} discount)`;
                    } else {
                        appliedCoupon = { code: "", valid: false, discountType: null, discountAmount: 0.0 };
                        document.getElementById('hiddenCouponCode').value = "";
                        msg.style.color = "var(--danger)";
                        msg.innerText = data.errorMsg || "Invalid coupon code.";
                    }
                    recalculateTotals();
                })
                .catch(err => {
                    console.error("Error validating coupon:", err);
                    msg.style.color = "var(--danger)";
                    msg.innerText = "Error validating coupon. Please try again.";
                });
        }

        function recalculateTotals() {
            const row = document.getElementById('couponRow');
            const discVal = document.getElementById('discountVal');
            const subtotalValEl = document.getElementById('subtotalVal');
            const taxValEl = document.getElementById('taxVal');
            const shippingValEl = document.getElementById('shippingVal');
            const totalValEl = document.getElementById('totalVal');
            const btnTotalTextEl = document.getElementById('btnTotalText');

            let discount = 0.0;
            if (appliedCoupon.valid) {
                if (appliedCoupon.discountType === "PERCENTAGE") {
                    discount = subtotal * (appliedCoupon.discountAmount / 100.0);
                } else if (appliedCoupon.discountType === "FIXED") {
                    discount = appliedCoupon.discountAmount;
                }
                
                const couponRowLabel = row.querySelector('span:first-child');
                if (couponRowLabel) {
                    if (appliedCoupon.discountType === "PERCENTAGE") {
                        couponRowLabel.innerText = `Coupon Discount (${appliedCoupon.discountAmount}%)`;
                    } else {
                        couponRowLabel.innerText = `Coupon Discount`;
                    }
                }
                
                row.style.display = 'flex';
                discVal.innerText = "-" + formatCurrency(discount);
            } else {
                row.style.display = 'none';
            }

            let discountedSubtotal = subtotal - discount;
            if (discountedSubtotal < 0) discountedSubtotal = 0;
            let shipping = (discountedSubtotal >= 1500.0) ? 0.0 : 9.99;
            let tax = discountedSubtotal * 0.08;
            let total = discountedSubtotal + tax + shipping;

            subtotalValEl.innerText = formatCurrency(subtotal);
            taxValEl.innerText = formatCurrency(tax);
            if (shipping === 0.0) {
                shippingValEl.innerHTML = '<span style="color: var(--success); font-weight: 600;">Free Shipping</span>';
            } else {
                shippingValEl.innerText = formatCurrency(shipping);
            }
            totalValEl.innerText = formatCurrency(total);
            btnTotalTextEl.innerText = formatCurrency(total);
        }

        // Toggle payment form panels visibility depending on selection
        function togglePaymentPanels() {
            const select = document.getElementById('paymentMethod');
            const panels = document.querySelectorAll('.payment-panel');
            
            // Hide all panels first
            panels.forEach(p => p.style.display = 'none');
            
            // Disable all panel inputs/selects from being required initially
            panels.forEach(p => {
                p.querySelectorAll('input, select').forEach(input => {
                    input.required = false;
                });
            });

            // Show and set required inputs for chosen method
            if (select.value === 'CARD') {
                const panel = document.getElementById('cardDetailsPanel');
                panel.style.display = 'block';
                panel.querySelectorAll('input').forEach(i => i.required = true);
            } else if (select.value === 'UPI') {
                const panel = document.getElementById('upiDetailsPanel');
                panel.style.display = 'block';
                panel.querySelector('input').required = true;
            } else if (select.value === 'NET_BANKING') {
                const panel = document.getElementById('netbankingDetailsPanel');
                panel.style.display = 'block';
                panel.querySelector('select').required = true;
            } else if (select.value === 'COD') {
                document.getElementById('codDetailsPanel').style.display = 'block';
            }
        }
        
        // Initial setup
        togglePaymentPanels();
        
        // Auto default values on load if saved default exists
        <% if (!savedAddresses.isEmpty() && "true".equals(savedAddresses.get(0)[5])) { %>
            document.addEventListener('DOMContentLoaded', () => {
                const selector = document.getElementById('addressSelector');
                selector.value = "<%= savedAddresses.get(0)[1] %>|<%= savedAddresses.get(0)[2] %>|<%= savedAddresses.get(0)[3] %>|<%= savedAddresses.get(0)[4] %>";
                autoFillAddress();
            });
        <% } %>
        
        // Simple card formatting
        document.getElementById('cardnumber').addEventListener('input', function (e) {
            e.target.value = e.target.value.replace(/[^\d]/g, '').replace(/(.{4})/g, '$1 ').trim();
        });
        document.getElementById('cardexp').addEventListener('input', function (e) {
            e.target.value = e.target.value.replace(/[^\d]/g, '').replace(/(.{2})/, '$1/').trim();
        });
    </script>
</body>
</html>

