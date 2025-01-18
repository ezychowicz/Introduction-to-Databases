CREATE VIEW COURSE_INCOME as 
SELECT c.CourseID, c.CourseName, si.Income
FROM Courses AS c
INNER JOIN SERVICE_ID_INCOME AS si
    ON c.ServiceID = si.ServiceID