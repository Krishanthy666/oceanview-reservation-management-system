<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.oceanview.dao.RoomDAO" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>Phase 3 Test: API Client</title>
    <style>
        body { font-family: sans-serif; padding: 20px; }
        .card { border: 1px solid #ccc; padding: 20px; border-radius: 8px; margin-top: 20px; background: #fff; }
        input, select { padding: 8px; margin: 5px; }
        button { padding: 10px 20px; background: navy; color: white; border: none; cursor: pointer; }
        button:hover { background: darkblue; }
        #result { margin-top: 15px; font-weight: bold; color: green; }
        #error { margin-top: 15px; font-weight: bold; color: red; }
    </style>
</head>
<body>

    <h2>Phase 3: Web Service Test (AJAX)</h2>
    <p>Testing the distributed pricing engine.</p>

    <div class="card">
        <h3>Booking Calculator</h3>

        <label>Room Type:</label>
        <select id="roomType">
            <%
                RoomDAO dao = new RoomDAO();
                List<RoomType> types = dao.getAllRoomTypes();
                for (RoomType rt : types) {
                    out.println("<option value='" + rt.getTypeId() + "'>" + rt.getTypeName() + " (" + rt.getBaseRate() + ")</option>");
                }
            %>
        </select>
        <br><br>

        <label>Check In:</label>
        <input type="date" id="checkIn" value="2025-03-01">
        <br>

        <label>Check Out:</label>
        <input type="date" id="checkOut" value="2025-03-05">
        <br><br>

        <button type="button" onclick="calculatePrice()">Fetch Price (API Call)</button>

        <div id="result"></div>
        <div id="error"></div>
    </div>

    <script>
        function calculatePrice() {
            // Clear previous messages
            document.getElementById("result").innerHTML = "";
            document.getElementById("error").innerHTML = "";

            var typeId = document.getElementById("roomType").value;
            var checkIn = document.getElementById("checkIn").value;
            var checkOut = document.getElementById("checkOut").value;

            // Construct API URL
            var url = '/api/pricing?typeId=' + typeId + '&checkIn=' + checkIn + '&checkOut=' + checkOut;

            // Native Javascript Fetch API (No JQuery)
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        document.getElementById("error").innerText = "Error: " + data.error;
                    } else {
                        var html = "<h4>Quote Calculated:</h4>" +
                                   "<ul>" +
                                   "<li>Nights: " + data.nights + "</li>" +
                                   "<li>Base Cost: " + data.baseCost + "</li>" +
                                   "<li>Service Charge: " + data.serviceCharge + "</li>" +
                                   "<li>Tax: " + data.tax + "</li>" +
                                   "<li><strong>Total: " + data.total + "</strong></li>" +
                                   "</ul>";
                        document.getElementById("result").innerHTML = html;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById("error").innerText = "Failed to connect to API.";
                });
        }
    </script>
</body>
</html>

