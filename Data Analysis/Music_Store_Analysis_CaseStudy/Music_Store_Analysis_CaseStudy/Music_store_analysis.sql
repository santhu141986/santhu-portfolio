 -- 1. Who is the senior most employee based on job title?
SELECT   employee_id,
         first_name,
         last_name,
         title,
         levels
FROM     employee
ORDER BY levels DESC limit 1;

-- 2. Which countries have the most Invoices?
SELECT   billing_country,
         Count(*) AS coun_of_invoices
FROM     invoice
GROUP BY 1
ORDER BY 2 DESC;

-- 3. What are top 3 values of total invoice?
SELECT   total
FROM     invoice
ORDER BY 1 DESC limit 3;

-- 3. Which city has the best customers?
-- We would like to throw a promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals
SELECT   city,
         Round(Sum(total), 2) AS invoice_total
FROM     customer c
JOIN     invoice i
ON       c.customer_id = i.customer_id
GROUP BY city
ORDER BY 2 DESC;

-- OR --
SELECT   billing_city,
         Round(Sum(total), 2) AS invoice_total
FROM     invoice
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Who is the best customer? The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money
SELECT   customer_id,
         Round(Sum(total), 2) AS invoice_total
FROM     invoice
GROUP BY 1
ORDER BY 2 DESC;

-- 5. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A
WITH genre_track_id AS
(
       SELECT track_id
       FROM   genre g
       JOIN   track t
       ON     g.genre_id = t.genre_id
       WHERE  g.NAME LIKE 'Rock'), ivoice_track_id AS
(
       SELECT invoice_id ,
              gid.track_id
       FROM   invoice_line il
       JOIN   genre_track_id gid
       ON     il.track_id = gid.track_id), customer_track_id AS
(
       SELECT track_id ,
              customer_id
       FROM   invoice i
       JOIN   ivoice_track_id it
       ON     i.invoice_id = it.invoice_id)
SELECT first_name ,
       last_name ,
       email ,
       track_id
FROM   customer c
JOIN   customer_track_id cid
ON     c.customer_id = cid.customer_id;

-- 6. Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
SELECT   artist.artist_id ,
         artist.NAME ,
         Count(artist.artist_id) AS number_of_songs
FROM     track
JOIN     album
ON       album.album_id = track.album_id
JOIN     artist
ON       artist.artist_id = album.artist_id
JOIN     genre
ON       genre.genre_id = track.genre_id
WHERE    genre.NAME LIKE 'Rock'
GROUP BY artist.artist_id,
         artist.NAME
ORDER BY number_of_songs DESC limit 10;

-- 7. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
SELECT   NAME,
         milliseconds
FROM     track
WHERE    milliseconds >
         (
                SELECT Avg(milliseconds) AS avg_miliseconds
                FROM   track)
ORDER BY 2 DESC;

-- 8 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
-- best selling artist
WITH most_costly_artist AS
(
         SELECT   a.artist_id ,
                  art.NAME ,
                  Round(Sum(il.unit_price * il.quantity),2) AS total_amount
         FROM     album a
         JOIN     track t
         ON       a.album_id = t.album_id
         JOIN     artist art
         ON       art.artist_id = a.artist_id
         JOIN     invoice_line il
         ON       il.track_id = t.track_id
         GROUP BY 1,
                  2
         ORDER BY 3 DESC limit 1 )
SELECT   c.first_name ,
         c.last_name ,
         Round(Sum(iln.unit_price * iln.quantity),2) AS amount_spent
FROM     customer c
JOIN     invoice i
ON       c.customer_id = i.customer_id
JOIN     invoice_line iln
ON       i.invoice_id = iln.invoice_id
JOIN     track t
ON       iln.track_id = t.track_id
JOIN     album a
ON       t.album_id = a.album_id
JOIN     most_costly_artist mc
ON       mc.artist_id = a.artist_id
GROUP BY 1,
         2
ORDER BY 3 DESC;

-- 9. We want to find out the most popular music Genre for each country.
--  We determine the most popular genre as the genre with the highest amount of purchases.
--  Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres\
with detailed_genre as(
         SELECT   c.country ,
                  g.NAME ,
                  g.genre_id ,
                  Count(iln.quantity)                                                         AS no_of_purchases ,
                  Row_number() OVER(partition BY c.country ORDER BY Count(iln.quantity) DESC) AS rows_num
         FROM     invoice i
         JOIN     customer c
         ON       i.customer_id = c.customer_id
         JOIN     invoice_line iln
         ON       iln.invoice_id = i.invoice_id
         JOIN     track t
         ON       t.track_id = iln.track_id
         JOIN     genre g
         ON       g.genre_id = t.genre_id
         GROUP BY 1,
                  2,
                  3 )
SELECT *
FROM   detailed_genre
WHERE  rows_num <=1;
       -- 10 -- Write a query that determines the customer that has spent the most on music for each country.
       -- Write a query that returns the country along with the top customer and how much they spent.
       -- For countries where the top amount spent is shared, provide all customers who spent this amount
with full_details AS
(
	SELECT   	c.customer_id ,
				c.first_name ,
				c.last_name ,
				i.billing_country ,
				sum(i.total)                                                                   AS total_amount_spent ,
				row_number() OVER (partition BY i.billing_country ORDER BY sum(i.total) DESC ) AS row_num
                FROM     customer c
                JOIN     invoice i
                ON       c.customer_id = i.customer_id
                GROUP BY 1,
                         2,
                         3,
                         4 )SELECT *
FROM   full_details
WHERE  row_num <=1; 