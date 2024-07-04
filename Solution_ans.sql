--Question Set 1 - Easy

--1. Who is the senior most employee based on job title?

select top(1) * from employee
order by levels desc

 --2. Which countries have the most Invoices?

 select billing_country,count(billing_country) as quntities
 from invoice
 group by billing_country
 order by quntities desc;

--3. What are top 3 values of total invoice?


	select Top(3) total from invoice
	order by total desc


--4. Which city has the best customers? We would like to throw a promotional Music
--Festival in the city we made the most money. Write a query that returns one city that
--has the highest sum of invoice totals. Return both the city name & sum of all invoice
--totals


	select billing_city,billing_country,round(sum(total),3) as t
	from invoice
	group by billing_city,billing_country
	order by t desc;


--5. Who is the best customer? The customer who has spent the most money will be
--declared the best customer. Write a query that returns the person who has spent the
--most money

	select top(1) invoice.customer_id,customer.first_name,customer.last_name,
	round(sum(invoice.total),3) as total from customer
	inner join invoice
	on customer.customer_id=invoice.customer_id
	group by invoice.customer_id,customer.first_name,customer.last_name
	order by total desc;

--Question Set 2 – Moderate

--1. Write query to return the email, first name, last name, & Genre of all Rock Music
--listeners. Return your list ordered alphabetically by email starting with A

	select first_name,last_name,email from customer
	inner join invoice
	on customer.customer_id=invoice.customer_id
	inner join invoice_line
	on invoice.invoice_id=invoice_line.invoice_id
	where track_id IN(
		select track_id from track
		inner join genre
		on genre.genre_id=track.genre_id
		where genre.name like'Rock')
	order by email

--2. Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands

	select top(10) artist.name,count(track.track_id) as written_rock from artist
	inner join album
	on artist.artist_id=album.artist_id
	inner join track
	on album.album_id=track.album_id
	where track_id In(select track.track_id from track
			inner join genre
			on track.genre_id=genre.genre_id
			where genre.name like'Rock')
	group by artist.name order by written_rock desc;

--3. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the
--longest songs listed first	select track.name,track.milliseconds from track	where milliseconds>(select avg(milliseconds) from track)	order by track.milliseconds desc;--Question Set 3 – Advance

--1. Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent	with best_selling as (		select top(1) artist.artist_id,artist.name,		sum(invoice_line.unit_price * invoice_line.quantity) as s		from invoice_line		inner join track		on invoice_line.track_id=track.track_id		inner join album		on album.album_id=track.album_id		inner join artist		on artist.artist_id=album.artist_id		group by artist.artist_id,artist.name order by s desc	)	select customer.first_name,customer.last_name,best_selling.name as artist_name,	round(sum(invoice_line.unit_price*invoice_line.quantity),3) as tspen 	from invoice	inner join customer	on customer.customer_id=invoice.customer_id	inner join invoice_line	on invoice.invoice_id=invoice_line.invoice_id	inner join track	on invoice_line.track_id=track.track_id	inner join album	on track.album_id=album.album_id	inner join best_selling	on best_selling.artist_id=album.artist_id	group by customer.first_name,customer.last_name,best_selling.name	order by tspen desc;--2. We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query
--that returns each country along with the top Genre. For countries where the maximum
--number of purchases is shared return all Genres

	WITH populargenre AS 
	(
		SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
		ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
		FROM invoice_line 
		inner JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		inner JOIN customer ON customer.customer_id = invoice.customer_id
		inner JOIN track ON track.track_id = invoice_line.track_id
		inner JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY customer.country, genre.name, genre.genre_id
	)
	SELECT * FROM populargenre WHERE RowNo <= 1


--3. Write a query that determines the customer that has spent the most on music for each
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all
--customers who spent this amount


	WITH Customter_with_country AS (
			SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
			ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
			FROM invoice
			JOIN customer ON customer.customer_id = invoice.customer_id
			GROUP BY customer.customer_id,first_name,last_name,billing_country)

	SELECT * FROM Customter_with_country WHERE RowNo <= 1
