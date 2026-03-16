use testdb;
-- 1.total revenue by male and female gender
select gender, sum(purchase_amount) as revenue
from mytable
group by gender;

-- 2.which customer used discount but still spent more than average purchase amount
select customer_id, purchase_amount
from mytable
where discount_applied = 'yes' and purchase_amount >= (select avg(purchase_amount) from mytable);

-- 3. top 5 products with the highest review rating
select item_purchased, round(avg(review_rating), 2) as average_review_rating
from mytable
group by item_purchased
ORDER BY average_review_rating DESC 
limit 5;

-- 4. compare the average purchase amounts between standard and express shipping
select shipping_type, round(avg(purchase_amount),2)
from mytable
where shipping_type in ('Standard','Express')
group by shipping_type;

-- 5. do subscribed customer spend more ? compare average spend and total revenue 
-- between subscriber and non subscriber
SELECT subscription_status,
COUNT(customer_id) AS total_customers,
ROUND(AVG(purchase_amount),2) AS avg_spend,
ROUND(SUM(purchase_amount),2) AS total_revenue
FROM mytable
GROUP BY subscription_status
ORDER BY avg_spend DESC, total_revenue DESC;

-- 6. top 5 prodcuts have the highest percentage of purchase with discount applied

select item_purchased,
round(sum(case when discount_applied = 'Yes' then 1 else 0 end) * 100 / count(*),2) as discount_percentage
from mytable
group by item_purchased
order by discount_percentage desc
limit 5;

-- 7.cutomer segment into new, returning, and loyal based on their previous purchases and total each segment
with customer_type as (
select customer_id, previous_purchases,
case
	when previous_purchases = 1 then "new"
    when previous_purchases between 2 and 20 then "returning"
    else "loyal"
    end as customer_segment
from mytable
)
select customer_segment, count(*) as "number of customers"
from customer_type
group by customer_segment;

-- 8. top 3 most purchased products within each category
with item_count as (
select category,
item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from mytable
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_count
where item_rank <= 3;

-- 9. analysis repeat buyers also likely to subscriber.
select subscription_status,
count(customer_id) as repeat_buyers
from mytable
where previous_purchases > 5
group by subscription_status;

-- 10. revenue contibution of each group
select age_group,
sum(purchase_amount) as total_revenue
from mytable
group by age_group
order by total_revenue desc;
