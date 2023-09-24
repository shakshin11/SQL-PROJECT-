CREATE DATABASE ZOMATO ;
USE ZOMATO;
 DROP TABLE IF EXISTS goldusers_signup;
  
CREATE TABLE goldusers_signup(userid int , 
                               gold_signup_date date
                               );
                               
INSERT INTO goldusers_signup(userid , gold_signup_date)VALUES (1 , '2017-09-12'), (3 , '2019-08-04');

SET SQL_SAFE_UPDATES=0;

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid , signup_date)VALUES(1,'2017-04-14'),
											(2,'2014-11-12'),
											(3,'2016-08-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid , created_date , product_id) VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-15',2),
(1,'2018-09-03',3),
(3,'2016-12-20',2),
(1,'2017-11-09',1),
(1,'2017-07-14',3);

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

/* 1 WHAT IS TOTAL AMOUNT EACH CUSTOMER SPENT ON ZOMATO */

SELECT sales.userid  , sum( product.price) from sales

join product
ON sales.product_id = product.product_id
group by sales.userid  order by userid;

/* how many days has each customer visited zomato */ 

select userid , count(distinct(created_date)) from sales 
group by userid;

/* what was first product purchased by each customer  */ 

select * from(
 SELECT *, rank () over ( partition by userid  order by created_date ) rnk from sales) a
 where rnk =1;
 
 /* what is the most purchased item on menu and how many times was it purchased by all customers */

SELECT userid, COUNT(product_id) AS cnt
FROM sales
WHERE product_id = (
    SELECT product_id 
    FROM sales
    GROUP BY product_id
    ORDER BY COUNT(product_id) DESC
    LIMIT 1
)
GROUP BY userid;

/* which item was most popular for each customer */

select * from 
(select * , rank() over ( partition by userid order by cnt desc ) rnk from 
(select userid , product_id  , count(product_id) cnt from sales group by userid , product_id)a)b
where rnk=1 ;

/* 6 which item was purchased first after they become memeber */

select * from(
select c.* , rank() over( partition by userid order by created_date ) rnk from
(select a.userid , a.product_id , a.created_date , b.gold_signup_date from sales a 
join goldusers_signup b
on a.userid= b.userid and created_date>=gold_signup_date)c ) d where rnk=1 ;

/* 7 which item was bought just before it become memeber */

select * from (
select c.* ,rank() over (partition by created_date order by created_date desc) rnk from 
(select a.userid , a.created_date , a.product_id , b.gold_signup_date from sales a 
join goldusers_signup b 
on a.userid = b.userid and created_date<= gold_signup_date ) c) d where rnk=1;

/* what is total order and amount spend for each member before they become a member */

select userid, count(created_date ) , sum(price) from (
select c.* ,  d.price from 
( select a.userid , a.created_date , a.product_id , b.gold_signup_date from sales a 
join goldusers_signup b 
on a.userid = b.userid and created_date<= gold_signup_date)c
join product d
on c.product_id=d.product_id) e
group by userid ;


/* rank all the transcations */

select * , rank () over ( partition by userid order by created_date ) from sales; 

/* rank all the transcations for each customer whenever they are gold memeber and for ither null*/

select c.* , rank() over ( partition by userid order by created_date ) from 
 (select a.userid , a.created_date , b.gold_signup_date from sales a
left join goldusers_signup b
on a.userid=b.userid and created_date>=gold_signup_date) c;

