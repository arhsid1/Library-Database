--print_branch
SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE print_branch(
    branch_id IN CHAR
) IS
TYPE copies_table_type IS TABLE OF BOOK_COPIES%ROWTYPE
    INDEX BY BINARY_INTEGER;
copies_table copies_table_type;
CURSOR my_branch IS 
SELECT * 
FROM BOOK_COPIES
WHERE BOOK_COPIES.branch_id = print_branch.branch_id;
count_recs NUMBER(5,0);
loaned_out_copies NUMBER(4,0);
total_loaned_out NUMBER(4,0);
total_in_stock NUMBER(4,0);
branch_name BRANCHES.branch_name%TYPE;
book_name BOOKS.title1%TYPE;
branch_address BRANCHES.address2%TYPE;
BEGIN

    SELECT BRANCHES.branch_name INTO print_branch.branch_name
    FROM BRANCHES
    WHERE BRANCHES.BRANCH_ID = print_branch.branch_id;

    SELECT BRANCHES.address2 INTO branch_address
    FROM BRANCHES
    WHERE BRANCHES.BRANCH_ID = print_branch.BRANCH_ID;

    SELECT COUNT(*) INTO total_loaned_out
    FROM BOOK_LOANS
    WHERE BOOK_LOANS.BRANCH_ID = print_branch.branch_id;

    SELECT COUNT(*) INTO total_in_stock
    FROM BOOK_COPIES
    WHERE BOOK_COPIES.BRANCH_ID = print_branch.branch_id;

    IF NOT my_branch%ISOPEN THEN
        OPEN my_branch;
    END IF;

    SELECT COUNT(*) INTO count_recs
    FROM BOOK_COPIES
    WHERE BOOK_COPIES.branch_id = print_branch.branch_id;

    FOR i IN 1..count_recs LOOP
        FETCH my_branch INTO copies_table(i).BOOK_ID, copies_table(i).BRANCH_ID, copies_table(i).no_of_copies;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Branch information results:');
    DBMS_OUTPUT.PUT_LINE('Branch ID: "' || branch_id || '"');
    DBMS_OUTPUT.PUT_LINE('Branch name: "' || branch_name || '"');
    DBMS_OUTPUT.PUT_LINE('Branch address: "' || branch_address || '"');
    DBMS_OUTPUT.PUT_LINE('Branch book inventory information:');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    FOR i IN 1..count_recs LOOP
        SELECT COUNT(*) INTO loaned_out_copies
        FROM BOOK_LOANS
        WHERE BOOK_LOANS.BOOK_ID = copies_table(i).BOOK_ID AND BOOK_LOANS.BRANCH_ID = branch_id;

        SELECT BOOKS.title1 INTO book_name
        FROM BOOKS
        WHERE BOOKS.BOOK_ID = copies_table(i).BOOK_ID;

        DBMS_OUTPUT.PUT_LINE('ID: "' || copies_table(i).BOOK_ID || '"');
        DBMS_OUTPUT.PUT_LINE('Title: "' || book_name || '"');
        DBMS_OUTPUT.PUT_LINE('number of copies currently in branch: ' || copies_table(i).no_of_copies);
        DBMS_OUTPUT.PUT_LINE('number of copies currently loaned out: ' || loaned_out_copies);
        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total books currently in branch: ' || total_in_stock);
    DBMS_OUTPUT.PUT_LINE('Total books currently loaned out: ' || total_loaned_out);
    CLOSE my_branch;
END print_branch;
/

ACCEPT my_branch PROMPT 'Enter the branch ID you want information about';

DECLARE
    branch_check VARCHAR2(100) := &my_branch;
    checker1 NUMBER(2,0);
    branch_id BRANCHES.BRANCH_ID%TYPE;
    wrong_branch EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO checker1
    FROM BRANCHES
    WHERE BRANCHES.BRANCH_ID = branch_check;

    IF checker1 = 0 THEN
        RAISE wrong_branch;
    END IF;

    branch_id := &my_branch;
    print_branch(branch_id);

EXCEPTION
    WHEN wrong_branch THEN
        DBMS_OUTPUT.PUT_LINE('There is no branch with the ID "' || branch_check || '" Please select an existing branch ID');
END;
/

COMMIT;

        
