create view SERVICE_USERS as
select ServiceID, ServiceUserID from STUDIES_USERS
union
select ServiceID, ServiceUserID from COURSES_USERS
union
select ServiceID, ServiceUserID from CLASSMEETING_USERS
union
select ServiceID, ServiceUserID from CONVENTION_USERS
union 
select ServiceID, ServiceUserID from WEBINAR_USERS
