CREATE TABLE users (
    USER_ID INT PRIMARY KEY,
    USER_NAME VARCHAR(20) NOT NULL,
    USER_STATUS VARCHAR(20) NOT NULL
);

CREATE TABLE logins (
    USER_ID INT,
    LOGIN_TIMESTAMP DATETIME NOT NULL,
    SESSION_ID INT PRIMARY KEY,
    SESSION_SCORE INT,
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

-- Users Table
INSERT INTO USERS VALUES (1, 'Alice', 'Active');
INSERT INTO USERS VALUES (2, 'Bob', 'Inactive');
INSERT INTO USERS VALUES (3, 'Charlie', 'Active');
INSERT INTO USERS  VALUES (4, 'David', 'Active');
INSERT INTO USERS  VALUES (5, 'Eve', 'Inactive');
INSERT INTO USERS  VALUES (6, 'Frank', 'Active');
INSERT INTO USERS  VALUES (7, 'Grace', 'Inactive');
INSERT INTO USERS  VALUES (8, 'Heidi', 'Active');
INSERT INTO USERS VALUES (9, 'Ivan', 'Inactive');
INSERT INTO USERS VALUES (10, 'Judy', 'Active');

-- Logins Table 

INSERT INTO LOGINS  VALUES (1, '2023-07-15 09:30:00', 1001, 85);
INSERT INTO LOGINS VALUES (2, '2023-07-22 10:00:00', 1002, 90);
INSERT INTO LOGINS VALUES (3, '2023-08-10 11:15:00', 1003, 75);
INSERT INTO LOGINS VALUES (4, '2023-08-20 14:00:00', 1004, 88);
INSERT INTO LOGINS  VALUES (5, '2023-09-05 16:45:00', 1005, 82);

INSERT INTO LOGINS  VALUES (6, '2023-10-12 08:30:00', 1006, 77);
INSERT INTO LOGINS  VALUES (7, '2023-11-18 09:00:00', 1007, 81);
INSERT INTO LOGINS VALUES (8, '2023-12-01 10:30:00', 1008, 84);
INSERT INTO LOGINS  VALUES (9, '2023-12-15 13:15:00', 1009, 79);


-- 2024 Q1
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1011, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2024-01-25 09:30:00', 1012, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-02-05 11:00:00', 1013, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2024-03-01 14:30:00', 1014, 91);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-03-15 16:00:00', 1015, 83);

INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2024-04-12 08:00:00', 1016, 80);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (7, '2024-05-18 09:15:00', 1017, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (8, '2024-05-28 10:45:00', 1018, 87);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (9, '2024-06-15 13:30:00', 1019, 76);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-25 15:00:00', 1010, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-26 15:45:00', 1020, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-27 15:00:00', 1021, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-28 15:45:00', 1022, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1101, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-01-25 09:30:00', 1102, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-01-15 11:00:00', 1103, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2023-11-10 07:45:00', 1201, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2023-11-25 09:30:00', 1202, 84);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2023-11-15 11:00:00', 1203, 80);


Select * from users;
Select * from logins;

--Q1 Management wants to see all the users that did not login in the last 5 months 
with cte as (
Select USER_ID,max(login_timestamp) as last_login_date
from logins
group by USER_ID
)
,cte2 as (
Select *,DATEADD(Month,-7,GETDATE()) as prev7_month from cte 
)
Select * from cte2  inner join users on cte2.user_id = users.user_id
where last_login_date<prev7_month

--Q2 For the business' units quarterly analysis , calculate how many users and how many sessions were at each quarter
--order by quarter from newest to oldest 
--Return: First day of the quarter , user_cnt , session_cnt

Select DATETRUNC(quarter,MIN(login_timestamp)) as first_day_qtr,count(distinct USER_ID) as user_cnt , count(distinct session_id) as session_cnt
from logins
group by DATETRUNC(quarter,login_timestamp)
order by first_day_qtr	

--Q3 Display user id's that log -in in January2024 and did not log in on November 2023.

Select distinct user_id,LOGIN_TIMESTAMP from logins
where LOGIN_TIMESTAMP between '2024-01-01' and '2024-01-31'
and user_id not in (Select distinct user_id from logins
where LOGIN_TIMESTAMP between '2023-11-01' and '2023-11-30'
);

--Q4 Add to the query from q2 the percentage change in sessions from last quarter 
--Return first_day_qtr,Session_cnt, session_cnt_prev,session_percent_change

with cte as (
Select DATETRUNC(quarter,MIN(login_timestamp)) as first_day_qtr, count(distinct session_id) as session_cnt
from logins
group by DATETRUNC(quarter,login_timestamp)
	
)
Select * , round(((session_cnt- session_cnt_prev)*100.0/session_cnt_prev),2) as session_percent_change
from (
Select * , lag(session_cnt,1) over(order by first_day_qtr) as session_cnt_prev from cte
) a

--Q5 Display the user which had the highest session score (max) for each day 
Select * from logins;

with cte as (
Select *,cast(login_timestamp as date) as login_Date from logins
)

Select  *,rank()over(partition by login_date order by session_score desc) as rnk from cte
order by login_Date;

--Q6 To identify our best users - Return the users that had a session on every single day since their first login 
with cte as (
Select USER_ID,min(cast(login_timestamp as date)) as first_login,count(distinct cast(login_timestamp as date)) as distinct_login_days  from logins
group by USER_ID
)
,cte2 as (
Select *,cast('2024-06-29' as date) as curr_date from cte
)
,cte3 as (
Select *,DATEDIFF(day,first_login,curr_date) as login_days_gap from cte2
) 
Select * from cte3 where login_days_gap =distinct_login_days; 


---Q6 On what days there were no logins at all?

Select user_id,CAST(login_timestamp as date) as Date from logins
order by user_id , LOGIN_TIMESTAMP


--recursive cte to print all the days between min date and today's date.
with cte as (
Select cast(min(login_timestamp) as Date) as first_date, cast(GETDATE() as date) as last_date
from logins
union all 
Select DATEADD(day,1,first_date) as first_date, last_date from cte 
where first_date<last_date
)
--all the dates that are not in logins table
Select first_date from cte
where first_date not in ( Select CAST(login_timestamp as date) as Date from logins)
option(maxrecursion 500)

