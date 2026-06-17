# Advanced Vehicle Sales Database System

This enterprise-grade relational database schema was designed and implemented as part of the **Advanced Database** module for the Bachelor of Science (BSc) in Computing program at **Arden University (Manchester)**. 

The system simulates a fully operational vehicle marketplace platform, managing data synchronization between multiple user classes (Buyers and Sellers), vehicle inventories, dynamic shipping logs, and automated real-time sales performance indicators.

## Architectural Highlights & Database Schema

The physical model is built around data integrity, professional optimization, and relational constraints:

* **Class Table Inheritance (Supertype/Subtype):** Implemented using a central `Users` table mapping out into distinct 1:1 relationships with `Buyers` and `Sellers` tables. This prevents core attribute redundancy while keeping domain profiles separated.
* **JSON Denormalization:** The `Buyers` schema incorporates a denormalized `Purchase_History` field leveraging a `JSON` object type. This provides quick access to client history for real-time dashboards without generating complex multitable overhead joins.
* **Performance Optimization:** Includes custom non-key indices like `idx_email` on the core user repository to accelerate authentication operations and quick lookup filters.
* **Domain Data Constraints:** Safe validation constraints utilizing auto-incrementing surrogate primary keys, default definitions (`ShippingStatus DEFAULT 'Dispatched'`), and `ENUM` domain data bindings (`Payment_Status`) to prevent data corruption.

---

## Core Database Architecture Components

The implementation goes beyond static tables, featuring programmatic database objects to drive automation:

### 1. Database Views
* **View 1:** Tailored to map specific enterprise reporting layouts.
* **View 2:** Designed to securely structure complex data joins for business intelligence consumption.

### 2. Stored Procedures
* **Procedure 1:** Encapsulates business logistics workflows natively inside the relational core engine.
* **Procedure 2:** Handles parametric reporting loops dynamically.

### 3. Automated Reporting Triggers
* **Sales Ledger Trigger:** An active database trigger bound to the `Order` ledger table. Whenever an order shifts status or a new acquisition record lands, the database trigger captures event variables and dynamically mutates or establishes a monthly operational timeline record inside the `Sales_Reports` table automatically.

---

## Repository Blueprint

```text
├── database/
│   ├── schema.sql        # Database structure (DDL - Tables, Views, Procedures & Triggers)
│   └── data.sql          # Production sample data & trigger validation tests (DML)
└── README.md             # Core portfolio documentation
