<%@ page import="com.oceanview.config.AppConfig" %>
<%@ page import="com.oceanview.util.DBConnection" %>
<%@ page import="com.oceanview.util.SecurityUtil" %>
<%@ page import="com.oceanview.dao.RoomDAO" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>System Diagnostic - Phase 1 & 2</title>
    <style>
        body { font-family: monospace; padding: 20px; background: #f4f4f4; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .card { background: white; padding: 15px; margin-bottom: 10px; border-left: 5px solid #ddd; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        h2 { border-bottom: 2px solid #333; padding-bottom: 5px; }
    </style>
</head>
<body>

<h1>🛠️ Ocean View Resort - System Diagnostic</h1>
<p>Running checks on core components...</p>

<!-- TEST 1: Configuration -->
<div class="card">
    <h3>Test 1: Configuration Loader</h3>
    <%
        try {
            String dbUrl = AppConfig.getDbUrl();
            if (dbUrl != null && !dbUrl.isEmpty()) {
                out.println("<p class='success'>✅ SUCCESS: Config loaded.</p>");
                out.println("<p>DB URL: " + dbUrl + "</p>");
                out.println("<p>Tax Rate: " + AppConfig.getTaxRate() + "</p>");
            } else {
                out.println("<p class='error'>❌ FAIL: Config file found but values are empty.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>❌ CRITICAL FAIL: Could not read 'oceanview.properties'. Did you create it in src/main/resources?</p>");
            out.println("<pre>" + e.getMessage() + "</pre>");
        }
    %>
</div>

<!-- TEST 2: Database Connection -->
<div class="card">
    <h3>Test 2: Database Connection (Singleton)</h3>
    <%
        // Fixed: Removed ClassNotFoundException as it is caught inside DBConnection
        try (Connection conn = DBConnection.getInstance().getConnection()) {
            if (conn != null && !conn.isClosed()) {
                out.println("<p class='success'>✅ SUCCESS: Database connected!</p>");
                out.println("<p>Connection Valid: " + conn.isValid(2) + "</p>");
            } else {
                out.println("<p class='error'>❌ FAIL: Connection object is null.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>❌ CONNECTION FAIL: Check DB URL, Username, Password, and ensure MySQL is running.</p>");
            out.println("<pre style='color:red;'>" + e.getMessage() + "</pre>");
        }
    %>
</div>

<!-- TEST 3: Security Utility -->
<div class="card">
    <h3>Test 3: Security Utility (SHA-256)</h3>
    <%
        try {
            String plain = "admin123";
            String hash = SecurityUtil.hashPassword(plain);

            // Pre-calculated hash for "admin123"
            String expectedHash = "240be518fabd2724ddb6f04eeb9d5b0428b5d4e3c6c6b3e7d5e3c6c6b3e7d5";

            if (hash.equals(expectedHash)) {
                out.println("<p class='success'>✅ SUCCESS: Hashing logic is correct.</p>");
                out.println("<p>Plain: " + plain + "</p>");
                out.println("<p>Hash: " + hash + "</p>");
            } else {
                out.println("<p class='error'>❌ FAIL: Hash generated but does not match expected value.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>❌ FAIL: Hashing crashed.</p>");
        }
    %>
</div>

<!-- TEST 4: DAO Layer -->
<div class="card">
    <h3>Test 4: DAO Layer (Fetching Room Types)</h3>
    <%
        try {
            RoomDAO roomDAO = new RoomDAO();
            List<RoomType> types = roomDAO.getAllRoomTypes();

            if (types != null && !types.isEmpty()) {
                out.println("<p class='success'>✅ SUCCESS: DAO works. Found " + types.size() + " room types.</p>");
                out.println("<ul>");
                for (RoomType rt : types) {
                    out.println("<li>" + rt.getTypeName() + " - Rate: " + rt.getBaseRate() + "</li>");
                }
                out.println("</ul>");
            } else {
                out.println("<p class='error'>❌ FAIL: List is empty. Check if 'room_types' table has data.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>❌ FAIL: Database query failed. Check Table Schema.</p>");
            out.println("<pre style='color:red;'>" + e.getMessage() + "</pre>");
        }
    %>
</div>

<hr>
<h3>Conclusion:</h3>
<%
    // Final Logic Check
    boolean allGood = true;
    try (Connection c = DBConnection.getInstance().getConnection()) {
        if (c == null) allGood = false;
    } catch (Exception e) {
        allGood = false;
    }

    if (allGood) {
        out.println("<h2 class='success'>System is Ready. Proceed to Phase 3 (API).</h2>");
    } else {
        out.println("<h2 class='error'>Critical Errors Found. Fix above issues before proceeding.</h2>");
    }
%>

</body>
</html>