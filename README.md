# Ocean View Room Reservation System

A simple Hotel Room Reservation Management System developed using **Java** and **MySQL** for the Advanced Programming module.

The system helps hotel staff manage reservations, calculate billing and maintain room records efficiently. It replaces manual booking processes with a structured digital system.

---

## Project Overview

Ocean View Resort currently manages reservations manually which can lead to booking conflicts and delays.  
This system provides a simple computerized solution for managing reservations, guest details and billing operations.

The application allows hotel staff to:

- Login securely
- Add new room reservations
- View reservation details
- Update or cancel reservations
- Calculate billing automatically
- Manage room availability
- Generate basic reports

---

## Technologies Used

- Java (Core Java)
- MySQL Database
- JDBC for database connectivity
- Git and GitHub for version control
- PlantUML for system diagrams

---

## System Architecture

The system follows a **three-tier architecture**:

1. **Presentation Layer**
   - Java user interface
   - Handles user input and display

2. **Business Logic Layer**
   - ReservationService
   - BillingService
   - AuthenticationService

3. **Data Access Layer**
   - DAO / Repository classes
   - Handles database operations

---

## Database Structure

Main tables used in the system:

- users
- rooms
- room_types
- reservations

The database is designed using relational principles with primary and foreign key relationships.

---

## Key Features

- User Authentication (Admin / Staff)
- Add Reservation
- View Reservation
- Update Reservation
- Cancel Reservation
- Calculate Bill
- Basic Reports
- Input Validation
- Error Handling

---

## UML Diagrams

The following UML diagrams were created for system design:

- Use Case Diagram
- Class Diagram
- Sequence Diagrams
- System Architecture Diagram
- Entity Relationship Diagram

These diagrams help explain system structure and interactions.

---

## How to Run the Project

1. Clone the repository
