CREATE VIEW IN_DEBT_USERS AS
-- CTE z u¿ytkownikami zapisanymi na zakoñczone us³ugi
WITH UsersFinished AS (
    SELECT DISTINCT s_user.ServiceUserID
    FROM SERVICE_USERS AS s_user
    INNER JOIN START_END_OF_SERVICES AS s_end
        ON s_user.ServiceID = s_end.ServiceID
    WHERE s_end.EndOfService < CONVERT(DATE, GETDATE())
),

-- CTE z sum¹ p³atnoœci za zakonczone uslugi dla uzytkownikow ktorzy korzystali uslug zakonczonych
Suspects AS (
    SELECT 
        o.UserID, 
        p.OrderID, 
        p.ServiceID, 
        SUM(p.PaymentValue) AS Paid
    FROM Orders AS o
    INNER JOIN UsersFinished AS u 
        ON o.UserID = u.ServiceUserID
    INNER JOIN OrderDetails AS od
        ON o.OrderID = od.OrderID
    INNER JOIN Payments AS p
        ON p.OrderID = od.OrderID AND p.ServiceID = od.ServiceID
    WHERE p.PaymentDate IS NOT NULL 
      AND p.ServiceID IN (
          SELECT s_e_services.ServiceID 
          FROM START_END_OF_SERVICES AS s_e_services 
          WHERE s_e_services.EndOfService < CONVERT(DATE, GETDATE())
      )
    GROUP BY o.UserID, p.OrderID, p.ServiceID
)
/*
select * from COURSES_USERS as cu
INNER JOIN START_END_OF_COURSES as sec
on cu.ServiceID = sec.ServiceID
*/

SELECT 
    Suspects.UserID, 
	(SELECT u.FirstName  FROM Users AS u WHERE Suspects.UserID = u.UserID) as FirstName,
	(SELECT u.LastName  FROM Users AS u WHERE Suspects.UserID = u.UserID) as LastName,
    Suspects.Paid - toPay AS InDebt, 
    (SELECT s.ServiceType FROM Services as s where Suspects.ServiceID = s.ServiceID) as ServiceType
FROM Suspects
CROSS APPLY ( --dla kazdego wiersza stosuje ponizsze obliczenia
    SELECT 
        CASE 
            WHEN Suspects.UserID IN (SELECT StudentID FROM StudiesDetails)
                 AND Suspects.ServiceID IN (SELECT ServiceUserID FROM CLASSMEETING_USERS)
            THEN (SELECT cms.PriceStudents 
                  FROM ClassMeetingService AS cms 
                  WHERE cms.ServiceID = Suspects.ServiceID)
            ELSE (SELECT fp.FullPrice FROM FULL_PRICE AS fp where fp.ServiceID = Suspects.ServiceID)
        END AS toPay
) AS Calculations
WHERE Suspects.Paid < Calculations.toPay;
