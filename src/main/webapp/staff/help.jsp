<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Help & Guidelines</title>
    <style>
        :root { --primary: #1a237e; --accent: #ffca28; --bg-light: #f4f6f9; }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; height: 100vh; background: var(--bg-light); color: #333; }

        /* SIDEBAR */
        .sidebar { width: 260px; background: var(--primary); color: white; display: flex; flex-direction: column; flex-shrink: 0; box-shadow: 2px 0 5px rgba(0,0,0,0.1); }
        .brand { padding: 25px 20px; border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 10px; }
        .brand h2 { font-size: 18px; font-weight: 700; }
        .brand span { color: var(--accent); }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item { display: flex; align-items: center; padding: 15px 25px; color: rgba(255,255,255,0.8); text-decoration: none; transition: 0.3s; font-size: 14px; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,0.1); color: white; border-left: 4px solid var(--accent); }
        .user-box { padding: 20px; border-top: 1px solid rgba(255,255,255,0.1); background: rgba(0,0,0,0.1); }
        .user-box small { opacity: 0.6; }

        /* MAIN AREA */
        .main-area { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .top-bar { background: white; height: 60px; display: flex; align-items: center; padding: 0 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .content-area { flex: 1; padding: 40px; overflow-y: auto; }
        .content-inner { max-width: 860px; margin: 0 auto; }

        /* HELP CARDS */
        .help-card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.08); margin-bottom: 20px; }
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
        <nav class="nav-menu">
            <a href="<%= request.getContextPath() %>/staff/ReservationServlet" class="nav-item">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/help.jsp" class="nav-item active">❓ Help</a>
        </nav>
        <div class="user-box">
            <small>Logged in as:</small><br>
            <strong><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></strong>
            <div style="margin-top:10px;">
                <a href="<%= request.getContextPath() %>/LogoutServlet" style="color:#ffca28; text-decoration:none; font-size:12px;">Logout</a>
            </div>
        </div>
    </div>

    <!-- MAIN AREA -->
    <div class="main-area">
        <div class="top-bar">
            <h3>Staff User Manual</h3>
        </div>

        <div class="content-area">
            <div class="content-inner">

                <div class="help-card">
                    <h2>📚 1. Creating a New Reservation</h2>
                    <p>The primary role of staff is to manage guest bookings. Follow these steps to create a reservation:</p>
                    <ul class="step-list">
                        <li><strong>Step 1:</strong> Navigate to the <strong>Dashboard</strong>.</li>
                        <li><strong>Step 2:</strong> Fill in the Guest Details (Name, Contact, Address).</li>
                        <li><strong>Step 3:</strong> Select a <strong>Room Type</strong> (e.g., Deluxe).</li>
                        <li><strong>Step 4:</strong> Select <strong>Check-In</strong> and <strong>Check-Out</strong> dates. The system will automatically calculate the price.</li>
                        <li><strong>Step 5:</strong> Select an <strong>Available Room</strong> from the dropdown. (Rooms marked "Booked" are disabled).</li>
                        <li><strong>Step 6:</strong> Click <strong>Confirm Booking</strong>.</li>
                    </ul>
                </div>

                <div class="help-card">
                    <h2>📄 2. Printing Invoices</h2>
                    <p>To generate a professional PDF invoice for a guest:</p>
                    <ul class="step-list">
                        <li><strong>Step 1:</strong> Locate the booking in the "Recent Reservations" table on the Dashboard.</li>
                        <li><strong>Step 2:</strong> Click the <strong>Download Invoice</strong> link in the Action column.</li>
                        <li><strong>Step 3:</strong> A PDF file will be generated automatically. Save or print this file for the guest.</li>
                    </ul>
                </div>

            </div>
        </div>
    </div>

</body>
</html>




