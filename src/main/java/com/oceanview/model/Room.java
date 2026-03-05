package com.oceanview.model;

public class Room {
    private int roomId;
    private String roomNumber;
    private int typeId;
    private String typeName; // For display purposes (joined data)
    private String status; // AVAILABLE, OCCUPIED, UNDER_MAINTENANCE
    private int floorNumber;

    // Getters and Setters
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getFloorNumber() { return floorNumber; }
    public void setFloorNumber(int floorNumber) { this.floorNumber = floorNumber; }
}

