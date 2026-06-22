<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<footer style="background: #151313; color: #FAF6F4; padding: 60px 8% 40px 8%; margin-top: auto; border-top: 1px solid rgba(197, 171, 87, 0.15);">
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 40px; text-align: left; margin-bottom: 50px;">
        
        <!-- Brand Info -->
        <div>
            <div class="footer-logo" style="font-size: 2.2rem; font-weight: 700; letter-spacing: 3px; color: var(--gold); margin-bottom: 20px;">LuxeGlow</div>
            <p style="font-size: 0.85rem; color: #CFC5C7; line-height: 1.6; margin-bottom: 20px;">
                Dermatologist-tested, clinical-grade cosmetic formulations designed to bring out your skin's natural, healthy radiance.
            </p>
            <div class="footer-socials" style="display: flex; gap: 15px;">
                <a href="#" style="color: #FAF6F4; font-size: 1.1rem; width: 36px; height: 36px; border: 1px solid rgba(250,246,244,0.15); border-radius: 50%; display: flex; align-items: center; justify-content: center; transition: var(--transition);"><i class="fab fa-instagram"></i></a>
                <a href="#" style="color: #FAF6F4; font-size: 1.1rem; width: 36px; height: 36px; border: 1px solid rgba(250,246,244,0.15); border-radius: 50%; display: flex; align-items: center; justify-content: center; transition: var(--transition);"><i class="fab fa-pinterest"></i></a>
                <a href="#" style="color: #FAF6F4; font-size: 1.1rem; width: 36px; height: 36px; border: 1px solid rgba(250,246,244,0.15); border-radius: 50%; display: flex; align-items: center; justify-content: center; transition: var(--transition);"><i class="fab fa-facebook-f"></i></a>
            </div>
        </div>

        <!-- Sitemap Quick Links -->
        <div>
            <h4 style="color: var(--gold); font-size: 0.95rem; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 20px;">Discover</h4>
            <ul style="list-style: none; padding: 0; margin: 0; font-size: 0.85rem; display: flex; flex-direction: column; gap: 10px;">
                <li><a href="product.jsp" style="color: #CFC5C7;">Shop All Products</a></li>
                <li><a href="new-arrivals.jsp" style="color: #CFC5C7;">New Arrivals</a></li>
                <li><a href="best-sellers.jsp" style="color: #CFC5C7;">Best Sellers</a></li>
                <li><a href="gift-sets.jsp" style="color: #CFC5C7;">Gift Sets</a></li>
                <li><a href="quiz.jsp" style="color: #CFC5C7;">Skin Analysis Quiz</a></li>
            </ul>
        </div>

        <!-- Policies & Service -->
        <div>
            <h4 style="color: var(--gold); font-size: 0.95rem; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 20px;">Information</h4>
            <ul style="list-style: none; padding: 0; margin: 0; font-size: 0.85rem; display: flex; flex-direction: column; gap: 10px;">
                <li><a href="about.jsp" style="color: #CFC5C7;">About Our Brand</a></li>
                <li><a href="contact.jsp" style="color: #CFC5C7;">Contact Support</a></li>
                <li><a href="faq.jsp" style="color: #CFC5C7;">FAQs</a></li>
                <li><a href="shipping-policy.jsp" style="color: #CFC5C7;">Shipping & Handling</a></li>
                <li><a href="returns-policy.jsp" style="color: #CFC5C7;">Returns & Refunds</a></li>
            </ul>
        </div>

        <!-- Interactive Newsletter -->
        <div>
            <h4 style="color: var(--gold); font-size: 0.95rem; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 20px;">The LuxeNewsletter</h4>
            <p style="font-size: 0.85rem; color: #CFC5C7; line-height: 1.6; margin-bottom: 15px;">
                Join our beauty circle for 15% off your first order, custom routines, and secret sales.
            </p>
            <form id="newsletterForm" onsubmit="handleNewsletter(event)" style="display: flex; gap: 10px; flex-wrap: wrap;">
                <input type="email" id="newsletterEmail" placeholder="Enter email address" required 
                       style="flex: 1; padding: 12px 18px; border-radius: 30px; border: 1px solid rgba(255,255,255,0.1); background: rgba(255,255,255,0.05); color: white; font-size: 0.85rem; outline: none; transition: var(--transition);">
                <button type="submit" class="btn-gold" style="padding: 10px 24px; font-size: 0.75rem; border-radius: 30px; margin: 0;">Join</button>
            </form>
        </div>

    </div>

    <!-- Copyright and Legal info -->
    <div style="border-top: 1px solid rgba(255,255,255,0.05); padding-top: 30px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; font-size: 0.8rem; color: #8F8486;">
        <p>&copy; <span id="footerYear"></span> LuxeGlow Cosmetics. All Rights Reserved.</p>
        <div style="display: flex; gap: 20px;">
            <a href="privacy.jsp" style="color: #8F8486;">Privacy Policy</a>
            <a href="terms.jsp" style="color: #8F8486;">Terms of Use</a>
        </div>
    </div>
</footer>

<script>
    document.getElementById('footerYear').textContent = new Date().getFullYear();

    function handleNewsletter(event) {
        event.preventDefault();
        const email = document.getElementById('newsletterEmail').value;
        if (email) {
            // Display toast notification using global showToast if defined, or simple alert
            if (typeof showToast === "function") {
                showToast("Welcome to LuxeJournal! Check your inbox for a 15% discount code.");
            } else {
                alert("Thank you! You are now subscribed to the LuxeJournal.");
            }
            document.getElementById('newsletterEmail').value = "";
        }
    }
</script>
