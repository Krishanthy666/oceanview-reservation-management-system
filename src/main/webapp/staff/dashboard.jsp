<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%@ page import="com.oceanview.util.FlashMessageUtil" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort - Staff Portal</title>
    <style>
        /* --- CSS VARIABLES (Design System) --- */
        :root {
            --primary: #1a237e; /* Deep Blue */
            --primary-light: #534bae;
            --accent: #ffca28; /* Amber */
            --bg-light: #f4f6f9;
            --text-dark: #333;
            --text-light: #666;
            --white: #ffffff;
            --shadow: 0 4px 6px rgba(0,0,0,0.1);
            --radius: 8px;
        }

        /* --- RESET & LAYOUT --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; height: 100vh; background: var(--bg-light); color: var(--text-dark); }

        /* --- SIDEBAR --- */
        .sidebar {
            width: 260px;
            background: var(--primary);
            color: var(--white);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
        }
        .brand {
            padding: 25px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .brand h2 { font-size: 18px; font-weight: 700; letter-spacing: 0.5px; }
        .brand span { color: var(--accent); }

        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            transition: 0.3s;
            font-size: 14px;
        }
        .nav-item:hover, .nav-item.active {
            background: rgba(255,255,255,0.1);
            color: var(--white);
            border-left: 4px solid var(--accent);
        }

        .user-box {
            padding: 20px;
            border-top: 1px solid rgba(255,255,255,0.1);
            background: rgba(0,0,0,0.1);
        }
        .user-box small { opacity: 0.6; }

        /* --- MAIN CONTENT --- */
        .main-area { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

        .top-bar {
            background: var(--white);
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 30px;
            box-shadow: var(--shadow);
            z-index: 10;
        }
        .search-bar { display: flex; gap: 10px; }
        .search-bar input { padding: 8px 15px; border: 1px solid #ddd; border-radius: 20px; width: 250px; }

        .content-area { flex: 1; padding: 30px; overflow-y: auto; }

        /* --- CARDS & GRID --- */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: var(--white);
            padding: 20px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border-left: 4px solid var(--primary);
        }
        .stat-card h3 { font-size: 28px; color: var(--primary); margin-bottom: 5px; }
        .stat-card p { font-size: 13px; color: var(--text-light); text-transform: uppercase; }

        /* --- FORM & SECTIONS --- */
        .section-card {
            background: var(--white);
            padding: 25px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 30px;
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        .section-header h3 { font-size: 16px; color: var(--primary); }

        /* Form Styles */
        .form-row { display: flex; gap: 20px; margin-bottom: 15px; }
        .form-group { flex: 1; }
        .form-group label { display: block; margin-bottom: 6px; font-size: 13px; font-weight: 600; color: var(--text-light); }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; transition: 0.3s; }
        .form-control:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(26,35,126,0.1); }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: 0.2s;
        }
        .btn-primary { background: var(--primary); color: var(--white); }
        .btn-primary:hover { background: var(--primary-light); }
        .btn-success { background: #2e7d32; color: var(--white); }
        .btn-success:hover { background: #1b5e20; }

        /* --- TABLE --- */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; font-size: 13px; }
        .data-table th { background: #f8f9fa; color: var(--text-light); font-weight: 600; text-transform: uppercase; }
        .data-table tr:hover { background: #fafafa; }

        .badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-success { background: #e8f5e9; color: #2e7d32; }
        .badge-warning { background: #fff8e1; color: #f57f17; }

        /* --- ALERTS --- */
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; }
        .alert-danger { background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; }
        .alert-success { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }

        /* Quote Preview Box */
        #quotePreview {
            background: #e3f2fd;
            border: 1px solid #bbdefb;
            padding: 15px;
            border-radius: 4px;
            margin-top: 10px;
            display: none;
        }
        #quotePreview strong { color: var(--primary); }

    </style>

    <script>
        // Load Room Types Data for JS
        const roomTypesData = {};
        <%
            // Safe retrieval with null check
            List<RoomType> types = (List<RoomType>) request.getAttribute("roomTypes");
            if (types != null) {
                for (RoomType rt : types) {
                    out.println("roomTypesData[" + rt.getTypeId() + "] = { rate: " + rt.getBaseRate() + " };");
                }
            }
        %>
    </script>
</head>
<body>

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="brand">
            <div>🌊</div>
            <h2>Ocean <span>View</span></h2>
        </div>

        <nav class="nav-menu">
            <a href="<%= request.getContextPath() %>/staff/ReservationServlet" class="nav-item active">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/help.jsp" class="nav-item">❓ Help</a>
        </nav>

        <div class="user-box">
            <small>Logged in as:</small><br>
            <!-- FIXED: Using Java scriptlet for safe session access -->
            <strong><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></strong>
            <div style="margin-top:10px;">
                <a href="<%= request.getContextPath() %>/LogoutServlet" style="color:#ffca28; text-decoration:none; font-size:12px;">Logout</a>
            </div>
        </div>
    </div>

    <!-- MAIN AREA -->
    <div class="main-area">

        <!-- Top Bar -->
        <div class="top-bar">
            <h3>Front Desk Overview</h3>
            <div class="search-bar">
                <input type="text" placeholder="Search reservations..." class="form-control">
                <button class="btn btn-primary">Search</button>
            </div>
        </div>

        <!-- Content -->
        <div class="content-area">

            <!-- Flash Messages -->
            <%
                String[] flash = FlashMessageUtil.getAndClearFlash(request);
                if (flash != null) {
                    String alertClass = "danger".equals(flash[0]) ? "alert-danger" : "alert-success";
                    out.println("<div class='alert " + alertClass + "'>" + flash[1] + "</div>");
                }
            %>

            <!-- Stats Cards (NOW DYNAMIC - FETCHED FROM DATABASE) -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3><%= request.getAttribute("newBookings") != null ? request.getAttribute("newBookings") : 0 %></h3>
                    <p>New Bookings</p>
                </div>
                <div class="stat-card">
                    <h3><%= request.getAttribute("checkouts") != null ? request.getAttribute("checkouts") : 0 %></h3>
                    <p>Check-outs Today</p>
                </div>
                <div class="stat-card">
                    <h3><%= request.getAttribute("occupancy") != null ? String.format("%.0f", request.getAttribute("occupancy")) : 0 %>%</h3>
                    <p>Occupancy Rate</p>
                </div>
                <div class="stat-card">
                    <h3><%= request.getAttribute("revenueMonth") != null ? request.getAttribute("revenueMonth") : "0" %> LKR</h3>
                    <p>Revenue This Month</p>
                </div>
            </div>

            <!-- New Reservation Form -->
            <div class="section-card">
                <div class="section-header">
                    <h3>New Reservation</h3>
                    <span style="color:#999; font-size:12px;">* Fields required</span>
                </div>

                <form action="ReservationServlet" method="post" onsubmit="return validateForm()">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Guest Name *</label>
                            <input type="text" name="guestName" class="form-control" placeholder="John Doe" required>
                        </div>
                        <div class="form-group">
                            <label>Contact Number *</label>
                            <input type="text" name="guestContact" class="form-control" placeholder="+94 77 123 4567" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Address</label>
                        <input type="text" name="guestAddress" class="form-control" placeholder="123 Beach Road, Galle">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Room Type *</label>
                            <select name="roomType" id="roomType" class="form-control" required onchange="calculateQuote()">
                                <option value="">Select Room Category</option>
                                <%
                                    if (types != null) {
                                        for (RoomType rt : types) {
                                %>
                                    <option value="<%= rt.getTypeId() %>">
                                        <%= rt.getTypeName() %> - <%= rt.getBaseRate() %> LKR/night
                                    </option>
                                <%      }
                                    }
                                %>
                            </select>
                        </div>

                        <!-- Room Assignment Dropdown: populated dynamically by JS after API call -->
                        <div class="form-group">
                            <label>Assign Room *</label>
                            <select name="roomId" id="roomId" class="form-control" required>
                                <option value="">Select dates &amp; room type first...</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Check In *</label>
                            <input type="date" name="checkIn" id="checkIn" class="form-control" required onchange="calculateQuote()">
                        </div>
                        <div class="form-group">
                            <label>Check Out *</label>
                            <input type="date" name="checkOut" id="checkOut" class="form-control" required onchange="calculateQuote()">
                        </div>
                    </div>

                    <!-- Dynamic Quote Preview -->
                    <div id="quotePreview">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <div>
                                <strong>Estimated Total:</strong> <span id="quoteText">0.00 LKR</span><br>
                                <small style="color:#666;" id="nightsText"></small>
                            </div>
                            <input type="hidden" name="totalCost" id="totalCostInput">
                        </div>
                    </div>
                    <br>

                    <button type="submit" class="btn btn-success">Confirm Booking</button>
                </form>
            </div>

            <!-- Reservations Table -->
            <div class="section-card">
                <div class="section-header">
                    <h3>Recent Reservations</h3>
                    <button class="btn btn-primary" style="padding:5px 10px; font-size:12px;">Export PDF</button>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Guest Name</th>
                            <th>Room</th>
                            <th>Check In</th>
                            <th>Check Out</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Reservation> list = (List<Reservation>) request.getAttribute("reservations");
                            if (list != null && !list.isEmpty()) {
                                for (Reservation r : list) {
                        %>
                            <tr>
                                <td>#<%= r.getReservationId() %></td>
                                <td><%= r.getGuestName() %></td>
                                <td><strong><%= r.getRoomNumber() %></strong></td>
                                <td><%= r.getCheckIn() %></td>
                                <td><%= r.getCheckOut() %></td>
                                <td><%= r.getTotalCost() %> LKR</td>
                                <td><span class="badge badge-success"><%= r.getStatus() %></span></td>
                                <td>
                    <a href="<%= request.getContextPath() %>/staff/InvoiceServlet?id=<%= r.getReservationId() %>"
                       target="_blank"
                       title="Download PDF Invoice for this reservation"
                       style="display:inline-flex; align-items:center; gap:4px;
                              background:var(--primary); color:#fff;
                              padding:5px 10px; border-radius:4px;
                              font-size:11px; font-weight:600;
                              text-decoration:none; transition:0.2s;"
                       onmouseover="this.style.background='var(--primary-light)'"
                       onmouseout="this.style.background='var(--primary)'">
                        &#128196; Invoice
                    </a>
                </td>
                            </tr>
                        <%      }
                            } else {
                        %>
                            <tr>
                                <td colspan="8" style="text-align:center; color:#999;">No reservations found.</td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

        </div>
    </div>

    <script>
        // 1. Set default dates
        const today = new Date().toISOString().split('T')[0];
        document.getElementById("checkIn").value = today;
        // Default checkout to tomorrow
        let tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        document.getElementById("checkOut").value = tomorrow.toISOString().split('T')[0];

        // 2. API Call Function — fetches pricing AND room availability in one request
        function calculateQuote() {
            var typeId = document.getElementById("roomType").value;
            var checkIn = document.getElementById("checkIn").value;
            var checkOut = document.getElementById("checkOut").value;

            // Reset room dropdown while we wait
            var roomSelect = document.getElementById("roomId");
            roomSelect.innerHTML = "<option value=''>Loading rooms...</option>";

            if (typeId && checkIn && checkOut) {
                fetch('/api/pricing?typeId=' + typeId + '&checkIn=' + checkIn + '&checkOut=' + checkOut)
                    .then(response => response.json())
                    .then(data => {
                        if (data.error) {
                            alert(data.error);
                            roomSelect.innerHTML = "<option value=''>Error loading rooms</option>";
                            return;
                        }

                        // Update Quote Preview
                        document.getElementById("quoteText").innerText = data.total.toLocaleString() + " LKR";
                        document.getElementById("nightsText").innerText = data.nights + " Night(s) | Tax & Service Included";
                        document.getElementById("totalCostInput").value = data.total;
                        document.getElementById("quotePreview").style.display = 'block';

                        // Populate Room Dropdown
                        roomSelect.innerHTML = ""; // Clear loading placeholder
                        var hasAvailable = false;

                        if (data.rooms && data.rooms.length > 0) {
                            data.rooms.forEach(function(room) {
                                var option = document.createElement("option");
                                option.value = room.id;

                                if (room.available) {
                                    option.text = "Room " + room.number + " - Available ✓";
                                    option.style.color = "green";
                                    hasAvailable = true;
                                } else {
                                    option.text = "Room " + room.number + " - Booked / Maintenance";
                                    option.disabled = true;
                                    option.style.color = "red";
                                }
                                roomSelect.appendChild(option);
                            });
                        }

                        // If no rooms at all are available, show a placeholder message
                        if (!hasAvailable) {
                            var noOption = document.createElement("option");
                            noOption.value = "";
                            noOption.text = "No rooms available for these dates";
                            noOption.disabled = true;
                            noOption.selected = true;
                            roomSelect.insertBefore(noOption, roomSelect.firstChild);
                        }
                    })
                    .catch(function(err) {
                        console.error("API error:", err);
                        roomSelect.innerHTML = "<option value=''>Error loading rooms</option>";
                    });
            } else {
                roomSelect.innerHTML = "<option value=''>Select dates &amp; room type first...</option>";
            }
        }

        function validateForm() {
            var inDate = new Date(document.getElementById("checkIn").value);
            var outDate = new Date(document.getElementById("checkOut").value);

            if (outDate <= inDate) {
                alert("Error: Check-out date must be after check-in date.");
                return false;
            }

            // Ensure a specific room has been chosen from the dropdown
            var roomSelect = document.getElementById("roomId");
            if (!roomSelect.value) {
                alert("Please select an available room from the 'Assign Room' dropdown.");
                return false;
            }

            return true;
        }
    </script>
</body>
</html>

