<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Help & Guidelines</title>
    <style>
        :root { --primary: #1a237e; --accent: #ffca28; --bg-light: #f4f6f9; --white: #ffffff; --text-dark: #333; --text-light: #666; }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; height: 100vh; background: var(--bg-light); color: var(--text-dark); }

        /* SIDEBAR */
        .sidebar { width: 260px; background: var(--primary); color: var(--white); display: flex; flex-direction: column; flex-shrink: 0; box-shadow: 2px 0 5px rgba(0,0,0,0.1); }
        .brand { padding: 25px 20px; border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 10px; }
        .brand h2 { font-size: 18px; font-weight: 700; }
        .brand span { color: var(--accent); }
        .admin-badge { display: block; text-align: center; background: rgba(255,202,40,0.2); color: var(--accent); font-size: 11px; padding: 4px 10px; margin: 0 20px 10px; border-radius: 4px; font-weight: 700; }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-section { padding: 10px 25px 5px; font-size: 10px; color: rgba(255,255,255,0.4); text-transform: uppercase; letter-spacing: 1px; }
        .nav-item { display: flex; align-items: center; padding: 13px 25px; color: rgba(255,255,255,0.8); text-decoration: none; transition: 0.3s; font-size: 14px; border-left: 4px solid transparent; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,0.1); color: var(--white); border-left-color: var(--accent); }
        .user-box { padding: 20px; border-top: 1px solid rgba(255,255,255,0.1); background: rgba(0,0,0,0.1); }
        .user-box small { opacity: 0.6; }

        /* MAIN AREA */
        .main-area { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .top-bar { background: var(--white); height: 60px; display: flex; align-items: center; padding: 0 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .top-bar h3 { color: var(--primary); }
        .content-area { flex: 1; padding: 40px; overflow-y: auto; }
        .content-inner { max-width: 860px; margin: 0 auto; }

        /* HELP CARDS */
        .help-card { background: var(--white); padding: 30px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.08); margin-bottom: 20px; }
        .help-card h2 { color: var(--primary); margin-bottom: 15px; border-bottom: 2px solid #eee; padding-bottom: 10px; font-size: 18px; }
        .help-card p { line-height: 1.7; color: #555; margin-bottom: 15px; }
        .step-list { list-style: none; padding: 0; }
        .step-list li { background: #f8f9fa; padding: 14px 18px; margin-bottom: 10px; border-left: 4px solid var(--primary); border-radius: 4px; line-height: 1.5; color: #444; }
        .step-list li strong { color: var(--primary); margin-right: 8px; }
        .warning-box { background: #fff3cd; color: #856404; padding: 15px 18px; border-radius: 5px; border: 1px solid #ffeeba; line-height: 1.6; }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="brand">
            <h2>Ocean <span>View</span></h2>
        </div>
        <span class="admin-badge">&#9881; Admin</span>
        <nav class="nav-menu">
            <div class="nav-section">Management</div>
            <a href="<%= request.getContextPath() %>/admin/DashboardServlet" class="nav-item">&#128202; Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/ReportServlet" class="nav-item">&#128200; Reports</a>
            <a href="<%= request.getContextPath() %>/admin/help.jsp" class="nav-item active">❓ Help</a>
        </nav>
        <div class="user-box">
            <small>Logged in as:</small><br>
            <strong><%= session.getAttribute("username") != null ? session.getAttribute("username") : "Admin" %></strong>
            <div style="margin-top:10px;">
                <a href="<%= request.getContextPath() %>/LogoutServlet" style="color:#ffca28; text-decoration:none; font-size:12px;">Logout</a>
            </div>
        </div>
    </div>

    <!-- MAIN AREA -->
    <div class="main-area">
        <div class="top-bar">
            <h3>Administrator Guidelines</h3>
        </div>

        <div class="content-area">
            <div class="content-inner">

                <div class="help-card">
                    <h2>🔐 1. Admin Responsibilities</h2>
                    <p>As an Administrator, you have full control over the system. Your role includes managing staff accounts, overseeing room inventory, and analysing business performance.</p>
                    <div class="warning-box">
                        <strong>Security Warning:</strong> Do not share your Admin password. Use strong passwords (a mix of letters, numbers, and symbols). Admin accounts have elevated privileges — keep credentials secure.
                    </div>
                </div>

                <div class="help-card">
                    <h2>👤 2. Managing Staff Accounts</h2>
                    <p>Use the Admin Dashboard to create and manage staff user accounts.</p>
                    <ul class="step-list">
                        <li><strong>Create Account:</strong> Enter the new staff member's username and set a temporary password.</li>
                        <li><strong>Reset Password:</strong> You can reset a staff member's password if they are locked out.</li>
                        <li><strong>Deactivate Account:</strong> Remove access for staff who are no longer employed.</li>
                    </ul>
                </div>

                <div class="help-card">
                    <h2>📊 3. Understanding Reports (Admin Only)</h2>
                    <p>The Reports section is accessible exclusively to Administrators and provides critical business intelligence to drive decisions.</p>
                    <ul class="step-list">
                        <li><strong>Access:</strong> Click <strong>Reports</strong> in the left sidebar from the Admin Dashboard.</li>
                        <li><strong>Revenue Trends:</strong> View the Bar Chart to see which months are most profitable.</li>
                        <li><strong>Room Popularity:</strong> Use the Pie Chart to identify which Room Types are in high demand.</li>
                        <li><strong>Decision Making:</strong> Use this data to adjust pricing or run promotions during low-season months.</li>
                    </ul>
                    <div class="warning-box">
                        <strong>Admin Only:</strong> Staff members do not have access to the Reports section. Only Admin accounts can view financial and occupancy analytics.
                    </div>
                </div>

                <div class="help-card">
                    <h2>⚙️ 4. System Configuration</h2>
                    <p>Core business rules such as tax rates and service charges are configured in the server-side properties file.</p>
                    <ul class="step-list">
                        <li><strong>Tax Rate:</strong> Currently set to 12% (configurable by the system administrator).</li>
                        <li><strong>Service Charge:</strong> Currently set to 10%.</li>
                        <li><strong>Database:</strong> Connection settings are managed via the <code>oceanview.properties</code> file on the server.</li>
                    </ul>
                </div>

            </div>
        </div>
    </div>

</body>
</html>







