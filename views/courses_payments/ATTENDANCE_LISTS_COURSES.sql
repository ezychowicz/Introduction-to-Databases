create view ATTENDANCE_LISTS_COURSES as
select
	smd.MeetingID,
	smd.ParticipantID,
	'Course Stationary' as MeetingType,
	u.FirstName, 
	u.LastName,
	smd.Attendance,
	sm.MeetingDate
from StationaryMeetingDetails as smd
INNER JOIN StationaryMeeting as sm
	on sm.MeetingID = smd.MeetingID
INNER JOIN ServiceUserDetails as us
	on us.ServiceUserID = smd.ParticipantID
INNER JOIN Users as u
	on u.UserID = us.ServiceUserID
	where sm.MeetingDate < CONVERT(DATE, GETDATE())
union
select
	omd.MeetingID,
	omd.ParticipantID,
	'Course Online' as MeetingType,
	u.FirstName, 
	u.LastName,
	omd.Attendance,
	om.MeetingDate
from OnlineLiveMeetingDetails as omd
INNER JOIN OnlineLiveMeeting as om
	on om.MeetingID = omd.MeetingID
INNER JOIN ServiceUserDetails as us
	on us.ServiceUserID = omd.ParticipantID
INNER JOIN Users as u
	on u.UserID = us.ServiceUserID
	where om.MeetingDate < CONVERT(DATE, GETDATE())