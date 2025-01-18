create view WEBINAR_USERS as
select wd.WebinarID, w.ServiceID, w.WebinarName, us.ServiceUserID, u.FirstName, u.LastName 
	from WebinarDetails as wd
	INNER JOIN Webinars as w
	on wd.WebinarID = w.WebinarID
	INNER JOIN ServiceUserDetails as us
	on us.ServiceUserID = wd.UserID
	INNER JOIN Users as u
	on u.UserID = us.ServiceUserID

