--1. Group info. Group hosts by CPU number and sort by their memory size in descending order(within each cpu_number group)
SELECT cpu_number,id as host_id, total_mem
FROM host_info
ORDER BY cpu_number asc, total_mem desc;
--2. Average memory usage. Average used memory in percentage over 5 mins interval for each host. (used memory = total memory - free memory).
CREATE OR REPLACE FUNCTION round5(ts timestamp) RETURNS timestamp AS
    $$
BEGIN
    RETURN date_trunc('hour', ts) + date_part('minute', ts):: int / 5 * interval '5 min';
END;
$$
LANGUAGE PLPGSQL;
SELECT hu.host_id, round5(hu.timestamp) AS rounded_timestamp,
       ROUND(AVG((hi.total_mem-(hu.memory_free))*100.0/hi.total_mem),2) AS avg_mem_usage_pct
FROM host_usage hu join host_info hi on hu.host_id = hi.id
GROUP BY hu.host_id, rounded_timestamp
ORDER BY hu.host_id, rounded_timestamp;
--3. Detect host failure.
SELECT host_id, round5(timestamp) AS rounded_timestamp, COUNT(*) AS count_data_points
FROM host_usage
GROUP BY host_id, rounded_timestamp
HAVING COUNT(*) <3
ORDER BY host_id, rounded_timestamp;
