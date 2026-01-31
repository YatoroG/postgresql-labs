CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    last_name VARCHAR(40) NOT NULL,
    first_name VARCHAR(40) NOT NULL,
    patronymic VARCHAR(40),
    phone VARCHAR(12) NOT NULL,
    email VARCHAR(255) UNIQUE
);

CREATE TABLE Order_status (
    order_status_id SERIAL PRIMARY KEY,
    order_status_type VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE City (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL REFERENCES Country(country_id)
);

CREATE TABLE Address (
    address_id SERIAL PRIMARY KEY,    
    city_id INT NOT NULL REFERENCES City(city_id),
    zip_code VARCHAR(10) NOT NULL,
    full_address VARCHAR(255) NOT NULL
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id),
    departure_address INT NOT NULL REFERENCES Address(address_id),
    arrival_address INT NOT NULL REFERENCES Address(address_id),
    order_date DATE NOT NULL,
    order_status_id INT NOT NULL REFERENCES Order_status(order_status_id)
);

CREATE TABLE Cargo (
    cargo_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES Orders(order_id),
    weight NUMERIC(10, 2) NOT NULL,
    volume NUMERIC(10, 2) NOT NULL,
    is_fragile BOOLEAN NOT NULL,
    descr VARCHAR(255)
);

CREATE TABLE Employee_role (
    role_id SERIAL PRIMARY KEY,
    role_type VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE Employee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    patronymic VARCHAR(40),
    phone VARCHAR(12) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    date_of_birth DATE,
    hire_date DATE,
    role_id INT NOT NULL REFERENCES Employee_role(role_id)
);

CREATE TABLE Vehicle_type (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    descr VARCHAR(255)
);

CREATE TABLE Vehicle_model (
    model_id SERIAL PRIMARY KEY,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    max_load NUMERIC(10, 2) NOT NULL,
    max_volume NUMERIC(10, 2) NOT NULL,
    type_id INT NOT NULL REFERENCES Vehicle_type(type_id),
    CONSTRAINT Vehicle_model_brand_model_UN UNIQUE (brand, model)
);

CREATE TABLE Vehicle_status (
    vehicle_status_id SERIAL PRIMARY KEY,
    vehicle_status_type VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    license_plate VARCHAR(15) NOT NULL UNIQUE,
    model_id INT NOT NULL REFERENCES Vehicle_model(model_id),
    vehicle_status_id INT NOT NULL REFERENCES Vehicle_status(vehicle_status_id)
);

CREATE TABLE Route (
    route_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL UNIQUE REFERENCES Orders(order_id),
    driver_id INT NOT NULL REFERENCES Employee(employee_id),
    manager_id INT NOT NULL REFERENCES Employee(employee_id),
    vehicle_id INT NOT NULL REFERENCES Vehicle(vehicle_id),
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL
);
