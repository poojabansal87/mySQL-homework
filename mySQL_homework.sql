USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column 'Actor Name'
SELECT upper(concat(first_name,' ',last_name)) as 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order.
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country in ('Afghanistan','Bangladesh','China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as occur
FROM actor
GROUP BY last_name
HAVING occur > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff as s
LEFT JOIN address as a
on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT first_name, last_name, sum(amount) as 'Total Amount'
FROM staff as s
LEFT JOIN payment as p
on s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
SELECT f.title, count(a.actor_id)
FROM film_actor as a
INNER JOIN film as f
ON a.film_id = f.film_id
GROUP BY a.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, count(*)
FROM inventory as i
INNER JOIN film as f
ON i.film_id = f.film_id
GROUP BY i.film_id
HAVING f.title = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name
SELECT first_name, last_name, sum(amount) as 'Total Paid'
FROM payment as p
JOIN customer as c
on p.customer_id = c.customer_id
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE (title like 'K%'
OR title like 'Q%')
AND language_id in 
(
	SELECT language_id
	FROM language
	WHERE name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT concat(first_name,' ',last_name) as ActorName
FROM actor
WHERE actor_id in
( 
	SELECT actor_id 
	FROM film_actor
	WHERE film_id IN
	(
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need 
-- the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT concat(first_name,' ',last_name), email
FROM customer as c
INNER JOIN address as a
ON c.address_id = a.address_id
INNER JOIN city as ct
ON a.city_id = ct.city_id
INNER JOIN country as cy
ON ct.country_id = cy.country_id
WHERE cy.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT film.title 
FROM film
INNER JOIN film_category as fc
on film.film_id = fc.film_id
INNER JOIN category as c
on fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, count(film.title) as freq
FROM rental as r
LEFT JOIN inventory as i
ON r.inventory_id = i.inventory_id
LEFT JOIN film
ON i.film_id = film.film_id
GROUP BY film.film_id
ORDER BY freq DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, sum(amount) as 'Dollars'
FROM payment as p
LEFT JOIN staff
ON p.staff_id = staff.staff_id
LEFT JOIN store as s
on s.store_id = staff.staff_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, ct.city, c.country
FROM store
LEFT JOIN address as a
ON store.address_id = a.address_id
LEFT JOIN city as ct
ON a.city_id = ct.city_id
LEFT JOIN country as c
ON ct.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, sum(amount) as Revenue
FROM category as c
LEFT JOIN film_category as fc
ON c.category_id = fc.category_id
LEFT JOIN inventory as i
ON fc.film_id = i.film_id
LEFT JOIN rental as r
ON i.inventory_id = r.inventory_id
LEFT JOIN payment as p
on r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY REVENUE desc
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW TOP_FIVE_GENRES as
SELECT c.name, sum(amount) as Revenue
FROM category as c
LEFT JOIN film_category as fc
ON c.category_id = fc.category_id
LEFT JOIN inventory as i
ON fc.film_id = i.film_id
LEFT JOIN rental as r
ON i.inventory_id = r.inventory_id
LEFT JOIN payment as p
on r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY REVENUE desc
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM TOP_FIVE_GENRES;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW TOP_FIVE_GENRES;
