CREATE VIEW STUDIES_INCOME as
SELECT s.StudiesID, s.StudiesName, si.Income
FROM Studies AS s
INNER JOIN SERVICE_ID_INCOME AS si
    ON s.ServiceID = si.ServiceID