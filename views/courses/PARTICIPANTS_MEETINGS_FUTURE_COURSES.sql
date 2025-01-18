create view PARTICIPANTS_MEETINGS_FUTURE_COURSES as
select 
	smd.MeetingID,
	sm.MeetingDate,
	'Stationary' as MeetingType,
	m.ModuleID,
	c.CourseID,
	c.CourseName,
	smd.ParticipantID,
	u.FirstName, 
	u.LastName
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
where sm.MeetingDate > CONVERT(DATE, GETDATE()) 
union
select 
	omd.MeetingID,
	om.MeetingDate,
	'Online' as MeetingType,
	m.ModuleID,
	c.CourseID,
	c.CourseName,
	omd.ParticipantID,
	u.FirstName, 
	u.LastName
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
where om.MeetingDate > CONVERT(DATE, GETDATE()) 

