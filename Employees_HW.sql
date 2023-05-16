/* 1. feladat */
SELECT departments.dept_name, gender, AVG(salary) AS avg_salary
FROM employees
JOIN salaries ON employees.emp_no = salaries.emp_no
JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
JOIN departments ON dept_emp.dept_no = departments.dept_no
GROUP BY departments.dept_name, gender;

/* 2. feladat */
SELECT MIN(dept_no) AS lowest_dept_no,
MAX(dept_no) AS highest_dept_no
FROM departments;

/* 3. feladat */
SELECT 
  emp_no AS 'Employee number',
  (SELECT MIN(dept_no) FROM dept_emp WHERE emp_no = e.emp_no) AS 'Lowest dept_no',
  CASE 
    WHEN emp_no <= 10020 THEN 110022
    WHEN emp_no BETWEEN 10021 AND 10040 THEN 110039
    ELSE NULL
  END AS 'Manager'
FROM employees e
WHERE emp_no <= 10040;

/* 4. feladat */
SELECT *
FROM employees
WHERE hire_date BETWEEN '2000-01-01' AND '2000-12-31';

/* 5. feladat */
SELECT e.*, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.title LIKE '%Engineer%' -- szerepel az Engineer a titulusában (bárhol)
-- Ha csak 'sima Engineer' akkor: WHERE t.title ='Engineer'
LIMIT 10;

SELECT e.*, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Senior Engineer'
LIMIT 10;

/* 6. feladat */
use employees;
drop procedure if exists last_dept;
delimiter $$
CREATE PROCEDURE last_dept (IN p_emp_no INT)
BEGIN
    SELECT dept_name FROM departments
    INNER JOIN dept_emp ON departments.dept_no = dept_emp.dept_no
    WHERE dept_emp.emp_no = p_emp_no
    ORDER BY dept_emp.from_date DESC LIMIT 1;
END$$
delimiter ;

CALL employees.last_dept (10010);


/* 7. feladat */
SELECT COUNT(*)
FROM salaries
WHERE DATEDIFF(to_date, from_date) / 365 > 1 -- DATEDIFF napod ad, ezért osztani kell 365-el, hogy meglegyen az évek száma és ha ez több mint 1 akkor hosszabb mint 1-év
AND salary > 100000;

/* 8. feladat */
DROP TRIGGER IF EXISTS check_hire_date;
delimiter $$
CREATE TRIGGER check_hire_date 
BEFORE INSERT ON employees 
FOR EACH ROW 
BEGIN 
    IF NEW.hire_date > curdate() THEN 
        SET NEW.hire_date = date_format(curdate(), '%Y-%m-%d'); 
    END IF;
END$$
delimiter ;

-- Teszt
USE employees;
INSERT employees VALUES('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');
SELECT * FROM employees ORDER BY emp_no DESC LIMIT 10;

-- Teszt torlese
DELETE FROM employees WHERE emp_no = '999904';


/* 9. feladat */
-- Legmagasabb fizetés lekérdezése employee no. alapján
DROP FUNCTION IF exists get_max_salary;
delimiter $$
CREATE FUNCTION get_max_salary(p_emp_no INT) 
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
  DECLARE max_salary DECIMAL(10,2);
  SELECT MAX(salary) INTO max_salary FROM salaries WHERE emp_no = p_emp_no;
  RETURN max_salary;
END$$
delimiter ;

SELECT employees.get_max_salary(11356);

-- Legalacsonyabb fizetés lekérdezése employee no. alapján
DROP FUNCTION IF exists get_min_salary;
delimiter $$
CREATE FUNCTION get_min_salary(p_emp_no INT) 
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
  DECLARE min_salary DECIMAL(10,2);
  SELECT MIN(salary) INTO min_salary FROM salaries WHERE emp_no = p_emp_no;
  RETURN min_salary;
END$$
delimiter ;

SELECT employees.get_min_salary(11356);

/* 10. feladat */
DROP FUNCTION IF exists get_salary_type;
delimiter $$
CREATE FUNCTION get_salary_type(p_emp_no INT, search_type CHAR(3)) 
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE result DECIMAL(10,2);
    IF (search_type = 'min') THEN
        SELECT MIN(salary) INTO result FROM salaries WHERE emp_no = p_emp_no;
    ELSEIF (search_type = 'max') THEN
        SELECT MAX(salary) INTO result FROM salaries WHERE emp_no = p_emp_no;
    ELSE
        SELECT MAX(salary) - MIN(salary) INTO result FROM salaries WHERE emp_no = p_emp_no;
    END IF;
  RETURN result;
END$$
delimiter ;

-- SELECT employees.get_salary_type(11356, 'max');
-- SELECT employees.get_salary_type(11356, 'min');
-- SELECT employees.get_salary_type(11356, '');

