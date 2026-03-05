package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.util.FlashMessageUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * ACADEMIC NOTE:
 * GuestServlet handles all guest management and guest history operations.
 *
 * Features:
 * - View all guests with their contact information
 * - View guest booking history
 * - Calculate guest statistics (total visits, total spending, etc.)
 * - Display guest loyalty metrics
 */
@WebServlet("/staff/GuestServlet")
public class GuestServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // Get guest summary using new method
            List<Map<String, Object>> guestSummary = reservationDAO.getGuestSummary();

            // Calculate statistics
            int totalGuests = guestSummary.size();
            double totalRevenue = 0;
            for (Map<String, Object> g : guestSummary) {
                Object totalSpent = g.get("totalSpent");
                if (totalSpent != null) {
                    totalRevenue += ((java.math.BigDecimal) totalSpent).doubleValue();
                }
            }
            double averageSpent = totalGuests > 0 ? totalRevenue / totalGuests : 0;

            req.setAttribute("guestSummary", guestSummary);
            req.setAttribute("totalGuests", totalGuests);
            req.setAttribute("totalRevenue", totalRevenue);
            req.setAttribute("averageSpent", averageSpent);

            req.getRequestDispatcher("guests.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            FlashMessageUtil.setFlash(req, "danger", "Error loading guests: " + e.getMessage());
            resp.sendRedirect("GuestServlet");
        }
    }

    /**
     * Inner class to aggregate guest metrics
     */
    public static class GuestMetrics {
        private String name;
        private String contact;
        private String address;
        private String firstVisit;
        private String lastVisit;
        private int visits = 0;
        private double totalSpent = 0;

        // Getters and Setters
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getContact() { return contact; }
        public void setContact(String contact) { this.contact = contact; }

        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }

        public String getFirstVisit() { return firstVisit; }
        public void setFirstVisit(String firstVisit) { this.firstVisit = firstVisit; }

        public String getLastVisit() { return lastVisit; }
        public void setLastVisit(String lastVisit) { this.lastVisit = lastVisit; }

        public int getVisits() { return visits; }
        public void incrementVisits() { this.visits++; }

        public double getTotalSpent() { return totalSpent; }
        public void addTotalSpent(double amount) { this.totalSpent += amount; }

        public double getAveragePerVisit() {
            return visits > 0 ? totalSpent / visits : 0;
        }
    }
}

