--search_book

SET SERVEROUTPUT ON;
--SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE search_book(
    book_id CHAR,
    branch_name VARCHAR2
) IS 
check1 NUMBER(4,0) := 0;
no_book EXCEPTION;
not_in_branch EXCEPTION;
branch_id BRANCHES.BRANCH_ID%TYPE;
book_title BOOKS.title1%TYPE;
book_author BOOK_AUTHORS.AUTHOR_NAME%TYPE;
publisher1 PUBLISHERS.NAME1%TYPE;
no_of_copies BOOK_COPIES.no_of_copies%TYPE;
BEGIN

SELECT COUNT(*) INTO check1
FROM BOOKS
WHERE BOOKS.BOOK_ID = search_book.BOOK_ID;

IF check1 = 0 THEN
    RAISE no_book;
END IF;

check1 := 0;

SELECT BRANCHES.BRANCH_ID INTO search_book.branch_id
FROM BRANCHES
WHERE BRANCHES.branch_name = search_book.branch_name;

SELECT COUNT(*) INTO check1
FROM BOOK_COPIES
WHERE BOOK_COPIES.BOOK_ID = search_book.book_id AND BOOK_COPIES.BRANCH_ID = search_book.branch_id;

IF check1 = 0 THEN
    RAISE not_in_branch;
END IF;

SELECT BOOKS.title1 INTO search_book.book_title
FROM BOOKS
WHERE search_book.book_id = BOOKS.BOOK_ID;

SELECT BOOK_AUTHORS.AUTHOR_NAME INTO search_book.book_author
FROM BOOK_AUTHORS
WHERE search_book.book_id = BOOK_AUTHORS.BOOK_ID;

SELECT BOOKS.publisher_name INTO search_book.publisher1
FROM BOOKS
WHERE search_book.book_id = BOOKS.BOOK_ID;

SELECT BOOK_COPIES.no_of_copies INTO search_book.no_of_copies
FROM BOOK_COPIES
WHERE search_book.book_id = BOOK_COPIES.BOOK_ID AND search_book.branch_id = BOOK_COPIES.BRANCH_ID;

DBMS_OUTPUT.PUT_LINE('Book Search Result:');
DBMS_OUTPUT.PUT_LINE('ID: "' || book_id || '"');
DBMS_OUTPUT.PUT_LINE('Title: "' || book_title || '"');
DBMS_OUTPUT.PUT_LINE('Author: "' || book_author || '"');
DBMS_OUTPUT.PUT_LINE('Publisher: "' || publisher1 || '"');
DBMS_OUTPUT.PUT_LINE('Copies: ' || no_of_copies);


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('There is no branch named "' || branch_name || '" in the database. Please select an exisiting branch name.');
    WHEN no_book THEN
        DBMS_OUTPUT.PUT_LINE('There is no book in the database with the ID "' || book_id || '"');
    WHEN not_in_branch THEN
        DBMS_OUTPUT.PUT_LINE('This branch holds no copies of the book with an ID "' || book_id || '"');

END search_book;
/

ACCEPT my_book_id PROMPT 'Enter the book ID you want to search';
ACCEPT my_branch PROMPT 'Enter the branch name to conduct the search in';

DECLARE
    book_id BOOKS.BOOK_ID%TYPE := &my_book_id;
    branch_name BRANCHES.branch_name%TYPE := &my_branch;
BEGIN
    search_book(book_id, branch_name);
END;
/

COMMIT;