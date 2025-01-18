create view START_END_OF_SERVICES as 
select ServiceID, StartOfService, EndOfService 
	from START_END_OF_CONVENTION
union
select ServiceID, StartOfService, EndOfService 
	from START_END_STUDIES
union
select ServiceID, StartOfService, EndOfService 
	from START_END_OF_COURSES
union 
select ServiceID, StartOfService, EndOfService 
	from START_END_OF_CLASSMEETING

