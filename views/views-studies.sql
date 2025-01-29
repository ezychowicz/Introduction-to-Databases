-- CREATE VIEW V_StudentGrades AS
-- SELECT
--     st.ServiceUserID,
--     CONCAT(u.FirstName, ' ', u.LastName) AS StudentName,
--     sd.StudiesID,
--     s.StudiesName,
--     g.GradeValue AS StudiesGradeValue,
--     g.GradeName  AS StudiesGradeLabel
-- FROM StudiesDetails sd
--     JOIN ServiceUserDetails st
--     ON sd.StudentID = st.ServiceUserID
--     JOIN Users u
--     ON u.UserID = st.ServiceUserID
--     JOIN Studies s
--     ON s.StudiesID = sd.StudiesID
--     JOIN Grades g
--     ON g.GradeID = sd.StudiesGrade;

-- CREATE VIEW V_SemesterSubjectsConventions AS
-- SELECT
--     sem.SemesterID,
--     sem.StudiesID,
--     ss.SubjectID,
--     sub.SubjectName,
--     c.StartDate AS ConventionStart,
--     c.Duration AS ConventionDays
-- FROM SemesterDetails sem
--     JOIN Studies s
--     ON s.StudiesID = sem.StudiesID
--     JOIN SubjectStudiesAssignment ss
--     ON ss.StudiesID = s.StudiesID
--     JOIN Subject sub
--     ON sub.SubjectID = ss.SubjectID
--     LEFT JOIN Convention c
--     ON c.SemesterID = sem.SemesterID
--         AND c.SubjectID = ss.SubjectID;

-- CREATE VIEW V_StudiesEnrollment AS
-- SELECT
--     s.StudiesID,
--     s.StudiesName,
--     s.EnrollmentLimit,
--     s.EnrollmentDeadline,
--     COUNT(sd.StudentID) AS TotalEnrolled,
--     e.EmployeeID AS CoordinatorEmployeeID,
--     CONCAT(u.FirstName, ' ', u.LastName) AS CoordinatorName
-- FROM Studies s
--     LEFT JOIN StudiesDetails sd
--     ON s.StudiesID = sd.StudiesID
--     LEFT JOIN Employees e
--     ON e.EmployeeID = s.StudiesCoordinatorID
--     LEFT JOIN Users u
--     ON u.UserID = e.EmployeeID
-- GROUP BY 
--     s.StudiesID, s.StudiesName, s.EnrollmentLimit, s.EnrollmentDeadline, 
--     e.EmployeeID, u.FirstName, u.LastName;
-- Select * from V_StudiesEnrollment

-- CREATE VIEW V_EmployeeHierarchy AS
-- SELECT
--     e.EmployeeID,
--     CONCAT(u.FirstName, ' ', u.LastName) AS EmployeeName,
--     es.ReportsTo AS SuperiorID,
--     CONCAT(u2.FirstName, ' ', u2.LastName) AS SuperiorName
-- FROM Employees e
--     JOIN Users u
--     ON u.UserID = e.EmployeeID
--     LEFT JOIN EmployeesSuperior es
--     ON es.EmployeeID = e.EmployeeID
--     LEFT JOIN Employees e2
--     ON e2.EmployeeID = es.ReportsTo
--     LEFT JOIN Users u2
--     ON u2.UserID = e2.EmployeeID;

-- CREATE VIEW V_ConventionSchedule AS
-- SELECT
--     c.ConventionID,
--     c.SemesterID,
--     c.SubjectID,
--     sub.SubjectName,
--     c.StartDate,
--     c.Duration AS DurationDays,
--     DATEADD(DAY, c.Duration, c.StartDate) AS EndDate
-- FROM Convention c
--     JOIN Subject sub
--     ON c.SubjectID = sub.SubjectID;

-- CREATE VIEW V_SubjectMeetingSchedule AS
-- SELECT
--     cm.ClassMeetingID,
--     cm.SubjectID,
--     s.SubjectName,
--     cm.MeetingType,
--     CASE WHEN sc.StartDate IS NOT NULL THEN sc.StartDate
--          WHEN oc.StartDate IS NOT NULL THEN oc.StartDate
--          ELSE ofc.StartDate
--     END AS MeetingStartDate,
--     t2.EmployeeID AS TeacherID,
--     CONCAT(u2.FirstName, ' ', u2.LastName) AS TeacherName,
--     c.ConventionID,
--     c.StartDate AS ConventionStart,
--     c.Duration AS ConventionDays
-- FROM ClassMeeting cm
--     JOIN Subject s
--     ON s.SubjectID = cm.SubjectID
--     LEFT JOIN StationaryClass sc
--     ON sc.MeetingID = cm.ClassMeetingID
--     LEFT JOIN OnlineLiveClass oc
--     ON oc.MeetingID = cm.ClassMeetingID
--     LEFT JOIN OfflineVideoClass ofc
--     ON ofc.MeetingID = cm.ClassMeetingID
--     LEFT JOIN Employees t2
--     ON t2.EmployeeID = cm.TeacherID
--     LEFT JOIN Users u2
--     ON u2.UserID = t2.EmployeeID
--     LEFT JOIN Convention c
--     ON c.SubjectID = cm.SubjectID
-- Typically you'd match the date logic inside the view or keep it simpler:
-- e.g., "AND (MeetingStartDate BETWEEN c.StartDate AND c.StartDate + c.Duration - 1 day)"
-- but that depends on your DB syntax
;

-- CREATE VIEW V_TranslatorLanguageSkill AS
-- SELECT
--     t.TranslatorID,
--     CONCAT(u.FirstName, ' ', u.LastName) AS TranslatorName,
--     l.LanguageID,
--     l.LanguageName,
--     uc.Email,
--     uc.Phone
-- FROM Translators t
--     JOIN Employees e
--     ON e.EmployeeID = t.TranslatorID
--     JOIN Users u
--     ON u.UserID = e.EmployeeID
--     JOIN TranslatorsLanguages tl
--     ON tl.TranslatorID = t.TranslatorID
--     JOIN Languages l
--     ON l.LanguageID = tl.LanguageID
--     LEFT JOIN UserContact uc
--     ON uc.UserID = u.UserID;

-- CREATE VIEW V_SemesterSubjectsConventions AS
-- SELECT
--     sem.SemesterID,
--     sem.StudiesID,
--     ss.SubjectID,
--     sub.SubjectName,
--     c.ConventionID,
--     c.StartDate AS ConventionStart,
--     c.Duration AS ConventionDays
-- FROM SemesterDetails sem
--     JOIN Studies s
--     ON s.StudiesID = sem.StudiesID
--     JOIN SubjectStudiesAssignment ss
--     ON ss.StudiesID = s.StudiesID
--     JOIN Subject sub
--     ON sub.SubjectID = ss.SubjectID
--     LEFT JOIN Convention c
--     ON c.SemesterID = sem.SemesterID
--         AND c.SubjectID = ss.SubjectID;
--     GO

-- CREATE VIEW V_ConventionStudents AS
-- SELECT
--     c.ConventionID,
--     c.SemesterID,
--     c.SubjectID,
--     sub.SubjectName,
--     st.ServiceUserID,
--     u.FirstName,
--     u.LastName,
--     c.StartDate,
--     c.Duration AS ConventionDays
-- FROM Convention c
--     JOIN SemesterDetails sem
--     ON sem.SemesterID = c.SemesterID
--     JOIN StudiesDetails sd
--     ON sd.StudiesID = sem.StudiesID
--     JOIN ServiceUserDetails st
--     ON st.ServiceUserID = sd.StudentID
--     JOIN Users u
--     ON u.UserID = st.ServiceUserID
--     JOIN SubjectStudiesAssignment s2s
--     ON s2s.StudiesID = sem.StudiesID
--         AND s2s.SubjectID = c.SubjectID
--     JOIN Subject sub
--     ON sub.SubjectID = c.SubjectID
-- ;

-- CREATE VIEW V_ClassMeetingStudents AS
-- SELECT
--     cm.ClassMeetingID,
--     cm.SubjectID,
--     cm.MeetingName,
--     cm.MeetingType,
--     st.ServiceUserID,
--     u.FirstName,
--     u.LastName,
--     scd.Attendance AS SyncAttendance,
--     acd.ViewDate AS AsyncViewDate
-- FROM ClassMeeting cm
--     LEFT JOIN SyncClassDetails scd
--     ON scd.MeetingID = cm.ClassMeetingID
--     LEFT JOIN AsyncClassDetails acd
--     ON acd.MeetingID = cm.ClassMeetingID

--     LEFT JOIN ServiceUserDetails st
--     ON st.ServiceUserID = scd.StudentID
--         OR st.ServiceUserID = acd.StudentID

--     LEFT JOIN Users u
--     ON u.UserID = st.ServiceUserID
-- WHERE scd.StudentID IS NOT NULL
--     OR acd.StudentID IS NOT NULL
-- ;

-- CREATE VIEW [dbo].[AllEvents] AS
-- Stationary class
--     SELECT
--         scd.StudentID as ParticipantID,
--         'StationaryClass' AS EventType,
--         sc.MeetingID        AS EventID,
--         sc.MeetingDate      AS StartTime,
--         DATEADD(Minute, 90, sc.MeetingDate) AS EndTime
--     FROM StationaryMeeting sc
--         JOIN SyncClassDetails scd
--         ON sc.MeetingID = scd.MeetingID

-- UNION ALL

--     SELECT
--         scd.StudentID as ParticipantID,
--         'OnlineClass' AS EventType,
--         oc.MeetingID        AS EventID,
--         oc.StartDate      AS StartTime,
--         DATEADD(Minute, 90, oc.StartDate) AS EndTime
--     FROM OnlineLiveClass oc
--         JOIN SyncClassDetails scd
--         ON oc.MeetingID = scd.MeetingID

-- UNION ALL

--     -- 1) Stationary Meeting
--     SELECT
--         smd.ParticipantID,
--         'StationaryMeeting' AS EventType,
--         sm.MeetingID        AS EventID,
--         sm.MeetingDate      AS StartTime,
--         -- End time = MeetingDate + MeetingDuration
--         --   DATEADD(time,sm.MeetingDate, sm.MeetingDuration) AS EndTime
--         DATEADD(Minute, 90, sm.MeetingDate) AS EndTime
--     FROM StationaryMeeting sm
--         JOIN StationaryMeetingDetails smd
--         ON sm.MeetingID = smd.MeetingID

-- UNION ALL

--     -- 2) Online Live Meeting
--     SELECT
--         olmd.ParticipantID,
--         'OnlineLiveMeeting' AS EventType,
--         olm.MeetingID       AS EventID,
--         olm.MeetingDate     AS StartTime,
--         DATEADD(Minute, 90, olm.MeetingDate) AS EndTime
--     FROM OnlineLiveMeeting olm
--         JOIN OnlineLiveMeetingDetails olmd
--         ON olm.MeetingID = olmd.MeetingID

-- UNION ALL
--     -- 5) Webinars
--     SELECT
--         wd.UserID   AS ParticipantID,
--         'Webinar'    AS EventType,
--         w.WebinarID  AS EventID,
--         w.WebinarDate AS StartTime,
--         DATEADD(Minute, 90, w.WebinarDate) AS EndTime
--     FROM Webinars w
--         JOIN WebinarDetails wd
--         ON w.WebinarID = wd.WebinarID
-- ;
-- CREATE or alter VIEW V_StudentCollidingEvents AS
-- SELECT
--     A.ParticipantID, A.EventType as ET1, A.EventID AS EID1, B.EventType as ET2, B.EventID as EID2, A.StartTime as ST1, A.EndTime as EnT1, B.StartTime as ST2, B.EndTime as EnT2
--     -- A.ParticipantID, A.EventID AS EID1, B.EventID as EID2, A.StartTime as ST1, A.EndTime as EnT1, B.StartTime as ST2, B.EndTime as EnT2
--     -- COUNT(DISTINCT CAST(B.EventID AS VARCHAR(20)) + '_' + B.EventType) AS CollisionsCount
-- FROM AllEvents A
-- JOIN AllEvents B
--     ON A.ParticipantID = B.ParticipantID
--     -- AND A.EventType <> B.EventType
--     AND (A.EventID <> B.EventID)
--     AND A.StartTime < B.EndTime
--     AND B.StartTime < A.EndTime
--     AND A.EventID < B.EventID
-- -- where A.StartTime > GETDATE()
-- where A.StartTime > GETDATE()
-- GROUP BY
--     A.ParticipantID, A.EventType, A.EventID, B.EventType, B.EventID, A.StartTime, A.EndTime, B.StartTime, B.EndTime
-- Select * from V_StudentCollidingEvents

-- -- CREATE VIEW dbo.V_WebinarsWithAttendance AS
-- SELECT
--     w.WebinarID,
--     w.WebinarName,
--     w.WebinarDate,
--     w.DurationTime,
--     wd.UserID AS ParticipantID,
--     1 AS Attended
-- FROM Webinars w
-- JOIN WebinarDetails wd
--     ON w.WebinarID = wd.WebinarID;

-- CREATE VIEW dbo.V_StudentSchedule AS
-- SELECT
--         u.UserID AS ParticipantID,
--         'StationaryMeeting' AS EventType,
--         sm.MeetingID AS EventID,
--         sm.MeetingDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, sm.MeetingDuration), sm.MeetingDate) AS EndTime
--     FROM StationaryMeeting sm
--     JOIN StationaryMeetingDetails smd ON sm.MeetingID = smd.MeetingID
--     JOIN Users u ON u.UserID = smd.ParticipantID
--                 AND u.UserTypeID = 1  -- Student

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'OnlineLiveMeeting' AS EventType,
--         olm.MeetingID AS EventID,
--         olm.MeetingDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, olm.MeetingDuration), olm.MeetingDate) AS EndTime
--     FROM OnlineLiveMeeting olm
--     JOIN OnlineLiveMeetingDetails omd ON omd.MeetingID = olm.MeetingID
--     JOIN Users u ON u.UserID = omd.ParticipantID
--                 AND u.UserTypeID = 1

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'StationaryClass' AS EventType,
--         sc.MeetingID AS EventID,
--         sc.StartDate AS StartTime,
--         DATEADD(MINUTE, 90, sc.StartDate) AS EndTime
--     FROM StationaryClass sc
--     JOIN SyncClassDetails scd ON sc.MeetingID = scd.MeetingID
--     JOIN Users u ON u.UserID = scd.StudentID
--                 AND u.UserTypeID = 1

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'OnlineLiveClass' AS EventType,
--         olc.MeetingID AS EventID,
--         olc.StartDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, olc.Duration), olc.StartDate) AS EndTime
--     FROM OnlineLiveClass olc
--     JOIN SyncClassDetails olcd ON olc.MeetingID = olcd.MeetingID
--     JOIN Users u ON u.UserID = olcd.StudentID
--                 AND u.UserTypeID = 1

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'Webinar' AS EventType,
--         w.WebinarID AS EventID,
--         w.WebinarDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, w.DurationTime), w.WebinarDate) AS EndTime
--     FROM Webinars w
--     JOIN WebinarDetails wd ON w.WebinarID = wd.WebinarID
--     JOIN Users u ON u.UserID = wd.UserID
--                 AND u.UserTypeID = 1
-- ;


-- CREATE VIEW dbo.V_EmployeeSchedule
-- AS
--     SELECT
--         u.UserID AS EmployeeID,
--         'StationaryMeeting' AS EventType,
--         sm.MeetingID        AS EventID,
--         sm.MeetingDate      AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, sm.MeetingDuration), sm.MeetingDate) AS EndTime
--     FROM StationaryMeeting sm
--     JOIN Users u
--         ON u.UserID = sm.TeacherID
--        AND u.UserTypeID = 2

--     UNION ALL

--     SELECT
--         u.UserID AS EmployeeID,
--         'OnlineLiveMeeting' AS EventType,
--         olm.MeetingID       AS EventID,
--         olm.MeetingDate     AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, olm.MeetingDuration), olm.MeetingDate) AS EndTime
--     FROM OnlineLiveMeeting olm
--     JOIN Users u
--         ON u.UserID = olm.TeacherID
--        AND u.UserTypeID = 2

--     UNION ALL

--         SELECT
--        u.UserID AS EmployeeID,
--        'StationaryClass' AS EventType,
--        cm.ClassMeetingID AS EventID,
--        sc.StartDate      AS StartTime,
--        DATEADD(SECOND, DATEDIFF(SECOND, 0, sc.Duration), sc.StartDate) AS EndTime
--     FROM ClassMeeting cm
--     JOIN StationaryClass sc
--        ON sc.MeetingID = cm.ClassMeetingID
--     JOIN Users u
--        ON u.UserID = cm.TeacherID
--        AND u.UserTypeID = 2

--     UNION ALL

--     SELECT
--        u.UserID AS EmployeeID,
--        'OnlineLiveClass' AS EventType,
--        cm.ClassMeetingID AS EventID,
--        olc.StartDate     AS StartTime,
--        DATEADD(SECOND, DATEDIFF(SECOND, 0, olc.Duration), olc.StartDate) AS EndTime
--     FROM ClassMeeting cm
--     JOIN OnlineLiveClass olc
--        ON olc.MeetingID = cm.ClassMeetingID
--     JOIN Users u
--        ON u.UserID = cm.TeacherID
--        AND u.UserTypeID = 2

--     UNION ALL

--     SELECT
--         u.UserID AS EmployeeID,
--         'Webinar'       AS EventType,
--         w.WebinarID     AS EventID,
--         w.WebinarDate   AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, w.DurationTime), w.WebinarDate) AS EndTime
--     FROM Webinars w
--     JOIN Users u
--         ON u.UserID = w.TeacherID
--        AND u.UserTypeID = 2
-- ;
-- GO

-- CREATE VIEW dbo.V_ClassAttendanceList
-- AS
    -- SELECT
    --     scc.MeetingID,
    --     scd.StudentID,
    --     'Stationary' AS MeetingType,
    --     st.FirstName,
    --     st.LastName,
    --     scd.Attendance,
    --     scc.StartDate
    -- FROM StationaryClass scc
    -- JOIN SyncClassDetails scd
    --     ON scc.MeetingID = scd.MeetingID
    -- JOIN Users st
    --     ON st.UserID = scd.StudentID

    -- UNION ALL

    -- SELECT
    --     olc.MeetingID,
    --     scd.StudentID,
    --     'OnlineLive' AS MeetingType,
    --     st.FirstName,
    --     st.LastName,
    --     scd.Attendance,
    --     olc.StartDate
    -- FROM OnlineLiveClass olc
    -- JOIN SyncClassDetails scd
    --     ON olc.MeetingID = scd.MeetingID
    -- JOIN Users st
    --     ON st.UserID = scd.StudentID
-- ;

-- CREATE VIEW dbo.V_ClassAttendanceAggregate
-- AS
--     SELECT
--         scc.MeetingID,
--         scc.StartDate AS MeetingDate,
--         'StationaryClass'  AS MeetingType,
--         Round(AVG(CAST(scd.Attendance AS FLOAT)),2) AS Attendance
--     FROM StationaryClass scc
--     JOIN SyncClassDetails scd
--         ON scc.MeetingID = scd.MeetingID
--     GROUP BY
--         scc.MeetingID,
--         scc.StartDate

--     UNION ALL

--     SELECT
--         olc.MeetingID,
--         olc.StartDate AS MeetingDate,
--         'OnlineLive'  AS MeetingType,
--         Round(AVG(CAST(scd.Attendance AS FLOAT)),2) AS Attendance
--     FROM OnlineLiveClass olc
--     JOIN SyncClassDetails scd
--         ON olc.MeetingID = scd.MeetingID
--     GROUP BY
--         olc.MeetingID,
--         olc.StartDate
-- ;

-- CREATE VIEW V_EmplyeeWorkload AS
-- select EmployeeID, DATEDIFF(MINUTE, StartTime, EndTime)/45 as worked_hours from V_EmployeeSchedule
-- GROUP by EmployeeID, DATEDIFF(MINUTE, StartTime, EndTime);

-- CREATE VIEW V_StudentsFinishedStudies
-- AS
-- SELECT
--     st.ServiceUserID,
--     u.FirstName,
--     u.LastName,
--     uad.Address,
--     uad.PostalCode,
--     uad.LocationID,
--     s.StudiesID,
--     s.StudiesName
-- FROM ServiceUserDetails st
-- JOIN 
-- (
--     SELECT
--         sd.StudentID,
--         sts.StudiesID,
--         count(*) as TotalSubjects
--     FROM SubjectDetails sd
--     JOIN SubjectStudiesAssignment sts
--         ON sd.SubjectID = sts.SubjectID
--     GROUP BY sd.StudentID, sts.StudiesID
--     HAVING 
--         COUNT(*) = 
--         (
--            SELECT COUNT(*)
--            FROM SubjectStudiesAssignment X
--            WHERE X.StudiesID = sts.StudiesID
--         )
--         AND MIN(sd.SubjectGrade) >= 3
-- ) AS T
--    ON T.StudentID = st.ServiceUserID
-- JOIN Studies s
--    ON s.StudiesID = T.StudiesID
-- JOIN Users u
--    ON u.UserID = st.ServiceUserID
-- Join UserAddressDetails uad
--     ON uad.UserID = u.UserID
-- ;

-- CREATE OR ALTER VIEW V_StudiesInfo AS
-- SELECT
--     s.StudiesID,
--     s.StudiesName,
--     s.StudiesDescription,
--     s.StudiesCoordinatorID,
--     s.EnrollmentDeadline,
--     s.EnrollmentLimit,
--     s.ExpectedGraduationDate,
--     CONCAT(u.FirstName, ' ', u.LastName) AS CoordinatorName
-- FROM Studies s
--     LEFT JOIN Employees e
--     ON e.EmployeeID = s.StudiesCoordinatorID
--     LEFT JOIN Users u
--     ON u.UserID = e.EmployeeID
-- where s.EnrollmentDeadline > GETDATE();

-- use u_szymocha
-- Select * from V_StudentSchedule

-- CREATE VIEW dbo.V_StudentSchedule AS
-- SELECT
--         u.UserID AS ParticipantID,
--         'StationaryMeeting' AS EventType,
--         sm.MeetingID AS EventID,
--         sm.MeetingDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, sm.MeetingDuration), sm.MeetingDate) AS EndTime
--     FROM StationaryMeeting sm
--     JOIN StationaryMeetingDetails smd ON sm.MeetingID = smd.MeetingID
--     JOIN Users u ON u.UserID = smd.ParticipantID
--                 AND u.UserTypeID = 1  -- Student

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'OnlineLiveMeeting' AS EventType,
--         olm.MeetingID AS EventID,
--         olm.MeetingDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, olm.MeetingDuration), olm.MeetingDate) AS EndTime
--     FROM OnlineLiveMeeting olm
--     JOIN OnlineLiveMeetingDetails omd ON omd.MeetingID = olm.MeetingID
--     JOIN Users u ON u.UserID = omd.ParticipantID
--                 AND u.UserTypeID = 1

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'StationaryClass' AS EventType,
--         sc.MeetingID AS EventID,
--         sc.StartDate AS StartTime,
--         DATEADD(MINUTE, 90, sc.StartDate) AS EndTime
--     FROM StationaryClass sc
--     JOIN SyncClassDetails scd ON sc.MeetingID = scd.MeetingID
--     JOIN Users u ON u.UserID = scd.StudentID
--                 AND u.UserTypeID = 1

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'OnlineLiveClass' AS EventType,
--         olc.MeetingID AS EventID,
--         olc.StartDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, olc.Duration), olc.StartDate) AS EndTime
--     FROM OnlineLiveClass olc
--     JOIN SyncClassDetails olcd ON olc.MeetingID = olcd.MeetingID
--     JOIN Users u ON u.UserID = olcd.StudentID
--                 AND u.UserTypeID = 1

--     UNION ALL

--     SELECT
--         u.UserID AS ParticipantID,
--         'Webinar' AS EventType,
--         w.WebinarID AS EventID,
--         w.WebinarDate AS StartTime,
--         DATEADD(SECOND, DATEDIFF(SECOND, 0, w.DurationTime), w.WebinarDate) AS EndTime
--     FROM Webinars w
--     JOIN WebinarDetails wd ON w.WebinarID = wd.WebinarID
--     JOIN Users u ON u.UserID = wd.UserID
--                 AND u.UserTypeID = 1
-- ;

-- CREATE OR ALTER VIEW V_FutureStudentSchedule AS
-- SELECT * from V_StudentSchedule
-- WHERE StartTime > GETDATE()
-- GO

CREATE OR ALTER VIEW V_ConventionUsers
AS
WITH 
AllSyncMeetings AS
(
    SELECT 
        c.ServiceID,
        COUNT(DISTINCT cm.ClassMeetingID) AS TotalSyncRequired
    FROM Convention c
    JOIN ClassMeeting cm 
        ON cm.SubjectID = c.SubjectID
    LEFT JOIN StationaryClass st
        ON st.MeetingID = cm.ClassMeetingID
    LEFT JOIN OnlineLiveClass ol
        ON ol.MeetingID = cm.ClassMeetingID
    WHERE (st.MeetingID IS NOT NULL OR ol.MeetingID IS NOT NULL)
      AND (
           COALESCE(st.StartDate, ol.StartDate) 
           BETWEEN c.StartDate 
               AND DATEADD(DAY, c.Duration, c.StartDate)
          )
    GROUP BY c.ServiceID
),

AllAsyncMeetings AS
(
    SELECT 
        c.ServiceID,
        COUNT(DISTINCT cm.ClassMeetingID) AS TotalAsyncRequired
    FROM Convention c
    JOIN ClassMeeting cm 
        ON cm.SubjectID = c.SubjectID
    JOIN OfflineVideoClass ov
        ON ov.MeetingID = cm.ClassMeetingID
    WHERE ov.StartDate 
          BETWEEN c.StartDate 
              AND DATEADD(DAY, c.Duration, c.StartDate)
    GROUP BY c.ServiceID
),

UserSyncCounts AS
(
    SELECT 
        c.ServiceID,
        scd.StudentID,
        COUNT(DISTINCT scd.MeetingID) AS UserSyncCount
    FROM SyncClassDetails scd
    JOIN ClassMeeting cm
        ON cm.ClassMeetingID = scd.MeetingID
    JOIN Convention c
        ON c.SubjectID = cm.SubjectID
    LEFT JOIN StationaryClass st
        ON st.MeetingID = cm.ClassMeetingID
    LEFT JOIN OnlineLiveClass ol
        ON ol.MeetingID = cm.ClassMeetingID
    WHERE (st.MeetingID IS NOT NULL OR ol.MeetingID IS NOT NULL)
      AND COALESCE(st.StartDate, ol.StartDate)
          BETWEEN c.StartDate 
              AND DATEADD(DAY, c.Duration, c.StartDate)
    GROUP BY c.ServiceID, scd.StudentID
),
UserAsyncCounts AS
(
    SELECT 
        c.ServiceID,
        acd.StudentID,
        COUNT(DISTINCT acd.MeetingID) AS UserAsyncCount
    FROM AsyncClassDetails acd
    JOIN ClassMeeting cm
        ON cm.ClassMeetingID = acd.MeetingID
    JOIN Convention c
        ON c.SubjectID = cm.SubjectID
    JOIN OfflineVideoClass ov
        ON ov.MeetingID = cm.ClassMeetingID
    WHERE ov.StartDate
          BETWEEN c.StartDate 
              AND DATEADD(DAY, c.Duration, c.StartDate)
    GROUP BY c.ServiceID, acd.StudentID
)

SELECT 
    s.ServiceID,
    s.StudentID AS ServiceUserID
FROM UserSyncCounts s
JOIN UserAsyncCounts a
    ON a.ServiceID = s.ServiceID
   AND a.StudentID    = s.StudentID
JOIN AllSyncMeetings reqS
    ON reqS.ServiceID = s.ServiceID
JOIN AllAsyncMeetings reqA
    ON reqA.ServiceID = a.ServiceID
WHERE s.UserSyncCount   = reqS.TotalSyncRequired
--   AND a.UserAsyncCount  = reqA.TotalAsyncRequired;
GO

-- exec p_EnrollStudentInConvention 40, 197 

SELECT * FROM V_ConventionUsers;