--print_top10

SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE
    b_id BOOKS.BOOK_ID%TYPE;
    b_title BOOKS.title1%TYPE;
    amount1 RENT_FREQUENCY.loan_count%TYPE;

    TYPE top10_table_type IS TABLE OF RENT_FREQUENCY%ROWTYPE
        INDEX BY BINARY_INTEGER;
    top10_table top10_table_type;
    CURSOR my_top10 IS SELECT * 
    FROM RENT_FREQUENCY
    ORDER BY RENT_FREQUENCY.loan_count DESC;
BEGIN

    IF NOT my_top10%ISOPEN THEN
        OPEN my_top10;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Here are the top 10 most frequently checked-out books across all branches ranked from most popular to least.');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');
    FOR i IN 1..10 LOOP
        FETCH my_top10 INTO b_id, amount1;
        SELECT BOOKS.title1 INTO b_title
        FROM BOOKS
        WHERE BOOKS.BOOK_ID = b_id;
        DBMS_OUTPUT.PUT_LINE('RANK: ' || i);
        DBMS_OUTPUT.PUT_LINE('Book ID: ' || b_id);
        DBMS_OUTPUT.PUT_LINE('Book title: ' || b_title);
        DBMS_OUTPUT.PUT_LINE('Number of times loaned out: ' || amount1);
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
    END LOOP;
    CLOSE my_top10;
END;
/

COMMIT;