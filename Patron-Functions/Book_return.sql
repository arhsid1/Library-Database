--Book_return

SET VERIFY OFF;
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE book_return(
    card_no IN NUMBER,
    branch_name IN VARCHAR2,
    Book_title IN VARCHAR2
) IS
book_check NUMBER(2,0);
book_id BOOKS.BOOK_ID%TYPE;
Branch_id BOOK_COPIES.BRANCH_ID%TYPE;
curr_date DATE;
curr_date_str VARCHAR2(100) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
date_check DATE;
date_due DATE;
past_due_amount NUMBER(5,2);
past_due_date NUMBER(4,0);
wrong_book EXCEPTION;
not_exists EXCEPTION;
already_returned EXCEPTION;

BEGIN
    SELECT BRANCHES.BRANCH_ID INTO book_return.Branch_id
    FROM BRANCHES
    WHERE BRANCHES.branch_name = book_return.branch_name;

    SELECT BOOKS.BOOK_ID INTO book_return.book_id
    FROM BOOKS
    WHERE BOOKS.title1 = book_return.Book_title;

    SELECT COUNT(*) INTO book_check
    FROM BOOK_COPIES
    INNER JOIN BOOKS ON BOOK_COPIES.BOOK_ID = BOOKS.BOOK_ID
    WHERE book_return.Book_title = BOOKS.title1;

    IF book_check = 0 THEN
        RAISE not_exists;
    END IF;
    
    book_check := 0;
    SELECT COUNT(*) INTO book_check
    FROM BOOK_LOANS
    WHERE BOOK_LOANS.BOOK_ID = book_return.book_id AND BOOK_LOANS.BRANCH_ID = book_return.Branch_id AND BOOK_LOANS.card_no = book_return.card_no;

    IF book_check = 0 THEN
        RAISE wrong_book;
    END IF;

    SELECT date_returned INTO date_check
    FROM BOOK_LOANS
    WHERE BOOK_LOANS.BOOK_ID = book_return.book_id AND BOOK_LOANS.BRANCH_ID = book_return.Branch_id AND BOOK_LOANS.card_no = book_return.card_no;

    IF date_check IS NOT NULL THEN
        RAISE already_returned;
    END IF; 

    UPDATE BOOK_COPIES
    SET no_of_copies = no_of_copies + 1
    WHERE BOOK_COPIES.BOOK_ID = book_return.book_id AND BOOK_COPIES.BRANCH_ID = book_return.Branch_id;

    curr_date := SYSDATE;
    UPDATE BOOK_LOANS
    SET date_returned = curr_date
    WHERE BOOK_LOANS.BOOK_ID = book_return.book_id AND BOOK_LOANS.BRANCH_ID = book_return.Branch_id AND BOOK_LOANS.card_no = book_return.card_no;

    SELECT BOOK_LOANS.date_due INTO Book_return.date_due
    FROM BOOK_LOANS
    WHERE BOOK_LOANS.BOOK_ID = book_return.book_id AND BOOK_LOANS.BRANCH_ID = book_return.Branch_id AND BOOK_LOANS.card_no = book_return.card_no;
    
    IF curr_date > date_due THEN
        past_due_date := TO_DATE(curr_date_str, 'YYYY-MM-DD') - date_due;
        past_due_amount := past_due_date * 0.25;
        UPDATE BORROWERS
        SET BORROWERS.unpaid_dues = past_due_amount + BORROWERS.unpaid_dues
        WHERE BORROWERS.CARD_NO = book_return.card_no;
    END IF;

    IF curr_date > date_due THEN
        DBMS_OUTPUT.PUT_LINE('Since you are returning this book '|| past_due_date || ' days past its due date, a $' || past_due_amount || ' penalty fee will be charged to your account.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('You have successfully returned "' || Book_title || '".');
EXCEPTION
    WHEN wrong_book THEN
        DBMS_OUTPUT.PUT_LINE('The book "' || book_return.Book_title || '" is either not currently loaned out to you, or you borrowed this book from a different branch');
    WHEN not_exists THEN
        DBMS_OUTPUT.PUT_LINE('Sorry, but the book: "' || Book_title || '" does not exist in the library database');
    WHEN already_returned THEN
        DBMS_OUTPUT.PUT_LINE('You have already returned "' || Book_title || '" on ' || date_check);
END;
/

ACCEPT my_cardNum PROMPT 'Enter your member card number';
ACCEPT my_branchName PROMPT 'Enter the branch name you want to visit today';
ACCEPT my_bookTitle PROMPT 'Enter the book title you want to return';

DECLARE 
    cardNum BORROWERS.CARD_NO%TYPE := &my_cardNum;
    branchName BRANCHES.branch_name%TYPE := &my_branchName;
    bookTitle BOOKS.title1%TYPE := &my_bookTitle;
BEGIN
    book_return(cardNum, branchName, bookTitle);
END;
/


COMMIT;