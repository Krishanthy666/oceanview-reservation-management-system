package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.util.PDFGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;

/**
 * ACADEMIC NOTE:
 * This servlet acts as a Controller in the MVC pattern.
 * It handles GET requests to /staff/InvoiceServlet?id=X, fetches the reservation
 * from the DAO, delegates PDF rendering to PDFGenerator (a utility / Service),
 * and streams the PDF bytes directly to the browser via the response OutputStream.
 *
 * Content-Disposition: attachment  → tells the browser to save the file, not display it.
 * Content-Type: application/pdf   → MIME type so the OS opens it with a PDF viewer.
 */
@WebServlet("/staff/InvoiceServlet")
public class InvoiceServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");

        // ── 1. Validate parameter ────────────────────────────────────────────────
        if (idParam == null || idParam.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing reservation id parameter");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid reservation id: " + idParam);
            return;
        }

        // ── 2. Fetch reservation (with room type details for invoice breakdown) ──
        Reservation res = reservationDAO.getReservationById(id);

        if (res == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Reservation #" + id + " not found");
            return;
        }

        // ── 3. Stream PDF to browser ─────────────────────────────────────────────
        try {
            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition",
                    "attachment; filename=\"Invoice_" + String.format("%05d", id) + ".pdf\"");
            // Disable caching so a re-issued invoice always reflects current data
            resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            resp.setHeader("Pragma", "no-cache");
            resp.setDateHeader("Expires", 0);

            OutputStream out = resp.getOutputStream();
            PDFGenerator.generateInvoice(res, out);
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            // Only send an error if the response hasn't been committed yet
            if (!resp.isCommitted()) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Could not generate PDF: " + e.getMessage());
            }
        }
    }
}
