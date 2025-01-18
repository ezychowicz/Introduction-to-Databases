CREATE VIEW CLASS_MEETINGS_INCOME as
SELECT cm.ClassMeetingID, si.Income
FROM ClassMeeting as cm
INNER JOIN SERVICE_ID_INCOME AS si
    ON cm.ServiceID = si.ServiceID