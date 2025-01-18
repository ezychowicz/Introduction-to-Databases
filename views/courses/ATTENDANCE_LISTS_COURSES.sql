create view ATTENDANCE_LISTS_COURSES as
select
	c.CourseName,
	c.CourseID,
	m.ModuleID,
	smd.MeetingID,
	'Course Stationary' as MeetingType,
	smd.ParticipantID,
	u.FirstName, 
	u.LastName,
	smd.Attendance,
	sm.MeetingDate
from StationaryMeetingDetails as smd
INNER JOIN StationaryMeeting as sm
	on sm.MeetingID = smd.MeetingID
INNER JOIN Modules as m
	on sm.ModuleID = m.ModuleID
INNER JOIN Courses as c
	on c.CourseID = m.CourseID
INNER JOIN ServiceUserDetails as us
	on us.ServiceUserID = smd.ParticipantID
INNER JOIN Users as u
	on u.UserID = us.ServiceUserID
	where sm.MeetingDate < CONVERT(DATE, GETDATE())
union
select
	c.CourseName,
	c.CourseID,
	m.ModuleID,
	omd.MeetingID,
	'Course Online' as MeetingType,
	omd.ParticipantID,
	u.FirstName, 
	u.LastName,
	omd.Attendance,
	om.MeetingDate
from OnlineLiveMeetingDetails as omd
INNER JOIN OnlineLiveMeeting as om
	on om.MeetingID = omd.MeetingID
INNER JOIN Modules as m
	on om.ModuleID = m.ModuleID
INNER JOIN Courses as c
	on c.CourseID = m.CourseID
INNER JOIN ServiceUserDetails as us
	on us.ServiceUserID = omd.ParticipantID
INNER JOIN Users as u
	on u.UserID = us.ServiceUserID
	where om.MeetingDate < CONVERT(DATE, GETDATE())


