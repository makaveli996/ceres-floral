-- Seed fake orders so products 15, 16, 17, 18, 19 appear as bestsellers.
-- Uses existing customer 1, address 1, carrier 1, lang 1, currency 3.
-- Run: make seed-bestsellers  (or: docker compose exec -T db mariadb -u prestashop -pprestashop prestashop < scripts/seed-bestsellers.sql)

-- New cart for customer 1
INSERT INTO ps_cart (id_shop_group, id_shop, id_carrier, delivery_option, id_lang, id_address_delivery, id_address_invoice, id_currency, id_customer, id_guest, secure_key, recyclable, gift, mobile_theme, allow_seperated_package, date_add, date_upd)
SELECT 1, 1, 1, '', 1, 1, 1, 3, 1, 0, '-1', 1, 0, 0, 0, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ps_cart WHERE id_customer = 1 LIMIT 1);

SET @id_cart = (SELECT id_cart FROM ps_cart WHERE id_customer = 1 ORDER BY id_cart DESC LIMIT 1);

-- If no cart existed, we just created one; get its id
SET @id_cart = COALESCE(@id_cart, LAST_INSERT_ID());
-- If carts already exist for customer 1, use the one we might have created now
SET @id_cart = IF(@id_cart IS NULL, (SELECT MAX(id_cart) FROM ps_cart), @id_cart);

SET @next_order_ref = (SELECT COALESCE(MAX(id_order), 0) + 1 FROM ps_orders);

-- One new order (valid=1, current_state=2 = Payment accepted)
INSERT INTO ps_orders (
  reference, id_shop_group, id_shop, id_carrier, id_lang, id_customer, id_cart,
  id_currency, id_address_delivery, id_address_invoice, current_state, secure_key,
  payment, conversion_rate, total_discounts, total_discounts_tax_incl, total_discounts_tax_excl,
  total_paid, total_paid_tax_incl, total_paid_tax_excl, total_paid_real,
  total_products, total_products_wt, total_shipping, total_shipping_tax_incl, total_shipping_tax_excl,
  carrier_tax_rate, total_wrapping, total_wrapping_tax_incl, total_wrapping_tax_excl,
  round_mode, round_type, invoice_number, delivery_number,
  invoice_date, delivery_date, valid, date_add, date_upd
) VALUES (
  CONCAT('XBS', LPAD(@next_order_ref, 6, '0')),
  1, 1, 1, 1, 1, @id_cart,
  3, 1, 1, 2, '-1',
  'Fake (bestsellers seed)', 1.000000, 0, 0, 0,
  0, 0, 0, 0,
  0, 0, 0, 0, 0,
  0.000, 0, 0, 0,
  2, 1, 0, 0,
  NOW(), NOW(), 1, NOW(), NOW()
);

SET @id_order = LAST_INSERT_ID();

-- Order details for products 15,16,17,18,19 (quantity 10 each so they rank as bestsellers)
-- product_reference and product_supplier_reference must be '' not NULL (BO OrderProductForViewing expects string)
-- Product 15: 35.00 net -> 43.05 gross
INSERT INTO ps_order_detail (id_order, id_shop, product_id, product_attribute_id, product_name, product_reference, product_supplier_reference, product_quantity, product_quantity_in_stock, product_price, unit_price_tax_incl, unit_price_tax_excl, total_price_tax_incl, total_price_tax_excl, tax_name, tax_rate, product_weight, purchase_supplier_price, original_product_price, original_wholesale_price)
VALUES (@id_order, 1, 15, 0, 'Drewniana szafka GAB 055', '', '', 10, 0, 35.000000, 43.05, 35.000000, 430.50, 350.00, 'VAT PL', 23.000, 0, 0, 35.000000, 0);

-- Product 16: 12.90 net
INSERT INTO ps_order_detail (id_order, id_shop, product_id, product_attribute_id, product_name, product_reference, product_supplier_reference, product_quantity, product_quantity_in_stock, product_price, unit_price_tax_incl, unit_price_tax_excl, total_price_tax_incl, total_price_tax_excl, tax_name, tax_rate, product_weight, purchase_supplier_price, original_product_price, original_wholesale_price)
VALUES (@id_order, 1, 16, 28, 'Drewniana szafka GAB 054', '', '', 10, 0, 12.900000, 15.867, 12.900000, 158.67, 129.00, 'VAT PL', 23.000, 0, 0, 12.900000, 0);

-- Product 17: 12.90 net
INSERT INTO ps_order_detail (id_order, id_shop, product_id, product_attribute_id, product_name, product_reference, product_supplier_reference, product_quantity, product_quantity_in_stock, product_price, unit_price_tax_incl, unit_price_tax_excl, total_price_tax_incl, total_price_tax_excl, tax_name, tax_rate, product_weight, purchase_supplier_price, original_product_price, original_wholesale_price)
VALUES (@id_order, 1, 17, 32, 'Drewniana szafka GAB 053', '', '', 10, 0, 12.900000, 15.867, 12.900000, 158.67, 129.00, 'VAT PL', 23.000, 0, 0, 12.900000, 0);

-- Product 18: 12.90 net
INSERT INTO ps_order_detail (id_order, id_shop, product_id, product_attribute_id, product_name, product_reference, product_supplier_reference, product_quantity, product_quantity_in_stock, product_price, unit_price_tax_incl, unit_price_tax_excl, total_price_tax_incl, total_price_tax_excl, tax_name, tax_rate, product_weight, purchase_supplier_price, original_product_price, original_wholesale_price)
VALUES (@id_order, 1, 18, 36, 'Drewniana szafka GAB 052', '', '', 10, 0, 12.900000, 15.867, 12.900000, 158.67, 129.00, 'VAT PL', 23.000, 0, 0, 12.900000, 0);

-- Product 19: 13.90 net
INSERT INTO ps_order_detail (id_order, id_shop, product_id, product_attribute_id, product_name, product_reference, product_supplier_reference, product_quantity, product_quantity_in_stock, product_price, unit_price_tax_incl, unit_price_tax_excl, total_price_tax_incl, total_price_tax_excl, tax_name, tax_rate, product_weight, purchase_supplier_price, original_product_price, original_wholesale_price)
VALUES (@id_order, 1, 19, 0, 'Drewniana szafka GAB 05', '', '', 10, 0, 13.900000, 17.097, 13.900000, 170.97, 139.00, 'VAT PL', 23.000, 0, 0, 13.900000, 0);

-- Update order totals from order_detail
UPDATE ps_orders o
SET
  total_products = (SELECT SUM(total_price_tax_excl) FROM ps_order_detail WHERE id_order = o.id_order),
  total_products_wt = (SELECT SUM(total_price_tax_incl) FROM ps_order_detail WHERE id_order = o.id_order),
  total_paid = (SELECT SUM(total_price_tax_incl) FROM ps_order_detail WHERE id_order = o.id_order),
  total_paid_tax_incl = (SELECT SUM(total_price_tax_incl) FROM ps_order_detail WHERE id_order = o.id_order),
  total_paid_tax_excl = (SELECT SUM(total_price_tax_excl) FROM ps_order_detail WHERE id_order = o.id_order),
  total_paid_real = (SELECT SUM(total_price_tax_incl) FROM ps_order_detail WHERE id_order = o.id_order)
WHERE o.id_order = @id_order;
