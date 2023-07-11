--Q) Who is the senior most emploee based on job title(Levels)?

select employee_id, first_name, last_name, levels
from employee 
order by levels desc
limit 1;
-------------------------------------------------

--Q) which countries have the most invoices?
 
select billing_country, count(total) as invoices
from invoice
group by billing_country
order by invoices desc;
-------------------------------------------------

--Q) what are the toop 3 values of total invoices

select total as Count_of_total 
from invoice
order by total desc
limit 3;
-------------------------------------------------

--Q)Which city has the best customers?

select billing_city, sum(total) as Total_invoices
from invoice
group by billing_city
order by Total_invoices;
--------------------------------------------------

--Q)who is the best customer?

select customer.customer_id, customer.first_name, customer.last_name,
sum(total) as Toatal_purchases
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3
order by 4 desc
limit 1;
----------------------------------------------------------------------

--Q)Write a Query to return the email,first name, last name and gener of all Rock music 
--listners? return the list in alphabetic order starting from 'A'.

select email, first_name, last_name, genre.name as genre_name 
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by 2,3,4,1
order by 2,3 asc;
------------(ANOTHER METHOD)--------------------------------------------------------
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in 
(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;
----------------------------------------------------------------------

--Q) lets invite the artist who have writtwn the most rock music in our dataset
--write a query that return the artist name and total track count of the top 10 rock bands

select artist.artist_id, artist.name, count(album.artist_id) 
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by 1
order by 3 desc
limit 10;
-----------------------------------------------------------------------


--Q) Return all the track names that have a song length longer then the average song length.
--return the name and millisecond for each track order by the song length with the longest song listed first

select name, milliseconds as length_of_the_song
from track
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc
------------------------------------------------------------------------


--Q)find how much amount spent by each customer on artist? wite a query to return 
--customer name,artis tname and total spent

WITH best_selling_artist AS(
	SELECT artist.artist_id AS artist_id,  artist.name AS artist_name, 
	SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(inl.unit_price * inl.quantity) AS amount
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line inl ON inl.invoice_id = i.invoice_id
JOIN track t ON t.track_id = inl.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-------------------------------------------------------------------

--Q) we want to find out the most popular music genre for each country. we determinne the most
--popular genre as the genre with heighest amount of purchases.

with popular_genre as
(
	select customer.country, genre.name, count(invoice_line.quantity) as purchases,
	row_number() over (partition by customer.country order by count(invoice_line.quantity)desc) as Row_no
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	group by 1, 2 
	order by 1 asc,3 desc
)
select * from popular_genre where Row_no <= 1;

-----------------------------------------------------------------------


--Q)write a query that determines the customer that has spent the most on music for each country.

with customer_spending_contries as
(
	select c.customer_id,c.first_name, c.last_name, billing_country, sum(total) as total_amount,
	row_number() over(partition by billing_country order by sum(total)desc) as rowno
	from invoice
	join customer c on c.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)
select * from customer_spending_contries where rowno<=1;


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------




