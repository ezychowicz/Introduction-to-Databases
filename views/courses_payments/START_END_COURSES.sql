--widok: poczatki i konce trwania danych kursow
create view START_END_OF_COURSES as
select c.ServiceID, c.CourseDate as StartOfService, CAST(max(T1.MeetingDate) AS DATE) as EndOfService
	from Courses as c
	INNER JOIN Modules as m
	on c.CourseID = m.CourseID
	INNER JOIN (
		select MeetingDate, ModuleID from OnlineLiveMeeting
		UNION
		select MeetingDate, ModuleID from StationaryMeeting) as T1
	on T1.ModuleID = m.ModuleID
	group by c.ServiceID, c.CourseDate
	
	

