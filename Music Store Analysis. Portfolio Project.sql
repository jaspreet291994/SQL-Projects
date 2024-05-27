												Music Store Analysis
												
----The objective of the store is to understand its business by analysing their store data using SQL.
												Easy
												
-- Who is the senior most employee based on the job title?
												
SELECT * 
	FROM employee
	ORDER BY levels DESC
	LIMIT 1;

--Which countries have the most invoices?

SELECT COUNT(*) as total_count , billing_country
	FROM invoice 
	GROUP BY billing_country
	ORDER BY total_count DESC;
												
--What are the top 3 values of invoice?

SELECT total 
	FROM invoice
	ORDER BY total desc
	LIMIT 3;

--Which city has the best customers? Return both the city names and the sum of all invoice totals?

SELECT billing_city,  sum(total) as invoice_total
	FROM invoice
	GROUP BY billing_city
	ORDER BY invoice_total DESC;

--Which city has the best customer? Write a query that returns the person who has spent the most amount of money?

SELECT c.customer_id, c.first_name, c.last_name, sum(i.total) as invoice_total
	FROM customer as c
JOIN invoice as i 
	ON
 	c.customer_id = i.customer_id
		GROUP BY c.customer_id,c.first_name,c.last_name
		ORDER BY invoice_total DESC
		LIMIT 1;



                                                   Medium
                                                   
----Write a query to return the email,firstname,lastname and genre of all rock music listeners.
----Return the list ordered alphabetically by email stating with A.  

 SELECT DISTINCT email,first_name,last_name
 	FROM customer as c
 	JOIN invoice as i on c.customer_id = i.customer_id
 	JOIN invoice_line as il on i.invoice_id = il.invoice_id
 		WHERE track_id in 
 (
  SELECT track_id 
  	FROM track as t
  	JOIN genre as g 
  	ON t.genre_id = g.genre_id
  	WHERE g.name like 'Rock'
  )
  	ORDER BY email;
 
 ----Write a query that returns the artist name and total track count of the top 10 rock bands.
 
 SELECT a.artist_id,a.name,count(a.artist_id) as number_of_songs
 	FROM track as t
	JOIN album as ab on ab.album_id = t.album_id
 	JOIN artist as a on a.artist_id = ab.artist_id
 	JOIN genre as g on g.genre_id = t.genre_id
 	WHERE g.name like 'Rock'
 		GROUP BY a.artist_id,a.name
 		ORDER BY number_of_songs DESC 
 		LIMIT 10;

----Return all the track names that have a song length longer than the average song length.
----Return all the names and milliseconds for each track.
----Order by song length with the longest song first.
 
SELECT name,milliseconds
	FROM track
	WHERE milliseconds >
(
SELECT AVG(milliseconds) as avg_length
	FROM track 
)
	ORDER BY milliseconds DESC;


                                                       Advanced
 ----Find out how much amount is spent by each customer on artists. Write a query that returns the customer name,artist name and total spent.
 
 ----For this solution we need to use the Common Table Expression 
 
 WITH best_selling_artist as
 (
 SELECT a.artist_id as artist_id,
 a.name as artist_name,
 sum(il.unit_price*il.quantity)as total_sales
 	FROM invoice_line as il
 		JOIN track as t on t.track_id = il.track_id
 		JOIN album as al on al.album_id = t.album_id
 		JOIN artist as a on a.artist_id = al.artist_id 
 GROUP BY 1,2
 ORDER BY 3 DESC 
 LIMIT 1
 )
 SELECT c.customer_id,
 c.first_name,
 c.last_name,
 bsa.artist_name,
 SUM(il.unit_price*il.quantity) as amount_spent 
 	FROM invoice as i
 		JOIN customer as c on c.customer_id = i.customer_id
 		JOIN invoice_line as il on i.invoice_id = il.invoice_id
 		JOIN track as t on t.track_id = il.track_id
 		JOIN album as al on al.album_id = t.album_id
 		JOIN best_selling_artist as bsa on bsa.artist_id = al.artist_id 
GROUP BY 1,2,3,4
 ORDER BY 5 DESC;
 

----Write a query that returns each country along with the top genre.
----Return all genres for the countries where the maximum number of purchases is shared.


 WITH popular_genre AS 
(
  SELECT 
    COUNT(invoice_line.quantity) AS purchases,
    c.country,
    g.name,
    g.genre_id,
    ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rowno
  FROM 
    invoice_line 
    JOIN invoice AS i ON invoice_line.invoice_id = i.invoice_id
    JOIN customer AS c ON c.customer_id = i.customer_id
    JOIN track AS t ON t.track_id = invoice_line.track_id
    JOIN genre AS g ON g.genre_id = t.genre_id
  GROUP BY 
    c.country,
    g.name,
    g.genre_id
  ORDER BY 
    c.country ASC,
    purchases DESC
)
SELECT * 
FROM popular_genre 
WHERE rowno <= 1;



----Write a query that determines the customer that has spent the most on music for each country.
----Write a query that returns the country along with the top customer and how much they spent.
----For countries where the top amount spent is shared, return all the customers who spent this amount.

--We will use the recursive method for this solution.

WITH RECURSIVE customer_country as 
(
SELECT c.customer_id,
c.first_name,
c.last_name,
i.billing_country,
SUM(total) as total_spending
	FROM invoice as i
JOIN customer as c on c.customer_id = i.customer_id
GROUP BY 1,2,3,4 
 ORDER BY 2,3 DESC 
),

country_max_spending as 
(
SELECT billing_country, 
MAX(total_spending) as max_spending
	FROM customer_country as cc
GROUP BY billing_country
)

SELECT cc.billing_country,
cc.total_spending,
cc.first_name,
cc.last_name 
	FROM customer_country as cc
		JOIN country_max_spending as ms on cc.billing_country = ms.billing_country
		WHERE cc.total_spending = ms.max_spending
 ORDER BY 1;
