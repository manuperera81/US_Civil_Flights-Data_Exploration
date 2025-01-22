--- **Most Delayed Routes**: Routes with the highest average delay.

WITH all_delays AS (
	SELECT 
	    uf.Dep_CityName,
	    uf.Arr_CityName,
	    SUM(COALESCE(uf.Dep_Delay, 0) + COALESCE(uf.Arr_Delay, 0)) AS total_delay,
	    COUNT(CASE WHEN uf.Dep_Delay > 0 OR uf.Arr_Delay >0 THEN 1 END) AS flight_count
	FROM US_flights uf
	WHERE uf.Dep_Delay > 0 OR uf.Arr_Delay > 0
	GROUP BY uf.Dep_CityName, uf.Arr_CityName 
)
SELECT Dep_CityName ,
	Arr_CityName ,
	(total_delay/flight_count)/60 AS delays_avg_hour
FROM all_delays
ORDER BY delays_avg_hour DESC

-- most popular route
SELECT 
    uf.Dep_CityName,
    uf.Arr_CityName,
    count(*) AS count
FROM US_flights uf
GROUP BY uf.Dep_CityName, uf.Arr_CityName 
ORDER BY count DESC

--- **Top Performing Airports**: Airports with the lowest delay and cancellation rates.
WITH delay_dep AS (
	SELECT  uf.Dep_Airport,
			uf.Dep_CityName,
		 	SUM(uf.Dep_Delay)/count(*)  AS avg_Dep_delay_min
	FROM US_flights uf 
	GROUP BY uf.Dep_Airport, uf.Dep_CityName
),
Arr_delay AS (
	SELECT  uf.Arr_Airport ,
		 	SUM(uf.Arr_delay)/count(*) AS avg_Arr_delay_min
	FROM US_flights uf 
	GROUP BY  uf.Arr_Airport
),
 total_sum_delay AS (
	 SELECT dd.Dep_CityName,
	 		(dd.avg_Dep_delay_min + ad.avg_Arr_delay_min)/2 AS avg_Delay_By_airport_min
	 FROM delay_dep dd JOIN  Arr_delay ad
	  ON dd.Dep_airport = ad.Arr_Airport  
),
cancel_flights AS(
	SELECT cd.Dep_CityName,
		COUNT(Cancelled) AS cancel
	FROM Cancelled_Diverted_2023 cd
	WHERE cd.Cancelled =1
	GROUP BY cd.Dep_CityName
),
departure_flights AS (
	SELECT Dep_CityName,
		Dep_airport,
		COUNT(*) AS total_departure
	FROM US_Flights
	GROUP BY Dep_CityName,Dep_airport
)
SELECT cf.Dep_CityName,
		d.Dep_airport,
		ROUND(((cf.cancel*100.0)/ d.total_departure),2) AS cancellation_rate,
		ts.avg_Delay_By_airport_min
FROM cancel_flights cf JOIN departure_flights d
	ON cf.Dep_CityName = d.Dep_CityName
JOIN total_sum_delay ts
		ON cf.Dep_CityName =  ts.Dep_CityName
ORDER BY ts.avg_Delay_By_airport_min, cancellation_rate





