--add_book_copies
SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE add_book_copies(
    title1 IN VARCHAR2,
    branch_name IN VARCHAR2,
    num_copies NUMBER
) IS
    no_book EXCEPTION;
    book_check NUMBER(2,0);
    no_branch EXCEPTION;
    branch_check NUMBER(2,0);
    book_id BOOKS.BOOK_ID%TYPE;
    branch_id BRANCHES.BRANCH_ID%TYPE;

BEGIN
    SELECT COUNT(*) INTO add_book_copies.book_check
    FROM BOOKS
    WHERE BOOKS.title1 = add_book_copies.title1;

    IF book_check = 0 THEN
        RAISE no_book;
    END IF;

    SELECT COUNT(*) INTO add_book_copies.branch_check
    FROM BRANCHES
    WHERE BRANCHES.branch_name = add_book_copies.branch_name;

    IF branch_check = 0 THEN
        RAISE no_branch;
    END IF;

    SELECT BRANCHES.BRANCH_ID INTO add_book_copies.branch_id
    FROM BRANCHES
    WHERE BRANCHES.branch_name = add_book_copies.branch_name;

    SELECT BOOKS.BOOK_ID INTO add_book_copies.book_id
    FROM BOOKS
    WHERE BOOKS.title1 = add_book_copies.title1;

    book_check := 0;

    SELECT COUNT(*) INTO add_book_copies.book_check
    FROM BOOK_COPIES
    WHERE BOOK_COPIES.BOOK_ID = add_book_copies.book_id AND BOOK_COPIES.BRANCH_ID = add_book_copies.branch_id;

    IF book_check != 0 THEN
        UPDATE BOOK_COPIES
        SET no_of_copies = no_of_copies + num_copies
        WHERE BOOK_COPIES.BOOK_ID = add_book_copies.book_id AND BOOK_COPIES.BRANCH_ID = add_book_copies.branch_id;
    ELSE
        INSERT INTO BOOK_COPIES VALUES(book_id, branch_id, num_copies);
    END IF;

    DBMS_OUTPUT.PUT_LINE(num_copies || ' copies of "' || title1 || '" successfully added to branch "' || branch_name || '"');

EXCEPTION
    WHEN no_book THEN
        DBMS_OUTPUT.PUT_LINE('Sorry, but "' || title1 ||  '" does not exist in the database, add the book to database first before adding copies.');
    WHEN no_branch THEN
        DBMS_OUTPUT.PUT_LINE('There is no branch in the database named "' || branch_name || '" Please select an existing branch name');
END add_book_copies;
/

ACCEPT my_title PROMPT 'Enter the existing book title you wish to add copies of';
ACCEPT my_branch PROMPT 'Enter the branch name you want to add the book copies to';
ACCEPT my_copies PROMPT 'Enter the number of book copies you want to add';
DECLARE
    title BOOKS.title1%TYPE := &my_title;
    branch BRANCHES.branch_name%TYPE := &my_branch;
    num_copies NUMBER(4,0) := &my_copies;
BEGIN
    add_book_copies(title, branch, num_copies);
END;
/

COMMIT;