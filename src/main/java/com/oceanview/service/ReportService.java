package com.oceanview.service;

import com.oceanview.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * ACADEMIC NOTE:
 * Service Layer for Dashboard Reports and Statistics.
 * Fetches real data from the database for:
 * - New bookings today
 * - Check-outs today
 * - Current occupancy rate
 * - Revenue today
 *
 * This prevents hardcoding values and provides actual business metrics.
 */
public class ReportService {

    /**
     * Gets the count of new reservations created today.
     * ACADEMIC NOTE: Uses DATE() function to compare only the date part.
     * Fixed: Uses DATE(NOW()) on both sides for timezone-safe comparison.
     */
    public int getNewBookingsToday() {
        String sql = "SELECT COUNT(*) FROM reservations WHERE DATE(created_at) = DATE(NOW())";
        return getCount(sql);
    }

    /**
     * Gets the count of reservations with check-out today and status CONFIRMED.
     * These guests will be leaving today.
     * Fixed: Uses DATE(NOW()) for timezone-safe comparison.
     */
    public int getCheckoutsToday() {
        String sql = "SELECT COUNT(*) FROM reservations WHERE DATE(check_out) = DATE(NOW()) AND status = 'CONFIRMED'";
        return getCount(sql);
    }

    /**
     * Calculates the occupancy rate as a percentage.
     * Logic: (Rooms currently occupied / Total rooms in system) * 100
     *
     * A room is considered "occupied" if:
     * - It has a CONFIRMED reservation
     * - Where today's date falls between check_in and check_out
     * Fixed: Handles division by zero and uses NOW() for consistency.
     */
    public double getOccupancyRate() {
        String sql = "SELECT " +
                "CASE WHEN (SELECT COUNT(*) FROM rooms) = 0 THEN 0 ELSE " +
                "(SELECT COUNT(DISTINCT rm.room_id) " +
                "FROM rooms rm " +
                "JOIN reservations res ON rm.room_id = res.room_id " +
                "WHERE res.status = 'CONFIRMED' " +
                "AND DATE(NOW()) >= res.check_in " +
                "AND DATE(NOW()) < res.check_out) * 100.0 " +
                "/ (SELECT COUNT(*) FROM rooms) END";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    /**
     * Calculates total revenue from reservations created today.
     * Sums the total_cost of all reservations where created_at is today.
     * Fixed: Uses DATE(NOW()) for timezone-safe comparison.
     */
    public BigDecimal getRevenueToday() {
        String sql = "SELECT COALESCE(SUM(total_cost), 0) FROM reservations WHERE DATE(created_at) = DATE(NOW())";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculates total revenue from reservations created in the current month.
     * Sums the total_cost of all reservations where YEAR and MONTH of created_at match current month.
     * Fixed: Uses YEAR() and MONTH() functions for timezone-safe comparison.
     */
    public BigDecimal getRevenueMonth() {
        String sql = "SELECT COALESCE(SUM(total_cost), 0) FROM reservations WHERE YEAR(created_at) = YEAR(NOW()) AND MONTH(created_at) = MONTH(NOW())";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Gets the total count of rooms in the system.
     * ACADEMIC NOTE: Simple count of all rooms regardless of status.
     */
    public int getTotalRooms() {
        return getCount("SELECT COUNT(*) FROM rooms");
    }

    /**
     * Gets the count of rooms currently under maintenance.
     * These rooms should not be available for booking.
     * ACADEMIC NOTE: Status column tracks maintenance state.
     */
    public int getMaintenanceRooms() {
        return getCount("SELECT COUNT(*) FROM rooms WHERE status = 'UNDER_MAINTENANCE'");
    }

    /**
     * Gets the count of rooms currently occupied.
     * A room is "Occupied" if it has a CONFIRMED reservation where today's date
     * falls between check_in and check_out dates.
     * ACADEMIC NOTE: Uses DATE(NOW()) to safely compare dates regardless of time portion.
     */
    public int getOccupiedRooms() {
        String sql = "SELECT COUNT(DISTINCT room_id) FROM reservations " +
                     "WHERE status = 'CONFIRMED' " +
                     "AND DATE(NOW()) >= check_in AND DATE(NOW()) < check_out";
        return getCount(sql);
    }

    /**
     * Gets the count of rooms currently available for booking.
     * Logic: Total Rooms - (Rooms in Maintenance + Rooms Occupied Today)
     * ACADEMIC NOTE: This is real-time availability based on active reservations.
     */
    public int getAvailableRooms() {
        return getTotalRooms() - getMaintenanceRooms() - getOccupiedRooms();
    }

    /**
     * Helper method to execute a COUNT query.
     * Returns the count result, or 0 if no rows or error occurs.
     */
    private int getCount(String sql) {
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}

