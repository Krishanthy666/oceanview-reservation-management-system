package com.oceanview.service;

import com.oceanview.config.AppConfig;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * ACADEMIC NOTE:
 * Service Layer Pattern:
 * This class contains business logic. It does not know about HTTP, Servlets, or Databases.
 * It only knows about Math and Rules. This makes it reusable and testable.
 */
public class BillingService {

    /**
     * Calculates the total cost of a stay.
     * Formula: (Nights * BaseRate) + ServiceCharge + Tax
     */
    public BillingResult calculateBilling(LocalDate checkIn, LocalDate checkOut, BigDecimal baseRate) {
        // 1. Calculate number of nights
        long nights = ChronoUnit.DAYS.between(checkIn, checkOut);

        if (nights <= 0) {
            return null; // Invalid dates
        }

        // 2. Calculate Base Cost
        BigDecimal totalBase = baseRate.multiply(new BigDecimal(nights));

        // 3. Calculate Service Charge (e.g., 10%)
        BigDecimal serviceCharge = totalBase.multiply(BigDecimal.valueOf(AppConfig.getServiceCharge()));

        // 4. Calculate Tax (e.g., 12% on Base + Service)
        BigDecimal taxableAmount = totalBase.add(serviceCharge);
        BigDecimal tax = taxableAmount.multiply(BigDecimal.valueOf(AppConfig.getTaxRate()));

        // 5. Grand Total
        BigDecimal grandTotal = totalBase.add(serviceCharge).add(tax);

        // Round to 2 decimal places
        grandTotal = grandTotal.setScale(2, RoundingMode.HALF_UP);
        tax = tax.setScale(2, RoundingMode.HALF_UP);
        serviceCharge = serviceCharge.setScale(2, RoundingMode.HALF_UP);

        return new BillingResult(nights, totalBase, serviceCharge, tax, grandTotal);
    }

    /**
     * Inner class to hold the result data.
     * This acts as a DTO (Data Transfer Object).
     */
    public static class BillingResult {
        public long nights;
        public BigDecimal baseCost;
        public BigDecimal serviceCharge;
        public BigDecimal tax;
        public BigDecimal total;

        public BillingResult(long nights, BigDecimal baseCost, BigDecimal serviceCharge, BigDecimal tax, BigDecimal total) {
            this.nights = nights;
            this.baseCost = baseCost;
            this.serviceCharge = serviceCharge;
            this.tax = tax;
            this.total = total;
        }
    }
}

