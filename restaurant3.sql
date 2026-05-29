-- view the menu_items table and write a query to find the number of items on the menu?

SELECT * FROM menu_items;
SELECT COUNT(DISTINCT item_name) as Iteam_count 
FROM menu_items;

-- what are the least and most expensive items on the menu?

SELECT 
      (SELECT item_name FROM menu_items ORDER BY price ASC LIMIT 1) AS MinName,
      (SELECT price FROM menu_items ORDER BY price ASC LIMIT 1) AS MinPrice,
      (SELECT item_name FROM menu_items ORDER BY price DESC LIMIT 1) AS MaxName,
      (SELECT price FROM menu_items ORDER BY price DESC LIMIT 1) AS MaxPrice;
      
      
      
-- how many italian dishes are on the menu? 

SELECT COUNT(*) AS Italian_dishes FROM menu_items
WHERE category= 'Italian';

-- What are the least and most expensive italian dishes?

SELECT 
	   (SELECT item_name FROM menu_items 
        WHERE category = 'Italian'
        ORDER BY price DESC
        LIMIT 1) AS MaxName,
        (SELECT price FROM menu_items 
        WHERE category = 'Italian'
        ORDER BY price DESC
        LIMIT 1) AS MaxName,
        (SELECT item_name FROM menu_items 
        WHERE category = 'Italian'
        ORDER BY price
        LIMIT 1) AS MaxName,
        (SELECT price FROM menu_items 
        WHERE category = 'Italian'
        ORDER BY price
        LIMIT 1) AS MinPrice;

-- how many dishes are in each category? 

SELECT category, COUNT(menu_item_id) AS num_items
FROM menu_items
GROUP BY category;

-- What is the average price in each category?

SELECT category, COUNT(menu_item_id) AS num_items, ROUND(AVG(price),2) AS Avg_price
FROM menu_items
GROUP BY category;


-- view the order_details table 

SELECT * FROM order_details;

-- what is the date range of the table?

SELECT 
      MIN(order_date) AS first_date,
      MAX(order_date) AS last_date
FROM order_details;

-- how many orders were made within this date range?
SELECT COUNT(DISTINCT order_id) AS Num_items
FROM order_details
WHERE order_date BETWEEN (SELECT MIN(order_date) FROM order_details) AND (SELECT MAX(order_date) FROM order_details);


-- how many items were ordered within this date range?

SELECT COUNT(item_id) AS Num_items
FROM order_details
WHERE order_date BETWEEN (SELECT MIN(order_date) FROM order_details) AND (SELECT MAX(order_date) FROM order_details);

-- which order has the most number of items?

SELECT order_id, COUNT(item_id) AS item_count
FROM order_details
GROUP BY order_id
ORDER BY item_count DESC
LIMIT 1;

-- how many orders have more than 12 items?

SELECT COUNT(*) AS count
FROM (SELECT order_id, COUNT(item_id) AS item_count
      FROM order_details
	  GROUP BY order_id
	  HAVING COUNT(item_id) > 12) AS t;

-- combine menu_items with order_details table into a single table

SELECT * 
FROM order_details AS od
LEFT JOIN menu_items AS mi 
     ON od.item_id = mi.menu_item_id ;

-- what are the least and most ordered items are? what categories were they in?

SELECT mi.menu_item_id, item_name, category, COUNT(*) AS count
      FROM order_details AS od
      LEFT JOIN menu_items AS mi 
         ON od.item_id = mi.menu_item_id
      GROUP BY mi.menu_item_id, item_name, category
      ORDER BY count
      LIMIT 1;

SELECT mi.menu_item_id, item_name, category, COUNT(*) AS count
      FROM order_details AS od
      LEFT JOIN menu_items AS mi 
         ON od.item_id = mi.menu_item_id
      GROUP BY mi.menu_item_id, item_name, category
      ORDER BY count DESC
      LIMIT 1;
      
-- what are the top 5 orders that spend the most money?

SELECT od.order_id, SUM(price) AS total_price
FROM order_details AS od
LEFT JOIN menu_items AS mi 
	 ON od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY total_price DESC 
LIMIT 5;

-- view the details of highest spend order. What insights can you gather from the results?

SELECT od.order_id, od.order_date,mi.item_name, mi.category, mi.price, SUM(mi.price) OVER(PARTITION BY od.order_id) AS total_price
FROM order_details AS od
LEFT JOIN menu_items AS mi 
	ON od.item_id = mi.menu_item_id
WHERE od.order_id = (
					SELECT od.order_id
                    FROM order_details AS od
                    LEFT JOIN menu_items AS mi 
	                    ON od.item_id = mi.menu_item_id
					GROUP BY od.order_id 
                    ORDER BY SUM(mi.price) DESC
                    LIMIT 1);


-- view the details of top 5 highest spend orders. What insights can you gather from the results?

SELECT od.order_id,od.order_date, mi.category, mi.item_name, mi.price, SUM(mi.price) OVER(PARTITION BY od.order_id) AS total_price
FROM order_details AS od
LEFT JOIN menu_items AS mi 
	ON od.item_id = mi.menu_item_id
WHERE od.order_id IN ( 
					SELECT *
                    FROM (
                        SELECT od.order_id
                        FROM order_details AS od
                        LEFT JOIN menu_items AS mi 
	                       ON od.item_id = mi.menu_item_id
                       GROUP BY od.order_id
                       ORDER BY SUM(mi.price) DESC 
                       LIMIT 5) as t)

ORDER BY total_price DESC;




-- Find average order value
SELECT (
        ROUND(
               SUM(mi.price) / COUNT(DISTINCT od.order_id),2)
		  ) AS AOV
FROM order_details AS od
LEFT JOIN menu_items AS mi 
		ON od.item_id = mi.menu_item_id;


