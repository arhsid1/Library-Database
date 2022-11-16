--add_new_book

SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE add_new_book(
    book_id IN CHAR,
    title1 IN VARCHAR2,
    publisher1 IN VARCHAR2,
    author1 IN VARCHAR2,
    branch_name IN VARCHAR2
) IS
id_taken EXCEPTION;
title_taken EXCEPTION;
branch_not_exists EXCEPTION;
id_check NUMBER(2,0) := 0;
title_check NUMBER(2,0) := 0;
branch_check NUMBER(2,0) := 0;
publisher_new NUMBER(2,0) := 0;
publisher_not_exists EXCEPTION;
branch_id BRANCHES.BRANCH_ID%TYPE;


BEGIN
    SELECT COUNT(*) INTO id_check
    FROM BOOKS
    WHERE add_new_book.book_id = BOOKS.BOOK_ID;

    IF id_check > 0 THEN
        RAISE id_taken;
    END IF;

    SELECT COUNT(*) INTO title_check
    FROM BOOKS
    WHERE add_new_book.title1 = BOOKS.title1;

    IF title_check > 0 THEN
        RAISE title_taken;
    END IF;

    SELECT COUNT(*) INTO add_new_book.branch_check
    FROM BRANCHES
    WHERE BRANCHES.branch_name = add_new_book.branch_name;

    IF branch_check = 0 THEN
        RAISE branch_not_exists;
    END IF;

    SELECT COUNT(*) INTO add_new_book.publisher_new
    FROM PUBLISHERS
    WHERE PUBLISHERS.NAME1 = add_new_book.publisher1;

    IF publisher_new = 0 THEN
        RAISE publisher_not_exists;
    END IF;

    SELECT BRANCHES.BRANCH_ID INTO add_new_book.branch_id
    FROM BRANCHES
    WHERE BRANCHES.branch_name = add_new_book.branch_name;

    INSERT INTO BOOK_AUTHORS VALUES(book_id, author1);
    INSERT INTO BOOKS VALUES(book_id, title1, publisher1);
    INSERT INTO BOOK_COPIES VALUES(book_id, branch_id, 1);
  
EXCEPTION
    WHEN branch_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('The branch "'|| add_new_book.branch_name || '" does not exist in the database. Please select an existing branch');
    WHEN id_taken THEN
        DBMS_OUTPUT.PUT_LINE('The book id "' || add_new_book.book_id || '" is already taken by another book. Select a different ID');
    WHEN title_taken THEN
        DBMS_OUTPUT.PUT_LINE('The book title "' || add_new_book.title1 || '" is already taken by a another book. Select a different book title');
    WHEN publisher_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('This library only works with publishers already in the database. We do not currently hold inventory from "' || add_new_book.publisher1 || '"');

END add_new_book;
/

CREATE OR REPLACE TRIGGER add_frequency
AFTER INSERT ON BOOKS
FOR EACH ROW
BEGIN
    INSERT INTO RENT_FREQUENCY VALUES(:new.BOOK_ID, 0);
END;
/

ACCEPT my_bookid PROMPT 'Enter a new 2 character ID for the book';
ACCEPT my_title PROMPT 'Enter the name of the new book';
ACCEPT my_publisher PROMPT 'Enter an existing publisher name for the new book';
ACCEPT my_author PROMPT 'Enter the author name';
ACCEPT my_branch PROMPT 'Enter the library branch you want to add the book to';

DECLARE
book_id BOOKS.BOOK_ID%TYPE := &my_bookid;
title1 BOOKS.title1%TYPE := &my_title;
publisher1 PUBLISHERS.NAME1%TYPE := &my_publisher;
author1 BOOK_AUTHORS.AUTHOR_NAME%TYPE := &my_author;
branch1 BRANCHES.branch_name%TYPE := &my_branch;

BEGIN
add_new_book(book_id, title1, publisher1, author1, branch1);
END;
/
COMMIT;