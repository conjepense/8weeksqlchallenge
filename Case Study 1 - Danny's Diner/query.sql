/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?



-- 1. What is the total amount each customer spent at the restaurant?

SELECT a.customer_id, SUM(b.price) as total_spent
FROM dannys_diner.sales a
LEFT JOIN dannys_diner.menu b
ON a.product_id=b.product_id
GROUP BY a.customer_id

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) as cnt_days
FROM dannys_diner.sales
GROUP BY customer_id


-- 3. What was the first item from the menu purchased by each customer?

WITH cte AS (

SELECT a.customer_id, b.product_name, ROW_NUMBER() OVER (PARTITION BY a.customer_id ORDER BY a.order_date, a.product_id) AS ordered
FROM dannys_diner.sales a
LEFT JOIN dannys_diner.menu b
ON a.product_id=b.product_id

)

SELECT * 
FROM cte
WHERE ordered=1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT b.product_name, COUNT(a.product_id) as total_orders
FROM dannys_diner.sales a
LEFT JOIN dannys_diner.menu b
ON a.product_id=b.product_id
GROUP BY b.product_name
ORDER BY total_orders desc
LIMIT 1

-- 5. Which item was the most popular for each customer?

WITH cte AS (

  SELECT a.customer_id, a.product_id, COUNT(a.product_id) as cnt_order
  FROM dannys_diner.sales a
  GROUP BY a.customer_id, a.product_id

),

rnk_counts AS (
  SELECT c.customer_id, c.cnt_order, d.product_name , DENSE_RANK() OVER (PARTITION BY c.customer_id ORDER BY c.cnt_order DESC) as rnk
  FROM cte c
  LEFT JOIN dannys_diner.menu d
  ON c.product_id=d.product_id
  )
  
  SELECT * 
  FROM rnk_counts
  WHERE rnk=1
  

-- 6. Which item was purchased first by the customer after they became a member?

WITH cte as(
  SELECT a.*
  , ROW_NUMBER() OVER (PARTITION BY a.customer_id ORDER BY a.order_date) as row_numb
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.members b
  ON a.customer_id=b.customer_id
  AND a.order_date>b.join_date
  )
  
  SELECT c.customer_id, d.product_name
  FROM cte c
  INNER JOIN dannys_diner.menu d
  ON c.product_id=d.product_id
  WHERE c.row_numb=1

-- 7. Which item was purchased just before the customer became a member?

WITH cte as(
  SELECT a.*
  , ROW_NUMBER() OVER (PARTITION BY a.customer_id ORDER BY a.order_date DESC) as row_numb
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.members b
  ON a.customer_id=b.customer_id
  AND a.order_date<b.join_date
  )
  
  SELECT c.customer_id, d.product_name
  FROM cte c
  INNER JOIN dannys_diner.menu d
  ON c.product_id=d.product_id
  WHERE c.row_numb=1
  
-- 8. What is the total items and amount spent for each member before they became a member?

WITH cte as(
  SELECT a.*, c.product_name, c.price
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.members b
  ON a.customer_id=b.customer_id
  AND a.order_date<b.join_date
  INNER JOIN dannys_diner.menu c
  ON a.product_id=c.product_id
  
  )
  
  SELECT customer_id, SUM(price)
  FROM cte
  GROUP BY customer_id
  
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


