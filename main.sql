-- **Flight Operations Metrics**

--- **Total Flights Operated**: Total number of flights in the dataset.

SELECT 
    COUNT(*) AS US_Flights,
    (SELECT COUNT(*) FROM Cancelled_Diverted_2023) AS Cancelled_Diverted_Flights,
    COUNT(*) + (SELECT COUNT(*) FROM Cancelled_Diverted_2023) AS Total_Flights
FROM US_flights;

--number of airports
SELECT count(DISTINCT uf.Arr_Airport )
FROM US_flights uf 

--**On-Time Arrival Percentage**: Ratio of flights arriving on or before their scheduled time.

SELECT ((SELECT count(*) 
				FROM US_flights uf 
				WHERE  uf.Arr_Delay  = 0 OR uf.Arr_Delay < 0 )*100.0) / COUNT(*) AS On_Time_Arrival_Percentage
FROM US_flights uf;
		

--- **On-Time Departure Percentage**: Ratio of flights departing on or before their scheduled time.
SELECT ((SELECT count(*) 
			FROM US_flights uf 
			WHERE  uf.Dep_Delay = 0 OR  uf.Dep_Delay < 0  )*100.0 /COUNT(*)) AS percentage
FROM US_flights uf;


--- **Average Delay (Arrival/Departure)**: Mean delay for arrivals and departures.

SELECT 
    ROUND(AVG(COALESCE(Arr_Delay, 0)), 2) AS Mean_Arrival_Delay,
    ROUND(AVG(COALESCE(Dep_Delay, 0)), 2) AS Mean_Departure_Delay
FROM US_flights;

--- **Arrival Delay Distribution**: Distribution of delay times across flights (e.g., 0–15 mins, 15–30 mins, etc.).
WITH arr_delay AS ( 
	SELECT *,(Dep_Delay + Arr_delay) AS total_arr_delay
	FROM US_flights uf 
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
			ROUND(CAST((count(*)*100)  AS decimal(15,2))/CAST((SELECT count(*) 
						FROM US_flights uf)  AS decimal(15,2)),2) AS count_precentage
FROM delay_distribution 
GROUP BY total_delay_type 
ORDER BY num_of_delays DESC


--- **Flight Cancellation/diverted Rate**: Percentage of flights canceled.

WITH cancel_flights AS(
	SELECT COUNT(*) AS cancel
	FROM Cancelled_Diverted_2023 cd
)
SELECT
	ROUND((cancel)*100.0/
	((cancel)+(SELECT COUNT(*) FROM US_Flights)),2)
FROM cancel_flights
	
	


SELECT *
FROM Cancelled_Diverted_2023 cd 
WHERE Delay_Weather =0
	
	
	
	
	

