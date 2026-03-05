<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Business Reports - Ocean View Resort</title>
    <style>
        /* === CSS VARIABLES (Design System — mirrors rooms.jsp / guests.jsp) === */
        :root {
            --primary:       #1a237e;
            --primary-light: #534bae;
            --primary-dark:  #0d1854;
            --accent:        #ffca28;
            --accent-dark:   #ffa000;
            --success:       #2e7d32;
            --warning:       #f57f17;
            --danger:        #d32f2f;
            --info:          #0288d1;
            --bg-light:      #f4f6f9;
            --bg-white:      #ffffff;
            --text-dark:     #333;
            --text-light:    #666;
            --border-color:  #e0e0e0;
            --shadow:        0 4px 6px rgba(0,0,0,0.1);
            --shadow-hover:  0 8px 12px rgba(0,0,0,0.15);
            --radius:        8px;
            --transition:    0.3s ease;
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
            flex-shrink: 0;
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
        .top-bar-right { font-size: 13px; color: var(--text-light); }

        .content-area {
            flex: 1;
            padding: 30px;
            overflow-y: auto;
            background: var(--bg-light);
        }

        /* === KPI SUMMARY CARDS === */
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
        .stat-card:hover { box-shadow: var(--shadow-hover); transform: translateY(-2px); }
        .stat-card.success  { border-top-color: var(--success); }
        .stat-card.warning  { border-top-color: var(--warning); }
        .stat-card.info     { border-top-color: var(--info);    }
        .stat-card.danger   { border-top-color: var(--danger);  }
        .stat-card .icon    { font-size: 28px; margin-bottom: 10px; }
        .stat-card .value   { font-size: 28px; font-weight: 700; color: var(--primary); margin-bottom: 4px; }
        .stat-card .label   { font-size: 12px; color: var(--text-light); text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-card .sub     { font-size: 11px; color: var(--text-light); margin-top: 4px; }

        /* === SECTION CARDS (charts / tables) === */
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
        .section-header h3 { font-size: 18px; color: var(--primary); font-weight: 600; }
        .section-header small { color: var(--text-light); font-size: 12px; }

        /* === CHART GRID === */
        .chart-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        .chart-wrapper {
            position: relative;
        }
        /* Pure CSS bar chart */
        .bar-chart { display: flex; align-items: flex-end; gap: 6px; height: 220px; padding-top: 10px; }
        .bar-group { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; height: 100%; justify-content: flex-end; }
        .bar {
            width: 100%;
            background: linear-gradient(to top, var(--primary), var(--primary-light));
            border-radius: 4px 4px 0 0;
            min-height: 4px;
            transition: var(--transition);
            position: relative;
            cursor: pointer;
        }
        .bar:hover { background: linear-gradient(to top, var(--accent-dark), var(--accent)); }
        .bar .tooltip {
            display: none;
            position: absolute;
            top: -32px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--primary-dark);
            color: white;
            font-size: 10px;
            padding: 3px 6px;
            border-radius: 4px;
            white-space: nowrap;
            z-index: 10;
        }
        .bar:hover .tooltip { display: block; }
        .bar-label { font-size: 9px; color: var(--text-light); margin-top: 4px; text-align: center; }

        /* Donut / Pie chart (CSS only) */
        .donut-wrapper { display: flex; flex-direction: column; align-items: center; gap: 20px; }
        .donut-container { position: relative; width: 180px; height: 180px; }
        .donut-svg { width: 100%; height: 100%; }
        .donut-label {
            position: absolute;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
        }
        .donut-label strong { font-size: 22px; color: var(--primary); display: block; }
        .donut-label small  { font-size: 10px; color: var(--text-light); text-transform: uppercase; }

        .legend { width: 100%; }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
            font-size: 13px;
        }
        .legend-dot { width: 12px; height: 12px; border-radius: 50%; flex-shrink: 0; }
        .legend-name { flex: 1; color: var(--text-dark); }
        .legend-count { font-weight: 600; color: var(--primary); }
        .legend-pct { color: var(--text-light); font-size: 11px; }

        /* === TOP EARNERS TABLE === */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; font-size: 13px; }
        .data-table th { background: #f8f9fa; color: var(--text-light); font-weight: 600; text-transform: uppercase; font-size: 11px; letter-spacing: 0.5px; }
        .data-table tr:hover td { background: #fafbff; }
        .rank-badge { display: inline-flex; align-items: center; justify-content: center; width: 26px; height: 26px; border-radius: 50%; font-size: 12px; font-weight: 700; }
        .rank-1 { background: #FFD700; color: #5a4800; }
        .rank-2 { background: #C0C0C0; color: #444; }
        .rank-3 { background: #CD7F32; color: #fff; }
        .rank-n { background: #eee; color: #666; }

        .progress-bar-bg { background: #eee; border-radius: 4px; height: 6px; overflow: hidden; margin-top: 4px; }
        .progress-bar    { height: 100%; border-radius: 4px; background: linear-gradient(to right, var(--primary), var(--primary-light)); }

        /* === INSIGHT CALLOUT === */
        .insight-box {
            background: linear-gradient(135deg, #e8eaf6 0%, #f3e5f5 100%);
            border-left: 4px solid var(--primary);
            border-radius: var(--radius);
            padding: 18px 22px;
            margin-bottom: 30px;
            font-size: 13px;
            color: var(--text-dark);
        }
        .insight-box strong { color: var(--primary); }
    </style>
</head>
<body>

<!-- ═══════════════════════════ SIDEBAR ═══════════════════════════ -->
<div class="sidebar">
    <div class="brand">
        <div class="brand-icon">🌊</div>
        <div><h2>Ocean <span>View</span></h2></div>
    </div>

    <nav class="nav-menu">
        <a href="<%= request.getContextPath() %>/admin/DashboardServlet" class="nav-item">📊 Dashboard</a>
        <a href="<%= request.getContextPath() %>/staff/ReportServlet"    class="nav-item active">📈 Reports</a>
        <a href="<%= request.getContextPath() %>/admin/help.jsp"         class="nav-item">❓ Help</a>
    </nav>

    <div class="user-box">
        <small>Logged in as:</small>
        <strong><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></strong>
        <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
    </div>
</div>

<!-- ═══════════════════════════ MAIN ══════════════════════════════ -->
<div class="main-area">

    <!-- TOP BAR -->
    <div class="top-bar">
        <h3>📈 Business Intelligence Reports</h3>
        <div class="top-bar-right">Year: <strong><%= request.getAttribute("currentYear") %></strong></div>
    </div>

    <!-- CONTENT -->
    <div class="content-area">

        <%-- ── PARSE ALL DATA AT TOP — avoids duplicate variable errors in Jasper ── --%>
        <%
            Object rev   = request.getAttribute("totalRevenue");
            Object books = request.getAttribute("totalBookings");
            Object avg   = request.getAttribute("avgValue");
            Object canc  = request.getAttribute("cancelled");

            // ── Bar chart data ──────────────────────────────────────────────
            String rawTotals = (String) request.getAttribute("chartTotals");
            double[] vals = new double[12];
            double maxVal = 1;
            if (rawTotals != null) {
                String inner = rawTotals.replaceAll("[\\[\\]]", "").trim();
                if (!inner.isEmpty()) {
                    String[] parts = inner.split(",");
                    for (int mi = 0; mi < parts.length && mi < 12; mi++) {
                        try { vals[mi] = Double.parseDouble(parts[mi].trim()); } catch (Exception ignore) {}
                        if (vals[mi] > maxVal) maxVal = vals[mi];
                    }
                }
            }
            String[] shortMonths = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

            // ── Donut / table data ──────────────────────────────────────────
            String rawLabels = (String) request.getAttribute("roomLabels");
            String rawCounts = (String) request.getAttribute("roomCounts");
            String[] roomNames = new String[0];
            int[]    roomCnts  = new int[0];
            int      totalRooms = 0;
            if (rawLabels != null && rawCounts != null) {
                String lblInner = rawLabels.replaceAll("[\\[\\]']", "").trim();
                String cntInner = rawCounts.replaceAll("[\\[\\]]", "").trim();
                if (!lblInner.isEmpty()) {
                    roomNames = lblInner.split(",");
                    String[] cntParts = cntInner.split(",");
                    roomCnts = new int[roomNames.length];
                    for (int ri = 0; ri < roomNames.length; ri++) {
                        try { roomCnts[ri] = Integer.parseInt(cntParts[ri].trim()); } catch (Exception ignore) {}
                        totalRooms += roomCnts[ri];
                    }
                }
            }
            String[] palette = {"#1a237e","#534bae","#ffca28","#0288d1","#2e7d32","#d32f2f"};
            double circ = 2 * Math.PI * 70;
        %>
        <div class="insight-box">
            💡 <strong>Year-at-a-Glance:</strong> &nbsp;
            This year Ocean View recorded <strong><%= books %> bookings</strong> generating
            <strong>LKR <%= rev %></strong> in revenue
            (average stay value: <strong>LKR <%= avg %></strong>).
            <%= canc %> reservation<%= ((Integer)canc == 1 ? "" : "s") %> were cancelled.
        </div>

        <%-- ── KPI SUMMARY CARDS ─────────────────────────────────────────── --%>
        <div class="stats-grid">
            <div class="stat-card success">
                <div class="icon">🎟️</div>
                <div class="value"><%= books %></div>
                <div class="label">Total Bookings</div>
                <div class="sub">Current year</div>
            </div>
            <div class="stat-card info">
                <div class="icon">💰</div>
                <div class="value">LKR <%= rev %></div>
                <div class="label">Total Revenue</div>
                <div class="sub">Current year</div>
            </div>
            <div class="stat-card">
                <div class="icon">📋</div>
                <div class="value">LKR <%= avg %></div>
                <div class="label">Avg Booking Value</div>
                <div class="sub">Per reservation</div>
            </div>
            <div class="stat-card danger">
                <div class="icon">❌</div>
                <div class="value"><%= canc %></div>
                <div class="label">Cancellations</div>
                <div class="sub">Current year</div>
            </div>
        </div>

        <%-- ── CHARTS ROW ─────────────────────────────────────────────────── --%>
        <div class="chart-grid">

            <%-- BAR CHART — Monthly Revenue -%>
            <div class="section-card" style="padding-bottom:20px;">
                <div class="section-header">
                    <h3>📊 Monthly Revenue Trend</h3>
                    <small>LKR · <%= request.getAttribute("currentYear") %></small>
                </div>
                <div class="chart-wrapper">
                    <div class="bar-chart">
                        <% for (int mi = 0; mi < 12; mi++) {
                               int heightPct = (int) Math.round((vals[mi] / maxVal) * 200);
                               if (heightPct < 4 && vals[mi] == 0) heightPct = 4;
                               String barFmt = String.format("%,.0f", vals[mi]);
                        %>
                        <div class="bar-group">
                            <div class="bar" style="height: <%= heightPct %>px;">
                                <span class="tooltip">LKR <%= barFmt %></span>
                            </div>
                            <div class="bar-label"><%= shortMonths[mi] %></div>
                        </div>
                        <% } %>
                    </div>
                </div>
                <div style="margin-top:12px; font-size:11px; color:var(--text-light); text-align:center;">
                    Hover a bar to see the exact revenue figure
                </div>
            </div>

            <%-- DONUT / PIE CHART — Room Type Popularity -%>
            <div class="section-card">
                <div class="section-header">
                    <h3>🛏️ Room Type Popularity</h3>
                    <small>All-time bookings</small>
                </div>
                <%
                    // SVG donut: r=70, cx=cy=90
                %>

                <div class="donut-wrapper">
                    <% if (totalRooms == 0) { %>
                        <div style="color:var(--text-light); font-size:13px; padding:40px 0; text-align:center;">
                            No booking data available yet.
                        </div>
                    <% } else { %>
                        <div class="donut-container">
                            <svg class="donut-svg" viewBox="0 0 180 180">
                                <circle cx="90" cy="90" r="70" fill="none" stroke="#eee" stroke-width="28"/>
                                <%
                                    double runningOffset = 0;
                                    for (int di = 0; di < roomNames.length; di++) {
                                        double pctD   = (double) roomCnts[di] / totalRooms;
                                        double dash   = pctD * circ;
                                        double gap    = circ - dash;
                                        String colD   = palette[di % palette.length];
                                        double rotate = -90 + (runningOffset / circ) * 360;
                                        runningOffset += dash;
                                %>
                                <circle cx="90" cy="90" r="70"
                                        fill="none"
                                        stroke="<%= colD %>"
                                        stroke-width="28"
                                        stroke-dasharray="<%= String.format("%.2f",dash) %> <%= String.format("%.2f",gap) %>"
                                        stroke-dashoffset="0"
                                        transform="rotate(<%= String.format("%.2f", rotate) %> 90 90)"/>
                                <% } %>
                            </svg>
                            <div class="donut-label">
                                <strong><%= totalRooms %></strong>
                                <small>bookings</small>
                            </div>
                        </div>

                        <div class="legend">
                            <% for (int li = 0; li < roomNames.length; li++) {
                                   double pctL  = totalRooms > 0 ? (double) roomCnts[li] * 100 / totalRooms : 0;
                                   String colL  = palette[li % palette.length];
                            %>
                            <div class="legend-item">
                                <div class="legend-dot" style="background:<%= colL %>"></div>
                                <span class="legend-name"><%= roomNames[li].trim() %></span>
                                <span class="legend-count"><%= roomCnts[li] %></span>
                                <span class="legend-pct">(<%= String.format("%.0f", pctL) %>%)</span>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div><%-- end chart-grid --%>

        <%-- ── ROOM PERFORMANCE TABLE ──────────────────────────────────────── --%>
        <div class="section-card">
            <div class="section-header">
                <h3>🏆 Room Type Performance Ranking</h3>
                <small>Sorted by booking volume</small>
            </div>
            <% if (roomNames.length == 0) { %>
                <p style="color:var(--text-light); font-size:13px;">No data available.</p>
            <% } else { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Room Type</th>
                        <th>Bookings</th>
                        <th>Share</th>
                        <th>Visual Share</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (int pi = 0; pi < roomNames.length; pi++) {
                           double pctP   = totalRooms > 0 ? (double) roomCnts[pi] * 100 / totalRooms : 0;
                           String rankP  = pi == 0 ? "rank-1" : (pi == 1 ? "rank-2" : (pi == 2 ? "rank-3" : "rank-n"));
                           String colP   = palette[pi % palette.length];
                    %>
                    <tr>
                        <td><span class="rank-badge <%= rankP %>"><%= pi + 1 %></span></td>
                        <td><strong><%= roomNames[pi].trim() %></strong></td>
                        <td><strong><%= roomCnts[pi] %></strong></td>
                        <td><%= String.format("%.1f", pctP) %>%</td>
                        <td style="width:200px;">
                            <div class="progress-bar-bg">
                                <div class="progress-bar" style="width:<%= String.format("%.0f",pctP) %>%; background:<%= colP %>;"></div>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>

    </div><%-- end content-area --%>
</div><%-- end main-area --%>

</body>
</html>

