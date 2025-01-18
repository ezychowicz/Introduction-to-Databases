create view NUM_OF_PARTICIPANTS_MEETINGS_COURSES as
select smd.MeetingID, sm.MeetingDate, 'Stationary' as MeetingType, COUNT(smd.ParticipantID) as [Number of Participants]
	from StationaryMeetingDetails as smd
	INNER JOIN StationaryMeeting as sm
	on sm.MeetingID = smd.MeetingID
	group by smd.MeetingID, sm.MeetingDate
	having sm.MeetingDate > CONVERT(DATE, GETDATE()) 
union
select omd.MeetingID, om.MeetingDate, 'Online' as MeetingType, COUNT(omd.ParticipantID) as [Number of Participants]
	from OnlineLiveMeetingDetails as omd
	INNER JOIN OnlineLiveMeeting as om
	on om.MeetingID = omd.MeetingID
	group by omd.MeetingID, om.MeetingDate
	having om.MeetingDate > CONVERT(DATE, GETDATE()) 

