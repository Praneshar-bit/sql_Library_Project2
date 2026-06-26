issued_member_idmember_idemp_id
CREATE TABLE books(
	isbn VARCHAR(15) PRIMARY KEY,
	book_title	VARCHAR(30),
	category	VARCHAR(20),
	rental_price	FLOAT,
	status	VARCHAR(30),
	author	VARCHAR(40),
	publisher VARCHAR(30)
)

ALTER TABLE books
ALTER COLUMN  isbn TYPE VARCHAR(40)

ALTER TABLE books
ALTER COLUMN  book_title TYPE VARCHAR(100)

ALTER TABLE books
ALTER COLUMN  author TYPE VARCHAR(100)

ALTER TABLE books
ALTER COLUMN  publisher TYPE VARCHAR(100)

CREATE TABLE branch(
	branch_id	VARCHAR(6) PRIMARY KEY,
	manager_id	VARCHAR(6),
	branch_address	VARCHAR(20),
	contact_no VARCHAR(20)
)

CREATE TABLE employees(
	emp_id	VARCHAR(6) PRIMARY KEY,
	emp_name VARCHAR(20),	
	position	VARCHAR(15),
	salary	INT,
	branch_id VARCHAR(6)
)

CREATE TABLE issued_status(
	issued_id	VARCHAR(6) PRIMARY KEY,
	issued_member_id	VARCHAR(6),   --FK
	issued_book_name	VARCHAR(30),
	issued_date	DATE,
	issued_book_isbn	VARCHAR(15),
	issued_emp_id VARCHAR(6)
)

ALTER TABLE issued_status
ALTER COLUMN  issued_book_name TYPE VARCHAR(100)


ALTER TABLE issued_status
ALTER COLUMN  issued_book_isbn TYPE VARCHAR(100)

CREATE TABLE members(
	member_id	VARCHAR(6) PRIMARY KEY,
	member_name	VARCHAR(20),
	member_address	VARCHAR(15),
	reg_date DATE
)

CREATE TABLE return_status(
	return_id	VARCHAR(6) PRIMARY KEY,
	issued_id	VARCHAR(6),
	return_book_name VARCHAR(20),
	return_date	DATE,
	return_book_isbn VARCHAR(15)
)

ALTER TABLE return_status
ALTER COLUMN return_book_name  TYPE VARCHAR(50);

ALTER TABLE return_status
ALTER COLUMN return_book_isbn  TYPE VARCHAR(50);


-- FOREIGN KEY
ALTER TABLE public.issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES  members(member_id)

ALTER TABLE public.employees
ADD CONSTRAINT fk_branch_id
FOREIGN KEY (branch_id)
REFERENCES  branch(branch_id)

ALTER TABLE public.issued_status
ADD CONSTRAINT fk_employee_id
FOREIGN KEY (issued_emp_id)
REFERENCES  employees(emp_id)

ALTER TABLE public.issued_status
ADD CONSTRAINT fk_book_name
FOREIGN KEY (issued_book_isbn)
REFERENCES  books(isbn)

ALTER TABLE public.return_status
ADD CONSTRAINT fk_issued_id
FOREIGN KEY (issued_id)
REFERENCES  issued_status(issued_id)



--PROJECT TASK

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books ( isbn,	book_title,	category,	rental_price,	status,	author,	publisher)
	VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')


--Task 2: Update an Existing Member's Address
UPDATE public.members
SET member_address = '129 Main St' 
	WHERE member_id='C101'


--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM public.issued_status
	WHERE issued_id = 'IS121'


-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT 
	issued_book_name,
	issued_emp_id
FROM public.issued_status 
WHERE  issued_emp_id= 'E101'


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT 
	issued_emp_id, 
	COUNT(*) AS total_books
FROM public.issued_status
GROUP BY issued_emp_id
HAVING COUNT(*)>=1
ORDER BY COUNT(*)

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE frequency AS 
	SELECT 
		b.isbn, 
		b.book_title, 
		COUNT(*) AS no_of_books
	FROM public.issued_status AS ist
	JOIN public.books AS b
	ON b.isbn=ist.issued_book_isbn
	GROUP BY 1
	ORDER BY 3


-- 4. Data Analysis & Findings
-- Task 7. Retrieve All Books in a Specific Category:
SELECT 
	book_title, 
	category
FROM books
ORDER BY category


-- Task 8: Find Total Rental Income by Category:
SELECT 
	category,
	SUM(rental_price),
	COUNT(*)
FROM public.books
GROUP BY category
ORDER BY 2 DESC


-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT
	member_id,
	member_name,
	reg_date
FROM public.members
WHERE CURRENT_DATE - reg_date>=180
ORDER BY 3


-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT 
	emp.emp_id,
	emp.emp_name,
	emp.position,
	emp.salary,
	b.*,
	emp2.emp_name AS manager_name
FROM public.employees AS emp
JOIN public.branch AS b
ON emp.branch_id=b.branch_id

JOIN public.employees AS emp2   -- SELF JOIN
ON emp2.emp_id=b.manager_id
ORDER BY 6


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE advanced_books AS
SELECT * 
FROM public.books
WHERE rental_price>=5.5


-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status AS isd
LEFT JOIN 
return_status AS rs
ON rs.issued_id= isd.issued_id
WHERE rs.return_id IS NULL


-- Advanced SQL Operations
/*
Task 13: Identify Members with Overdue Books
	Write a query to identify members who have overdue books (assume a 30-day return period). 
	Display the member's_id, member's name, book title, issue date, and days overdue.
*/
SELECT 
	m.member_id,
	m.member_name,
	b.book_title,
	isd.issued_date,
	CURRENT_DATE - isd.issued_date AS overdue_days
FROM public.issued_status AS isd
JOIN members AS m
ON m.member_id= isd.issued_member_id

JOIN books AS b
ON b.isbn= isd.issued_book_isbn

WHERE CURRENT_DATE - isd.issued_date>30
ORDER BY 4


/* Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).*/

-- STORE PROCEDURE
CREATE OR REPLACE PROCEDURE update_column(p_return_id VARCHAR(6), p_issued_id VARCHAR(6), p_return_book_name VARCHAR(40))
LANGUAGE plpgsql 
AS $$
DECLARE
	v_isbn VARCHAR(20);
	v_book VARCHAR(50);
	
BEGIN
	INSERT INTO public.return_status(return_id, issued_id, return_date, return_book_name)
	VALUES(p_return_id, p_issued_id, CURRENT_DATE, p_return_book_name);

	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book
	FROM issued_status
	WHERE issued_id=p_issued_id;

	UPDATE books
	SET status='yes'
	WHERE isbn=v_isbn;
	
	RAISE NOTICE 'Thank You For Returning The Book %', v_book;
END;
$$

-- Testing FUNCTION add_return_records
SELECT * FROM books
WHERE isbn='978-0-307-58837-1';

SELECT * FROM public.issued_status
WHERE issued_book_isbn='978-0-307-58837-1';

SELECT * FROM public.return_status
WHERE return_book_isbn='978-0-307-58837-1';

CALL update_column('RS119', 'IS135','Sapiens: A Brief History of Humankind');


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
CREATE TABLE info AS 
SELECT 
	b.branch_id,
	m.member_name,
	COUNT(iss.issued_id) AS issued_books,
	COUNT(rs.return_id) AS returned_books,
	SUM(b2.rental_price)
FROM public.issued_status AS iss
JOIN public.employees AS e
ON e.emp_id=iss.issued_emp_id

JOIN public.branch AS b
ON b.branch_id=e.branch_id

LEFT JOIN public.return_status AS rs
ON rs.issued_id=iss.issued_id

JOIN books AS b2
ON b2.isbn= iss.issued_book_isbn

JOIN public.members AS m
ON m.member_id=iss.issued_member_id

GROUP BY 1,2
ORDER BY 3

SELECT * FROM info



/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.*/
CREATE TABLE statement_lib AS
SELECT 
	m.member_id,
	m.member_name,
	COUNT(iss.issued_id)
FROM public.issued_status AS iss
JOIN public.members AS m
ON m.member_id=iss.issued_member_id

	WHERE CURRENT_DATE - iss.issued_date<=900
GROUP BY 1,2
	HAVING COUNT(iss.issued_id)>=1;
	
SELECT * FROM statement_lib;


/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/
SELECT 
	e.emp_name,
	COUNT(iss.issued_book_name)AS no_of_books,
	e.branch_id
FROM public.issued_status AS iss
JOIN public.employees AS e
ON e.emp_id=iss.issued_emp_id
GROUP BY 1,3
ORDER BY 2 DESC
LIMIT 3;


/*
Task 18: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available, 
it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book is currently not available
*/ 


--------------------------------------------------------GREAT JOB----------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE system_manage(p_isbn VARCHAR(30))
LANGUAGE plpgsql
AS $$
DECLARE
	v_isbn VARCHAR(30);
	v_status VARCHAR(30);
	
BEGIN
	SELECT 
		isbn,
		status
		INTO
		v_isbn,
		v_status
	FROM books
	WHERE isbn = p_isbn;
	
	IF v_status='yes'
		THEN
			RAISE NOTICE 'Book is issued successfully';
			
			UPDATE books
				SET status='no'
			WHERE isbn=v_isbn;

	ELSE 
		RAISE NOTICE 'the book is currently not available';

	END IF;
	
END;
$$

CALL system_manage('978-0-553-29698-2')

SELECT * FROM books;