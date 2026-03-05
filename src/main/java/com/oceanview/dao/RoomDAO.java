package com.oceanview.dao;

import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import com.oceanview.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * ACADEMIC NOTE:
 * Data Access Object for Room and RoomType entities.
 * Contains the critical Availability Engine logic.
 */
public class RoomDAO {

    /**
     * ACADEMIC NOTE:
     * Fetches all room types for the dropdown menu.
     * Used in the reservation creation form.
     */
    public List<RoomType> getAllRoomTypes() {
        List<RoomType> list = new ArrayList<>();
        String sql = "SELECT * FROM room_types";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                RoomType rt = new RoomType();
                rt.setTypeId(rs.getInt("type_id"));
                rt.setTypeName(rs.getString("type_name"));
                rt.setBaseRate(rs.getBigDecimal("base_rate"));
                list.add(rt);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ACADEMIC NOTE - THE AVAILABILITY ENGINE:
     * This method finds specific room numbers (e.g., 101, 102) that are:
     * 1. Of the correct category.
     * 2. Not under maintenance.
     * 3. NOT booked during the requested date range.
     *
     * LOGIC: A room is unavailable if:
     * (Requested_CheckIn < Existing_CheckOut) AND (Requested_CheckOut > Existing_CheckIn)
     *
     * We use a SUBQUERY to exclude rooms that have conflicts in the reservations table.
     */
    public List<Room> getAvailableRooms(int typeId, String checkIn, String checkOut) {
        List<Room> list = new ArrayList<>();

        // Query explanation: Select rooms where ID is NOT IN the list of conflicting reservations
        String sql = "SELECT r.room_id, r.room_number, rt.type_name, rt.base_rate " +
                     "FROM rooms r " +
                     "JOIN room_types rt ON r.type_id = rt.type_id " +
                     "WHERE r.type_id = ? AND r.status = 'AVAILABLE' " +
                     "AND r.room_id NOT IN (" +
                     "   SELECT room_id FROM reservations " +
                     "   WHERE status = 'CONFIRMED' " +
                     "   AND (? < check_out AND ? > check_in)" +
                     ")";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, typeId);
            stmt.setString(2, checkIn);
            stmt.setString(3, checkOut);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Room room = new Room();
                    room.setRoomId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setTypeName(rs.getString("type_name"));
                    // We can temporarily store rate in Room object for easy access in UI
                    list.add(room);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Gets ALL rooms of a specific type (regardless of availability).
     * Used for the room assignment dropdown so staff can see "Available" vs "Booked/Maintenance".
     */
    public List<Room> getRoomsByType(int typeId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT room_id, room_number, status FROM rooms WHERE type_id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, typeId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Room room = new Room();
                    room.setRoomId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setStatus(rs.getString("status")); // AVAILABLE, OCCUPIED, UNDER_MAINTENANCE
                    list.add(room);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ACADEMIC NOTE:
     * Method to get all rooms for Admin management dashboard.
     * Used for inventory and status monitoring.
     */
    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.room_id, r.room_number, r.status, r.floor_number, r.type_id, rt.type_name " +
                     "FROM rooms r " +
                     "JOIN room_types rt ON r.type_id = rt.type_id " +
                     "ORDER BY r.room_number";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setStatus(rs.getString("status"));
                room.setFloorNumber(rs.getInt("floor_number"));
                room.setTypeId(rs.getInt("type_id"));
                room.setTypeName(rs.getString("type_name"));
                list.add(room);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ACADEMIC NOTE:
     * Adds a new room to the inventory.
     * Status defaults to 'AVAILABLE'.
     */
    public boolean addRoom(String roomNumber, int typeId, int floorNumber) {
        String sql = "INSERT INTO rooms (room_number, type_id, floor_number, status) VALUES (?, ?, ?, 'AVAILABLE')";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, roomNumber);
            stmt.setInt(2, typeId);
            stmt.setInt(3, floorNumber);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * ACADEMIC NOTE:
     * Updates the status of a room (AVAILABLE, OCCUPIED, UNDER_MAINTENANCE).
     */
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE rooms SET status = ? WHERE room_id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, roomId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * ACADEMIC NOTE:
     * Deletes a room from inventory.
     * Should only delete if no active reservations exist.
     */
    public boolean deleteRoom(int roomId) {
        // First check if room has any active reservations
        String checkSql = "SELECT COUNT(*) FROM reservations WHERE room_id = ? AND status = 'CONFIRMED'";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(checkSql)) {
            stmt.setInt(1, roomId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // Room has active bookings
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        // If no active reservations, proceed with deletion
        String deleteSql = "DELETE FROM rooms WHERE room_id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(deleteSql)) {
            stmt.setInt(1, roomId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

