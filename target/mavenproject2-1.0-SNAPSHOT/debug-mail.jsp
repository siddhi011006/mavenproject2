<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mycompany.mavenproject2.EmailUtility" %>
<!DOCTYPE html>
<html>
<head>
    <title>Email Utility Debugger</title>
</head>
<body>
    <h1>Resolved Properties in Running Environment</h1>
    <table border="1">
        <tr>
            <th>Property Key</th>
            <th>Value from EmailUtility.getProperty()</th>
        </tr>
        <tr>
            <td>mail.smtp.host</td>
            <td><%= EmailUtility.getProperty("mail.smtp.host", "N/A") %></td>
        </tr>
        <tr>
            <td>mail.smtp.port</td>
            <td><%= EmailUtility.getProperty("mail.smtp.port", "N/A") %></td>
        </tr>
        <tr>
            <td>mail.smtp.username</td>
            <td><%= EmailUtility.getProperty("mail.smtp.username", "N/A") %></td>
        </tr>
        <tr>
            <td>mail.smtp.password (Length)</td>
            <td>
                <% 
                    String pwd = EmailUtility.getProperty("mail.smtp.password", "");
                    out.print(pwd != null ? "'" + pwd + "' (Length: " + pwd.length() + ")" : "NULL");
                %>
            </td>
        </tr>
        <tr>
            <td>mail.from</td>
            <td><%= EmailUtility.getProperty("mail.from", "N/A") %></td>
        </tr>
    </table>

    <h2>System Environment Variables</h2>
    <table border="1">
        <tr>
            <th>Env Var Key</th>
            <th>Value</th>
        </tr>
        <tr>
            <td>SMTP_USERNAME</td>
            <td><%= System.getenv("SMTP_USERNAME") %></td>
        </tr>
        <tr>
            <td>SMTP_PASSWORD</td>
            <td><%= System.getenv("SMTP_PASSWORD") %></td>
        </tr>
        <tr>
            <td>MAIL_SMTP_USERNAME</td>
            <td><%= System.getenv("MAIL_SMTP_USERNAME") %></td>
        </tr>
        <tr>
            <td>MAIL_SMTP_PASSWORD</td>
            <td><%= System.getenv("MAIL_SMTP_PASSWORD") %></td>
        </tr>
    </table>

    <h2>System Properties</h2>
    <table border="1">
        <tr>
            <th>Property Key</th>
            <th>Value</th>
        </tr>
        <tr>
            <td>mail.smtp.username</td>
            <td><%= System.getProperty("mail.smtp.username") %></td>
        </tr>
        <tr>
            <td>mail.smtp.password</td>
            <td><%= System.getProperty("mail.smtp.password") %></td>
        </tr>
    </table>
</body>
</html>
