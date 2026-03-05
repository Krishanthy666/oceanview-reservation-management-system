package com.oceanview.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false); // Get existing session, don't create new
        if (session != null) {
            session.invalidate(); // Destroys session
        }
        // Due to our SecurityFilter headers, the "Back" button won't work after this.
        resp.sendRedirect("login.jsp");
    }
}

