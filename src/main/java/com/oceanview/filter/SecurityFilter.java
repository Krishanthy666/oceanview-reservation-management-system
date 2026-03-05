package com.oceanview.filter;

import com.oceanview.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * ACADEMIC NOTE:
 * This Filter intercepts EVERY request before it reaches a Servlet or JSP.
 *
 * 1. Security: It injects "Cache-Control: no-store" headers.
 *    This fixes the browser "Back Button" exploit, ensuring that after logout,
 *    the browser cannot display cached versions of secure pages.
 *
 * 2. Access Control: It checks URL patterns against User Roles.
 */
@WebFilter("/*") // Applies to every single URL in the application
public class SecurityFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization logic (if needed)
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // --- STEP 1: THE "BACK BUTTON" FIX ---
        // Force browser not to cache secure pages.
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        resp.setHeader("Pragma", "no-cache"); // HTTP 1.0
        resp.setHeader("Expires", "0"); // Proxies

        // --- STEP 2: PUBLIC RESOURCE CHECK ---
        // Allow CSS, JS, Images, and the Login page to pass through without checking session.
        String path = req.getRequestURI();
        if (path.endsWith("login.jsp") || path.endsWith("LoginServlet")
            || path.contains("/api/") || path.contains(".css") || path.contains(".js")
            || path.contains(".png") || path.contains("test.jsp") || path.contains("test_api.jsp")) {
            chain.doFilter(request, response);
            return;
        }

        // --- STEP 3: AUTHENTICATION CHECK ---
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            // User is NOT logged in. Redirect to login page.
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // --- STEP 4: ROLE-BASED ACCESS CONTROL (RBAC) ---
        User user = (User) session.getAttribute("user");
        String role = user.getRole();

        // Admin Protection: Only Admins can access /admin/*
        if (path.contains("/admin/") && !"ADMIN".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/access_denied.jsp");
            return;
        }

        // Staff Protection: Only Staff/Admins can access /staff/*
        if (path.contains("/staff/") && !("STAFF".equals(role) || "ADMIN".equals(role))) {
            resp.sendRedirect(req.getContextPath() + "/access_denied.jsp");
            return;
        }

        // If all checks pass, continue to the requested resource.
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup logic
    }
}

