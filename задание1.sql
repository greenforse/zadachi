--Задание 1. Выведите уникальные названия городов из таблицы городов.
select distinct c.city from city c 

/*Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только 
 * те города, названия которых начинаются на “L” и заканчиваются на “a”, 
 * и названия не содержат пробелов.
*/
select distinct c.city from city c 
where 
c.city like 'L%'
and c.city  like '%a'
and c.city not like '% %'

/*Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам,
  которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и 
  стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.
*/
select *  from payment p 
where 
p.payment_date between to_date('17.06.2005','DD.MM.YYYY') and to_date('19.06.2005','DD.MM.YYYY')
and p.amount > 1.00

/*Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.*/
select *  from payment p 
order by p.payment_date desc 
limit 10

/*Задание 5. Выведите следующую информацию по покупателям:
Фамилия и имя (в одной колонке через пробел)
Электронная почта
Длину значения поля email
Дату последнего обновления записи о покупателе (без времени)

 Каждой колонке задайте наименование на русском языке.
*/

select first_name||' '||last_name as "ФИО", email as "Почта",
char_length(email) as "Число символов в почте",
to_char(last_update,'DD.MM.YYYY')
from customer c

/*Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
 Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.*/
select lower(first_name),  lower(last_name)
from customer 
where 
	activebool  = True
	and
	(upper(first_name) = 'KELLY' or upper(first_name) = 'WILLIE')
	
/*Задание 7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00
 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.*/	
select * from film f 
where 
(rating = 'R' and rental_rate between 0.00 and 3.00)
or 
(rating = 'PG-13' and rental_rate >= 4.00 )

/*
 Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.
 */

select *
from film f
order by char_length(description) desc 
limit 3

/*
  Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
в первой колонке должно быть значение, указанное до @,
во второй колонке должно быть значение, указанное после @.
 */

select substring(email from 1 for (position('@' in email))-1),
	   substring(email from (position('@' in email))+1)
  from customer c 
  
  
  
 /* Задание 10. Доработайте запрос из предыдущего задания, скорректируйте 
   значения в новых колонках: первая буква должна быть заглавной, остальные строчными.
   */
select initcap(substring(email from 1 for (position('@' in email))-1)),
	    initcap(substring(email from (position('@' in email))+1))
 from customer c 
 
 

  


