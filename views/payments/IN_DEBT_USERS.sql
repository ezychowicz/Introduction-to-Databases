CREATE VIEW IN_DEBT_USERS AS

-- CTE z sum¹ p³atnoœci za zakonczone uslugi dla uzytkownikow ktorzy korzystali z uslug zakonczonych
WITH Suspects AS (
    SELECT 
        o.UserID, 
        p.OrderID, 
        p.ServiceID, 
        SUM(p.PaymentValue) AS Paid
    FROM Orders AS o
    LEFT OUTER JOIN OrderDetails AS od
        ON o.OrderID = od.OrderID
    LEFT OUTER JOIN Payments AS p
        ON p.OrderID = od.OrderID AND p.ServiceID = od.ServiceID AND od.PrincipalAgreement = 0 --jesli ma zgode dyrektora na odroczenie to nie licz danej uslugi dla danego zamowienia
    WHERE p.PaymentDate IS NOT NULL 
      AND p.ServiceID IN (
          SELECT s_e_services.ServiceID 
          FROM START_END_OF_SERVICES AS s_e_services 
          WHERE s_e_services.EndOfService < CONVERT(DATE, GETDATE()) 
      )
    GROUP BY o.UserID, p.OrderID, p.ServiceID
)


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

