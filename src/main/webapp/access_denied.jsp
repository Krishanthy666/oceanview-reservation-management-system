<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Access Denied</title>
    <style>
        body { font-family: sans-serif; background: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .error-box { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); text-align: center; }
        h1 { color: #d32f2f; }
        p { color: #666; margin-bottom: 20px; }
        a { color: #003366; text-decoration: none; padding: 10px 20px; background: #e3f2fd; border-radius: 4px; display: inline-block; }
        a:hover { background: #bbdefb; }
    </style>
</head>
<body>

<div class="error-box">
    <h1>Access Denied</h1>
    <p>You do not have permission to view this page.</p>
    <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
</div>

</body>
</html>

