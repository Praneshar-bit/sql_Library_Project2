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
	return_book_name	VARCHAR(20),
	return_date	DATE,
	return_book_isbn VARCHAR(15)
)

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


SELECT *FROM 