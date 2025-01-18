CREATE VIEW WEBINAR_INCOME AS
select w.WebinarID, w.WebinarName, si.Income
from Webinars as w
INNER JOIN SERVICE_ID_INCOME AS si
    ON w.ServiceID = si.ServiceID


