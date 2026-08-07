# Beep Beep - Database Documentation

## Overview

This document describes the database structure of the Beep Beep project.

The first version (MVP) is designed for Aleppo city and supports local stores. The database is designed to be scalable so that new categories, cities, and features can be added in the future without rebuilding the system.

---

# Database Design Principles

- Use integer primary keys.
- Use foreign keys to maintain data integrity.
- Avoid duplicated data.
- Separate entities into independent tables.
- Keep the database scalable and maintainable.
- Store image paths instead of image files.
- Preserve order history even if products change later.

---

# Tables

## users

### Purpose

Stores all application users.

### Columns

- id
- name
- phone
- email
- password
- role
- created_at
- updated_at

### Relations

- One user can have multiple addresses.
- One user has one shopping cart.
- One user can create many orders.
- One user can have many favorite products.

---

## stores

### Purpose

Stores all shops available in the application.

### Columns

- id
- name
- description
- phone
- address
- logo
- cover_image
- status
- created_at
- updated_at

### Relations

- One store contains many products.

---

## categories

### Purpose

Stores product categories.

Supports parent-child categories.

Example:

Clothes
 ├── Men
 ├── Women
 └── Kids

### Relations

- One category contains many products.
- One category can have child categories.

---

## products

### Purpose

Stores the main information of each product.

Products do not store colors, sizes or stock.

Those are stored inside product_variants.

### Relations

- Belongs to one store.
- Belongs to one category.
- Has many images.
- Has many variants.

---

## product_images

### Purpose

Stores all product images.

Only image paths are stored.

### Relations

- Belongs to one product.

---

## product_variants

### Purpose

Stores product variations.

Each variant has its own:

- Color
- Size
- Price
- Stock

### Relations

- Belongs to one product.

---

## carts

### Purpose

Stores each user's shopping cart.

### Relations

- Belongs to one user.
- Contains many cart items.

---

## cart_items

### Purpose

Stores products inside the shopping cart.

References product variants instead of products.

### Relations

- Belongs to one cart.
- Belongs to one product variant.

---

## orders

### Purpose

Stores customer orders.

Each order has its own status and total price.

### Status

- pending
- confirmed
- shipping
- delivered
- cancelled

### Relations

- Belongs to one user.
- Contains many order items.

---

## order_items

### Purpose

Stores a snapshot of purchased products.

Product name, variant details and price are copied to preserve purchase history.

### Relations

- Belongs to one order.

---

## addresses

### Purpose

Stores customer delivery addresses.

Users may have multiple addresses.

### Relations

- Belongs to one user.

---

## favorites

### Purpose

Stores favorite products for each user.

### Relations

- Belongs to one user.
- Belongs to one product.

---

# Notes

This database represents the MVP version of Beep Beep.

Future versions may include:

- Store owner accounts
- Delivery drivers
- Coupons
- Notifications
- Product reviews
- Online payments
- Multi-city support