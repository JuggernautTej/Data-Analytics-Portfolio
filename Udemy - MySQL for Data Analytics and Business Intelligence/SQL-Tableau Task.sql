use employees_mod;
/* Task 1. Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990 */
SELECT 
    YEAR(t_dept_emp.from_date) AS calendar_year,
    t_employees.gender AS gender,
    COUNT(t_employees.gender) AS no_of_emp
FROM
    t_employees
        JOIN
    t_dept_emp ON t_employees.emp_no = t_dept_emp.emp_no
GROUP BY calendar_year, t_employees.gender
having calendar_year >=1990 ;

select year(t_dept_emp.from_date) as calendar_year,  t_employees.gender AS gender FROM
    t_employees
        JOIN
    t_dept_emp ON t_employees.emp_no = t_dept_emp.emp_no
GROUP BY gender;
select emp_no, from_date, to_date from t_dept_emp;

select distinct emp_no, from_date, to_date from t_dept_emp;
 use employees_mod;

/* Task 2. Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990 */ 
 SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS Live
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , e.calendar_year;


SELECT 
    e.emp_no, e.first_name, e.last_name, e.gender, d.dept_name
FROM
    t_departments d
        CROSS JOIN
    t_dept_emp de 
        JOIN
    t_employees e ON de.emp_no = e.emp_no
ORDER BY e.emp_no;

/* Task 3. Compare the average salary of female versus male employees in the entire company until year 2002, and add a filter allowing you to see that 
per each department. */
SELECT 
    e.gender as Gender,round(avg(s.salary),2) as Salary, d.dept_name as Department, year(s.from_date) as Calendar_Year
FROM
    t_departments d
        JOIN
    t_dept_emp de on d.dept_no=de.dept_no
        JOIN
    t_employees e ON de.emp_no = e.emp_no
    JOIN 
    t_salaries s on e.emp_no= s.emp_no
group by Gender, Department, Calendar_Year
having Calendar_Year <= 2002
order by d.dept_no;

/* Task 4. Create an SQL stored procedure that will allow you to obtain the average male and female salary
 per department within a certain salary range. Let this range be defined by two values the user can insert when calling the procedure. */
SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no , e.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;
use employees_mod;

drop procedure if exists Average_Salary_P;

delimiter $$
create procedure Average_Salary_P (in Min_Salary float, in Max_Salary float) 
begin 
select  e.gender,avg(s.salary) as Average_Salary, d.dept_name as Department
FROM
    t_departments d
        JOIN
    t_dept_emp de on d.dept_no=de.dept_no
        JOIN
    t_employees e ON de.emp_no = e.emp_no
    JOIN 
    t_salaries s on e.emp_no= s.emp_no
    where s.salary between Min_Salary and Max_Salary
group by e.gender , d.dept_no;
end$$

delimiter ;
