--new_patron
SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE new_patron(
    CARD_NO IN NUMBER,
    name2 IN VARCHAR2,
    address3 IN VARCHAR2,
    phone2 IN CHAR
) IS 
card_taken EXCEPTION;
wrong_phone EXCEPTION;
card_check NUMBER(1,0) := 0;


BEGIN

    SELECT COUNT(*) INTO card_check
    FROM BORROWERS
    WHERE new_patron.CARD_NO = BORROWERS.CARD_NO;

    IF card_check != 0 THEN
        RAISE card_taken;
    END IF;

    INSERT INTO BORROWERS VALUES(CARD_NO, name2, address3, phone2, 0.00);
EXCEPTION
    WHEN card_taken THEN
        DBMS_OUTPUT.PUT_LINE('The card number "' || CARD_NO || '" is already taken, please choose a different number.');
    
    
END new_patron;
/

ACCEPT my_card PROMPT 'Please enter a new 5 digit card number';
ACCEPT my_name PROMPT 'Please enter your name';
ACCEPT my_address PROMPT 'Please enter your address';
ACCEPT my_phone PROMPT 'Please enter your phone number as a 10 digit number in XXXXXXXXXX format exactly';

DECLARE
    format_check2 NUMBER(20,0) := &my_card;
    wrong_num EXCEPTION;
    format_check1 NUMBER(20,0) := &my_phone;
    wrong_phone EXCEPTION;
    card_no BORROWERS.CARD_NO%TYPE;
    name1 BORROWERS.name2%TYPE := &my_name;
    address1 BORROWERS.address3%TYPE := &my_address;
    phone2 BORROWERS.phone2%TYPE;
BEGIN
    IF TO_CHAR(format_check2) NOT LIKE '_____' THEN
        RAISE wrong_num;
    END IF;
    card_no := &my_card;
    IF TO_CHAR(format_check1) NOT LIKE '__________' THEN
        RAISE wrong_phone;
    END IF;
    phone2 := SUBSTR(TO_CHAR(format_check1), 1, 3) || '-' || SUBSTR(TO_CHAR(format_check1), 4, 3) || '-' || SUBSTR(TO_CHAR(format_check1), 7, 4);
    new_patron(card_no, name1, address1, phone2);

EXCEPTION
    WHEN wrong_num THEN
        DBMS_OUTPUT.PUT_LINE('The card number "' || format_check2 || '" is not exactly 5 digits, please enter a card number that is exactly 5 digits long');
    WHEN wrong_phone THEN
        DBMS_OUTPUT.PUT_LINE('The phone number "' || format_check1 || '" is not in the correct format, please enter it as "XXX-XXX-XXXX" format exactly');
END;
/

COMMIT;