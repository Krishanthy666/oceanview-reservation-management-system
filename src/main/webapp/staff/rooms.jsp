<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%@ page import="com.oceanview.util.FlashMessageUtil" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Inventory - Ocean View Resort</title>
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
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--bg-white);
            padding: 20px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border-top: 4px solid var(--primary);
            transition: var(--transition);
            text-align: center;
        }
        .stat-card:hover {
            box-shadow: var(--shadow-hover);
            transform: translateY(-2px);
        }
        .stat-card.available { border-top-color: var(--success); }
        .stat-card.occupied { border-top-color: var(--info); }
        .stat-card.maintenance { border-top-color: var(--warning); }

        .stat-card .value {
            font-size: 32px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 5px;
        }
        .stat-card .label { font-size: 13px; color: var(--text-light); text-transform: uppercase; }

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

        /* === FORM STYLES === */
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .form-group {
            flex: 1;
            min-width: 200px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-light);
        }
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 14px;
            transition: var(--transition);
            font-family: inherit;
        }
        .form-control:focus {
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(26,35,126,0.1);
        }

        /* === BUTTONS === */
        .btn {
            padding: 11px 22px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn-primary {
            background: var(--primary);
            color: var(--bg-white);
        }
        .btn-primary:hover {
            background: var(--primary-light);
            box-shadow: var(--shadow);
        }
        .btn-success {
            background: var(--success);
            color: var(--bg-white);
        }
        .btn-success:hover {
            background: #1b5e20;
            box-shadow: var(--shadow);
        }
        .btn-warning {
            background: var(--warning);
            color: var(--bg-white);
        }
        .btn-warning:hover {
            background: #e65100;
        }
        .btn-danger {
            background: var(--danger);
            color: var(--bg-white);
        }
        .btn-danger:hover {
            background: #b71c1c;
        }
        .btn-sm {
            padding: 7px 14px;
            font-size: 12px;
        }

        /* === ALERTS === */
        .alert {
            padding: 16px 20px;
            border-radius: var(--radius);
            margin-bottom: 20px;
            font-size: 14px;
            border-left: 4px solid transparent;
            animation: slideDown 0.3s ease;
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .alert-success {
            background: #e8f5e9;
            color: var(--success);
            border-left-color: var(--success);
        }
        .alert-danger {
            background: #ffebee;
            color: var(--danger);
            border-left-color: var(--danger);
        }
        .alert-info {
            background: #e3f2fd;
            color: var(--info);
            border-left-color: var(--info);
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

        /* === BADGES === */
        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-success {
            background: #e8f5e9;
            color: var(--success);
        }
        .badge-occupied {
            background: #e3f2fd;
            color: var(--info);
        }
        .badge-maintenance {
            background: #fff8e1;
            color: var(--warning);
        }

        /* === ACTION LINKS === */
        .action-links {
            display: flex;
            gap: 8px;
        }
        .action-links a, .action-links button {
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            text-decoration: none;
            cursor: pointer;
            border: 1px solid var(--border-color);
            transition: var(--transition);
            background: var(--bg-white);
        }
        .action-links a:hover, .action-links button:hover {
            background: var(--primary);
            color: var(--bg-white);
            border-color: var(--primary);
        }

        /* === MODAL === */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
            animation: fadeIn 0.3s ease;
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        .modal-content {
            background-color: var(--bg-white);
            margin: 10% auto;
            padding: 30px;
            border-radius: var(--radius);
            box-shadow: var(--shadow-hover);
            width: 90%;
            max-width: 500px;
            animation: slideDown 0.3s ease;
        }
        .modal-header {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 20px;
            color: var(--primary);
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 15px;
        }
        .close-btn {
            color: var(--text-light);
            font-size: 28px;
            font-weight: bold;
            float: right;
            cursor: pointer;
            line-height: 1;
        }
        .close-btn:hover { color: var(--primary); }

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
            <h3>🛏️ Room Inventory Management</h3>
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
                    <div class="value"><%= request.getAttribute("totalRooms") != null ? request.getAttribute("totalRooms") : 0 %></div>
                    <div class="label">Total Rooms</div>
                </div>
                <div class="stat-card available">
                    <div class="value"><%= request.getAttribute("availableRooms") != null ? request.getAttribute("availableRooms") : 0 %></div>
                    <div class="label">Available</div>
                </div>
                <div class="stat-card occupied">
                    <div class="value"><%= request.getAttribute("occupiedRooms") != null ? request.getAttribute("occupiedRooms") : 0 %></div>
                    <div class="label">Occupied</div>
                </div>
                <div class="stat-card maintenance">
                    <div class="value"><%= request.getAttribute("maintenanceRooms") != null ? request.getAttribute("maintenanceRooms") : 0 %></div>
                    <div class="label">Maintenance</div>
                </div>
            </div>

            <!-- ROOMS TABLE -->
            <div class="section-card">
                <div class="section-header">
                    <h3>All Rooms</h3>
                </div>

                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Room Number</th>
                                <th>Type</th>
                                <th>Floor</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<Room> rooms = (List<Room>) request.getAttribute("rooms");
                                if (rooms != null && !rooms.isEmpty()) {
                                    for (Room r : rooms) {
                                        String badgeClass = "AVAILABLE".equals(r.getStatus()) ? "badge-success" :
                                                           "OCCUPIED".equals(r.getStatus()) ? "badge-occupied" : "badge-maintenance";
                            %>
                                <tr>
                                    <td><strong><%= r.getRoomNumber() %></strong></td>
                                    <td><%= r.getTypeName() %></td>
                                    <td><%= r.getFloorNumber() %></td>
                                    <td><span class="badge <%= badgeClass %>"><%= r.getStatus() %></span></td>
                                </tr>
                            <%  }
                                } else {
                            %>
                                <tr>
                                    <td colspan="4" style="text-align: center; color: var(--text-light);">No rooms found.</td>
                                </tr>
                            <%  }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <script>
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
    </script>

</body>
</html>

