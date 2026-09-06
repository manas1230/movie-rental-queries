/*SET 1*/
select a.category_id,b.film_id,a.name as category_name from category a join film_category b on a.category_id=b.category_id


select x.title as film_title,y.* from film x join (select a.category_id,b.film_id,a.name as category_name from category a join film_category b 
on a.category_id=b.category_id) y on x.film_id=y.film_id


select c.inventory_id ,h.* from inventory c join (select x.title as film_title,y.* from film x join (select a.category_id,b.film_id,a.name as category_name from 
category a join film_category b 
on a.category_id=b.category_id) y on x.film_id=y.film_id) h on c.film_id=h.film_id


select j.rental_id,k.* from rental j join (select c.inventory_id ,h.* from inventory c join (select x.title as film_title,y.* from film x 
join (select a.category_id,b.film_id,a.name as category_name from category a join film_category b 
on a.category_id=b.category_id) y on x.film_id=y.film_id) h on c.film_id=h.film_id) k on j.inventory_id=k.inventory_id



/*Q1-query that lists each movie, the film category it is classified in, and the number of times it has been rented out by families*/
WITH rt as (select j.rental_id,k.* from rental j 
join (select c.inventory_id ,h.* from inventory c 
join (select x.title as film_title,y.* from film x 
join (select a.category_id,b.film_id,a.name as category_name from category a join film_category b 
on a.category_id=b.category_id) y on x.film_id=y.film_id) h on c.film_id=h.film_id) k on j.inventory_id=k.inventory_id)
select rt.film_title,rt.category_name,count(rt.rental_id) as rental_count from rt 
where rt.category_name in ('Animation','Children','Classics','Comedy','Family','Music')group by rt.film_id,rt.film_title,rt.category_name order by rental_count desc






/*Q2-table with the movie titles and dividing them into 4 levels based on the quartiles of the average rental duration for movies across family categories*/
WITH SS AS (select z.film_title,z.category_name,z.rental_duration from (select x.title as film_title,x.rental_duration,y.* from film x 
join (select a.category_id,b.film_id,a.name as category_name from category a join film_category b on a.category_id=b.category_id) y on x.film_id=y.film_id) z
where z.category_name in ('Animation','Children','Classics','Comedy','Family','Music'))
select SS.*, NTILE(4) OVER (PARTITION BY category_name ORDER BY rental_duration) AS standard_quartile from SS order by standard_quartile





/*q3*/
WITH df as(select z.film_title,z.category_name,z.rental_duration from (select x.title as film_title,x.rental_duration,y.* from film x join 
(select a.category_id,b.film_id,a.name as category_name from category a join film_category b 
on a.category_id=b.category_id) y on x.film_id=y.film_id) z
where z.category_name in ('Animation','Children','Classics','Comedy','Family','Music'))
select df.category_name,NTILE(5) OVER (PARTITION BY df.category_name ORDER BY df.rental_duration) AS standard_quartile,count(df.rental_duration) 
as count from df group by df.category_name,df.rental_duration 

/*or*/

/*Q3-table with the family-friendly film category, quartiles, and count of movies within each combination of film category for each corresponding rental duration category*/
/*divided into 5 quartiles because of 5 distinct count values*/
WITH df as(select z.film_title,z.category_name,z.rental_duration from (select x.title as film_title,x.rental_duration,y.* from film x 
join (select a.category_id,b.film_id,a.name as category_name from category a join film_category b on a.category_id=b.category_id) y on x.film_id=y.film_id) z
where z.category_name in ('Animation','Children','Classics','Comedy','Family','Music'))
select df.category_name,CASE
    WHEN rental_duration <=3 THEN '1'
    WHEN rental_duration >3 AND rental_duration <=4 THEN '2'
    WHEN rental_duration >4 AND rental_duration <=5 THEN '3'
    WHEN rental_duration >5 AND rental_duration <=6 THEN '4'
    ELSE '5'
END AS standard_quartile,count(df.rental_duration) as count from df group by df.category_name,df.rental_duration order by 1,2 desc





/*SET 2*/

/*Q1-comparison of two stores in their count of rental orders during every month for all the years*/
select year,month,store_id,count(rental_id) as count_rentals 
from (select extract('year' from a.rental_date) as year,
extract('month' from a.rental_date) as month,a.rental_id,b.store_id 
from rental a join inventory b on a.inventory_id=b.inventory_id) s 
group by year,month,store_id order by count_rentals desc



/*q2*/
select x.year,x.month,x.fullname,x.amount from 
(select extract('year' from a.payment_date) as year,
extract('month' from a.payment_date) as month,concat(first_name,' ',last_name) as fullname,a.amount from payment a join customer b on a.customer_id=b.customer_id) x join
(select fullname,sum(amount) from (
select extract('year' from a.payment_date) as year,
extract('month' from a.payment_date) as month,concat(first_name,' ',last_name) as fullname,a.amount from payment a join customer b on a.customer_id=b.customer_id )
 a group by fullname order by sum desc limit 10) y on x.fullname=y.fullname



/*Q2-top 10 paying customers, no of payments they made on a monthly basis during 2007 and the amount of the monthly payments*/
WITH abc as (select x.year,x.month,x.fullname,x.amount from 
(select extract('year' from a.payment_date) as year,
extract('month' from a.payment_date) as month,concat(first_name,' ',last_name) as fullname,a.amount from payment a 
join customer b on a.customer_id=b.customer_id) x 
join (select fullname,sum(amount) from (select extract('year' from a.payment_date) as year,
extract('month' from a.payment_date) as month,concat(first_name,' ',last_name) as fullname,a.amount from payment a 
join customer b on a.customer_id=b.customer_id ) a group by fullname order by sum desc limit 10) y on x.fullname=y.fullname)
select year,month,fullname,count(amount) as paycount,sum(amount) as amount from abc group by fullname,year,month order by fullname,paycount desc