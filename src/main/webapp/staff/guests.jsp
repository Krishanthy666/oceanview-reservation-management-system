<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.oceanview.util.FlashMessageUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Management - Ocean View Resort</title>
    <style>
        /* === CSS VARIABLES (Design System) === */
        :root {
            --primary: #1a237e;
            --primary-light: #534bae;
            --primary-dark: #0d1854;
            --accent: #ffca28;
            --accent-dark: #ffa000;
            --success: #2e7d32;
            --warning: #f57f17;
            --danger: #d32f2f;
            --info: #0288d1;
            --bg-light: #f4f6f9;
            --bg-white: #ffffff;
            --text-dark: #333;
            --text-light: #666;
            --border-color: #e0e0e0;
            --shadow: 0 4px 6px rgba(0,0,0,0.1);
            --shadow-hover: 0 8px 12px rgba(0,0,0,0.15);
            --radius: 8px;
            --transition: 0.3s ease;
        }

        /* === RESET & BASE === */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-light);
            color: var(--text-dark);
            display: flex;
            height: 100vh;
        }

        /* === SIDEBAR === */
        .sidebar {
            width: 260px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: var(--bg-white);
            display: flex;
            flex-direction: column;
            box-shadow: 2px 0 10px rgba(0,0,0,0.2);
            overflow-y: auto;
        }

        .brand {
            padding: 25px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .brand-icon { font-size: 28px; }
        .brand h2 { font-size: 18px; font-weight: 700; letter-spacing: 0.5px; }
        .brand span { color: var(--accent); }

        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px 20px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            transition: var(--transition);
            font-size: 14px;
            border-left: 4px solid transparent;
        }
        .nav-item:hover {
            background: rgba(255,255,255,0.1);
            border-left-color: var(--accent);
            color: var(--bg-white);
        }
        .nav-item.active {
            background: rgba(255,255,255,0.15);
            border-left-color: var(--accent);
            color: var(--bg-white);
            font-weight: 600;
        }

        .user-box {
            padding: 20px;
            border-top: 1px solid rgba(255,255,255,0.1);
            background: rgba(0,0,0,0.15);
            font-size: 13px;
        }
        .user-box small { opacity: 0.7; display: block; margin-bottom: 8px; }
        .user-box strong { display: block; margin-bottom: 10px; }
        .user-box a { color: var(--accent); text-decoration: none; font-size: 12px; }
        .user-box a:hover { text-decoration: underline; }

        /* === MAIN CONTENT AREA === */
        .main-area { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

        .top-bar {
            background: var(--bg-white);
            height: 70px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 30px;
            box-shadow: var(--shadow);
            border-bottom: 2px solid var(--accent);
        }
        .top-bar h3 { font-size: 22px; color: var(--primary); font-weight: 600; }

        .content-area {
            flex: 1;
            padding: 30px;
            overflow-y: auto;
            background: var(--bg-light);
        }

        /* === STATISTICS CARDS === */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--bg-white);
            padding: 25px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border-top: 4px solid var(--primary);
            transition: var(--transition);
        }
        .stat-card:hover {
            box-shadow: var(--shadow-hover);
            transform: translateY(-2px);
        }
        .stat-card.success { border-top-color: var(--success); }
        .stat-card.warning { border-top-color: var(--warning); }
        .stat-card.info { border-top-color: var(--info); }

        .stat-card .value {
            font-size: 32px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 5px;
        }
        .stat-card .label { font-size: 13px; color: var(--text-light); text-transform: uppercase; }
        .stat-card .currency { font-size: 13px; color: var(--text-light); margin-top: 5px; }

        /* === SECTION CARDS === */
        .section-card {
            background: var(--bg-white);
            padding: 30px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 30px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }
        .section-header h3 {
            font-size: 18px;
            color: var(--primary);
            font-weight: 600;
        }

        /* === FILTERS & SEARCH === */
        .filter-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .filter-bar input, .filter-bar select {
            padding: 10px 15px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 14px;
        }
        .filter-bar input:focus, .filter-bar select:focus {
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(26,35,126,0.1);
        }

        /* === GUEST CARD (ALTERNATIVE VIEW) === */
        .guest-card {
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            padding: 20px;
            margin-bottom: 15px;
            transition: var(--transition);
            border-left: 4px solid var(--info);
        }
        .guest-card:hover {
            box-shadow: var(--shadow-hover);
            transform: translateX(5px);
        }

        .guest-card-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
        }
        .guest-card-name {
            font-size: 18px;
            font-weight: 600;
            color: var(--primary);
        }
        .guest-card-badge {
            background: #e3f2fd;
            color: var(--info);
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .guest-card-body {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            font-size: 14px;
        }
        .guest-info-row {
            display: flex;
            flex-direction: column;
        }
        .guest-info-row label {
            color: var(--text-light);
            font-size: 12px;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .guest-info-row value {
            color: var(--text-dark);
            font-weight: 600;
        }

        .guest-card-footer {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid var(--border-color);
        }
        .btn-view {
            padding: 8px 16px;
            background: var(--info);
            color: var(--bg-white);
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: var(--transition);
        }
        .btn-view:hover {
            background: #0277bd;
        }

        /* === TABLE === */
        .table-responsive {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: #f8f9fa;
            padding: 14px 15px;
            text-align: left;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-light);
            text-transform: uppercase;
            border-bottom: 2px solid var(--border-color);
        }
        td {
            padding: 14px 15px;
            border-bottom: 1px solid var(--border-color);
            font-size: 14px;
        }
        tr:hover {
            background: #f8f9fa;
        }

        /* === ALERTS === */
        .alert {
            padding: 16px 20px;
            border-radius: var(--radius);
            margin-bottom: 20px;
            font-size: 14px;
            border-left: 4px solid transparent;
        }
        .alert-success {
            background: #e8f5e9;
            color: var(--success);
            border-left-color: var(--success);
        }
        .alert-info {
            background: #e3f2fd;
            color: var(--info);
            border-left-color: var(--info);
        }

        /* === BADGES === */
        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-loyal {
            background: #fff3e0;
            color: var(--warning);
        }
        .badge-regular {
            background: #e3f2fd;
            color: var(--info);
        }
        .badge-new {
            background: #e8f5e9;
            color: var(--success);
        }

        /* === TABS === */
        .tab-container {
            margin-bottom: 20px;
            border-bottom: 2px solid var(--border-color);
        }
        .tabs {
            display: flex;
            gap: 0;
        }
        .tab {
            padding: 15px 20px;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            color: var(--text-light);
            border-bottom: 3px solid transparent;
            transition: var(--transition);
        }
        .tab:hover, .tab.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }

        /* === SCROLLBAR === */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        ::-webkit-scrollbar-track {
            background: var(--bg-light);
        }
        ::-webkit-scrollbar-thumb {
            background: #bbb;
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: #888;
        }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="brand">
            <div class="brand-icon">🌊</div>
            <div>
                <h2>Ocean <span>View</span></h2>
            </div>
        </div>

        <nav class="nav-menu">
            <a href="<%= request.getContextPath() %>/staff/ReservationServlet" class="nav-item">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/help.jsp" class="nav-item">❓ Help</a>
        </nav>

        <div class="user-box">
            <small>Logged in as:</small>
            <strong><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></strong>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>

    <!-- MAIN AREA -->
    <div class="main-area">
        <!-- TOP BAR -->
        <div class="top-bar">
            <h3>👥 Guest Management & Analytics</h3>
        </div>

        <!-- CONTENT AREA -->
        <div class="content-area">

            <!-- FLASH MESSAGES -->
            <%
                String[] flash = FlashMessageUtil.getAndClearFlash(request);
                if (flash != null) {
                    String alertClass = "danger".equals(flash[0]) ? "alert-danger" : "alert-success";
                    out.println("<div class='alert " + alertClass + "'>" + flash[1] + "</div>");
                }
            %>

            <!-- STATISTICS CARDS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="value"><%= request.getAttribute("totalGuests") != null ? request.getAttribute("totalGuests") : 0 %></div>
                    <div class="label">Total Guests</div>
                </div>
                <div class="stat-card success">
                    <div class="value">LKR <%= request.getAttribute("totalRevenue") != null ? String.format("%.0f", request.getAttribute("totalRevenue")) : 0 %></div>
                    <div class="label">Total Revenue</div>
                </div>
                <div class="stat-card info">
                    <div class="value">LKR <%= request.getAttribute("averageSpent") != null ? String.format("%.0f", request.getAttribute("averageSpent")) : 0 %></div>
                    <div class="label">Avg. Spend Per Guest</div>
                </div>
            </div>

            <!-- TABS -->
            <div class="section-card">
                <div class="tab-container">
                    <div class="tabs">
                        <button class="tab active" onclick="switchTab('tableView')">📊 Table View</button>
                        <button class="tab" onclick="switchTab('cardView')">🗂️ Card View</button>
                    </div>
                </div>

                <!-- TABLE VIEW -->
                <div id="tableView" class="tab-content active">
                    <div style="margin-bottom: 20px;">
                        <input type="text" id="tableSearch" placeholder="🔍 Search guests by name or contact..." onkeyup="filterTable()" style="width: 100%; padding: 12px 15px; border: 1px solid var(--border-color); border-radius: 4px; font-size: 14px;">
                    </div>

                    <div class="table-responsive">
                        <table id="guestTable">
                            <thead>
                                <tr>
                                    <th>Guest Name</th>
                                    <th>Contact</th>
                                    <th>Address</th>
                                    <th>Visits</th>
                                    <th>Total Spent</th>
                                    <th>Last Visit</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0.00");
                                    List<Map<String, Object>> guestSummary = (List<Map<String, Object>>) request.getAttribute("guestSummary");
                                    if (guestSummary != null && !guestSummary.isEmpty()) {
                                        for (Map<String, Object> g : guestSummary) {
                                            int visits = (Integer) g.get("visits");
                                            String badge = visits >= 5 ? "badge-loyal" : visits >= 2 ? "badge-regular" : "badge-new";
                                            String badgeText = visits >= 5 ? "Loyal" : visits >= 2 ? "Regular" : "New";
                                %>
                                    <tr>
                                        <td><strong><%= g.get("name") %></strong></td>
                                        <td><%= g.get("contact") != null ? g.get("contact") : "N/A" %></td>
                                        <td><%= g.get("address") != null ? g.get("address") : "N/A" %></td>
                                        <td><span class="badge <%= badge %>"><%= badgeText %></span> <%= visits %></td>
                                        <td>LKR <%= df.format(g.get("totalSpent")) %></td>
                                        <td><%= g.get("lastVisit") %></td>
                                    </tr>
                                <%  }
                                    } else {
                                %>
                                    <tr>
                                        <td colspan="6" style="text-align: center; color: var(--text-light);">No guests found.</td>
                                    </tr>
                                <%  }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- CARD VIEW -->
                <div id="cardView" class="tab-content">
                    <%
                        if (guestSummary != null && !guestSummary.isEmpty()) {
                            for (Map<String, Object> g : guestSummary) {
                                int visits = (Integer) g.get("visits");
                                String badge = visits >= 5 ? "badge-loyal" : visits >= 2 ? "badge-regular" : "badge-new";
                                String badgeText = visits >= 5 ? "Loyal Guest" : visits >= 2 ? "Regular Guest" : "New Guest";
                    %>
                        <div class="guest-card">
                            <div class="guest-card-header">
                                <div>
                                    <div class="guest-card-name"><%= g.get("name") %></div>
                                </div>
                                <span class="guest-card-badge"><%= badgeText %></span>
                            </div>
                            <div class="guest-card-body">
                                <div class="guest-info-row">
                                    <label>📞 Contact</label>
                                    <value><%= g.get("contact") != null ? g.get("contact") : "N/A" %></value>
                                </div>
                                <div class="guest-info-row">
                                    <label>📍 Address</label>
                                    <value><%= g.get("address") != null ? g.get("address") : "N/A" %></value>
                                </div>
                                <div class="guest-info-row">
                                    <label>🏨 Total Visits</label>
                                    <value><%= visits %></value>
                                </div>
                                <div class="guest-info-row">
                                    <label>💰 Total Spent</label>
                                    <value>LKR <%= df.format(g.get("totalSpent")) %></value>
                                </div>
                                <div class="guest-info-row">
                                    <label>📅 Last Visit</label>
                                    <value><%= g.get("lastVisit") %></value>
                                </div>
                            </div>
                        </div>
                    <%  }
                        }
                    %>
                </div>

            </div>

        </div>
    </div>

    <script>
        // Tab switching functionality
        function switchTab(tabName) {
            // Hide all tab contents
            const contents = document.querySelectorAll('.tab-content');
            contents.forEach(content => content.classList.remove('active'));

            // Remove active class from all tabs
            const tabs = document.querySelectorAll('.tab');
            tabs.forEach(tab => tab.classList.remove('active'));

            // Show selected tab
            document.getElementById(tabName).classList.add('active');

            // Mark selected tab as active
            event.target.classList.add('active');
        }

        // Table search/filter functionality
        function filterTable() {
            const input = document.getElementById("tableSearch");
            const filter = input.value.toUpperCase();
            const table = document.getElementById("guestTable");
            const rows = table.getElementsByTagName("tr");

            for (let i = 1; i < rows.length; i++) {
                const cells = rows[i].getElementsByTagName("td");
                let match = false;

                for (let j = 0; j < cells.length; j++) {
                    if (cells[j].textContent.toUpperCase().indexOf(filter) > -1) {
                        match = true;
                        break;
                    }
                }

                rows[i].style.display = match ? "" : "none";
            }
        }

        // View guest profile (placeholder)
        function viewGuestProfile(guestName) {
            alert("View profile for: " + guestName + "\n\nFull guest history, booking details, and preferences would be displayed here.");
        }
    </script>

</body>
</html>

