--assign7
--Salii Maryna		

--0
SET ANSI_WARNINGS OFF; 
USE SIS;

--1
--Show the count of the employees in the Employee table who work in the School of Business,
--aliased as ‘Employees in the School of Business’

SELECT COUNT(number) AS 'Employees in the School of Business'
FROM Employee;


--NB! More than sure that there should be a way to make it work without repeating the query
--2
--List the students, and their final marks, who took PROG8080 during the Fall 2009 semester 
--and achieved a higher than average mark in the course. List each student’s student number and mark,
--along with their first and last name, in ascending order of last name.


DECLARE @my_avg INT;
SELECT @my_avg = AVG(finalMark) FROM CourseStudent AS cs 
INNER JOIN Person AS p 
	ON cs.studentNumber = p.number
INNER JOIN CourseOffering AS co
	ON co.id = cs.CourseOfferingId
WHERE co.courseNumber = 'PROG8080'
AND co.sessionCode = 'F09';

SELECT p.firstName, p.lastName, p.number, cs.finalMark 
FROM CourseStudent AS cs 
INNER JOIN Person AS p 
	ON cs.studentNumber = p.number
INNER JOIN CourseOffering AS co
	ON co.id = cs.CourseOfferingId
WHERE co.courseNumber = 'PROG8080'
AND co.sessionCode = 'F09'
GROUP BY cs.finalMark , p.firstName, p.lastName, p.number 
HAVING cs.finalMark > @my_avg
ORDER BY p.lastName;


--3
--Show CourseOffering courseNumber, CourseStudent minimum finalMark aliased as ‘Lowest Mark’, 
--CourseStudent average finalMark aliased as ‘Average Mark’ and 
--CourseStudent maximum finalMark aliased as ‘Maximum Mark’ 
--for the Fall 2010 session grouped by courseNumber.
--Report all grades as whole numbers

SELECT courseNumber AS 'Course', ROUND(MIN(cs.finalMark), 0) AS 'Lowest Mark', 
ROUND(AVG(cs.finalMark), 0) AS 'Average Mark', ROUND(MAX(cs.finalMark), 0) AS 'Maximum Mark'
FROM CourseOffering AS co, CourseStudent AS cs
WHERE co.sessionCode = 'F10' AND co.id = cs.CourseOfferingId
GROUP BY co.courseNumber;

--4
--List the students (student number, first and last name)
--who have thus far paid less in total for their education than the average amount paid by all students

SELECT p.number, p.lastName, p.firstName
FROM Person AS p
WHERE EXISTS (SELECT * FROM Audit AS a
				WHERE p.number = a.studentNumber
				GROUP BY a.balanceAfter
				HAVING a.balanceAfter < AVG(a.amount));

--5a
--List the number of courses taught by employees in the School of Engineering and IT, 
--for those courses offered in any semester of 2008 or 2009. 
--Include in the result the employee number, first name, and last name, 
--along with the count of the number of courses that they taught, aliased with “Courses Taught”. 
--Order the result by employee last name. 
--Use only inner joins

SELECT p.number AS 'EmployeeNumber', p.firstName, p.lastName, COUNT(co.courseNumber) AS 'Courses Taught'
FROM School AS s 
INNER JOIN Employee AS e 
		ON s.code = e.schoolCode
INNER JOIN CourseOffering AS co 
		ON e.number = co.employeeNumber
INNER JOIN Person AS p
		ON co.employeeNumber = p.number
WHERE s.name = 'Engineering and Information Technology'
AND  (co.sessionCode LIKE '%08' OR co.sessionCode LIKe '%09')
GROUP BY p.number, p.firstName, p.lastName
ORDER BY p.lastName;

--NB! I have no idea how to do this one, tried everything already
--There is a mistake in the task because there are no these teachers in the db
--5b
--Modify the query used in Question (5a) and include all faculty in the School of Engineering and IT,
--even if they did not teach any courses in the years 2008 or 2009.



--6
--Produce a list of all of the co-op programs in the SIS database 
--and the total tuition for those programs over all semesters. 
--As these amounts are for co-op programs, the base tuition amount 
--must be increased by the corresponding co-op multiplier for each specific program.
--Output the program acronym and program name in the result, along with the total tuition.
--Hint: the Computer Programmer (CP) program is not a co-op program. Order the results by program acronym, 
--and format the total tuition amounts using dollars and cents.

SELECT p.acronym, p.name, 
'$' + CONVERT( CHAR(10), CAST(SUM(pf.tuition * pf.coopFeeMultiplier +  pf.tuition) AS money ), 1 ) AS 'Total Fees'
FROM Program AS p
INNER JOIN ProgramFee AS pf
	ON p.code = pf.code
WHERE p.name LIKE '%(Coop)'
GROUP BY p.acronym, p.name
ORDER BY p.acronym;

--7
--List the students and the total amount paid for those students
--who have paid total fees of at least triple the average payment amount.
--Include the students’ first and last names in the result. 
--Order the result of first name within last name.
--Alias the total amount paid as [Fee Payment Total].
--Format the monetary amount using dollars and cents notation.

SELECT per.number, per.firstName, per.lastName,
'$' + CONVERT( CHAR(10), CAST(SUM(pay.amount) AS money ), 1 ) AS 'Fee Payment Total'
FROM Person AS per
INNER JOIN Payment AS pay
	ON per.number = pay.studentNumber
GROUP BY per.number, per.firstName, per.lastName
HAVING SUM(pay.amount) >= (SELECT 3*AVG(pay.amount) FROM Payment AS pay)
ORDER BY per.lastName;


--8
SET ANSI_WARNINGS ON; 