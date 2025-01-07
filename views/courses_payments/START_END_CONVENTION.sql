create view START_END_OF_CONVENTION as
select c.ServiceID, c.StartDate as StartOfService, DATEADD(DAY, c.Duration, c.StartDate) AS EndOfService
	from Convention as c


