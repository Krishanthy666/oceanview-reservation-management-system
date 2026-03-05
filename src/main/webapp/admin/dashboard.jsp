<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="com.oceanview.util.FlashMessageUtil" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Ocean View Resort</title>
    <style>
        :root {
            --primary: #1a237e; --primary-light: #534bae; --accent: #ffca28;
            --bg-light: #f4f6f9; --white: #ffffff; --text-dark: #333;
            --text-light: #666; --border: #e0e0e0;
            --shadow: 0 2px 8px rgba(0,0,0,0.08); --radius: 8px;
        }
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Segoe UI',Tahoma,sans-serif; }
        body { display:flex; height:100vh; background:var(--bg-light); color:var(--text-dark); overflow:hidden; }
        .sidebar { width:250px; background:var(--primary); color:var(--white); display:flex; flex-direction:column; flex-shrink:0; }
        .brand { padding:25px 20px; border-bottom:1px solid rgba(255,255,255,0.1); display:flex; align-items:center; gap:10px; }
        .brand h2 { font-size:18px; font-weight:700; }
        .brand span { color:var(--accent); }
        .admin-badge { margin:14px 20px 4px; padding:4px 10px; background:rgba(255,202,40,0.2); border:1px solid rgba(255,202,40,0.4); border-radius:20px; font-size:11px; font-weight:700; letter-spacing:1px; color:var(--accent); display:inline-block; }
        .nav-menu { padding:10px 0; flex-grow:1; }
        .nav-section { padding:14px 20px 4px; font-size:10px; letter-spacing:1.5px; color:rgba(255,255,255,0.4); text-transform:uppercase; }
        .nav-item { display:flex; align-items:center; gap:10px; padding:13px 20px; color:rgba(255,255,255,0.8); text-decoration:none; font-size:14px; transition:0.2s; border-left:4px solid transparent; }
        .nav-item:hover { background:rgba(255,255,255,0.08); color:var(--white); border-left-color:rgba(255,202,40,0.5); }
        .nav-item.active { background:rgba(255,255,255,0.12); color:var(--white); border-left-color:var(--accent); font-weight:600; }
        .user-box { padding:18px 20px; border-top:1px solid rgba(255,255,255,0.1); background:rgba(0,0,0,0.1); font-size:13px; }
        .user-box small { opacity:0.6; display:block; margin-bottom:5px; }
        .user-box strong { display:block; margin-bottom:8px; }
        .user-box a { color:var(--accent); text-decoration:none; font-size:12px; }
        .main-area { flex:1; display:flex; flex-direction:column; overflow:hidden; }
        .top-bar { background:var(--white); height:65px; display:flex; align-items:center; justify-content:space-between; padding:0 30px; box-shadow:var(--shadow); border-bottom:3px solid var(--accent); }
        .top-bar h3 { font-size:20px; color:var(--primary); font-weight:600; }
        .top-bar-right { font-size:13px; color:var(--text-light); }
        .content-area { flex:1; padding:28px 30px; overflow-y:auto; }
        .stats-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(195px,1fr)); gap:18px; margin-bottom:28px; }
        .stat-card { background:var(--white); padding:22px 20px; border-radius:var(--radius); box-shadow:var(--shadow); border-top:4px solid var(--primary); transition:box-shadow 0.2s; }
        .stat-card:hover { box-shadow:0 4px 14px rgba(0,0,0,0.12); }
        .stat-card.c-green  { border-top-color:#2e7d32; }
        .stat-card.c-blue   { border-top-color:#0288d1; }
        .stat-card.c-yellow { border-top-color:#f57f17; }
        .stat-card.c-red    { border-top-color:#c62828; }
        .stat-card .s-icon { font-size:26px; margin-bottom:10px; }
        .stat-card h3 { font-size:28px; font-weight:700; color:var(--primary); margin-bottom:4px; }
        .stat-card .s-label { font-size:11px; color:var(--text-light); text-transform:uppercase; letter-spacing:0.5px; }
        .lower-grid { display:grid; grid-template-columns:2fr 1fr; gap:20px; }
        .section-card { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
        .section-header { padding:16px 20px; border-bottom:1px solid var(--border); display:flex; justify-content:space-between; align-items:center; }
        .section-header h3 { font-size:15px; font-weight:600; color:var(--primary); }
        .count-pill { background:#e8eaf6; color:var(--primary); padding:3px 10px; border-radius:12px; font-size:11px; font-weight:600; }
        table { width:100%; border-collapse:collapse; }
        th, td { padding:11px 18px; text-align:left; border-bottom:1px solid #f0f0f0; font-size:13px; }
        th { background:#f8f9fa; color:var(--text-light); font-size:11px; font-weight:600; text-transform:uppercase; }
        tr:last-child td { border-bottom:none; }
        tbody tr:hover td { background:#fafbff; }
        .badge { padding:3px 9px; border-radius:20px; font-size:10px; font-weight:700; }
        .badge-confirmed { background:#e8f5e9; color:#2e7d32; }
        .badge-cancelled { background:#ffebee; color:#c62828; }
        .badge-pending   { background:#fff8e1; color:#f57f17; }
        .quick-list { padding:4px 0; }
        .quick-item { display:flex; justify-content:space-between; align-items:center; padding:13px 20px; border-bottom:1px solid #f5f5f5; font-size:13px; }
        .quick-item:last-child { border-bottom:none; }
        .quick-item .q-label { color:var(--text-light); }
        .quick-item .q-val   { font-weight:700; color:var(--text-dark); }
        .q-val.green  { color:#2e7d32; }
        .q-val.blue   { color:#0288d1; }
        .q-val.yellow { color:#f57f17; }
        .q-val.red    { color:#c62828; }
        .alert { padding:12px 18px; border-radius:6px; margin-bottom:18px; font-size:13px; }
        .alert-success { background:#e8f5e9; color:#2e7d32; border:1px solid #c8e6c9; }
        .alert-danger  { background:#ffebee; color:#c62828; border:1px solid #ffcdd2; }
        .no-data { text-align:center; color:var(--text-light); padding:28px; font-size:13px; }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="brand">
        <div>🌊</div>
        <h2>Ocean <span>View</span></h2>
    </div>
    <span class="admin-badge">&#9881; Admin</span>
    <nav class="nav-menu">
        <div class="nav-section">Management</div>
        <a href="<%= request.getContextPath() %>/admin/DashboardServlet" class="nav-item active">&#128202; Dashboard</a>
        <a href="<%= request.getContextPath() %>/staff/ReportServlet" class="nav-item">&#128200; Reports</a>
        <a href="<%= request.getContextPath() %>/admin/help.jsp" class="nav-item">❓ Help</a>
    </nav>
    <div class="user-box">
        <small>Logged in as:</small>
        <strong><%= session.getAttribute("username") != null ? session.getAttribute("username") : "Admin" %></strong>
        <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
    </div>
</div>

<div class="main-area">
    <div class="top-bar">
        <h3>Management Overview</h3>
        <div class="top-bar-right">Admin Console</div>
    </div>
    <div class="content-area">
        <%
            String[] adminFlash = FlashMessageUtil.getAndClearFlash(request);
            if (adminFlash != null) {
                String adminAlertClass = "danger".equals(adminFlash[0]) ? "alert-danger" : "alert-success";
                out.println("<div class='alert " + adminAlertClass + "'>" + adminFlash[1] + "</div>");
            }
            List<Reservation> adminResList = (List<Reservation>) request.getAttribute("reservations");
            int adminShown = (adminResList != null) ? Math.min(adminResList.size(), 10) : 0;
        %>

        <div class="stats-grid">
            <div class="stat-card c-green">
                <div class="s-icon">🏨</div>
                <h3><%= request.getAttribute("totalRooms") != null ? request.getAttribute("totalRooms") : 0 %></h3>
                <div class="s-label">Total Rooms</div>
            </div>
            <div class="stat-card c-blue">
                <div class="s-icon">🔑</div>
                <h3><%= request.getAttribute("occupiedRooms") != null ? request.getAttribute("occupiedRooms") : 0 %></h3>
                <div class="s-label">Occupied Now</div>
            </div>
            <div class="stat-card c-green">
                <div class="s-icon">✅</div>
                <h3><%= request.getAttribute("availableRooms") != null ? request.getAttribute("availableRooms") : 0 %></h3>
                <div class="s-label">Available Rooms</div>
            </div>
            <div class="stat-card c-yellow">
                <div class="s-icon">🔧</div>
                <h3><%= request.getAttribute("maintenanceRooms") != null ? request.getAttribute("maintenanceRooms") : 0 %></h3>
                <div class="s-label">Under Maintenance</div>
            </div>
            <div class="stat-card c-green">
                <div class="s-icon">💰</div>
                <h3><%= request.getAttribute("revenueMonth") != null ? request.getAttribute("revenueMonth") : "0" %></h3>
                <div class="s-label">Revenue This Month (LKR)</div>
            </div>
            <div class="stat-card c-blue">
                <div class="s-icon">📋</div>
                <h3><%= request.getAttribute("newBookings") != null ? request.getAttribute("newBookings") : 0 %></h3>
                <div class="s-label">New Bookings Today</div>
            </div>
            <div class="stat-card c-red">
                <div class="s-icon">🧳</div>
                <h3><%= request.getAttribute("checkoutsToday") != null ? request.getAttribute("checkoutsToday") : 0 %></h3>
                <div class="s-label">Check-outs Today</div>
            </div>
            <div class="stat-card">
                <div class="s-icon">👤</div>
                <h3><%= request.getAttribute("staffCount") != null ? request.getAttribute("staffCount") : 0 %></h3>
                <div class="s-label">Staff Accounts</div>
            </div>
        </div>

        <div class="lower-grid">
            <div class="section-card">
                <div class="section-header">
                    <h3>Recent Reservation Activity</h3>
                    <span class="count-pill">Last <%= adminShown %> records</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th><th>Guest</th><th>Room</th>
                            <th>Check-In</th><th>Check-Out</th>
                            <th>Total (LKR)</th><th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (adminResList != null && !adminResList.isEmpty()) {
                           int rowCount = 0;
                           for (Reservation adminRes : adminResList) {
                               if (rowCount >= 10) break;
                               String statusClass = "CONFIRMED".equals(adminRes.getStatus()) ? "badge-confirmed"
                                                  : "CANCELLED".equals(adminRes.getStatus()) ? "badge-cancelled"
                                                  : "badge-pending"; %>
                        <tr>
                            <td style="color:#999;">#<%= adminRes.getReservationId() %></td>
                            <td><strong><%= adminRes.getGuestName() %></strong></td>
                            <td><%= adminRes.getRoomNumber() %></td>
                            <td><%= adminRes.getCheckIn() %></td>
                            <td><%= adminRes.getCheckOut() %></td>
                            <td><%= String.format("%,.0f", adminRes.getTotalCost().doubleValue()) %></td>
                            <td><span class="badge <%= statusClass %>"><%= adminRes.getStatus() %></span></td>
                        </tr>
                    <% rowCount++; } } else { %>
                        <tr><td colspan="7" class="no-data">No reservations found.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="section-card">
                <div class="section-header"><h3>At a Glance</h3></div>
                <div class="quick-list">
                    <div class="quick-item">
                        <span class="q-label">Occupancy Rate</span>
                        <span class="q-val green"><%= request.getAttribute("occupancyRate") != null ? request.getAttribute("occupancyRate") : "0" %>%</span>
                    </div>
                    <div class="quick-item">
                        <span class="q-label">Available Rooms</span>
                        <span class="q-val blue"><%= request.getAttribute("availableRooms") != null ? request.getAttribute("availableRooms") : 0 %></span>
                    </div>
                    <div class="quick-item">
                        <span class="q-label">Maintenance Rooms</span>
                        <span class="q-val yellow"><%= request.getAttribute("maintenanceRooms") != null ? request.getAttribute("maintenanceRooms") : 0 %></span>
                    </div>
                    <div class="quick-item">
                        <span class="q-label">Check-outs Today</span>
                        <span class="q-val red"><%= request.getAttribute("checkoutsToday") != null ? request.getAttribute("checkoutsToday") : 0 %></span>
                    </div>
                    <div class="quick-item">
                        <span class="q-label">New Bookings Today</span>
                        <span class="q-val green"><%= request.getAttribute("newBookings") != null ? request.getAttribute("newBookings") : 0 %></span>
                    </div>
                    <div class="quick-item">
                        <span class="q-label">Staff Accounts</span>
                        <span class="q-val blue"><%= request.getAttribute("staffCount") != null ? request.getAttribute("staffCount") : 0 %></span>
                    </div>
                    <div class="quick-item">
                        <span class="q-label">Total Inventory</span>
                        <span class="q-val"><%= request.getAttribute("totalRooms") != null ? request.getAttribute("totalRooms") : 0 %> rooms</span>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>
