package com.oceanview.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Reservation {
    private String guestName;
    private String guestAddress;
    private String guestContact;
    private int reservationId;


    private int roomId;       // Foreign Key
    private String roomNumber; // For display (Joined data)

    // Joined from room_types – populated only when fetching a single reservation for the invoice
    private String typeName;
    private BigDecimal baseRate;

    private LocalDate checkIn;
    private LocalDate checkOut;
    private BigDecimal totalCost;
    private String status;
    private int createdBy; // User ID

    // Getters and Setters
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }
    public String getGuestAddress() { return guestAddress; }
    public void setGuestAddress(String guestAddress) { this.guestAddress = guestAddress; }
    public String getGuestContact() { return guestContact; }
    public void setGuestContact(String guestContact) { this.guestContact = guestContact; }
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public BigDecimal getBaseRate() { return baseRate; }
    public void setBaseRate(BigDecimal baseRate) { this.baseRate = baseRate; }
    public LocalDate getCheckIn() { return checkIn; }
    public void setCheckIn(LocalDate checkIn) { this.checkIn = checkIn; }
    public LocalDate getCheckOut() { return checkOut; }
    public void setCheckOut(LocalDate checkOut) { this.checkOut = checkOut; }
    public BigDecimal getTotalCost() { return totalCost; }
    public void setTotalCost(BigDecimal totalCost) { this.totalCost = totalCost; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
}

