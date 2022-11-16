--Book_checkout
SET SERVEROUTPUT ON;
SET VERIFY OFF;
CREATE OR REPLACE PROCEDURE check_out(
    card_no IN NUMBER,
    branch_name IN VARCHAR2,
    Book_title IN VARCHAR2
) IS
book_check NUMBER(2,0);
book_id BOOKS.BOOK_ID%TYPE;
Branch_id BOOK_COPIES.BRANCH_ID%TYPE;
avalible1 BOOK_COPIES.no_of_copies%TYPE;
curr_date DATE;
not_exists EXCEPTION;
not_in_branch EXCEPTION;
no_copies EXCEPTION;
BEGIN
    SELECT BRANCHES.BRANCH_ID INTO check_out.Branch_id
    FROM BRANCHES
    WHERE BRANCHES.branch_name = check_out.branch_name;

    SELECT COUNT(*) INTO book_check
    FROM BOOK_COPIES
    INNER JOIN BOOKS ON BOOK_COPIES.BOOK_ID = BOOKS.BOOK_ID
    WHERE check_out.Book_title = BOOKS.title1;

    IF book_check = 0 THEN
        RAISE not_exists;
    ELSE
        book_check := 0;
        SELECT COUNT(*) INTO book_check
        FROM BOOK_COPIES
        INNER JOIN BOOKS ON BOOK_COPIES.BOOK_ID = BOOKS.BOOK_ID
        WHERE check_out.Book_title = BOOKS.title1 AND BOOK_COPIES.BRANCH_ID = check_out.Branch_id;
        IF book_check = 0 THEN
            RAISE not_in_branch;
        END IF;
    END IF;

    SELECT no_of_copies INTO avalible1
    FROM BOOK_COPIES
    INNER JOIN BOOKS ON BOOK_COPIES.BOOK_ID = BOOKS.BOOK_ID
    WHERE check_out.Book_title = BOOKS.title1 AND BOOK_COPIES.BRANCH_ID = check_out.Branch_id;

    IF avalible1 = 0 THEN
        RAISE no_copies;
    END IF;

    SELECT BOOKS.BOOK_ID INTO check_out.book_id
    FROM BOOKS
    WHERE check_out.Book_title = BOOKS.title1;
    avalible1 := avalible1 - 1;
    
    UPDATE BOOK_COPIES
    SET no_of_copies = avalible1
    WHERE check_out.book_id = BOOK_COPIES.book_id AND BOOK_COPIES.BRANCH_ID = check_out.Branch_id;

    book_check := 0;

    SELECT COUNT(*) INTO book_check
    FROM BOOK_LOANS
    WHERE BOOK_LOANS.BOOK_ID = check_out.book_id AND BOOK_LOANS.BRANCH_ID = check_out.Branch_id AND BOOK_LOANS.card_no = check_out.card_no;
    curr_date := SYSDATE;
    IF book_check = 0 THEN
        INSERT INTO BOOK_LOANS VALUES(check_out.book_id, check_out.Branch_id, check_out.card_no, curr_date, ADD_MONTHS(curr_date, 1), NULL);
    ELSE
        UPDATE BOOK_LOANS
        SET date_out = curr_date, date_due = ADD_MONTHS(curr_date, 1), date_returned = NULL
        WHERE BOOK_LOANS.BOOK_ID = check_out.book_id AND BOOK_LOANS.BRANCH_ID = check_out.Branch_id AND BOOK_LOANS.card_no = check_out.card_no; 
    END IF;
    
    UPDATE RENT_FREQUENCY
    SET loan_count = loan_count + 1
    WHERE RENT_FREQUENCY.BOOK_ID = check_out.book_id;
EXCEPTION
    WHEN not_exists THEN
        DBMS_OUTPUT.PUT_LINE('Sorry, but the book: "' || Book_title || '" does not exist in the library database');
    WHEN not_in_branch THEN
        DBMS_OUTPUT.PUT_LINE('Sorry, but this branch does not carry the book: "' ||Book_title || '"');
    WHEN no_copies THEN
        DBMS_OUTPUT.PUT_LINE('Sorry, but this branch has no avalible copies of "' ||Book_title || '" yet');
    
END check_out;
/

ACCEPT my_cardNum PROMPT 'Enter your member card number';
ACCEPT my_branchName PROMPT 'Enter the branch name you want to visit today';
ACCEPT my_bookTitle PROMPT 'Enter the book title you want to check out';

DECLARE 
    cardNum BORROWERS.CARD_NO%TYPE := &my_cardNum;
    branchName BRANCHES.branch_name%TYPE := &my_branchName;
    bookTitle BOOKS.title1%TYPE := &my_bookTitle;
BEGIN
    check_out(cardNum, branchName, bookTitle);
END;
/

COMMIT;