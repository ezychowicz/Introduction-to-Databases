-- CREATE or ALTER TRIGGER [dbo].[AddStudentDetails]
-- ON [dbo].[StudiesDetails]
-- AFTER INSERT
-- AS
-- BEGIN
--     SET NOCOUNT ON; 

--     INSERT INTO dbo.SubjectDetails (SubjectID, StudentID, SubjectGrade, Attendance)
--     SELECT 
--         s2sa.SubjectID,
--         i.StudentID,
--         0.0 AS SubjectGrade,
--         0.0 AS Attendance
--     FROM Inserted i
--     INNER JOIN dbo.SubjectStudiesAssignment s2sa 
--         ON s2sa.StudiesID = i.StudiesID
--     WHERE NOT EXISTS (
--         SELECT 1 
--         FROM dbo.SubjectDetails sd
--         WHERE sd.SubjectID = s2sa.SubjectID
--           AND sd.StudentID = i.StudentID
--     );

--     INSERT INTO dbo.InternshipDetails (InternshipID, StudentID, Duration, InternshipGrade, InternshipAttendance)
--     SELECT
--         it.InternshipID,
--         i.StudentID,
--         14 AS Duration,
--         0 AS InternshipGrade,
--         0 AS InternshipAttendance
--     FROM Inserted i
--     INNER JOIN dbo.Internship it
--         ON it.StudiesID = i.StudiesID
--     WHERE NOT EXISTS (
--         SELECT 1 
--         FROM dbo.InternshipDetails ind
--         WHERE ind.InternshipID = it.InternshipID
--           AND ind.StudentID = i.StudentID
--     );

--     SET NOCOUNT OFF;
-- END;
-- GO

-- CREATE Or ALTER TRIGGER [dbo].[AddStudentDetailsSubject]
-- ON [dbo].[SubjectDetails]
-- AFTER INSERT
-- AS
-- BEGIN
--     SET NOCOUNT ON; 

--     INSERT INTO dbo.SyncClassDetails (MeetingID, StudentID, Attendance)
--     SELECT 
--         cm.ClassMeetingID,
--         i.StudentID,
--         0 AS Attendance
--     FROM Inserted i
--     Join ClassMeeting cm on i.SubjectID = cm.SubjectID
--     WHERE 
--         cm.MeetingType IN ('StationaryClass', 'OnlineLiveClass')
--         AND NOT EXISTS (
--             SELECT 1
--             FROM dbo.SyncClassDetails scd
--             WHERE scd.MeetingID = cm.ClassMeetingID
--               AND scd.StudentID = i.StudentID
--         );

--     INSERT INTO dbo.AsyncClassDetails (MeetingID, StudentID, ViewDate)
--     SELECT 
--         cm.ClassMeetingID,
--         i.StudentID,
--         NULL AS ViewDate
--     FROM Inserted i
--     Join ClassMeeting cm on i.SubjectID = cm.SubjectID
--     WHERE 
--         cm.MeetingType IN ('OfflineVideo')
--         AND NOT EXISTS (
--             SELECT 1
--             FROM dbo.AsyncClassDetails acd
--             WHERE acd.MeetingID = cm.ClassMeetingID
--               AND acd.StudentID = i.StudentID
--         );

--     SET NOCOUNT OFF;
-- END;

CREATE OR ALTER TRIGGER [dbo].[DeleteUserFromStudies]
ON [dbo].[StudiesDetails]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON; 

    DELETE FROM dbo.SubjectDetails
    WHERE StudentID IN (SELECT StudentID FROM Deleted);

    DELETE FROM dbo.InternshipDetails
    WHERE StudentID IN (SELECT StudentID FROM Deleted);

    SET NOCOUNT OFF;
END;

-- CREATE OR ALTER TRIGGER [dbo].[DeleteUserFromSubject]
-- ON [dbo].[SubjectDetails]
-- AFTER DELETE
-- AS
-- BEGIN
--     SET NOCOUNT ON; 

--     DELETE FROM dbo.SyncClassDetails
--     WHERE StudentID IN (SELECT StudentID FROM Deleted) and MeetingID in (SELECT ClassMeetingID FROM ClassMeeting WHERE MeetingType IN ('StationaryClass', 'OnlineLiveClass'));

--     DELETE FROM dbo.AsyncClassDetails
--     WHERE StudentID IN (SELECT StudentID FROM Deleted) and MeetingID in (SELECT ClassMeetingID FROM ClassMeeting WHERE MeetingType IN ('OfflineVideo'));

--     SET NOCOUNT OFF;
-- END;