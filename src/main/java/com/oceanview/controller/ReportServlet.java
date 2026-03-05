package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * ACADEMIC NOTE:
 * ReportServlet is a decision-making / business intelligence endpoint.
 *
 * Responsibility — Single Responsibility Principle:
 *   Fetches aggregated data from the DAO layer, transforms it into
 *   simple primitive arrays (suitable for rendering in JSP), and
 *   forwards to the Reports view.
 *
 * Data prepared:
 *   1. Monthly Revenue (bar chart data)  — 12 months, indexed 1-12
 *   2. Room Type Popularity (pie data)   — per room-type booking counts
 *   3. Annual KPI Summary                — total bookings, revenue, avg value
 *
 * Security: This servlet sits under /staff/* which is already guarded
 * by SecurityFilter — only STAFF and ADMIN roles may access it.
 */
@WebServlet("/staff/ReportServlet")
public class ReportServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── 1. RAW DATA FROM DAO ─────────────────────────────────────────────
        List<Map<String, Object>> revenueData  = reservationDAO.getMonthlyRevenue();
        List<Map<String, Object>> roomData     = reservationDAO.getRoomTypePopularity();
        Map<String, Object>       annualSummary = reservationDAO.getAnnualSummary();

        // ── 2. BUILD MONTHLY REVENUE ARRAYS (index 1-12, missing months = 0) ─
        double[] monthTotals = new double[13]; // 1-based; index 0 unused
        for (Map<String, Object> row : revenueData) {
            int m = (Integer) row.get("month");
            double t = ((Number) row.get("total")).doubleValue();
            if (m >= 1 && m <= 12) {
                monthTotals[m] = t;
            }
        }

        // Safe JSON helpers – avoid script-injection from DB data
        StringBuilder months = new StringBuilder("[");
        StringBuilder totals = new StringBuilder("[");
        for (int i = 1; i <= 12; i++) {
            months.append("'").append(getMonthName(i)).append("'");
            totals.append(String.format("%.2f", monthTotals[i]));
            if (i < 12) { months.append(","); totals.append(","); }
        }
        months.append("]");
        totals.append("]");

        // ── 3. BUILD ROOM-TYPE ARRAYS ────────────────────────────────────────
        StringBuilder roomLabels = new StringBuilder("[");
        StringBuilder roomCounts = new StringBuilder("[");
        boolean first = true;
        for (Map<String, Object> row : roomData) {
            if (!first) { roomLabels.append(","); roomCounts.append(","); }
            // Sanitise label for JS string literal
            String name = String.valueOf(row.get("name")).replace("'", "\\'");
            roomLabels.append("'").append(name).append("'");
            roomCounts.append(row.get("count"));
            first = false;
        }
        roomLabels.append("]");
        roomCounts.append("]");

        // ── 4. FORMAT KPI SUMMARY ─────────────────────────────────────────────
        int    totalBookings = (Integer) annualSummary.getOrDefault("totalBookings", 0);
        BigDecimal totalRevenue = (BigDecimal) annualSummary.getOrDefault("totalRevenue", BigDecimal.ZERO);
        BigDecimal avgValue     = (BigDecimal) annualSummary.getOrDefault("avgValue",     BigDecimal.ZERO);
        int    cancelled        = (Integer) annualSummary.getOrDefault("cancelled", 0);

        // ── 5. FORWARD TO VIEW ────────────────────────────────────────────────
        req.setAttribute("chartMonths",   months.toString());
        req.setAttribute("chartTotals",   totals.toString());
        req.setAttribute("roomLabels",    roomLabels.toString());
        req.setAttribute("roomCounts",    roomCounts.toString());
        req.setAttribute("totalBookings", totalBookings);
        req.setAttribute("totalRevenue",  String.format("%,.0f", totalRevenue.doubleValue()));
        req.setAttribute("avgValue",      String.format("%,.0f", avgValue.doubleValue()));
        req.setAttribute("cancelled",     cancelled);
        req.setAttribute("currentYear",   java.time.Year.now().getValue());

        req.getRequestDispatcher("reports.jsp").forward(req, resp);
    }

    // ── HELPERS ───────────────────────────────────────────────────────────────
    private static final String[] MONTH_NAMES =
        {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

    private String getMonthName(int month) {
        return (month >= 1 && month <= 12) ? MONTH_NAMES[month] : "?";
    }
}

