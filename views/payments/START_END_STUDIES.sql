create view START_END_STUDIES as
select ServiceID, CAST(EnrollmentDeadline as DATE) as StartOfService, CAST(ExpectedGraduationDate as DATE) as EndOfService
	from Studies