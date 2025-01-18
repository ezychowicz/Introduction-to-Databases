create view ATTENDANCE_RAPORT as 
select 
	'Course' as ServiceType, 
	c.MeetingID,
	c.MeetingDate,
	c.MeetingType
from ATTENDANCE_MEETINGS_IN_COURSES as c
union all
select
	'Studies' as ServiceType,
	s.MeetingID,
	s.MeetingDate,
	s.MeetingType
from V_ClassAttendanceAggregate as s
