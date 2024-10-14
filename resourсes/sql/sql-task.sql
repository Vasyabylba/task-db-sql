--1. Вывести к каждому самолету класс обслуживания и количество мест этого класса

SELECT
    a.model,
    s.fare_conditions,
    COUNT(s.seat_no) AS seat_count
FROM
    aircrafts a
JOIN
    seats s USING (aircraft_code)
GROUP BY
    a.model, s.fare_conditions
ORDER BY
    a.model, s.fare_conditions;

--2. Найти 3 самых вместительных самолета (модель + кол-во мест)

SELECT
    a.model,
    COUNT(s.seat_no) AS seat_count
FROM
    aircrafts a
JOIN
    seats s USING (aircraft_code)
GROUP BY
    a.model
ORDER BY
    seat_count DESC
LIMIT 3;

--3. Найти все рейсы, которые задерживались более 2 часов

SELECT
    flight_id,
    flight_no,
    scheduled_departure,
    actual_departure,
    scheduled_arrival,
    actual_arrival,
    (actual_arrival - scheduled_arrival) AS delay
FROM
    flights
WHERE
    (actual_arrival - scheduled_arrival) > INTERVAL '2 hours';

--4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'),
--с указанием имени пассажира и контактных данных

SELECT
    t.ticket_no,
    t.passenger_name,
    t.contact_data
FROM
    tickets t
JOIN
    ticket_flights tf USING (ticket_no)
JOIN
    bookings b USING (book_ref)
WHERE
    tf.fare_conditions IN ('Business')
ORDER BY
    b.book_date DESC
LIMIT 10;

--5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')

SELECT
    f.flight_id,
    f.flight_no,
	f.scheduled_departure
FROM
    flights f
WHERE
    f.flight_id NOT IN (
        SELECT
            tf.flight_id
        FROM
            ticket_flights tf
        WHERE
            tf.fare_conditions IN ('Business')
    );

--6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету

SELECT DISTINCT
    a.airport_name,
    a.city
FROM
    airports a
JOIN
    flights f ON a.airport_code = f.departure_airport
WHERE
    f.status IN ('Delayed');

--7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта,
--отсортированный по убыванию количества рейсов

SELECT
    a.airport_name,
    COUNT(f.flight_id) AS flight_count
FROM
    airports a
JOIN
    flights f ON a.airport_code = f.departure_airport
GROUP BY
    a.airport_name
ORDER BY
    flight_count DESC;

--8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и
--новое время прибытия (actual_arrival) не совпадает с запланированным

SELECT
    flight_id,
    flight_no,
	scheduled_departure,
    scheduled_arrival,
    actual_arrival
FROM
    flights
WHERE
    actual_arrival IS NOT NULL
    AND actual_arrival != scheduled_arrival;

--9. Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам

SELECT
    a.aircraft_code,
    a.model,
    s.seat_no
FROM
    aircrafts a
JOIN
    seats s USING (aircraft_code)
WHERE
    a.model = 'Аэробус A321-200'
    AND s.fare_conditions != 'Economy'
ORDER BY
    s.seat_no;

--10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)

SELECT
    a.airport_code,
    a.airport_name,
	a.city
FROM
    airports a
JOIN (
    SELECT
        city
    FROM
        airports
    GROUP BY
        city
    HAVING
        COUNT(airport_code) > 1
) c USING (city);

--11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований

SELECT
    t.passenger_id,
	t.passenger_name
FROM
    tickets t
JOIN
    bookings b USING (book_ref)
GROUP BY
     t.passenger_id, t.passenger_name
HAVING
    SUM(b.total_amount) > (SELECT AVG(total_amount) FROM bookings);

--12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация

SELECT
    flight_id,
    flight_no,
    scheduled_departure
FROM
    flights_v fv
WHERE
    departure_city = 'Екатеринбург'
    AND arrival_city = 'Москва'
    AND scheduled_departure > bookings.now()
    AND status IN ('On Time', 'Delayed')
ORDER BY
    scheduled_departure
LIMIT 1;

--13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)

(SELECT
    ticket_no,
    amount
FROM
    ticket_flights
ORDER BY
    amount ASC
LIMIT 1)

UNION ALL

(SELECT
    ticket_no,
    amount
FROM
    ticket_flights
ORDER BY
    amount DESC
LIMIT 1);

--14. Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone.
--Добавить ограничения на поля (constraints)

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    CHECK (email LIKE '%@%'),
    CHECK (phone ~ '^[0-9]+$')
);

--15. Написать DDL таблицы Orders, должен быть id, customerId, quantity.
--Должен быть внешний ключ на таблицу customers + constraints

CREATE TABLE orders (
    orders_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
		ON UPDATE NO ACTION
		ON DELETE CASCADE
);

--16. Написать 5 insert в эти таблицы

INSERT INTO customers (first_name, last_name, email, phone) VALUES
('John', 'Doe', 'john.doe@example.com', '375291234567'),
('Jane', 'Smith', 'jane.smith@example.com', '375291234568'),
('Alice', 'Johnson', 'alice.johnson@example.com', '375291234569'),
('Bob', 'Brown', 'bob.brown@example.com', '375291234570'),
('Charlie', 'Davis', 'charlie.davis@example.com', '375291234571');

INSERT INTO orders (customer_id, quantity) VALUES
(1, 10),
(2, 5),
(3, 15),
(4, 7),
(5, 3);

--17. Удалить таблицы

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
