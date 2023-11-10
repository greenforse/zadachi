/*
 Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) 
 равным “Behind the Scenes”.  
 */
select * from film f 
WHERE 'Behind the Scenes' = ANY (f.special_features)

/*
  Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции 
  или операторы языка SQL для поиска значения в массиве.
  */
select * from film f 
WHERE --'Behind the Scenes' = ANY (f.special_features)
   f.special_features && ARRAY['Behind the Scenes']
-----------------------------------------------------------------------
select * from film f 
WHERE 
  array_position(f.special_features,'Behind the Scenes') is not NULL
-----------------------------------------------------------------------
  
/*
Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.
 */  
  
with beh_sce as (
select * from film f 
WHERE 'Behind the Scenes' = ANY (f.special_features)
)

select c.customer_id, count(r.rental_id)
from customer c 
 left join rental r 
 	on c.customer_id = r.customer_id 
 join inventory i 
 	on i.inventory_id  = r.inventory_id
 join  beh_sce bs
 	on bs.film_id = i.film_id
group by c.customer_id


/*Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов 
со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, 
помещённый в подзапрос, который необходимо использовать для решения задания.*/

select c.customer_id, count(r.rental_id)
from customer c 
 left join rental r 
 	on c.customer_id = r.customer_id 
 join inventory i 
 	on i.inventory_id  = r.inventory_id
 join  (select * from film f 
		WHERE 'Behind the Scenes' = ANY (f.special_features)) bs
 	on bs.film_id = i.film_id
group by c.customer_id

/*
Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите
 запрос для обновления материализованного представления.
*/

CREATE MATERIALIZED VIEW buy_behind as
select c.customer_id, count(r.rental_id)
from customer c 
 left join rental r 
 	on c.customer_id = r.customer_id 
 join inventory i 
 	on i.inventory_id  = r.inventory_id
 join  (select * from film f 
		WHERE 'Behind the Scenes' = ANY (f.special_features)) bs
 	on bs.film_id = i.film_id
group by c.customer_id ;

select * from buy_behind

REFRESH MATERIALIZED VIEW buy_behind;


/*
Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;
какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.
  */
-- Значительных различий по скорости выполнения не выявил, cost первого варианта немного выше 
explain analyze select * from film f 
WHERE 'Behind the Scenes' = ANY (f.special_features)

explain analyze select * from film f 
WHERE 
   f.special_features && ARRAY['Behind the Scenes']

explain analyze select * from film f 
WHERE 
  array_position(f.special_features,'Behind the Scenes') is not NULL

-------------------------------------------------------------------------------------------------
-- Применение CTE или подзапрос план запроса не изменился и следовательно скорость выполнения
  
  
explain analyze 
with beh_sce as (
select * from film f 
WHERE 'Behind the Scenes' = ANY (f.special_features)
)

select c.customer_id, count(r.rental_id)
from customer c 
 left join rental r 
 	on c.customer_id = r.customer_id 
 join inventory i 
 	on i.inventory_id  = r.inventory_id
 join  beh_sce bs
 	on bs.film_id = i.film_id
group by c.customer_id


explain analyze select c.customer_id, count(r.rental_id)
from customer c 
 left join rental r 
 	on c.customer_id = r.customer_id 
 join inventory i 
 	on i.inventory_id  = r.inventory_id
 join  (select * from film f 
		WHERE 'Behind the Scenes' = ANY (f.special_features)) bs
 	on bs.film_id = i.film_id
group by c.customer_id


/*
 Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
 */
select *
from (select s.staff_id,s.first_name, s.last_name ,
	row_number()over(partition by s.staff_id order by p.payment_date) nn,
	p.*
from staff s 
join payment p 
	on p.staff_id  = s.staff_id)
where nn = 1 


/*
 Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.
 */select distinct  s2.store_id,
	 to_char(nth_value(date_trunc('day', r.rental_date),1)over(partition by s2.store_id order by count(r.rental_id)desc),'DD.MM.YYYY') day_max,
	 nth_value(count(r.rental_id) ,1)over(partition by s2.store_id order by count(r.rental_id)desc) cnt_film,
	 to_char(nth_value(date_trunc('day', r.rental_date),1)over(partition by s2.store_id order by sum(pgr.sum_amount)),'DD.MM.YYYY') day_min
from rental r 
join staff s 
   on s.staff_id  = r.staff_id 
join store s2 
   on s2.store_id  = s.store_id
join (select p.rental_id, sum(p.amount) sum_amount from payment p group by p.rental_id) pgr
	on pgr.rental_id = r.rental_id 
group by s2.store_id,  date_trunc('day', r.rental_date)
