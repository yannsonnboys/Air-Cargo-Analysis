-- Database creation
create database if not exists aircargo;

-- Use the database that has been created
use aircargo;

-- Task 2:
	-- Write a query to create a route_details table using suitable data types for
	-- the fields, such as route_id, flight_num, origin_airport, destination_airport,
	-- aircraft_id, and distance_miles. Implement the check constraint for the
	-- flight number and unique constraint for the route_id fields. Also, make sure
	-- that the distance miles field is greater than 0.

create table if not exists aircargo.route_details (
	Route_id int primary key not null auto_increment,
    Flight_num varchar(100) check (Flight_num like '[A-Z]{2}[0-9]{4}'),
    Origin_airport varchar(100),
    Destination_airport varchar(100),
    Aircraft_id varchar(100),
    Distance_miles int check (Distance_miles > 0)
);


select * from aircargo.customer;

select * from aircargo.passengers_on_flights;

select * from aircargo.routes;

select * from aircargo.ticket_details;


-- Task 3:
	-- Write a query to display all the passengers (customers) who have
	-- travelled in routes 01 to 25. Take data from the passengers_on_flights table.

select * from aircargo.passengers_on_flights
where route_id between 1 and 25
order by customer_id;


-- Task 4:
	-- Write a query to identify the number of passengers and total revenue in
	-- business class from the ticket_details table.
    
select sum(no_of_tickets) as number_of_passengers, sum(Price_per_ticket) as total_revenue  from aircargo.ticket_details
where class_id = "Bussiness";


-- Task 5:
	-- Write a query to display the full name of the customer by extracting the
	-- first name and last name from the customer table.

select concat(first_name, " ", last_name) as Customer_full_name from aircargo.customer; 



-- Task 6:
	-- Write a query to extract the customers who have registered and booked aticket. 
    -- Use data from the customer and ticket_details tables.

select * from 
(select customer_id, first_name, last_name from aircargo.customer) as Registered_customer
inner join
(select no_of_tickets, customer_id from aircargo.ticket_details) as Ticket_booked
on Registered_customer.customer_id = Ticket_booked.customer_id;



-- Task 7:
	/*
		Write a query to identify the customer’s first name and last name based
		on their customer ID and brand (Emirates) from the ticket_details table.
    */
select customer_id, brand from aircargo.ticket_details;



-- Task 8:
	/*
		Write a query to identify the customers who have travelled by Economy Plus 
        class using Group By and Having clause on the passengers_on_flights table.
    */
    
select * from aircargo.passengers_on_flights;

select count(class_id), class_id, aircraft_id from aircargo.passengers_on_flights
where class_id = "Economy Plus"
group by aircraft_id;


-- Task 9:
	-- Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.

select sum(Price_per_ticket) as Total_revenue,
case 
	when sum(Price_per_ticket) > 10000 then 'Yes! we just crossed the 10000 revenue'
    when sum(Price_per_ticket) <= 10000 then 'Yes we have not yer crossed the 10000 revenue'
    else null
end as Crossed_revenue
from aircargo.ticket_details;
    



-- Task 10: 
	/*  (I'm rewriting this question number 10 because the original question has nothing to do this database)
		Write a query to create and grant access to a passenger class level according to th ticket price.
    */

select customer_id, class_id, Price_per_ticket,
case 
	when Price_per_ticket <= 200 then 'You have access on Economy'
	when Price_per_ticket >= 200 then 'You have access on Economy Plus'
	when Price_per_ticket >= 300  then 'You have access on First Class'
	when Price_per_ticket >= 400 then 'You have access on First Class'
	else null 
end as access_type 
from aircargo.ticket_details ; 



-- Task 11:
	-- Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.

create view Max_ticket_price as
select class_id, max(Price_per_ticket) from aircargo.ticket_details
group by class_id;

select * from Max_ticket_price;


-- Task 12:
	/*
		Write a query to extract the passengers whose route ID is 4 by improving the speed and performance 
		of the passengers_on_flights table.
    */

create index idx_route_id on aircargo.passengers_on_flights(route_id);

select customer_id, class_id, seat_num
from aircargo.passengers_on_flights
where route_id = 4;
 


-- Task 13:
	 -- For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.
     
select * from aircargo.passengers_on_flights;

explain
select route_id
from aircargo.passengers_on_flights
where route_id = 4;



-- Task 14:
	/*
		Write a query to calculate the total price of all tickets booked by a customer 
        across different aircraft IDs using rollup function.
	*/
    
select customer_id, aircraft_id, sum(Price_per_ticket) as Total_price
from  aircargo.ticket_details
group by customer_id, aircraft_id with rollup;



-- Task 15:
	 -- Write a query to create a view with only business class customers along with the brand of airlines.


create view Business_class_customers as
select customer_id, class_id, brand 
from aircargo.ticket_details
where class_id = "Bussiness";

select * from Business_class_customers;



-- Task 16:
	/*
		Write a query to create a stored procedure to get the details of all
		passengers flying between a range of routes defined in run time. Also,
		return an error message if the table doesn't exist.
    */
USE `aircargo`;
DROP procedure IF EXISTS `GetPassengersByRouteRange`;

DELIMITER $$
USE `aircargo`$$
CREATE PROCEDURE `GetPassengersByRouteRange` (in strat_route int, in end_route int)
BEGIN
	if exists (select 1 from information_schema.tables where table_schema = DATABASE() AND table_name = 'aircargo.passengers_on_flights') THEN
		select customer_id, route_id, p_date
		from aircargo.passengers_on_flights
        where route_id between strat_route and end_route;
	else
		signal sqlstate '42X01'
        set message_text = 'Table passengers_on_flights does not exist.';
	end if;
END$$

DELIMITER ;

CALL GetPassengersByRouteRange (10, 20);



-- Task 17:
	/*
		Write a query to create a stored procedure that extracts all the details
		from the routes table where the travelled distance is more than 2000 miles.
	*/
USE `aircargo`;
DROP procedure IF EXISTS `TravelDistanceMoreThan2000`;

DELIMITER $$
USE `aircargo`$$
CREATE PROCEDURE `TravelDistanceMoreThan2000` ()
BEGIN
	select * 
    from aircargo.routes
    where distance_miles > 2000;
END$$

DELIMITER ;

call TravelDistanceMoreThan2000;



-- Task 18:
	/*
		Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. 
        The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance
		travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500.
    */
    
USE `aircargo`;
DROP procedure IF EXISTS `GroupDistanceTravelled`;

DELIMITER $$
USE `aircargo`$$
CREATE PROCEDURE `GroupDistanceTravelled` ()
BEGIN
	select * ,
		case
			when distance_miles >= 0 and distance_miles<= 2000 then 'Short Distance Travel (SDT)'
            when distance_miles > 2000 and distance_miles <= 6500 then 'Intermediate Distance Travel (IDT)'
            when distance_miles > 6500 then 'Long Distance Travel (LDT)'
            else null
		end as Distance_travelled
    from aircargo.routes;
END$$

DELIMITER ;

call GroupDistanceTravelled;



-- Task 19:
	/*
		 Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary 
         services are provided for the specific class using a stored function in stored procedure on the ticket_details table.
		  
		Condition:
			● If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No
    */

-- Function -- 
USE `aircargo`;
DROP function IF EXISTS `IsComplimentaryService`;

DELIMITER $$
USE `aircargo`$$
CREATE FUNCTION `IsComplimentaryService` (class_id VARCHAR(100))
RETURNS VARCHAR(100) READS SQL DATA
BEGIN
	IF class_id IN ('Bussiness', 'Economy Plus') THEN
        RETURN 'Yes';
    ELSE
        RETURN 'No';
    END IF;
RETURN class_id;
END$$

DELIMITER ;

-- Procedure --
USE `aircargo`;
DROP procedure IF EXISTS `GetTicketDetailsWithComplimentaryServices`;

DELIMITER $$
USE `aircargo`$$
CREATE PROCEDURE `GetTicketDetailsWithComplimentaryServices` ()
BEGIN
	SELECT p_date, customer_id, class_id, IsComplimentaryService(class_id) AS complimentary_services
	FROM aircargo.ticket_details;
END$$

DELIMITER ;

call GetTicketDetailsWithComplimentaryServices;

