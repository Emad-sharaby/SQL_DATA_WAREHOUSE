# Data Catalog for Gold Layer

---

### 1. **gold.dim_customers**
- **Purpose:** Stores customer details
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_id      | INT           | Unique numerical identifier assigned to each customer.                                        |
| customer_number  | NVARCHAR(50)  | Alphanumeric identifier representing the customer.       |
| first_name       | NVARCHAR(50)  | The customer's first name.                                        |
| last_name        | NVARCHAR(50)  | The customer's last name.                                                      |
| country          | NVARCHAR(50)  | The country of residence for the customer.                                |
| marital_status   | NVARCHAR(50)  | The marital status of the customer.                               |
| gender           | NVARCHAR(50)  | The gender of the customer ('Male', 'Female', 'n/a').                                   |
| birthdate        | DATE          | The date of birth of the customer, formatted as YYYY-MM-DD.                |
| create_date      | DATE          | The date and time when the customer record was created in the system                          |

---

### 2. **gold.dim_products**
- **Purpose:** Provides information about the products and their attributes.
- **Columns:**

| Column Name         | Data Type     | Description                                                                                   |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_id          | INT           | A unique identifier assigned to the product for internal tracking and referencing.            |
| product_number      | NVARCHAR(50)  | Alphanumeric code representing the product. |
| product_name        | NVARCHAR(50)  | Descriptive name of the product.         |
| category_id         | NVARCHAR(50)  | A unique identifier for the product's category.     |
| category            | NVARCHAR(50)  | Category name of the product.  |
| subcategory         | NVARCHAR(50)  | A more detailed classification of the product within the category.      |
| maintenance_required| NVARCHAR(50)  | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                       |
| cost                | INT           | The cost of the product.                            |
| product_line        | NVARCHAR(50)  | The specific product line to which the product belongs.      |
| start_date          | DATE          | The date when the product became available for sale.|

---

### 3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | Alphanumeric identifier for each sales order.                      |
| product_key     | INT           | Surrogate key linking the order to the product dimension table.                               |
| customer_key    | INT           | Surrogate key linking the order to the customer dimension table.                              |
| order_date      | DATE          | The date when the order was placed.                                                           |
| shipping_date   | DATE          | The date when the order was shipped to the customer.                                          |
| due_date        | DATE          | The date when the order payment was due.                                                      |
| sales_amount    | INT           | The total monetary value of the sale.   |
| quantity        | INT           | The number of units of the product ordered for the line item.                       |
| price           | INT           | The price per unit of the product for the line item.      |
