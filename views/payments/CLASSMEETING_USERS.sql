CREATE VIEW CLASSMEETING_USERS AS
SELECT
    cm.ClassMeetingID,
	cm.ServiceID,
    cm.SubjectID,
    cm.MeetingName,
    cm.MeetingType,
    st.ServiceUserID,
    u.FirstName,
    u.LastName,
    scd.Attendance AS SyncAttendance,
    acd.ViewDate AS AsyncViewDate
FROM ClassMeeting cm
LEFT JOIN SyncClassDetails scd
    ON scd.MeetingID = cm.ClassMeetingID
LEFT JOIN AsyncClassDetails acd
    ON acd.MeetingID = cm.ClassMeetingID

LEFT JOIN ServiceUserDetails st
    ON st.ServiceUserID = scd.StudentID 
       OR st.ServiceUserID = acd.StudentID

LEFT JOIN Users u
    ON u.UserID = st.ServiceUserID
WHERE scd.StudentID IS NOT NULL
      OR acd.StudentID IS NOT NULL
;