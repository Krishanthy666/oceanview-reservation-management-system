package com.oceanview.controller;

import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import com.oceanview.service.ReportService;
import com.oceanview.util.FlashMessageUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * ACADEMIC NOTE:
 * RoomServlet handles all room inventory management operations.
 *
 * Operations:
 * - GET: Display all rooms and available room types
 * - POST: Add new room, update room status, delete room
 */
@WebServlet("/staff/RoomServlet")
public class RoomServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // Fetch all rooms with their type information
            List<Room> rooms = roomDAO.getAllRooms();
            req.setAttribute("rooms", rooms);

            // Fetch room types for dropdowns
            List<RoomType> roomTypes = roomDAO.getAllRoomTypes();
            req.setAttribute("roomTypes", roomTypes);

            // Calculate room statistics using dynamic calculations
            // based on actual active reservations, not static status field
            ReportService reportService = new ReportService();
            req.setAttribute("totalRooms", reportService.getTotalRooms());
            req.setAttribute("availableRooms", reportService.getAvailableRooms());
            req.setAttribute("occupiedRooms", reportService.getOccupiedRooms());
            req.setAttribute("maintenanceRooms", reportService.getMaintenanceRooms());

            req.getRequestDispatcher("rooms.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            FlashMessageUtil.setFlash(req, "danger", "Error loading rooms: " + e.getMessage());
            resp.sendRedirect("RoomServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String action = req.getParameter("action");

            if ("add".equals(action)) {
                handleAddRoom(req, resp);
            } else if ("updateStatus".equals(action)) {
                handleUpdateStatus(req, resp);
            } else if ("delete".equals(action)) {
                handleDeleteRoom(req, resp);
            } else {
                FlashMessageUtil.setFlash(req, "danger", "Unknown action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            FlashMessageUtil.setFlash(req, "danger", "Error processing request: " + e.getMessage());
        }

        resp.sendRedirect("RoomServlet");
    }

    /**
     * Handle adding a new room to inventory
     */
    private void handleAddRoom(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String roomNumber = req.getParameter("roomNumber");
        int typeId = Integer.parseInt(req.getParameter("typeId"));
        int floorNumber = Integer.parseInt(req.getParameter("floorNumber"));

        // Validate room number is unique
        List<Room> rooms = roomDAO.getAllRooms();
        boolean roomExists = rooms.stream().anyMatch(r -> roomNumber.equals(r.getRoomNumber()));

        if (roomExists) {
            FlashMessageUtil.setFlash(req, "danger", "Room " + roomNumber + " already exists!");
            return;
        }

        boolean success = roomDAO.addRoom(roomNumber, typeId, floorNumber);

        if (success) {
            FlashMessageUtil.setFlash(req, "success", "Room " + roomNumber + " added successfully!");
        } else {
            FlashMessageUtil.setFlash(req, "danger", "Failed to add room. Database error.");
        }
    }

    /**
     * Handle updating room status (AVAILABLE, OCCUPIED, UNDER_MAINTENANCE)
     */
    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int roomId = Integer.parseInt(req.getParameter("roomId"));
        String status = req.getParameter("status");

        boolean success = roomDAO.updateRoomStatus(roomId, status);

        if (success) {
            FlashMessageUtil.setFlash(req, "success", "Room status updated successfully!");
        } else {
            FlashMessageUtil.setFlash(req, "danger", "Failed to update room status.");
        }
    }

    /**
     * Handle deleting a room from inventory
     */
    private void handleDeleteRoom(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int roomId = Integer.parseInt(req.getParameter("roomId"));

        // Prevent deletion if room has active bookings
        // This check should be implemented in RoomDAO.deleteRoom()

        boolean success = roomDAO.deleteRoom(roomId);

        if (success) {
            FlashMessageUtil.setFlash(req, "success", "Room deleted successfully!");
        } else {
            FlashMessageUtil.setFlash(req, "danger", "Failed to delete room. It may have active bookings.");
        }
    }
}

