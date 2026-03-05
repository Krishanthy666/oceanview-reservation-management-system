package com.oceanview.dao;

import com.oceanview.model.User;
import com.oceanview.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * ACADEMIC NOTE:
 * Data Access Object for User authentication.
 * Follows the DAO pattern to isolate database access logic.
 */
public class UserDAO {

    /**
     * ACADEMIC NOTE:
     * Validates user login credentials.
     * Uses PreparedStatement to prevent SQL Injection.
     */
    public User validateUser(String username, String passwordHash) {
        User user = null;
        String sql = "SELECT user_id, username, role FROM users WHERE username = ? AND password_hash = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, passwordHash);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setRole(rs.getString("role"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }

    /**
     * ACADEMIC NOTE:
     * Returns the total number of users in the system.
     * Used by the Admin Dashboard to display staff headcount.
     */
    public int getStaffCount() {
        String sql = "SELECT COUNT(*) FROM users";
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

