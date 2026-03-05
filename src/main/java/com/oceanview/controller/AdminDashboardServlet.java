package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.UserDAO;
import com.oceanview.service.ReportService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;

/**
 * ACADEMIC NOTE:
 * AdminDashboardServlet serves the executive/management overview.
 *
 * Separation of Concerns:
 *   - Staff portal (/staff/*) → operational day-to-day views.
 *   - Admin portal (/admin/*) → high-level KPI and management views.
 *
 * This servlet collects:
 *   1. Room inventory stats (total, occupied, available, maintenance).
 *   2. Revenue today.
 *   3. Staff headcount.
 *   4. Recent reservations for activity feed.
 *
 * Security: Already guarded by SecurityFilter — only ADMIN role reaches here.
 */
@WebServlet("/admin/DashboardServlet")
public class AdminDashboardServlet extends HttpServlet {

    private final ReportService    reportService    = new ReportService();
    private final ReservationDAO   reservationDAO   = new ReservationDAO();
    private final UserDAO          userDAO          = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── 1. ROOM INVENTORY STATS ──────────────────────────────────────────
        int totalRooms       = reportService.getTotalRooms();
        int occupiedRooms    = reportService.getOccupiedRooms();
        int maintenanceRooms = reportService.getMaintenanceRooms();
        int availableRooms   = reportService.getAvailableRooms();

        req.setAttribute("totalRooms",       totalRooms);
        req.setAttribute("occupiedRooms",     occupiedRooms);
        req.setAttribute("maintenanceRooms",  maintenanceRooms);
        req.setAttribute("availableRooms",    availableRooms);

        // ── 2. REVENUE THIS MONTH ────────────────────────────────────────────
        BigDecimal revenueMonth = reportService.getRevenueMonth();
        req.setAttribute("revenueMonth", String.format("%,.0f", revenueMonth.doubleValue()));

        // ── 3. NEW BOOKINGS & CHECK-OUTS TODAY ───────────────────────────────
        req.setAttribute("newBookings",  reportService.getNewBookingsToday());
        req.setAttribute("checkoutsToday", reportService.getCheckoutsToday());

        // ── 4. OCCUPANCY RATE ────────────────────────────────────────────────
        req.setAttribute("occupancyRate",
                String.format("%.0f", reportService.getOccupancyRate()));

        // ── 5. STAFF COUNT ───────────────────────────────────────────────────
        req.setAttribute("staffCount", userDAO.getStaffCount());

        // ── 6. RECENT RESERVATIONS (activity feed) ───────────────────────────
        req.setAttribute("reservations", reservationDAO.getAllReservations());

        // ── 7. FORWARD TO ADMIN DASHBOARD VIEW ───────────────────────────────
        req.getRequestDispatcher("dashboard.jsp").forward(req, resp);
    }
}

