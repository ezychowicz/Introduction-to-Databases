--frekwencja na zakonczonych stacjonarnych i online live z kursow
--chyba problem gdyby byly nulle pomimo ze wydarzenie sie juz odbylo
create view ATTENDANCE_MEETINGS_IN_COURSES as
select 
	c.CourseName, c.CourseID, m.ModuleID, smd.MeetingID, sm.MeetingDate, 'Stationary' as MeetingType,
	 ROUND(CAST((SELECT COUNT(smd1.ParticipantID) 
         FROM StationaryMeetingDetails AS smd1 
         WHERE smd1.MeetingID = smd.MeetingID AND smd1.Attendance = 1) AS FLOAT) / CAST(COUNT(smd.ParticipantID) AS FLOAT),2) AS Attendance
from StationaryMeetingDetails as smd
INNER JOIN StationaryMeeting as sm
	on sm.MeetingID = smd.MeetingID
INNER JOIN Modules as m
	on sm.ModuleID = m.ModuleID
INNER JOIN Courses as c
	on c.CourseID = m.CourseID
group by smd.MeetingID, sm.MeetingDate, c.CourseID, m.ModuleID, c.CourseName
having sm.MeetingDate < CONVERT(DATE, GETDATE())
union
select 
	c.CourseName, c.CourseID, m.ModuleID, omd.MeetingID, om.MeetingDate, 'OnlineLive' as MeetingType,
	 ROUND(CAST((SELECT COUNT(omd1.ParticipantID) 
         FROM OnlineLiveMeetingDetails AS omd1 
         WHERE omd1.MeetingID = omd.MeetingID AND omd1.Attendance = 1) AS FLOAT) / CAST(COUNT(omd.ParticipantID) AS FLOAT),2) AS Attendance
from OnlineLiveMeetingDetails as omd
INNER JOIN OnlineLiveMeeting as om
	on om.MeetingID = omd.MeetingID
INNER JOIN Modules as m
	on om.ModuleID = m.ModuleID
INNER JOIN Courses as c
	on c.CourseID = m.CourseID
group by omd.MeetingID, om.MeetingDate, c.CourseID, m.ModuleID, c.CourseName
having om.MeetingDate < CONVERT(DATE, GETDATE())





