<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.oceanview.util.FlashMessageUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Ocean View Resort - Login</title>
    <style>
        body { font-family: sans-serif; background: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-box { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); width: 350px; }
        h2 { text-align: center; color: #003366; }
        input { width: 100%; padding: 10px; margin: 10px 0; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; }
        button { width: 100%; padding: 10px; background: #003366; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #002244; }
        .alert { padding: 10px; margin-bottom: 15px; border-radius: 4px; text-align: center; }
        .alert-danger { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

<div class="login-box">
    <h2>Ocean View Resort</h2>

    <%-- Flash Message Handling --%>
    <%
        String[] flash = FlashMessageUtil.getAndClearFlash(request);
        if (flash != null) {
            out.println("<div class='alert alert-" + flash[0] + "'>" + flash[1] + "</div>");
        }
    %>

    <form action="LoginServlet" method="post">
        <input type="text" name="username" placeholder="Username" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Login</button>
    </form>

    <p style="text-align:center; margin-top:15px; font-size:12px; color:gray;">
        Demo Admin: <strong>admin</strong> / Pass: <strong>admin123</strong><br>
        Demo Staff: <strong>staff</strong> / Pass: <strong>admin123</strong>
    </p>
</div>

</body>
</html>

