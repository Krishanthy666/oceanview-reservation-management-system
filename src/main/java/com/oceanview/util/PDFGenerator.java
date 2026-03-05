package com.oceanview.util;

import com.oceanview.model.Reservation;
import com.oceanview.service.BillingService;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * ACADEMIC NOTE — Zero-dependency PDF generation using raw PDF syntax.
 *
 * PDF is a plain-text (ASCII) document format defined by ISO 32000.
 * Every PDF is a sequence of numbered "objects" (dictionaries, streams)
 * connected by a cross-reference table at the end of the file.
 * We hand-write every byte here so that the project compiles and runs
 * with NO extra Maven dependencies whatsoever.
 *
 * Structure we build:
 *   Obj 1  Catalog   → root of the document, points to Pages tree
 *   Obj 2  Pages     → parent node listing all Page objects
 *   Obj 3  Page      → single A4 page; references Font resources + content stream
 *   Obj 4  Font F1   → Helvetica-Bold  (PDF standard font, always available)
 *   Obj 5  Font F2   → Helvetica       (PDF standard font, always available)
 *   Obj 6  Content   → the drawing commands (text, rectangles, lines)
 *
 * PDF coordinate system: origin = bottom-left corner, Y increases upwards.
 * A4 page = 595 x 842 points  (1 pt = 1/72 inch).
 */
public class PDFGenerator {

    // ── Page geometry ────────────────────────────────────────────────────────────
    private static final int PW = 595;           // page width  (A4)
    private static final int ML = 50;            // left margin
    private static final int MR = 50;            // right margin
    private static final int CONTENT_W = PW - ML - MR; // 495 pt

    private static final DateTimeFormatter DISPLAY_FMT =
            DateTimeFormatter.ofPattern("dd MMMM yyyy");

    // ────────────────────────────────────────────────────────────────────────────
    /**
     * Generates a professional A4 invoice PDF and writes it to {@code out}.
     *
     * @param res  Reservation with typeName + baseRate populated by the DAO join.
     * @param out  Servlet response OutputStream.
     */
    public static void generateInvoice(Reservation res, OutputStream out)
            throws IOException {

        // ── 1. Billing calculation ───────────────────────────────────────────────
        BillingService svc = new BillingService();
        BillingService.BillingResult billing =
                (res.getBaseRate() != null)
                        ? svc.calculateBilling(res.getCheckIn(), res.getCheckOut(), res.getBaseRate())
                        : null;

        BigDecimal baseRate      = res.getBaseRate()     != null ? res.getBaseRate()     : BigDecimal.ZERO;
        BigDecimal baseCost      = billing != null ? billing.baseCost      : res.getTotalCost();
        BigDecimal serviceCharge = billing != null ? billing.serviceCharge : BigDecimal.ZERO;
        BigDecimal tax           = billing != null ? billing.tax           : BigDecimal.ZERO;
        BigDecimal grandTotal    = billing != null ? billing.total         : res.getTotalCost();
        long       nights        = billing != null ? billing.nights        : 1;

        // ── 2. Pre-compute page height dynamically ───────────────────────────────
        // Split long address across multiple lines (~42 chars per line at 8pt in colW)
        String fullAddr   = safe(res.getGuestAddress(), "-");
        int    addrWrap   = 42;
        List<String> addrLines = new ArrayList<>();
        String remaining = fullAddr;
        while (remaining.length() > addrWrap) {
            // try to break at a space near the wrap point
            int breakAt = addrWrap;
            int spaceAt = remaining.lastIndexOf(' ', addrWrap);
            if (spaceAt > addrWrap / 2) breakAt = spaceAt;
            addrLines.add(remaining.substring(0, breakAt).trim());
            remaining = remaining.substring(breakAt).trim();
        }
        addrLines.add(remaining);

        int boxRowH = 16;
        int boxPad  = 8;
        int titleH  = 20;
        // left box rows: Name, Contact, then each address line
        int leftRowCount  = 2 + addrLines.size();
        int rightRowCount = 5; // Room, Check-in, Check-out, Duration, Status
        int maxRows = Math.max(leftRowCount, rightRowCount);
        int boxH    = titleH + maxRows * boxRowH + boxPad * 2;

        int headerH = 82;
        int headerBottom = headerH + 5; // amber stripe below header
        int afterHeader  = 18;

        // Estimate total content height from top of page down
        int tableRowH = 18;
        int subtotalH = 3 * 16;
        int gtH       = 24;
        int footerH   = 50; // separator + 3 lines

        int estimatedContentH = headerBottom + afterHeader
                + boxH + 12
                + 14 + 6 + tableRowH + 3 * tableRowH  // charges section label + header + 3 rows
                + 6 + subtotalH + 4 + gtH              // subtotals + grand total
                + 14 + footerH + 20;                   // gap + footer + bottom margin

        // Page height = content + small bottom margin (at least 300 to look decent)
        int PH = Math.max(300, estimatedContentH);

        // ── 3. Build the PDF content stream ──────────────────────────────────────
        StringBuilder cs = new StringBuilder();

        // Current Y position — we draw top-to-bottom
        int y = PH - 40;

        // ════════════════════════════════════════════════════════════════════════
        // SECTION A — HEADER BAND
        // ════════════════════════════════════════════════════════════════════════
        // Deep-blue background  #1a237e → 0.102 0.137 0.494
        fillRect(cs, 0, PH - headerH, PW, headerH, "0.102 0.137 0.494");
        // Amber accent stripe   #ffca28 → 1.0 0.792 0.157
        fillRect(cs, 0, PH - headerH - 5, PW, 5, "1.0 0.792 0.157");

        // Hotel name
        text(cs, "F1", 18, ML, PH - 30, "1 1 1", "OCEAN VIEW RESORT");
        text(cs, "F2",  8, ML, PH - 44, "0.86 0.86 0.87", "Luxury Beachside Hotel  |  Galle, Sri Lanka");
        text(cs, "F2",  8, ML, PH - 56, "0.86 0.86 0.87", "Tel: +94 91 234 5678   reservations@oceanviewresort.lk");

        // Invoice meta (right side, amber text)
        textRight(cs, "F1", 14, PW - MR, PH - 28, "1.0 0.792 0.157", "TAX INVOICE");
        textRight(cs, "F2",  8, PW - MR, PH - 44, "0.8 0.8 0.85",
                "INV-" + String.format("%05d", res.getReservationId()));
        textRight(cs, "F2",  8, PW - MR, PH - 56, "0.8 0.8 0.85",
                "Issued: " + LocalDate.now().format(DISPLAY_FMT));

        y = PH - headerH - 5 - afterHeader;  // just below the amber stripe

        // ════════════════════════════════════════════════════════════════════════
        // SECTION B — INFO BOXES (Guest + Booking, side by side)
        // ════════════════════════════════════════════════════════════════════════
        int boxTop = y;
        int colW   = (CONTENT_W - 10) / 2;   // ~242 pt each
        int col1X  = ML;
        int col2X  = ML + colW + 10;

        String roomLine = safe(res.getRoomNumber()) +
                (res.getTypeName() != null ? " (" + res.getTypeName() + ")" : "");
        String[][] rightRows = {
                {"Room:",      roomLine},
                {"Check-in:",  res.getCheckIn().format(DISPLAY_FMT)},
                {"Check-out:", res.getCheckOut().format(DISPLAY_FMT)},
                {"Duration:",  nights + " Night" + (nights != 1 ? "s" : "")},
                {"Status:",    safe(res.getStatus())}
        };

        // Light-grey background
        fillRect(cs, col1X, boxTop - boxH, colW, boxH, "0.957 0.961 0.976");
        fillRect(cs, col2X, boxTop - boxH, colW, boxH, "0.957 0.961 0.976");

        // Section titles
        text(cs, "F1", 8, col1X + boxPad, boxTop - boxPad - 8, "0.2 0.2 0.2", "BILLED TO");
        text(cs, "F1", 8, col2X + boxPad, boxTop - boxPad - 8, "0.2 0.2 0.2", "BOOKING DETAILS");

        // Thin separator line
        hLine(cs, col1X + boxPad, boxTop - titleH, colW - boxPad * 2, "0.773 0.792 0.914");
        hLine(cs, col2X + boxPad, boxTop - titleH, colW - boxPad * 2, "0.773 0.792 0.914");

        // Left box: Name label on its own, then value; then Contact; then Address lines
        int rowY = boxTop - titleH - boxRowH;

        // Name row — label left, value right of label
        text(cs, "F2", 8, col1X + boxPad,      rowY, "0.4 0.4 0.4", "Name:");
        text(cs, "F1", 8, col1X + boxPad + 45, rowY, "0.2 0.2 0.2", safe(res.getGuestName()));
        rowY -= boxRowH;

        // Contact row
        text(cs, "F2", 8, col1X + boxPad,      rowY, "0.4 0.4 0.4", "Contact:");
        text(cs, "F1", 8, col1X + boxPad + 45, rowY, "0.2 0.2 0.2", safe(res.getGuestContact()));
        rowY -= boxRowH;

        // Address — first line has label, continuation lines are indented
        text(cs, "F2", 8, col1X + boxPad,      rowY, "0.4 0.4 0.4", "Address:");
        text(cs, "F1", 8, col1X + boxPad + 45, rowY, "0.2 0.2 0.2", addrLines.get(0));
        rowY -= boxRowH;
        for (int i = 1; i < addrLines.size(); i++) {
            text(cs, "F1", 8, col1X + boxPad + 45, rowY, "0.2 0.2 0.2", addrLines.get(i));
            rowY -= boxRowH;
        }

        // Right box rows
        rowY = boxTop - titleH - boxRowH;
        for (String[] row : rightRows) {
            text(cs, "F2", 8, col2X + boxPad,      rowY, "0.4 0.4 0.4", row[0]);
            text(cs, "F1", 8, col2X + boxPad + 55, rowY, "0.2 0.2 0.2", row[1]);
            rowY -= boxRowH;
        }

        y = boxTop - boxH - 12;

        // ════════════════════════════════════════════════════════════════════════
        // SECTION C — CHARGES TABLE
        // ════════════════════════════════════════════════════════════════════════
        text(cs, "F1", 7, ML, y, "0.102 0.137 0.494", "CHARGES BREAKDOWN");
        y -= 6;

        // Column widths & X positions
        int[] cw = {220, 85, 55, 135};
        int[] cx = {ML, ML + cw[0], ML + cw[0] + cw[1], ML + cw[0] + cw[1] + cw[2]};

        // Header row — deep blue
        int rowH = tableRowH;
        fillRect(cs, ML, y - rowH, CONTENT_W, rowH, "0.102 0.137 0.494");
        String[] colHdrs = {"Description", "Rate (LKR)", "Nights", "Amount (LKR)"};
        text     (cs, "F1", 8, cx[0] + 5,           y - 12, "1 1 1", colHdrs[0]);
        textRight(cs, "F1", 8, cx[1] + cw[1] - 5,   y - 12, "1 1 1", colHdrs[1]);
        textRight(cs, "F1", 8, cx[2] + cw[2] - 5,   y - 12, "1 1 1", colHdrs[2]);
        textRight(cs, "F1", 8, cx[3] + cw[3] - 5,   y - 12, "1 1 1", colHdrs[3]);
        y -= rowH;

        // Data rows
        String[][] tableRows = {
                {"Room Charge - " + safe(res.getRoomNumber()), fmt(baseRate), String.valueOf(nights), fmt(baseCost)},
                {"Service Charge (10%)", "10%", "", fmt(serviceCharge)},
                {"Government Tax (12%)", "12%", "", fmt(tax)}
        };

        boolean shaded = false;
        for (String[] row : tableRows) {
            String bg = shaded ? "0.94 0.94 0.96" : "1 1 1";
            fillRect(cs, ML, y - rowH, CONTENT_W, rowH, bg);
            hLine(cs, ML, y - rowH, CONTENT_W, "0.88 0.88 0.88");

            text(cs, "F2", 8, cx[0] + 5, y - 11, "0.2 0.2 0.2", row[0]);
            if (!row[1].isEmpty()) textRight(cs, "F2", 8, cx[1] + cw[1] - 5, y - 11, "0.2 0.2 0.2", row[1]);
            if (!row[2].isEmpty()) textRight(cs, "F2", 8, cx[2] + cw[2] - 5, y - 11, "0.2 0.2 0.2", row[2]);
            if (!row[3].isEmpty()) textRight(cs, "F2", 8, cx[3] + cw[3] - 5, y - 11, "0.2 0.2 0.2", row[3]);

            y -= rowH;
            shaded = !shaded;
        }

        y -= 6;

        // ════════════════════════════════════════════════════════════════════════
        // SECTION D — SUBTOTALS + GRAND TOTAL
        // ════════════════════════════════════════════════════════════════════════
        int totX  = PW / 2;
        int totW2 = PW - MR - totX;

        String[][] subtotals = {
                {"Sub-total (Room Charge)",  fmt(baseCost) + " LKR"},
                {"Service Charge (10%)",     fmt(serviceCharge) + " LKR"},
                {"Government Tax (12%)",     fmt(tax) + " LKR"}
        };
        for (String[] st : subtotals) {
            fillRect(cs, totX, y - 16, totW2, 16, "1 1 1");
            hLine(cs, totX, y - 16, totW2, "0.9 0.9 0.9");
            text     (cs, "F2", 8, totX + 6,      y - 10, "0.3 0.3 0.3", st[0]);
            textRight(cs, "F2", 8, PW - MR - 5,   y - 10, "0.3 0.3 0.3", st[1]);
            y -= 16;
        }

        y -= 4;

        // Grand total — deep-blue band, amber text
        fillRect(cs, totX, y - gtH, totW2, gtH, "0.102 0.137 0.494");
        text     (cs, "F1", 10, totX + 8,     y - 15, "1.0 0.792 0.157", "GRAND TOTAL");
        textRight(cs, "F1", 10, PW - MR - 8,  y - 15, "1.0 0.792 0.157", fmt(grandTotal) + " LKR");

        y -= gtH + 14;

        // ════════════════════════════════════════════════════════════════════════
        // SECTION E — FOOTER
        // ════════════════════════════════════════════════════════════════════════
        hLine(cs, ML, y, CONTENT_W, "0.773 0.792 0.914");
        y -= 13;
        textCenter(cs, "F1", 9, PW / 2, y, "0.102 0.137 0.494",
                "Thank you for choosing Ocean View Resort! We hope you had a wonderful stay.");
        y -= 12;
        textCenter(cs, "F2", 8, PW / 2, y, "0.5 0.5 0.5",
                "We look forward to welcoming you again.");
        y -= 11;
        textCenter(cs, "F2", 7, PW / 2, y, "0.65 0.65 0.65",
                "Computer-generated invoice | No signature required | Ocean View Resort, Galle, Sri Lanka");

        // ── 3. Assemble the final PDF bytes ─────────────────────────────────────
        byte[] contentBytes = cs.toString().getBytes(StandardCharsets.ISO_8859_1);

        List<Integer> offsets = new ArrayList<>();
        ByteArrayOutputStream buf = new ByteArrayOutputStream(8192);

        // PDF header (the 4 high bytes signal binary content to transfer agents)
        write(buf, "%PDF-1.4\n%\u00e2\u00e3\u00cf\u00d3\n");

        // Object 1 — Catalog
        offsets.add(buf.size());
        write(buf, "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");

        // Object 2 — Pages tree
        offsets.add(buf.size());
        write(buf, "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n");

        // Object 3 — Page (dynamic height = content height, no blank tail)
        offsets.add(buf.size());
        write(buf,
                "3 0 obj\n"
              + "<< /Type /Page /Parent 2 0 R\n"
              + "   /MediaBox [0 0 " + PW + " " + PH + "]\n"
              + "   /Contents 6 0 R\n"
              + "   /Resources << /Font << /F1 4 0 R /F2 5 0 R >> >>\n"
              + ">>\nendobj\n");

        // Object 4 — Helvetica-Bold
        offsets.add(buf.size());
        write(buf,
                "4 0 obj\n"
              + "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold\n"
              + "   /Encoding /WinAnsiEncoding >>\nendobj\n");

        // Object 5 — Helvetica
        offsets.add(buf.size());
        write(buf,
                "5 0 obj\n"
              + "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica\n"
              + "   /Encoding /WinAnsiEncoding >>\nendobj\n");

        // Object 6 — Content stream
        offsets.add(buf.size());
        write(buf, "6 0 obj\n<< /Length " + contentBytes.length + " >>\nstream\n");
        buf.write(contentBytes);
        write(buf, "\nendstream\nendobj\n");

        // Cross-reference table
        int xrefOffset = buf.size();
        write(buf, "xref\n");
        write(buf, "0 " + (offsets.size() + 1) + "\n");
        write(buf, "0000000000 65535 f \n");   // free-list head
        for (int offset : offsets) {
            write(buf, String.format("%010d 00000 n \n", offset));
        }

        // Trailer dictionary + EOF marker
        write(buf, "trailer\n<< /Size " + (offsets.size() + 1) + " /Root 1 0 R >>\n");
        write(buf, "startxref\n" + xrefOffset + "\n%%EOF\n");

        buf.writeTo(out);
    }

    // ────────────────────────────────────────────────────────────────────────────
    // PDF drawing helpers — emit raw PDF operator sequences into the content stream
    // ────────────────────────────────────────────────────────────────────────────

    /** Filled axis-aligned rectangle. rgb = "R G B" as 0.0-1.0 floats. */
    private static void fillRect(StringBuilder cs,
                                  int x, int y, int w, int h, String rgb) {
        cs.append(rgb).append(" rg\n")
          .append(x).append(' ').append(y).append(' ')
          .append(w).append(' ').append(h).append(" re f\n")
          .append("0 0 0 rg\n");
    }

    /** Horizontal rule, 0.5 pt wide. rgb = stroke colour. */
    private static void hLine(StringBuilder cs, int x, int y, int w, String rgb) {
        cs.append(rgb).append(" RG\n0.5 w\n")
          .append(x).append(' ').append(y).append(" m ")
          .append(x + w).append(' ').append(y).append(" l S\n")
          .append("0 0 0 RG\n");
    }

    /** Left-aligned text. */
    private static void text(StringBuilder cs,
                              String font, int size,
                              int x, int y, String rgb, String str) {
        cs.append("BT /").append(font).append(' ').append(size).append(" Tf\n")
          .append(rgb).append(" rg\n")
          .append(x).append(' ').append(y).append(" Td (")
          .append(escapePdf(str)).append(") Tj ET\n")
          .append("0 0 0 rg\n");
    }

    /**
     * Right-aligned text.
     * We approximate string width: avgCharWidth ≈ size × 0.52 (Helvetica metrics).
     */
    private static void textRight(StringBuilder cs,
                                   String font, int size,
                                   int rightX, int y, String rgb, String str) {
        int x = rightX - (int)(str.length() * size * 0.52);
        text(cs, font, size, x, y, rgb, str);
    }

    /** Centre-aligned text. */
    private static void textCenter(StringBuilder cs,
                                    String font, int size,
                                    int centreX, int y, String rgb, String str) {
        int x = centreX - (int)(str.length() * size * 0.52) / 2;
        text(cs, font, size, x, y, rgb, str);
    }

    // ── Formatting / escaping helpers ────────────────────────────────────────────

    /** Formats a BigDecimal as "12,500.00". */
    private static String fmt(BigDecimal v) {
        return v == null ? "0.00" : String.format("%,.2f", v);
    }

    private static String safe(String s, String fallback) {
        return (s == null || s.isBlank()) ? fallback : s;
    }
    private static String safe(String s) { return safe(s, ""); }

    /**
     * Escapes a string for embedding inside a PDF literal string  ( ... ).
     * Rules: escape '(', ')', '\'; strip any non-Latin-1 characters.
     */
    private static String escapePdf(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 4);
        for (char c : s.toCharArray()) {
            if      (c == '(')   sb.append("\\(");
            else if (c == ')')   sb.append("\\)");
            else if (c == '\\')  sb.append("\\\\");
            else if (c > 126)    sb.append('?');   // keep ASCII/Latin-1 only
            else                 sb.append(c);
        }
        return sb.toString();
    }

    /** Writes a String as ISO-8859-1 bytes. */
    private static void write(ByteArrayOutputStream buf, String s) throws IOException {
        buf.write(s.getBytes(StandardCharsets.ISO_8859_1));
    }
}
