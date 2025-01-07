--frekwencja na zakonczonych stacjonarnych i online live z kursow
--chyba problem gdyby byly nulle pomimo ze wydarzenie sie juz odbylo
create view ATTENDANCE_MEETINGS_IN_COURSES as
select 
	smd.MeetingID, sm.MeetingDate, 'Stationary' as MeetingType,
	 CAST((SELECT COUNT(smd1.ParticipantID) 
         FROM StationaryMeetingDetails AS smd1 
         WHERE smd1.MeetingID = smd.MeetingID AND smd1.Attendance = 1) AS FLOAT) / CAST(COUNT(smd.ParticipantID) AS FLOAT) AS Attendance
from StationaryMeetingDetails as smd
INNER JOIN StationaryMeeting as sm
	on sm.MeetingID = smd.MeetingID
group by smd.MeetingID, sm.MeetingDate
having sm.MeetingDate < CONVERT(DATE, GETDATE())
union
select 
	omd.MeetingID, om.MeetingDate, 'Online' as MeetingType,
	 CAST((SELECT COUNT(omd1.ParticipantID) 
         FROM OnlineLiveMeetingDetails AS omd1 
         WHERE omd1.MeetingID = omd.MeetingID AND omd1.Attendance = 1) AS FLOAT) / CAST(COUNT(omd.ParticipantID) AS FLOAT) AS Attendance
from OnlineLiveMeetingDetails as omd
INNER JOIN OnlineLiveMeeting as om
	on om.MeetingID = omd.MeetingID
group by omd.MeetingID, om.MeetingDate
having om.MeetingDate < CONVERT(DATE, GETDATE())
