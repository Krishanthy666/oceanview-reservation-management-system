package com.oceanview.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * ACADEMIC NOTE:
 * Security Utility for hashing passwords using SHA-256.
 * Never store plain text passwords.
 */
public class SecurityUtil {

    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Hashing algorithm not found.", e);
        }
    }
}

