-- sample_data.sql
CREATE TABLE public.customers (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL
);

CREATE TABLE public.products (
  id SERIAL PRIMARY KEY,
  sku TEXT NOT NULL,
  name TEXT NOT NULL,
  price numeric(10,2) NOT NULL
);

CREATE TABLE public.orders (
  id SERIAL PRIMARY KEY,
  customer_id int NOT NULL REFERENCES public.customers(id),
  product_id int NOT NULL REFERENCES public.products(id),
  quantity int NOT NULL,
  created_at timestamptz DEFAULT now()
);

INSERT INTO public.customers (name, email) VALUES
  ('Alice Smith', 'alice@example.com'),
  ('Bob Jones', 'bob@example.com');

INSERT INTO public.products (sku, name, price) VALUES
  ('SKU-001', 'Widget A', 9.99),
  ('SKU-002', 'Widget B', 19.95);

INSERT INTO public.orders (customer_id, product_id, quantity) VALUES
  (1, 1, 2),
  (2, 2, 1);
