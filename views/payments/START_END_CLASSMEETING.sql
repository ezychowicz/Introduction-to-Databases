create view START_END_OF_CLASSMEETING as
select CM.ServiceID, T1.StartDate as StartOfService, T1.EndDate as EndOfService
	from ClassMeeting as CM
	INNER JOIN (
		select MeetingID, CAST(StartDate as DATE) as StartDate,CAST(DATEADD(SECOND, 
            DATEDIFF(SECOND, '00:00:00', Duration), 
            StartDate) as DATE)  as EndDate from OnlineLiveClass
		UNION
		select MeetingID, CAST(StartDate as DATE) as StartDate, CAST(DATEADD(SECOND, 
            DATEDIFF(SECOND, '00:00:00', Duration), 
            StartDate) as DATE) as EndDate from StationaryClass
		UNION
		select MeetingID, StartDate, Deadline as EndDate from OfflineVideoClass
	) as T1
	on T1.MeetingID = CM.ClassMeetingID
	group by CM.ServiceID, T1.StartDate, T1.EndDate

