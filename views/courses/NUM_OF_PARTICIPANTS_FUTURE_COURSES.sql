--liczba zapisanych osob na przyszle kursy 
create view NUM_OF_PARTICIPANTS_FUTURE_COURSES as
select c.CourseID, c.CourseName, COUNT(cp.ParticipantID) as 'Number of participants' 
from CourseParticipants as cp
INNER JOIN Courses as c
on c.CourseID = cp.CourseID
group by c.CourseID, c.CourseName, c.CourseDate
having c.CourseDate > CONVERT(DATE, GETDATE())

