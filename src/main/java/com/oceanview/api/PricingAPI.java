package com.oceanview.api;

import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import com.oceanview.service.BillingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * ACADEMIC NOTE:
 * This is a RESTful Endpoint.
 * It returns JSON data, allowing the frontend (JSP/JS) to be decoupled from the backend.
 * This satisfies the "Distributed Application" requirement.
 *
 * URL: /api/pricing?typeId=1&checkIn=2025-01-01&checkOut=2025-01-05
 *
 * Response now includes pricing breakdown AND room availability list so the
 * frontend can populate a specific room assignment dropdown in a single request.
 */
@WebServlet("/api/pricing")
public class PricingAPI extends HttpServlet {

    private BillingService billingService = new BillingService();
    private RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Set response type to JSON
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        PrintWriter out = resp.getWriter();

        try {
            // 2. Get Parameters
            String typeIdStr = req.getParameter("typeId");
            String checkInStr = req.getParameter("checkIn");
            String checkOutStr = req.getParameter("checkOut");

            // 3. Validate Input
            if (typeIdStr == null || checkInStr == null || checkOutStr == null) {
                out.print("{\"error\": \"Missing parameters\"}");
                return;
            }

            int typeId = Integer.parseInt(typeIdStr);
            LocalDate checkIn = LocalDate.parse(checkInStr);
            LocalDate checkOut = LocalDate.parse(checkOutStr);

            // 4. Get Rate from Database (Simulating Remote Service Call)
            BigDecimal baseRate = BigDecimal.ZERO;
            for (RoomType rt : roomDAO.getAllRoomTypes()) {
                if (rt.getTypeId() == typeId) {
                    baseRate = rt.getBaseRate();
                    break;
                }
            }

            // 5. Calculate billing
            BillingService.BillingResult result = billingService.calculateBilling(checkIn, checkOut, baseRate);

            if (result == null) {
                out.print("{\"error\": \"Invalid date range\"}");
                return;
            }

            // 6. Get Room Availability
            // getAllRooms of this type (includes booked/maintenance rooms)
            List<Room> allRooms = roomDAO.getRoomsByType(typeId);

            // getAvailableRooms returns only rooms free for these dates AND not under maintenance
            List<Room> availableRooms = roomDAO.getAvailableRooms(typeId, checkInStr, checkOutStr);

            // Build a Set of available room IDs for O(1) lookup
            Set<Integer> availableIds = new HashSet<>();
            for (Room r : availableRooms) {
                availableIds.add(r.getRoomId());
            }

            // 7. Build JSON Manually (No external libraries needed)
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"nights\": ").append(result.nights).append(", ");
            json.append("\"baseCost\": ").append(result.baseCost).append(", ");
            json.append("\"serviceCharge\": ").append(result.serviceCharge).append(", ");
            json.append("\"tax\": ").append(result.tax).append(", ");
            json.append("\"total\": ").append(result.total).append(", ");

            // Build Rooms Array
            json.append("\"rooms\": [");
            boolean first = true;
            for (Room r : allRooms) {
                if (!first) json.append(", ");

                // A room is available only if it appears in availableRooms list
                // (that query already excludes UNDER_MAINTENANCE and confirmed overlapping bookings)
                boolean isAvailable = availableIds.contains(r.getRoomId());

                json.append("{");
                json.append("\"id\": ").append(r.getRoomId()).append(", ");
                json.append("\"number\": \"").append(r.getRoomNumber()).append("\", ");
                json.append("\"available\": ").append(isAvailable);
                json.append("}");
                first = false;
            }
            json.append("]");
            json.append("}");

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\": \"Server error: " + e.getMessage() + "\"}");
        }
    }
}

