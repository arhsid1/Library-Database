--print_loan_list

SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE loan_list(
    CARD_NO IN NUMBER
) IS
no_books EXCEPTION;
count_books NUMBER(2,0);
book_title BOOKS.title1%TYPE;
branch_name BRANCHES.branch_name%TYPE;

TYPE loan_table_type IS TABLE OF BOOK_LOANS%ROWTYPE
        INDEX BY BINARY_INTEGER;
loan_table loan_table_type;
CURSOR my_loan IS SELECT * 
FROM BOOK_LOANS
WHERE BOOK_LOANS.CARD_NO = loan_list.card_no;
BEGIN

    IF NOT my_loan%ISOPEN THEN
        OPEN my_loan;
    END IF;

    SELECT COUNT(*) INTO count_books
    FROM BOOK_LOANS
    WHERE BOOK_LOANS.CARD_NO = loan_list.card_no;

    IF count_books = 0 THEN
        RAISE no_books;
    END IF;

    IF count_books = 1 THEN
        DBMS_OUTPUT.PUT_LINE('You currently have ' || count_books || ' book loaned out');
    ELSE
         DBMS_OUTPUT.PUT_LINE('You currently have ' || count_books || ' books loaned out');
    END IF;

    FOR i IN 1..count_books LOOP
        FETCH my_loan INTO loan_table(i).BOOK_ID, loan_table(i).BRANCH_ID, loan_table(i).CARD_NO, loan_table(i).date_out, loan_table(i).date_due, loan_table(i).date_returned;
    END LOOP;

    FOR i IN 1..count_books LOOP
        SELECT BOOKS.title1 INTO loan_list.book_title
        FROM BOOKS
        WHERE BOOKS.BOOK_ID = loan_table(i).BOOK_ID;

        SELECT BRANCHES.branch_name INTO loan_list.branch_name
        FROM BRANCHES
        WHERE BRANCHES.BRANCH_ID = loan_table(i).BRANCH_ID;

        DBMS_OUTPUT.PUT_LINE('LOAN ' || i);
        DBMS_OUTPUT.PUT_LINE('Book title: "' || loan_list.book_title || '"');
        DBMS_OUTPUT.PUT_LINE('Book ID: "' || loan_table(i).BOOK_ID || '"');
        DBMS_OUTPUT.PUT_LINE('Branch name: "' || loan_list.branch_name || '"');
        DBMS_OUTPUT.PUT_LINE('Branch ID: "' || loan_table(i).BRANCH_ID || '"');
        DBMS_OUTPUT.PUT_LINE('Date borrowed: "' || loan_table(i).date_out || '"');
        DBMS_OUTPUT.PUT_LINE('Date due: "' || loan_table(i).date_due || '"');
        DBMS_OUTPUT.PUT_LINE('Date returned: "' || loan_table(i).date_returned || '"');
    END LOOP;

    CLOSE my_loan;

EXCEPTION
    WHEN no_books THEN
        DBMS_OUTPUT.PUT_LINE('You have no history of book loans');

END;
/

ACCEPT my_card Prompt 'Please enter your card number';

DECLARE
    card_num BORROWERS.CARD_NO%TYPE := &my_card;
BEGIN
    loan_list(card_num);
END;
/

COMMIT;