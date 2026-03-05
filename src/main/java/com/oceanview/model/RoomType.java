package com.oceanview.model;

import java.math.BigDecimal;

public class RoomType {
    private int typeId;
    private String typeName;
    private BigDecimal baseRate;
    private String description;

    // Getters and Setters
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public BigDecimal getBaseRate() { return baseRate; }
    public void setBaseRate(BigDecimal baseRate) { this.baseRate = baseRate; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}

