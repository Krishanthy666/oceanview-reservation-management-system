package com.oceanview.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * ACADEMIC NOTE:
 * Manages "Flash Messages" (Success/Error alerts).
 * Solves the issue where messages persist on browser refresh.
 * Uses session to pass the message, then clears it immediately after retrieval.
 */
public class FlashMessageUtil {

    public static void setFlash(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("flashType", type); // success, danger, warning
        session.setAttribute("flashMessage", message);
    }

    // Retrieves and instantly clears the message
    public static String[] getAndClearFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashMessage") != null) {
            String type = (String) session.getAttribute("flashType");
            String msg = (String) session.getAttribute("flashMessage");

            // Clear immediately
            session.removeAttribute("flashType");
            session.removeAttribute("flashMessage");

            return new String[]{type, msg};
        }
        return null;
    }
}

