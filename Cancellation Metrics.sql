--Delay/Cancellation Metrics

--- **Top 10 Airports by Cancellation**: Airports with the highest percentage of canceled flights.
SELECT TOP 10 Dep_CityName ,Dep_Airport ,COUNT(Dep_Airport) AS Num_flights_cancel_Diverted
FROM Cancelled_Diverted_2023 cd 
WHERE cd.Cancelled =1
GROUP BY Dep_Airport,Dep_CityName 
ORDER BY Num_flights_cancel_Diverted DESC

--- **Seasonal or Temporal Trends**: Cancellations by month, day of the week, or time of day.
SELECT MONTH(FlightDate) AS Month, COUNT(*) AS Num_of_Flights
FROM Cancelled_Diverted_2023 cd 
GROUP BY MONTH(FlightDate)
ORDER BY Month

SELECT Day_Of_Week AS Day,COUNT(*) AS Num_of_Flights
FROM Cancelled_Diverted_2023 cd 
GROUP BY Day_Of_Week 
ORDER BY Day_Of_Week 

SELECT DepTime_label AS Day,COUNT(*) AS Num_of_Flights
FROM Cancelled_Diverted_2023 cd 
GROUP BY DepTime_label 
ORDER BY DepTime_label 

--Cancellation Reasons:Delay Reasons reported:

SELECT 
ROUND((COUNT(CASE WHEN uf.Delay_NAS > 0 OR  uf.Delay_Security >0 OR uf.Delay_LastAircraft >0 OR Delay_Weather >0 OR uf.Delay_Carrier>0
    THEN 1 END) * 100.0) / COUNT(*),2) AS More_Reasons_Percentage,
ROUND((COUNT(CASE WHEN uf.Delay_NAS = 0 AND  uf.Delay_Security = 0 AND uf.Delay_LastAircraft = 0 AND Delay_Weather = 0 AND uf.Delay_Carrier= 0
    THEN 1 END) * 100.0) / COUNT(*),2) AS Not_Reported_Percentage
FROM (SELECT *
	FROM US_flights 
	WHERE Dep_Delay > 0 OR Arr_Delay  > 0) uf;
-- for categorized not reported delay reason 

WITH arr_delay AS ( 
	SELECT * , 
			(Dep_Delay + Arr_delay) AS total_arr_delay
	FROM US_flights uf 
	WHERE (Dep_Delay > 0 OR Arr_Delay  > 0) AND (uf.Delay_NAS = 0 AND  uf.Delay_Security = 0 AND uf.Delay_LastAircraft = 0 AND 
			Delay_Weather =0 AND uf.Delay_Carrier=0)
),
	delay_distribution AS (
	SELECT *,CASE 
			WHEN total_arr_delay >= 120 THEN 'severe_delay'
			WHEN total_arr_delay >= 60 THEN 'significant_delay'
			WHEN total_arr_delay >= 30 THEN 'moderate_delay'
			WHEN total_arr_delay >= 15 THEN 'short_delay'
			ELSE 'minor_or_no_delay' END as total_delay_type
	FROM arr_delay 
)
SELECT DISTINCT total_delay_type AS categories, 
			count(*) AS num_of_delays,
			ROUND(count(*)*100.0/(SELECT count(*) 
						FROM US_flights uf
						WHERE (Dep_Delay > 0 OR Arr_Delay  > 0) AND (uf.Delay_NAS = 0 AND  uf.Delay_Security = 0 AND uf.Delay_LastAircraft = 0 AND 
			Delay_Weather =0 AND uf.Delay_Carrier=0)),2) AS count_precentage
FROM delay_distribution 
GROUP BY total_delay_type 
ORDER BY num_of_delays DESC

