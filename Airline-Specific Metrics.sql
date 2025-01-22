--**Airline-Specific Metrics**

--- **Airline On-Time Performance**: Ranking airlines by on-time departure/arrival rates.

WITH ontime_operations AS (
	SELECT  uf.Airline,
		 	Count(uf.Delay_Carrier) AS Total_ON_TIME
	FROM US_flights uf 
	WHERE uf.Delay_Carrier = 0 OR uf.Delay_Carrier < 0
	GROUP BY uf.Airline
),
total_operations AS (
	SELECT uf.Airline,
			COUNT(*) AS total_operations
	FROM US_Flights uf
	GROUP BY uf.Airline	
)
SELECT oo.Airline,
		t.total_operations,
		ROUND(((oo.Total_ON_TIME)*100.0/ t.total_operations),2) AS on_time_rate
FROM ontime_operations oo JOIN total_operations t
	ON oo.Airline = t.Airline
ORDER BY on_time_rate DESC


--- **Aircrafts model stat

WITH ranked AS (
SELECT FlightDate,Tail_Number, Manufacturer,model,
        ROW_NUMBER() OVER (PARTITION BY Tail_Number ORDER BY FlightDate) AS ranked_order
FROM US_flights 
)
SELECT Manufacturer,
		model,
		count(*) AS num_of_aircrafts
 FROM ranked
 WHERE ranked_order = 1 
 GROUP BY Manufacturer,model
 ORDER BY num_of_aircrafts  DESC

	
	-- manufacture stat
WITH ranked AS (
SELECT FlightDate,Tail_Number, Manufacturer,model,
        ROW_NUMBER() OVER (PARTITION BY Tail_Number ORDER BY FlightDate) AS ranked_order
FROM US_flights 
)
SELECT Manufacturer,
		count(*) AS num_of_aircrafts,
		count(DISTINCT model) AS num_models
 FROM ranked
 WHERE ranked_order = 1 
 GROUP BY Manufacturer
 ORDER BY num_of_aircrafts  DESC
	

	
- --Average time aircraft spend on the air between flights. FOR EACH air line

WITH flight_duration AS (
	SELECT MAX(Airline) AS Airline, 
			Count(DISTINCT FlightDate)AS days, 
			MAX(Tail_Number) AS Tail_Number,
			Max(aircraft_age)AS age,
			SUM (uf.Flight_Duration)/60  AS Total_Daily_flight_time
	FROM US_flights uf 
	GROUP  BY Tail_Number
),
flight_time_avg AS (
	SELECT Airline, 
			Tail_Number, 
			age,
			Total_Daily_flight_time, 
			Total_Daily_flight_time/days AS avg_flight_time_hours
	FROM flight_duration 
)
SELECT Airline,
		count(Tail_Number) AS Num_Aircrafts_owned ,
		sum(age)/count(Tail_Number) AS avg_aircraft_age,
		SUM(avg_flight_time_hours)/count(Tail_Number) AS Total_avg_flight_time_for_aircraft_per_day
FROM flight_time_avg 
GROUP BY Airline
ORDER BY Num_Aircrafts_owned DESC	 



