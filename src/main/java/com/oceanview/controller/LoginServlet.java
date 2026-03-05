package com.oceanview.controller;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;
import com.oceanview.util.FlashMessageUtil;
import com.oceanview.util.SecurityUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * ACADEMIC NOTE:
 * Controller Logic:
 * 1. Receives POST request.
 * 2. Hashes the password (Security).
 * 3. Delegates authentication to DAO (Separation of Concerns).
 * 4. Creates Session on success.
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // 1. Hash the input password to compare with DB
        String hashedPassword = SecurityUtil.hashPassword(password);

        // 2. Validate via DAO
        User user = userDAO.validateUser(username, hashedPassword);

        if (user != null) {
            // LOGIN SUCCESS
            // Create Session and store User object
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setAttribute("username", user.getUsername());
            session.setAttribute("role", user.getRole());

            // Redirect based on Role (Polymorphism behavior)
            // IMPORTANT: Redirect to Servlet, not JSP, so that data is loaded
            if ("ADMIN".equals(user.getRole())) {
                resp.sendRedirect("admin/DashboardServlet"); // Will create in Phase 6
            } else {
                resp.sendRedirect("staff/ReservationServlet"); // Loads room types and reservations
            }

        } else {
            // LOGIN FAIL
            FlashMessageUtil.setFlash(req, "danger", "Invalid Username or Password!");
            resp.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // If someone types /LoginServlet in browser, redirect to login page
        resp.sendRedirect("login.jsp");
    }
}

