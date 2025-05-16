-- Dropping existing tables if they exist before creating them

-- Drop Customer table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Customer CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Menu_Item table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Menu_Item CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Orders table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Orders CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Order_Menu table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Order_Menu CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Supplier table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Supplier CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Inventory table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Inventory CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Employee table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Employee CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Driver table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Driver CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop KitchenStaff table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE KitchenStaff CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Cashier table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Cashier CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Delivery table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Delivery CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Payment table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Payment CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Cash table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Cash CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Card table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Card CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Creating tables
-- 1. CUSTOMER
CREATE TABLE Customer (
    Customer_ID        NUMBER PRIMARY KEY,
    Cus_Name           VARCHAR2(100) NOT NULL,
    Cus_Contact_Num    VARCHAR2(20),
    Cus_Loyalty        VARCHAR2(20) CHECK (Cus_Loyalty IN ('Yes', 'No')),
    CONSTRAINT uc_customer_name UNIQUE (Cus_Name)
);

-- 2. MENU ITEM
CREATE TABLE Menu_Item (
    Item_ID            NUMBER PRIMARY KEY,
    Menu_Name          VARCHAR2(100) NOT NULL,
    Menu_Description   VARCHAR2(255),
    Menu_Price         NUMBER(6,2) NOT NULL,
    Menu_Ingredients   VARCHAR2(255),
    Menu_Allergen      VARCHAR2(255),
    CONSTRAINT uc_menu_item_name UNIQUE (Menu_Name)
);

-- 3. ORDER
CREATE TABLE Orders (
    Order_ID           NUMBER PRIMARY KEY,
    Customer_ID        NUMBER NOT NULL,
    Order_Date         DATE DEFAULT SYSDATE,
    Order_Status       VARCHAR2(50),
    Order_Total_Amount NUMBER(8,2),
    CONSTRAINT fk_order_customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID),
    CONSTRAINT chk_order_status CHECK (Order_Status IN ('Pending', 'Completed', 'Cancelled'))
);

-- 4. ORDER_MENU (Bridge table)
CREATE TABLE Order_Menu (
    Order_ID           NUMBER,
    Item_ID            NUMBER,
    ORD_Quantity       NUMBER(3) NOT NULL,
    PRIMARY KEY (Order_ID, Item_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Item_ID) REFERENCES Menu_Item(Item_ID)
);

-- 5. SUPPLIER
CREATE TABLE Supplier (
    Supplier_ID        NUMBER PRIMARY KEY,
    Supplier_Name      VARCHAR2(100) NOT NULL,
    Supplier_Contac_Num VARCHAR2(20),
    Supplier_Delivery_Schedule VARCHAR2(100)
);

-- 6. INVENTORY
CREATE TABLE Inventory (
    Ingredient_ID      NUMBER PRIMARY KEY,
    Supplier_ID        NUMBER,
    Inv_Name           VARCHAR2(100),
    Inv_Quantity       NUMBER,
    Inv_Expiry_Date    DATE,
    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID)
);

-- 7. EMPLOYEE (Super entity)
CREATE TABLE Employee (
    Emp_ID             NUMBER PRIMARY KEY,
    Emp_Name           VARCHAR2(100) NOT NULL,
    Emp_Role           VARCHAR2(50),
    Emp_Contact        VARCHAR2(20)
);

-- 8. DRIVER (Subtype of Employee)
CREATE TABLE Driver (
    Emp_ID             NUMBER PRIMARY KEY,
    Emp_Wage           NUMBER(8,2),
    Emp_Shift_Details  VARCHAR2(100),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID)
);

-- 9. KITCHEN STAFF (Subtype)
CREATE TABLE KitchenStaff (
    Emp_ID             NUMBER PRIMARY KEY,
    Emp_Wage           NUMBER(8,2),
    Emp_Shift_Details  VARCHAR2(100),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID)
);

-- 10. CASHIER (Subtype)
CREATE TABLE Cashier (
    Emp_ID             NUMBER PRIMARY KEY,
    Emp_Wage           NUMBER(8,2),
    Emp_Shift_Details  VARCHAR2(100),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID)
);

-- 11. DELIVERY (Bridge between Orders and Employee[Driver])
CREATE TABLE Delivery (
    Delivery_ID           NUMBER PRIMARY KEY,
    Order_ID              NUMBER NOT NULL,
    Emp_ID                NUMBER NOT NULL,
    Delivery_Pickup_Time  TIMESTAMP,
    Delivery_Dropoff_Time TIMESTAMP,
    Delivery_Status       VARCHAR2(50),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Emp_ID) REFERENCES Driver(Emp_ID)
);

-- 12. PAYMENT
CREATE TABLE Payment (
    Payment_ID            NUMBER PRIMARY KEY,
    Order_ID              NUMBER NOT NULL,
    Pay_Method            VARCHAR2(20) CHECK (Pay_Method IN ('Cash', 'Card')),
    Pay_Loyalty_Discount  NUMBER(5,2),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
);

-- 13. CASH PAYMENT (Subtype of Payment)
CREATE TABLE Cash (
    Payment_ID            NUMBER PRIMARY KEY,
    FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
);

-- 14. CARD PAYMENT (Subtype of Payment)
CREATE TABLE Card (
    Payment_ID            NUMBER PRIMARY KEY,
    Card_Name             VARCHAR2(100),
    Card_Num              VARCHAR2(20),
    FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
);

-- Drop existing indexes and views if they exist to avoid conflicts
BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_customer_name';
    EXECUTE IMMEDIATE 'DROP INDEX idx_customer_contact';
    EXECUTE IMMEDIATE 'DROP INDEX idx_menu_item_name';
    EXECUTE IMMEDIATE 'DROP INDEX idx_menu_item_price';
    EXECUTE IMMEDIATE 'DROP INDEX idx_orders_customer_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_orders_status';
    EXECUTE IMMEDIATE 'DROP INDEX idx_ordermenu_order_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_ordermenu_item_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_supplier_name';
    EXECUTE IMMEDIATE 'DROP INDEX idx_supplier_contact';
    EXECUTE IMMEDIATE 'DROP INDEX idx_inventory_supplier_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_inventory_name';
    EXECUTE IMMEDIATE 'DROP INDEX idx_employee_name';
    EXECUTE IMMEDIATE 'DROP INDEX idx_employee_role';
    EXECUTE IMMEDIATE 'DROP INDEX idx_driver_wage';
    EXECUTE IMMEDIATE 'DROP INDEX idx_driver_shift';
    EXECUTE IMMEDIATE 'DROP INDEX idx_kitchenstaff_wage';
    EXECUTE IMMEDIATE 'DROP INDEX idx_kitchenstaff_shift';
    EXECUTE IMMEDIATE 'DROP INDEX idx_cashier_wage';
    EXECUTE IMMEDIATE 'DROP INDEX idx_cashier_shift';
    EXECUTE IMMEDIATE 'DROP INDEX idx_delivery_order_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_delivery_emp_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_payment_order_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_payment_method';
    EXECUTE IMMEDIATE 'DROP INDEX idx_cash_payment_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_cash_payment_method';
    EXECUTE IMMEDIATE 'DROP INDEX idx_card_payment_id';
    EXECUTE IMMEDIATE 'DROP INDEX idx_card_card_name';
    EXECUTE IMMEDIATE 'DROP VIEW Customer_Spending';
    EXECUTE IMMEDIATE 'DROP VIEW Menu_Sales_Report';
    EXECUTE IMMEDIATE 'DROP VIEW Low_Inventory';
    EXECUTE IMMEDIATE 'DROP VIEW Driver_Delivery_Log';
    EXECUTE IMMEDIATE 'DROP VIEW Payment_Summary';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore errors if objects do not exist
END;
/

-- Customer Table Indexes
CREATE INDEX idx_customer_name ON Customer(Cus_Name);
CREATE INDEX idx_customer_contact ON Customer(Cus_Contact_Num);

-- Menu_Item Table Indexes
CREATE INDEX idx_menu_item_name ON Menu_Item(Menu_Name);
CREATE INDEX idx_menu_item_price ON Menu_Item(Menu_Price);

-- Orders Table Indexes
CREATE INDEX idx_orders_customer_id ON Orders(Customer_ID);
CREATE INDEX idx_orders_status ON Orders(Order_Status);

-- Order_Menu Table Indexes
CREATE INDEX idx_ordermenu_order_id ON Order_Menu(Order_ID);
CREATE INDEX idx_ordermenu_item_id ON Order_Menu(Item_ID);

-- Supplier Table Indexes
CREATE INDEX idx_supplier_name ON Supplier(Supplier_Name);
CREATE INDEX idx_supplier_contact ON Supplier(Supplier_Contac_Num);

-- Inventory Table Indexes
CREATE INDEX idx_inventory_supplier_id ON Inventory(Supplier_ID);
CREATE INDEX idx_inventory_name ON Inventory(Inv_Name);

-- Employee Table Indexes
CREATE INDEX idx_employee_name ON Employee(Emp_Name);
CREATE INDEX idx_employee_role ON Employee(Emp_Role);

-- Driver Table Indexes
CREATE INDEX idx_driver_wage ON Driver(Emp_Wage);
CREATE INDEX idx_driver_shift ON Driver(Emp_Shift_Details);

-- KitchenStaff Table Indexes
CREATE INDEX idx_kitchenstaff_wage ON KitchenStaff(Emp_Wage);
CREATE INDEX idx_kitchenstaff_shift ON KitchenStaff(Emp_Shift_Details);

-- Cashier Table Indexes
CREATE INDEX idx_cashier_wage ON Cashier(Emp_Wage);
CREATE INDEX idx_cashier_shift ON Cashier(Emp_Shift_Details);

-- Delivery Table Indexes
CREATE INDEX idx_delivery_order_id ON Delivery(Order_ID);
CREATE INDEX idx_delivery_emp_id ON Delivery(Emp_ID);

-- Payment Table Indexes
CREATE INDEX idx_payment_order_id ON Payment(Order_ID);
CREATE INDEX idx_payment_method ON Payment(Pay_Method);

-- Cash Table Indexes
CREATE INDEX idx_cash_payment_id ON Cash(Payment_ID);
CREATE INDEX idx_cash_payment_method ON Cash(Payment_ID);

-- Card Table Indexes
CREATE INDEX idx_card_payment_id ON Card(Payment_ID);
CREATE INDEX idx_card_card_name ON Card(Card_Name);

-- Customer_Spending View
CREATE OR REPLACE VIEW Customer_Spending AS
SELECT 
    c.Customer_ID,
    c.Cus_Name,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    SUM(o.Order_Total_Amount) AS Total_Spent
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Cus_Name;

-- Menu_Sales_Report View
CREATE OR REPLACE VIEW Menu_Sales_Report AS
SELECT 
    m.Item_ID,
    m.Menu_Name,
    SUM(om.ORD_Quantity) AS Total_Units_Sold,
    SUM(om.ORD_Quantity * m.Menu_Price) AS Total_Revenue
FROM Menu_Item m
JOIN Order_Menu om ON m.Item_ID = om.Item_ID
GROUP BY m.Item_ID, m.Menu_Name
ORDER BY Total_Revenue DESC;

-- Low_Inventory View
CREATE OR REPLACE VIEW Low_Inventory AS
SELECT 
    i.Ingredient_ID,
    i.Inv_Name,
    i.Inv_Quantity,
    i.Inv_Expiry_Date,
    s.Supplier_Name
FROM Inventory i
JOIN Supplier s ON i.Supplier_ID = s.Supplier_ID
WHERE i.Inv_Quantity < 10;

-- Driver_Delivery_Log View
CREATE OR REPLACE VIEW Driver_Delivery_Log AS
SELECT 
    d.Delivery_ID,
    dr.Emp_ID,
    e.Emp_Name,
    d.Order_ID,
    d.Delivery_Pickup_Time,
    d.Delivery_Dropoff_Time,
    d.Delivery_Status
FROM Delivery d
JOIN Driver dr ON d.Emp_ID = dr.Emp_ID
JOIN Employee e ON dr.Emp_ID = e.Emp_ID;

-- Payment_Summary View
CREATE OR REPLACE VIEW Payment_Summary AS
SELECT 
    p.Payment_ID,
    p.Order_ID,
    p.Pay_Method,
    p.Pay_Loyalty_Discount,
    o.Order_Total_Amount,
    (o.Order_Total_Amount - NVL(p.Pay_Loyalty_Discount, 0)) AS Final_Amount
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID;



--ADD VALUES TO TABLES

-- 1. CUSTOMER
INSERT INTO Customer (Customer_ID, Cus_Name, Cus_Contact_Num, Cus_Loyalty)
VALUES (1, 'John Doe', '123-456-7890', 'Yes');
INSERT INTO Customer (Customer_ID, Cus_Name, Cus_Contact_Num, Cus_Loyalty)
VALUES (2, 'Jane Smith', '234-567-8901', 'No');
INSERT INTO Customer (Customer_ID, Cus_Name, Cus_Contact_Num, Cus_Loyalty)
VALUES (3, 'Emily Johnson', '345-678-9012', 'Yes');
INSERT INTO Customer (Customer_ID, Cus_Name, Cus_Contact_Num, Cus_Loyalty)
VALUES (4, 'Michael Brown', '456-789-0123', 'No');

-- 2. MENU ITEM
INSERT INTO Menu_Item (Item_ID, Menu_Name, Menu_Description, Menu_Price, Menu_Ingredients, Menu_Allergen)
VALUES (1, 'Pizza Margherita', 'Classic pizza with tomato sauce, mozzarella, and basil', 12.50, 'Tomato, Mozzarella, Basil', 'Dairy');
INSERT INTO Menu_Item (Item_ID, Menu_Name, Menu_Description, Menu_Price, Menu_Ingredients, Menu_Allergen)
VALUES (2, 'Cheeseburger', 'Beef patty with cheese, lettuce, tomato, and special sauce', 8.99, 'Beef, Cheese, Lettuce, Tomato, Bun', 'Dairy, Gluten');
INSERT INTO Menu_Item (Item_ID, Menu_Name, Menu_Description, Menu_Price, Menu_Ingredients, Menu_Allergen)
VALUES (3, 'Caesar Salad', 'Crisp romaine lettuce with Caesar dressing and croutons', 7.00, 'Lettuce, Croutons, Caesar Dressing', 'Gluten, Dairy');
INSERT INTO Menu_Item (Item_ID, Menu_Name, Menu_Description, Menu_Price, Menu_Ingredients, Menu_Allergen)
VALUES (4, 'Spaghetti Carbonara', 'Pasta with creamy egg-based sauce, pancetta, and Parmesan', 14.00, 'Pasta, Egg, Pancetta, Parmesan', 'Gluten, Dairy, Egg');

-- 3. ORDER
INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Order_Status, Order_Total_Amount)
VALUES (1, 1, SYSDATE, 'Pending', 25.50);
INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Order_Status, Order_Total_Amount)
VALUES (2, 2, SYSDATE, 'Completed', 18.99);
INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Order_Status, Order_Total_Amount)
VALUES (3, 3, SYSDATE, 'Pending', 35.00);
INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Order_Status, Order_Total_Amount)
VALUES (4, 4, SYSDATE, 'Completed', 22.75);

-- 4. ORDER_MENU (Bridge table)
INSERT INTO Order_Menu (Order_ID, Item_ID, ORD_Quantity)
VALUES (1, 1, 2);
INSERT INTO Order_Menu (Order_ID, Item_ID, ORD_Quantity)
VALUES (2, 2, 1);
INSERT INTO Order_Menu (Order_ID, Item_ID, ORD_Quantity)
VALUES (3, 3, 3);
INSERT INTO Order_Menu (Order_ID, Item_ID, ORD_Quantity)
VALUES (4, 4, 1);

-- 5. SUPPLIER
INSERT INTO Supplier (Supplier_ID, Supplier_Name, Supplier_Contac_Num, Supplier_Delivery_Schedule)
VALUES (1, 'Food Supply Co.', '555-111-2222', 'Monday to Friday');
INSERT INTO Supplier (Supplier_ID, Supplier_Name, Supplier_Contac_Num, Supplier_Delivery_Schedule)
VALUES (2, 'Veggie Farms', '555-333-4444', 'Tuesday and Thursday');
INSERT INTO Supplier (Supplier_ID, Supplier_Name, Supplier_Contac_Num, Supplier_Delivery_Schedule)
VALUES (3, 'Cheese World', '555-555-6666', 'Monday, Wednesday, Friday');
INSERT INTO Supplier (Supplier_ID, Supplier_Name, Supplier_Contac_Num, Supplier_Delivery_Schedule)
VALUES (4, 'Pasta Masters', '555-777-8888', 'Monday to Saturday');

-- 6. INVENTORY
INSERT INTO Inventory (Ingredient_ID, Supplier_ID, Inv_Name, Inv_Quantity, Inv_Expiry_Date)
VALUES (1, 1, 'Tomato', 100, TO_DATE('2025-05-31', 'YYYY-MM-DD'));
INSERT INTO Inventory (Ingredient_ID, Supplier_ID, Inv_Name, Inv_Quantity, Inv_Expiry_Date)
VALUES (2, 2, 'Lettuce', 50, TO_DATE('2025-06-15', 'YYYY-MM-DD'));
INSERT INTO Inventory (Ingredient_ID, Supplier_ID, Inv_Name, Inv_Quantity, Inv_Expiry_Date)
VALUES (3, 3, 'Cheese', 80, TO_DATE('2025-07-01', 'YYYY-MM-DD'));
INSERT INTO Inventory (Ingredient_ID, Supplier_ID, Inv_Name, Inv_Quantity, Inv_Expiry_Date)
VALUES (4, 4, 'Pasta', 200, TO_DATE('2025-08-15', 'YYYY-MM-DD'));

-- 7. EMPLOYEE
INSERT INTO Employee (Emp_ID, Emp_Name, Emp_Role, Emp_Contact)
VALUES (1, 'Alice Williams', 'Chef', '123-321-1234');
INSERT INTO Employee (Emp_ID, Emp_Name, Emp_Role, Emp_Contact)
VALUES (2, 'Bob Harris', 'Manager', '234-432-2345');
INSERT INTO Employee (Emp_ID, Emp_Name, Emp_Role, Emp_Contact)
VALUES (3, 'Charlie Brown', 'Server', '345-543-3456');
INSERT INTO Employee (Emp_ID, Emp_Name, Emp_Role, Emp_Contact)
VALUES (4, 'David Lee', 'Dishwasher', '456-654-4567');

-- 8. DRIVER
INSERT INTO Driver (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (1, 1500.00, 'Morning Shift');
INSERT INTO Driver (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (2, 1600.00, 'Afternoon Shift');
INSERT INTO Driver (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (3, 1700.00, 'Night Shift');
INSERT INTO Driver (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (4, 1800.00, 'Morning Shift');

-- 9. KITCHEN STAFF
INSERT INTO KitchenStaff (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (1, 1200.00, 'Morning Shift');
INSERT INTO KitchenStaff (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (2, 1300.00, 'Afternoon Shift');
INSERT INTO KitchenStaff (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (3, 1400.00, 'Night Shift');
INSERT INTO KitchenStaff (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (4, 1500.00, 'Morning Shift');

-- 10. CASHIER
INSERT INTO Cashier (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (1, 1200.00, 'Morning Shift');
INSERT INTO Cashier (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (2, 1300.00, 'Afternoon Shift');
INSERT INTO Cashier (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (3, 1400.00, 'Night Shift');
INSERT INTO Cashier (Emp_ID, Emp_Wage, Emp_Shift_Details)
VALUES (4, 1500.00, 'Morning Shift');

-- 11. DELIVERY
INSERT INTO Delivery (Delivery_ID, Order_ID, Emp_ID, Delivery_Pickup_Time, Delivery_Dropoff_Time, Delivery_Status)
VALUES (1, 1, 1, TO_TIMESTAMP('2025-05-09 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-05-09 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Completed');
INSERT INTO Delivery (Delivery_ID, Order_ID, Emp_ID, Delivery_Pickup_Time, Delivery_Dropoff_Time, Delivery_Status)
VALUES (2, 2, 2, TO_TIMESTAMP('2025-05-09 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-05-09 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Pending');
INSERT INTO Delivery (Delivery_ID, Order_ID, Emp_ID, Delivery_Pickup_Time, Delivery_Dropoff_Time, Delivery_Status)
VALUES (3, 3, 3, TO_TIMESTAMP('2025-05-09 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-05-09 14:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Completed');
INSERT INTO Delivery (Delivery_ID, Order_ID, Emp_ID, Delivery_Pickup_Time, Delivery_Dropoff_Time, Delivery_Status)
VALUES (4, 4, 4, TO_TIMESTAMP('2025-05-09 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-05-09 16:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Pending');

-- 12. PAYMENT
INSERT INTO Payment (Payment_ID, Order_ID, Pay_Method, Pay_Loyalty_Discount)
VALUES (1, 1, 'Cash', 0.00);
INSERT INTO Payment (Payment_ID, Order_ID, Pay_Method, Pay_Loyalty_Discount)
VALUES (2, 2, 'Card', 5.00);
INSERT INTO Payment (Payment_ID, Order_ID, Pay_Method, Pay_Loyalty_Discount)
VALUES (3, 3, 'Cash', 2.00);
INSERT INTO Payment (Payment_ID, Order_ID, Pay_Method, Pay_Loyalty_Discount)
VALUES (4, 4, 'Card', 3.00);

-- 13. CASH PAYMENT
INSERT INTO Cash (Payment_ID)
VALUES (1);
INSERT INTO Cash (Payment_ID)
VALUES (3);
INSERT INTO Cash (Payment_ID)
VALUES (2);
INSERT INTO Cash (Payment_ID)
VALUES (4);

-- 14. CARD PAYMENT
INSERT INTO Card (Payment_ID, Card_Name, Card_Num)
VALUES (2, 'Visa', '4111111111111111');
INSERT INTO Card (Payment_ID, Card_Name, Card_Num)
VALUES (4, 'Mastercard', '5500000000000004');
INSERT INTO Card (Payment_ID, Card_Name, Card_Num)
VALUES (1, 'Visa', '4111111111111111');
INSERT INTO Card (Payment_ID, Card_Name, Card_Num)
VALUES (3, 'Mastercard', '5500000000000004');


--BASED ON NFORMATION REQUIREMENTS OF THE COMPANY

--List all menu items that contain a specific allergen ("Peanuts"):

SELECT m.Menu_Name, m.Menu_Ingredients
FROM Menu_Item m
WHERE m.Menu_Allergen LIKE '%Peanuts%';


--List menu items and their prices, ordered by price in descending order:

SELECT Menu_Name, Menu_Price
FROM Menu_Item
ORDER BY Menu_Price DESC;


--Show the total amount spent by each customer (sum of all orders placed):

SELECT c.Cus_Name, SUM(o.Order_Total_Amount) AS Total_Spent
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Cus_Name;


-- Get the details of employees who have a wage greater than 5000 and work the morning shift (filter by shift details):

SELECT e.Emp_Name, e.Emp_Role, k.Emp_Wage, k.Emp_Shift_Details
FROM Employee e
JOIN KitchenStaff k ON e.Emp_ID = k.Emp_ID
WHERE k.Emp_Wage > 5000 AND k.Emp_Shift_Details LIKE '%morning%';


--List orders placed in the last 7 days along with the customer name:

SELECT o.Order_ID, o.Order_Date, c.Cus_Name
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Date > SYSDATE - 7;

-- Get all the suppliers for ingredients that are low in stock (less than 10 units):

SELECT s.Supplier_Name, i.Inv_Name, i.Inv_Quantity
FROM Inventory i
JOIN Supplier s ON i.Supplier_ID = s.Supplier_ID
WHERE i.Inv_Quantity < 10;


--Show the total number of deliveries handled by each driver:

SELECT e.Emp_Name, COUNT(d.Delivery_ID) AS Total_Deliveries
FROM Delivery d
JOIN Driver dr ON d.Emp_ID = dr.Emp_ID
JOIN Employee e ON dr.Emp_ID = e.Emp_ID
GROUP BY e.Emp_Name;


--LIMITATIONS
--Limiting Rows with ROWNUM
-- Display the first 4 records from the Customer table:

SELECT * FROM Customer
WHERE ROWNUM <= 4;

select * from table(dbms_xplan.display_cursor(sql_id=>'f3bvpc9xwhgnz', format=>'ALLSTATS LAST'));


--Limiting Columns with SELECT
-- Display only the Cus_Name and Cus_Contact_Num columns from the Customer table:

SELECT Cus_Name, Cus_Contact_Num FROM Customer;

--Limiting Rows and Columns
--Display the first 4 rows with only Item_ID and Menu_Name from the Menu_Item table

SELECT Item_ID, Menu_Name FROM Menu_Item
FETCH FIRST 4 ROWS ONLY;





--SORTING

--Sort the Customer table by Cus_Name in ascending order:

SELECT * FROM Customer
ORDER BY Cus_Name ASC;

--Sort the Orders table by Order_Date in descending order:

SELECT * FROM Orders
ORDER BY Order_Date DESC;

--Multiple Sorting Criteria

SELECT * FROM Employee
ORDER BY Emp_Role ASC, Emp_Name DESC;

-- Sort the Delivery table by Delivery_Status, placing NULL values last:

SELECT * FROM Delivery
ORDER BY Delivery_Status NULLS LAST;





--LIKE, AND, and OR

-- Find all customers whose names start with 'J':

SELECT * FROM Customer
WHERE Cus_Name LIKE 'J%';


--Using AND
--Find orders with a total amount greater than 20 and a status of 'Completed':

SELECT * FROM Orders
WHERE Order_Total_Amount > 20 AND Order_Status = 'Completed';

--Using OR
--Find menu items that are either priced above 10 or are vegetarian:

SELECT * FROM Menu_Item
WHERE Menu_Price > 10 OR Menu_Description LIKE '%vegetarian%';

--Combining AND and OR
--Find orders that are either completed or have a total amount greater than 30 and are still pending:

SELECT * FROM Orders
WHERE Order_Status = 'Completed' OR (Order_Total_Amount > 30 AND Order_Status = 'Pending');




--VARIABLES AND CHARACTER FUNCTIONS


--Using Variables
--Declare a variable and use it in a query:

DECLARE
  v_discount NUMBER := 5;
BEGIN
  SELECT * FROM Orders
  WHERE Order_Total_Amount > v_discount;
END;


--Using UPPER() Function
--Convert the Cus_Name of all customers to uppercase:

SELECT UPPER(Cus_Name) AS Upper_Name FROM Customer;


--Using SUBSTR() Function
--Extract the first 5 characters of Menu_Name from the Menu_Item table:

SELECT SUBSTR(Menu_Name, 1, 5) AS Short_Menu_Name
FROM Menu_Item;


--Round or Trunc


--Using ROUND() Function
--Round the Order_Total_Amount to 2 decimal places:

SELECT ROUND(Order_Total_Amount, 2) AS Rounded_Amount
FROM Orders;



--Using TRUNC() Function
--Truncate the Order_Total_Amount to 2 decimal places

SELECT TRUNC(Order_Total_Amount, 2) AS Truncated_Amount
FROM Orders;





--Date Functions



--Using SYSDATE 
--Retrieve the current system date

SELECT SYSDATE FROM DUAL;


--Using TO_DATE() Function
--Convert a string to a date format:

SELECT TO_DATE('2025-05-09', 'YYYY-MM-DD') AS Order_Date
FROM DUAL;


--Using ADD_MONTHS() Function
--Add 3 months to the current date:

SELECT ADD_MONTHS(SYSDATE, 3) AS Date_3_Months_Later
FROM DUAL;



--AGGREGATE FUNCTIONS



--Using COUNT()
--Count the total number of customers:

SELECT COUNT(*) AS Total_Customers
FROM Customer;


--Using SUM()
--Find the total amount of all completed orders:

SELECT SUM(Order_Total_Amount) AS Total_Sales
FROM Orders
WHERE Order_Status = 'Completed';

--Using AVG()
--Find the average menu price:

SELECT AVG(Menu_Price) AS Average_Price
FROM Menu_Item;

--Using MAX()
--Find the highest order total amount:

SELECT MAX(Order_Total_Amount) AS Max_Order_Amount
FROM Orders;




--GROUP BY AND HAVING



--Using GROUP BY
--Group the Orders table by Order_Status and calculate the total amount per status:

SELECT Order_Status, SUM(Order_Total_Amount) AS Total_Amount
FROM Orders
GROUP BY Order_Status;


--Using HAVING with GROUP BY
--Group the Orders table by Order_Status and only show statuses where the total amount is greater than 30:

SELECT Order_Status, SUM(Order_Total_Amount) AS Total_Amount
FROM Orders
GROUP BY Order_Status
HAVING SUM(Order_Total_Amount) > 30;



--Using GROUP BY with COUNT()
--Count the number of orders for each customer:

SELECT Customer_ID, COUNT(*) AS Order_Count
FROM Orders
GROUP BY Customer_ID;





--JOINS


--INNER JOIN � List all orders with customer names

SELECT o.Order_ID, c.Cus_Name, o.Order_Date, o.Order_Total_Amount
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID



--LEFT JOIN � Show all menu items and any orders that include them (if any)

SELECT m.Menu_Name, o.Order_ID, o.Order_Status
FROM Menu_Item m
LEFT JOIN Orders o ON m.Item_ID = o.Item_ID


--SUBQUERIES

--Simple Subquery (Single Row) � Find customers who placed orders above the average total amount

SELECT * FROM Customer
WHERE Customer_ID IN (
  SELECT Customer_ID FROM Orders
  WHERE Order_Total_Amount > (
    SELECT AVG(Order_Total_Amount) FROM Orders
  )
);


--Correlated Subquery � List customers who placed more than 1 order

SELECT Cus_Name FROM Customer c
WHERE EXISTS (
  SELECT 1 FROM Orders o
  WHERE o.Customer_ID = c.Customer_ID
  HAVING COUNT(*) > 1
);


--Subquery with IN Clause � List employees who handled deliveries

SELECT * FROM Employee
WHERE Emp_ID IN (
  SELECT Emp_ID FROM Delivery
);



