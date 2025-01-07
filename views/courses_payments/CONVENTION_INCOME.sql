CREATE VIEW CONVENTION_INCOME as 
SELECT c.ConventionID, si.Income
FROM Convention as c
INNER JOIN SERVICE_ID_INCOME AS si
    ON c.ServiceID = si.ServiceID