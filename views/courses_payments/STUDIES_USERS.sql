create view STUDIES_USERS as
select sd.StudiesID, s.ServiceID, s.StudiesName, us.ServiceUserID, u.FirstName, u.LastName 
	from StudiesDetails as sd
	INNER JOIN Studies as s
	on s.StudiesID = sd.StudiesID
	INNER JOIN ServiceUserDetails as us
	on us.ServiceUserID = sd.StudentID
	INNER JOIN Users as u
	on u.UserID = us.ServiceUserID

