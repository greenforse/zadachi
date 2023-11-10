/*
  Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
  *Пронумеруйте все платежи от 1 до N по дате
  *Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
  *Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
  *Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
  Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
*/

select row_number()over (order by p.payment_date) nn,  p.*
from payment p ;
---------------------------------------------------------
select row_number()over (partition by p.customer_id  order by p.payment_date) nn,  p.*
from payment p
---------------------------------------------------------
select sum(p.amount) over (partition by p.customer_id order by p.payment_date rows between unbounded preceding and current row),
  p.*
from payment p 
---------------------------------------------------------
select dense_rank()over (partition by p.customer_id  order by p.amount desc) nn,  p.*
from payment p
---------------------------------------------------------

/*
 Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа 
 из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
*/
select coalesce(lag(p.amount) over(partition by p.customer_id order by p.payment_date),0.00) ,  p.*
from payment p


/*
 Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
 */
select p.amount  - coalesce(lead(p.amount) over(partition by p.customer_id order by p.payment_date),0.00)  ,  p.*
from payment p

/*
 Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
 */
select c.customer_id, a.amount, a.payment_date , a.staff_id
from customer c 
left join (select row_number()over (partition by p.customer_id  order by p.payment_date desc) nn,  p.*
			from payment p) a
	on a.customer_id = c.customer_id 
	and nn = 1
	
/*
 Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с
  нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате
 */
	
select p.customer_id,date_trunc('day', payment_date),
	   sum(sum(p.amount)) over (partition by p.customer_id order by date_trunc('day', payment_date))
from payment p 
where 
p.payment_date between to_date('01.08.2005','DD.MM.YYYY') and to_date('31.08.2005','DD.MM.YYYY')
group by p.customer_id, date_trunc('day', payment_date)

/*
 Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку
 на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
 */

select a.*
from  (select row_number()over(partition by p.customer_id order by p.payment_date) nn,
			p.customer_id,
			p.payment_date
		from payment p) a
where 
date_trunc('day', payment_date) = to_date('20.08.2005','DD.MM.YYYY')
and nn = 100

/*
 Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
покупатель, арендовавший наибольшее количество фильмов;
покупатель, арендовавший фильмов на самую большую сумму;
покупатель, который последним арендовал фильм.
*/


--Есть вариант использования nth_value и дистинкт, но не додумался до него когда делал, в последнем задании сделал похожую 
--задачу через эту аналитическую функцию
with top_for_country as (
select 	c.country ,c.country_id,
		c3.customer_id,
		row_number()over(partition by c.country_id order by pp.last_date desc) as last_buy,
		row_number()over(partition by c.country_id order by b.sm desc) as top_sum,
		row_number()over(partition by c.country_id order by g.cnt desc) as top_rent
from country c 
join city c2 
	on c2.country_id = c.country_id 
join address a 
	on a.city_id = c2.city_id
join customer c3 ON c3.address_id  = a.address_id 
join (select r.customer_id, count(*) cnt
		from rental r
		group by r.customer_id)g
	on g.customer_id = c3.customer_id 
join (select p1.customer_id, sum(p1.amount) sm
 		 from payment p1 
 		group by p1.customer_id) b
	on b.customer_id = c3.customer_id 
join   (select p.customer_id, max(p.payment_date) last_date
	 	from payment p
	 	group by p.customer_id ) pp
			on pp.customer_id  = c3.customer_id
)
select c.country, tfc.customer_id as "Покуп. больше кл-во", tfc1.customer_id as "Покуп. большая сумма", tfc2.customer_id as "Последний покуп."
from country c 
left join top_for_country tfc
	on c.country_id  = tfc.country_id
	and tfc.top_rent = 1
left join top_for_country tfc1
	on c.country_id  = tfc1.country_id
	and tfc1.top_sum = 1
left join top_for_country tfc2
	on c.country_id  = tfc2.country_id
	and tfc2.last_buy = 1
