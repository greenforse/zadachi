/*
 Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
 */

select c.first_name, c.last_name,
	   a.address, c2.city, c3.country 
from customer c 
join address a 
	on a.address_id  = c.address_id 
join city c2 
	on c2.city_id  = a.city_id 
join country c3 
	on c3.country_id  = c2.country_id 
	
/*
Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300.
 Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём. 
*/

select s2.store_id , c2.city , s3.first_name , s3.last_name 
from (select s.store_id
		from store s 
			join customer c 
				on c.store_id  = s.store_id
		group by s.store_id
		having count(*) > 300) gs
join store s2 
	on s2.store_id  = gs.store_id
join address a 
	on a.address_id = s2.address_id 
join city c2
	on c2.city_id  = a.city_id 
join staff s3
	on s3.staff_id = s2.manager_staff_id

/*
 Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время 
 наибольшее количество фильмов.
 */

select c.customer_id , count(*) as cnt
from customer c 
join rental r 
on r.customer_id = c.customer_id 
group by c.customer_id
order by cnt desc 
limit 5

/*
 Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
количество взятых в аренду фильмов;
общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
минимальное значение платежа за аренду фильма;
максимальное значение платежа за аренду фильма.
 */
select c.customer_id, round(a.sm) , a.mn, a.mx, b.cnt
from customer c 
left join (select p.customer_id , sum(p.amount) sm , min(p.amount) mn, max(p.amount)  mx 
			from payment p 
			group by  p.customer_id) a 
  on a.customer_id = c.customer_id
left join (select customer_id, count(*) cnt  
			from rental r group by customer_id) b
	on b.customer_id  = c.customer_id


/*
 Задание 5. Используя данные из таблицы городов, составьте одним 
  запросом всевозможные пары городов так,
  чтобы в результате не было пар с одинаковыми названиями городов.
  Для решения необходимо использовать декартово произведение.
 */
	
	select *
	from city c ,city c2 
	where c.city != c2.city
	
/*
	Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
	 и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, 
	 за которые он возвращает фильмы.
*/
	
 select c.customer_id, avg(r.return_date - r.rental_date)  
 from customer c 
 join rental r 
 	on r.customer_id  = c.customer_id 
 group by c.customer_id 
 
 /*
 Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
 */
 
 select f.film_id,  coalesce(a.cnt,0), coalesce(b.sm,0) 
 from film f 
 left join (select i.film_id, count(r.rental_id) cnt 
 		from  inventory i 
		 join rental r 
 			on r.inventory_id = i.inventory_id 
 		group by i.film_id) a
 	on f.film_id = a.film_id
 left join (select i.film_id , sum(p.amount) sm
 		from inventory i 
		 join rental r 
 			on r.inventory_id = i.inventory_id 
 		 join payment p 
 		 	on p.rental_id = r.rental_id
 		group by i.film_id) b
 	on b.film_id = f.film_id 
 	
 	
 /*
  Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
  
  */
 select f.film_id,  coalesce(a.cnt,0) 
 from film f 
 left join (select i.film_id, count(r.rental_id) cnt 
 		from  inventory i 
		 join rental r 
 			on r.inventory_id = i.inventory_id 
 		group by i.film_id) a
 	on f.film_id = a.film_id
 where 
 a.film_id is null
 
 /*
  Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». 
  Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».
  */
select r.staff_id, case 
					when count(*) > 7300 
					then 'Да' else 'Нет' 
					end as prem
from rental r 		
group by r.staff_id

