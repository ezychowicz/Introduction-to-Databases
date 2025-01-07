create view COURSES_USERS as
select cp.CourseID, c.ServiceID, c.CourseName, us.ServiceUserID, u.FirstName, u.LastName
	from CourseParticipants as cp
	INNER JOIN ServiceUserDetails as us
	on cp.ParticipantID = us.ServiceUserID
	INNER JOIN Courses as c
	on c.CourseID = cp.CourseID
	INNER JOIN Users as u
	on u.UserID = us.ServiceUserID

