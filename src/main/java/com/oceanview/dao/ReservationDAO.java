package com.oceanview.dao;

import com.oceanview.model.Reservation;
import com.oceanview.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ACADEMIC NOTE:
 * Data Access Object for Reservation entity.
 * Handles all persistence operations for bookings.
 */
public class ReservationDAO {

    /**
     * ACADEMIC NOTE:
     * Inserts a new reservation.
     * Uses 'created_by' to track which staff member made the booking (Audit Trail).
     * PreparedStatement prevents SQL Injection attacks.
     */
    public boolean addReservation(Reservation res) {
        String sql = "INSERT INTO reservations (guest_name, guest_address, guest_contact, room_id, check_in, check_out, total_cost, status, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, 'CONFIRMED', ?)";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, res.getGuestName());
            stmt.setString(2, res.getGuestAddress());
            stmt.setString(3, res.getGuestContact());
            stmt.setInt(4, res.getRoomId());
            stmt.setString(5, res.getCheckIn().toString());
            stmt.setString(6, res.getCheckOut().toString());
            stmt.setBigDecimal(7, res.getTotalCost());
            stmt.setInt(8, res.getCreatedBy());

            int rows = stmt.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACADEMIC NOTE:
     * Fetches all reservations with Room Number for the Dashboard.
     * Joins reservation data with room numbers for better readability.
     */
    public List<Reservation> getAllReservations() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.reservation_id, r.guest_name, r.guest_contact, r.guest_address, r.check_in, r.check_out, r.total_cost, r.status, rm.room_number " +
                     "FROM reservations r " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "ORDER BY r.reservation_id DESC";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Reservation res = new Reservation();
                res.setReservationId(rs.getInt("reservation_id"));
                res.setGuestName(rs.getString("guest_name"));
                res.setGuestContact(rs.getString("guest_contact"));
                res.setGuestAddress(rs.getString("guest_address"));
                res.setCheckIn(rs.getDate("check_in").toLocalDate());
                res.setCheckOut(rs.getDate("check_out").toLocalDate());
                res.setTotalCost(rs.getBigDecimal("total_cost"));
                res.setStatus(rs.getString("status"));
                res.setRoomNumber(rs.getString("room_number"));
                list.add(res);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ACADEMIC NOTE:
     * Fetches a single reservation by ID with full room-type details.
     * The three-way JOIN (reservations → rooms → room_types) gives us everything
     * the PDF invoice needs in one round-trip to the database.
     */
    public Reservation getReservationById(int reservationId) {
        Reservation res = null;
        String sql = "SELECT r.reservation_id, r.guest_name, r.guest_address, r.guest_contact, " +
                     "r.room_id, r.check_in, r.check_out, r.total_cost, r.status, " +
                     "rm.room_number, rt.type_name, rt.base_rate " +
                     "FROM reservations r " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "JOIN room_types rt ON rm.type_id = rt.type_id " +
                     "WHERE r.reservation_id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, reservationId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    res = new Reservation();
                    res.setReservationId(rs.getInt("reservation_id"));
                    res.setGuestName(rs.getString("guest_name"));
                    res.setGuestAddress(rs.getString("guest_address"));
                    res.setGuestContact(rs.getString("guest_contact"));
                    res.setRoomId(rs.getInt("room_id"));
                    res.setRoomNumber(rs.getString("room_number"));
                    res.setTypeName(rs.getString("type_name"));
                    res.setBaseRate(rs.getBigDecimal("base_rate"));
                    res.setCheckIn(rs.getDate("check_in").toLocalDate());
                    res.setCheckOut(rs.getDate("check_out").toLocalDate());
                    res.setTotalCost(rs.getBigDecimal("total_cost"));
                    res.setStatus(rs.getString("status"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return res;
    }

    /**
     * ACADEMIC NOTE:
     * Updates a reservation status (e.g., CONFIRMED to CANCELLED).
     */
    public boolean updateReservationStatus(int reservationId, String status) {
        String sql = "UPDATE reservations SET status = ? WHERE reservation_id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, reservationId);

            int rows = stmt.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACADEMIC NOTE:
     * Aggregates total revenue per month for the current calendar year.
     * Uses MONTH() and YEAR() SQL functions to group data temporally.
     * Returns a sparse list — months with no bookings are omitted.
     */
    public List<Map<String, Object>> getMonthlyRevenue() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT MONTH(created_at) as month, SUM(total_cost) as total " +
                     "FROM reservations WHERE YEAR(created_at) = YEAR(NOW()) " +
                     "GROUP BY MONTH(created_at) ORDER BY month ASC";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("month", rs.getInt("month"));
                row.put("total", rs.getBigDecimal("total"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * ACADEMIC NOTE:
     * Counts how many reservations were made for each room type.
     * Uses a two-level JOIN: reservations → rooms → room_types.
     * This demonstrates relational data aggregation for BI reporting.
     */
    public List<Map<String, Object>> getRoomTypePopularity() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT rt.type_name, COUNT(r.reservation_id) as count " +
                     "FROM reservations r " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "JOIN room_types rt ON rm.type_id = rt.type_id " +
                     "GROUP BY rt.type_name ORDER BY count DESC";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", rs.getString("type_name"));
                row.put("count", rs.getInt("count"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * ACADEMIC NOTE:
     * Fetches total revenue, total bookings, and average booking value
     * for the current year — a high-level KPI summary for the reports page.
     */
    public Map<String, Object> getAnnualSummary() {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT COUNT(*) as total_bookings, " +
                     "COALESCE(SUM(total_cost), 0) as total_revenue, " +
                     "COALESCE(AVG(total_cost), 0) as avg_value, " +
                     "COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled " +
                     "FROM reservations WHERE YEAR(created_at) = YEAR(NOW())";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                summary.put("totalBookings", rs.getInt("total_bookings"));
                summary.put("totalRevenue", rs.getBigDecimal("total_revenue"));
                summary.put("avgValue", rs.getBigDecimal("avg_value"));
                summary.put("cancelled", rs.getInt("cancelled"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return summary;
    }

    /**
     * ACADEMIC NOTE:
     * Aggregates guest data by name and contact.
     * Calculates visits, total spending, and visit dates for each guest.
     */
    public List<Map<String, Object>> getGuestSummary() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT guest_name, guest_contact, guest_address, " +
                     "COUNT(reservation_id) as visits, " +
                     "SUM(total_cost) as total_spent, " +
                     "MIN(check_in) as first_visit, " +
                     "MAX(check_in) as last_visit " +
                     "FROM reservations GROUP BY guest_name, guest_contact, guest_address";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", rs.getString("guest_name"));
                map.put("contact", rs.getString("guest_contact"));
                map.put("address", rs.getString("guest_address"));
                map.put("visits", rs.getInt("visits"));
                map.put("totalSpent", rs.getBigDecimal("total_spent"));
                map.put("firstVisit", rs.getDate("first_visit").toLocalDate());
                map.put("lastVisit", rs.getDate("last_visit").toLocalDate());
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}

