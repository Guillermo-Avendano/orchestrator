CREATE TABLE agents (
  id int NOT NULL,
  name varchar(60),
  modified timestamp NULL,
  created timestamp NULL,
  folderid int NULL,
  details text NULL,
  ostype char(64) NULL,
  platform int NULL,
  timedelta int NULL,
  enable_flag smallint NULL,
  PRIMARY KEY (id)
);

CREATE TABLE customers (
  id int NOT NULL,
  name varchar(60),
  email varchar(255),
  address varchar(255),
  city varchar(255),
  state varchar(255),
  zip varchar(255),
  country varchar(255),
  phone varchar(255),
  PRIMARY KEY (id)
);

CREATE TABLE orders (
  id int NOT NULL,
  customer_id int NOT NULL,
  order_date timestamp NOT NULL,
  status varchar(255) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id)
    REFERENCES customers(id)
);

