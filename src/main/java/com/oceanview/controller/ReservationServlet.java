package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;
import com.oceanview.service.ReportService;
import com.oceanview.util.FlashMessageUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * ACADEMIC NOTE:
 * This Servlet acts as the Coordinator.
 * It coordinates between:
 * 1. The View (JSP) - Getting inputs.
 * 2. The Service (BillingService) - Calculating costs.
 * 3. The DAO (RoomDAO, ReservationDAO) - Checking availability and persisting data.
 */
@WebServlet("/staff/ReservationServlet")
public class ReservationServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Fetch all reservations to display in the table
        req.setAttribute("reservations", reservationDAO.getAllReservations());

        // 2. Fetch room types for the dropdown
        req.setAttribute("roomTypes", roomDAO.getAllRoomTypes());

        // 3. Fetch Dynamic Statistics from Database
        ReportService reportService = new ReportService();
        req.setAttribute("newBookings", reportService.getNewBookingsToday());
        req.setAttribute("checkouts", reportService.getCheckoutsToday());
        req.setAttribute("occupancy", reportService.getOccupancyRate());
        req.setAttribute("revenueMonth", reportService.getRevenueMonth());

        // 4. Forward to dashboard
        req.getRequestDispatcher("dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 1. Get Parameters
            String guestName = req.getParameter("guestName");
            String guestContact = req.getParameter("guestContact");
            String guestAddress = req.getParameter("guestAddress");

            // CRITICAL: Use the specific Room ID selected by the staff from the dropdown
            String roomIdStr = req.getParameter("roomId");
            if (roomIdStr == null || roomIdStr.isEmpty()) {
                FlashMessageUtil.setFlash(req, "danger", "No room selected. Please select an available room.");
                resp.sendRedirect("ReservationServlet");
                return;
            }
            int roomId = Integer.parseInt(roomIdStr);

            String checkInStr = req.getParameter("checkIn");
            String checkOutStr = req.getParameter("checkOut");

            LocalDate checkIn = LocalDate.parse(checkInStr);
            LocalDate checkOut = LocalDate.parse(checkOutStr);

            // 2. Get Current User (Staff)
            HttpSession session = req.getSession();
            User user = (User) session.getAttribute("user");

            // 3. Get pre-calculated total cost from the hidden input (set by JS / PricingAPI)
            BigDecimal totalCost = new BigDecimal(req.getParameter("totalCost"));

            // 4. Create Reservation Object
            Reservation res = new Reservation();
            res.setGuestName(guestName);
            res.setGuestContact(guestContact);
            res.setGuestAddress(guestAddress);
            res.setRoomId(roomId); // Use the specifically selected Room ID
            res.setCheckIn(checkIn);
            res.setCheckOut(checkOut);
            res.setTotalCost(totalCost);
            res.setCreatedBy(user.getUserId());

            // 5. Save to Database
            boolean saved = reservationDAO.addReservation(res);

            if (saved) {
                FlashMessageUtil.setFlash(req, "success", "Booking Confirmed! Room ID " + roomId + " assigned. Total: " + totalCost + " LKR");
            } else {
                FlashMessageUtil.setFlash(req, "danger", "Database error. Could not save reservation.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            FlashMessageUtil.setFlash(req, "danger", "Error: " + e.getMessage());
        }

        resp.sendRedirect("ReservationServlet");
    }
}





