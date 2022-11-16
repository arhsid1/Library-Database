--remove_books

SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE remove_book(
    BOOK_ID IN CHAR,
    BRANCH_ID IN CHAR,
    amount_removed IN NUMBER
) IS
    id_check NUMBER(2,0) := 0;
    id_not_exists EXCEPTION;
    branch_not_exists EXCEPTION;
    difference1 NUMBER(3,0);
    no_of_copies BOOK_COPIES.no_of_copies%TYPE;
BEGIN
    
    SELECT COUNT(*) INTO id_check
    FROM BRANCHES
    WHERE BRANCHES.BRANCH_ID = remove_book.BRANCH_ID;

    IF id_check = 0 THEN
        RAISE branch_not_exists;
    END IF;

    id_check := 0;

    SELECT COUNT(*) INTO id_check
    FROM BOOK_COPIES
    WHERE BOOK_COPIES.BOOK_ID = remove_book.BOOK_ID AND BOOK_COPIES.BRANCH_ID = remove_book.BRANCH_ID;

    IF id_check = 0 THEN
        RAISE id_not_exists;
    END IF;

    SELECT BOOK_COPIES.no_of_copies INTO remove_book.no_of_copies
    FROM BOOK_COPIES
    WHERE BOOK_COPIES.BOOK_ID = remove_book.BOOK_ID AND BOOK_COPIES.BRANCH_ID = remove_book.BRANCH_ID;

    difference1 := no_of_copies - amount_removed;

    IF difference1 < 0 THEN
        difference1 := 0;
    END IF;

    UPDATE BOOK_COPIES
    SET BOOK_COPIES.no_of_copies = remove_book.difference1
    WHERE BOOK_COPIES.BOOK_ID = remove_book.BOOK_ID AND BOOK_COPIES.BRANCH_ID = remove_book.BRANCH_ID;

EXCEPTION
    WHEN branch_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('There is no branch with the ID "' || BRANCH_ID || '" please select an existing branch ID');
    WHEN id_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('This branch does not hold any books with the ID "' || BOOK_ID || '"');
END;
/

ACCEPT my_book PROMPT 'Enter the ID of the book you want to remove (it is exactly a 2 character string)';
ACCEPT my_branch PROMPT 'Enter the ID of the branch you want to remove the book from (it is exactly a 3 character string)';
ACCEPT my_amount PROMPT 'Enter the number of copies you want to remove (it must be a positive integer)';

DECLARE
    book_check VARCHAR2(100) := &my_book;
    book_id BOOKS.BOOK_ID%TYPE;
    branch_check VARCHAR2(100) := &my_branch;
    branch_id BRANCHES.BRANCH_ID%TYPE;
    num_check NUMBER(20,0) := &my_amount;
    amount1 BOOK_COPIES.no_of_copies%TYPE;
    wrong_book EXCEPTION;
    wrong_branch EXCEPTION;
    wrong_num EXCEPTION;
BEGIN
    IF book_check NOT LIKE '__' THEN
        RAISE wrong_book;
    ELSIF branch_check NOT LIKE '___' THEN
        RAISE wrong_branch;
    ELSIF num_check < 0 THEN
        RAISE wrong_num;
    END IF;

    book_id := &my_book;
    branch_id := &my_branch;
    amount1 := &my_amount;

    remove_book(book_id, branch_id, amount1);
EXCEPTION
    WHEN wrong_book THEN
        DBMS_OUTPUT.PUT_LINE('The book ID "' || book_check || '" is not exactly 2 characters in length. Enter a book ID of exactly 2 characters in length.');
    WHEN wrong_branch THEN
        DBMS_OUTPUT.PUT_LINE('The branch ID "' || branch_check || '" is not exactly 3 characters in length. Enter a branch ID of exactly 3 characters in length.');
    WHEN wrong_num THEN
        DBMS_OUTPUT.PUT_LINE('The number "' || num_check || '" is negative. Please enter a positive integer.');
END;
/

COMMIT;

