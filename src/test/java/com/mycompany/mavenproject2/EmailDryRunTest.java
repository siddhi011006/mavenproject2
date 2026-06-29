package com.mycompany.mavenproject2;

public class EmailDryRunTest {
    public static void main(String[] args) {
        String recipient = "sidti0110@gmail.com";
        System.out.println("Starting SMTP Dry Run for email: " + recipient);

        try {
            // 1. Simulate sending OTP email
            System.out.println("\n--- Step 1: Sending OTP Email (Simulating registration) ---");
            String otpCode = "123456";
            String otpSubject = "LuxeGlow - Confirm Your Email OTP Verification";
            String otpBody = "<!DOCTYPE html>"
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
                    + "        <div class=\"footer\">&copy; 2026 LuxeGlow. All Rights Reserved.</div>"
                    + "    </div>"
                    + "</body>"
                    + "</html>";

            EmailUtility.sendEmailSync(recipient, otpSubject, otpBody);
            System.out.println("OTP Email sent successfully!");

            // 2. Simulate sending Order Confirmation email
            System.out.println("\n--- Step 2: Sending Order Confirmation Email ---");
            String purchasedProductsHtml = "<tr style=\"border-bottom:1px solid rgba(92,13,30,0.05);\">"
                    + "<td style=\"padding:10px 0;\">LuxeGlow Retinol Serum</td>"
                    + "<td style=\"padding:10px 0; text-align:center;\">1</td>"
                    + "<td style=\"padding:10px 0; text-align:right;\">$59.00</td>"
                    + "</tr>"
                    + "<tr style=\"border-bottom:1px solid rgba(92,13,30,0.05);\">"
                    + "<td style=\"padding:10px 0;\">LuxeGlow Hydrating Moisturizer</td>"
                    + "<td style=\"padding:10px 0; text-align:center;\">2</td>"
                    + "<td style=\"padding:10px 0; text-align:right;\">$78.00</td>"
                    + "</tr>";

            EmailUtility.sendOrderConfirmationEmail(
                    recipient, 
                    "Siddhi Tiwari", 
                    1024, 
                    "Jun 29, 2026 18:30", 
                    purchasedProductsHtml, 
                    137.00, 
                    10.00, 
                    0.00, 
                    10.16, 
                    137.16, 
                    "123 Luxe St, New York, NY 10001", 
                    "Credit Card", 
                    "Jul 04, 2026"
            );
            System.out.println("Order Confirmation Email queued/sent asynchronously!");
            
            // Sleep to allow the async executor thread pool to finish sending
            System.out.println("Waiting 5 seconds for async thread pool to finish sending...");
            Thread.sleep(5000);
            System.out.println("Dry Run completed successfully!");

        } catch (Exception e) {
            System.err.println("Dry Run failed with exception:");
            e.printStackTrace();
        }
    }
}
