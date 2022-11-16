--pay_fine

SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE PROCEDURE pay_fine(
    card_no IN NUMBER,
    amount_paid IN NUMBER
) IS
no_fine EXCEPTION;
amount_due BORROWERS.unpaid_dues%TYPE;
differnce1 BORROWERS.unpaid_dues%TYPE;
BEGIN
    SELECT BORROWERS.unpaid_dues INTO amount_due
    FROM BORROWERS
    WHERE pay_fine.card_no = BORROWERS.CARD_NO;

    IF amount_due = 0.00 THEN
        Raise no_fine;
    END IF;

    differnce1 := amount_due - amount_paid;

    IF differnce1 < 0 THEN
        differnce1 := 0.00;
    END IF;

    UPDATE BORROWERS
    SET unpaid_dues = differnce1
    WHERE pay_fine.card_no = BORROWERS.CARD_NO;

    DBMS_OUTPUT.PUT_LINE('Thanks, you have $' || differnce1 || ' left to pay.');

EXCEPTION
    WHEN no_fine THEN
        DBMS_OUTPUT.PUT_LINE('You have no fines to pay.');
END pay_fine;
/

ACCEPT my_card PROMPT 'Please enter your card number';
ACCEPT my_amount PROMPT 'Please enter the amount you wish to pay';

DECLARE
    card_no BORROWERS.CARD_NO%TYPE := &my_card;
    amount_paid BORROWERS.unpaid_dues%TYPE := &my_amount;
BEGIN
    pay_fine(card_no, amount_paid);
END;
/

COMMIT;



    

