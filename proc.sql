-- CREATE OR ALTER PROCEDURE p_AddRoom
-- (
--     @Capacity              INT,
--     @Address               VARCHAR(100),
--     @Floor                 INT,
--     @AccessibleForDisabled BIT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF @Capacity <= 0
--         BEGIN
--             RAISERROR('Room capacity must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Floor < 0
--         BEGIN
--             RAISERROR('Floor number cannot be negative.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO Rooms
--             (Capacity, Address, Floor, AccessibleForDisabled)
--         VALUES
--             (@Capacity, @Address, @Floor, @AccessibleForDisabled);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;
-- GO

-- CREATE OR ALTER PROCEDURE p_CreateStudies
-- (
--     @StudiesName         VARCHAR(200),
--     @StudiesDescription  VARCHAR(1000),
--     @CoordinatorID       INT,
--     @EnrollmentLimit     INT,
--     @EnrollmentDeadline  DATE,
--     @SemesterCount       INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @CoordinatorID)
--         BEGIN
--             RAISERROR('Invalid CoordinatorID: no matching Employee found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @SemesterCount < 2
--         BEGIN
--             RAISERROR('SemesterCount must be at least 2.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @EnrollmentLimit <= 0
--         BEGIN
--             RAISERROR('EnrollmentLimit must be greater than 0.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @EnrollmentDeadline < GETDATE()
--         BEGIN
--             RAISERROR('EnrollmentDeadline must be in the future.', 16, 4);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @NextStudiesID INT;

--         IF NOT EXISTS (SELECT 1 FROM Studies)
--         BEGIN
--             SET @NextStudiesID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextStudiesID = MAX(StudiesID) + 1 FROM Studies;
--         END;

--         INSERT INTO Studies
--             (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID,
--              EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate)
--         VALUES
--             (
--                 @NextStudiesID,
--                 @StudiesName,
--                 @StudiesDescription,
--                 @CoordinatorID,
--                 @EnrollmentLimit,
--                 @EnrollmentDeadline,
--                 @SemesterCount,
--                 NULL
--             );

--         DECLARE @SemesterIndex INT = 1;
--         DECLARE @StartDate     DATE = DATEADD(DAY, 1, @EnrollmentDeadline);
--         DECLARE @EndDate       DATE;
--         DECLARE @InternshipStart DATE = NULL;

--         DECLARE @NextSemesterID INT;

--         IF NOT EXISTS (SELECT 1 FROM SemesterDetails)
--         BEGIN
--             SET @NextSemesterID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextSemesterID = MAX(SemesterID) + 1 FROM SemesterDetails;
--         END;

--         WHILE @SemesterIndex <= @SemesterCount
--         BEGIN
--             SET @EndDate = DATEADD(DAY, 120, @StartDate);

--             INSERT INTO SemesterDetails
--                 (SemesterID, StudiesID, StartDate, EndDate)
--             VALUES
--                 (
--                     @NextSemesterID,
--                     @NextStudiesID,
--                     @StartDate,
--                     @EndDate
--                 );

--             IF @SemesterIndex = @SemesterCount - 1
--             BEGIN
--                 SET @InternshipStart = @StartDate;
--             END;

--             SET @SemesterIndex += 1;
--             SET @NextSemesterID += 1;

--             IF @SemesterIndex <= @SemesterCount
--             BEGIN
--                 SET @StartDate = DATEADD(DAY, 30 , @EndDate);
--             END;
--         END;

--         UPDATE Studies
--             SET ExpectedGraduationDate = @EndDate
--         WHERE StudiesID = @NextStudiesID;

--         DECLARE @NextInternshipID INT;
--         IF NOT EXISTS (SELECT 1 FROM Internship)
--         BEGIN
--             SET @NextInternshipID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextInternshipID = MAX(InternshipID) + 1 FROM Internship;
--         END;

--         INSERT INTO Internship
--             (InternshipID, StudiesID, StartDate)
--         VALUES
--             (
--                 @NextInternshipID,
--                 @NextStudiesID,
--                 @InternshipStart
--             );

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;
-- GO


-- CREATE OR ALTER PROCEDURE p_AddSubject
-- (
--     @SubjectName           VARCHAR(100),
--     @SubjectDescription    VARCHAR(500),
--     @SubjectCoordinatorID  INT,
--     @Meetings              INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF @SubjectName = ''
--         BEGIN
--             RAISERROR('SubjectName cannot be empty.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @SubjectCoordinatorID)
--         BEGIN
--             RAISERROR('Invalid CoordinatorID: no matching employee found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Meetings < 0
--         BEGIN
--             RAISERROR('Meetings cannot be negative.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;


--         DECLARE @NextSubjectID INT;
--         IF NOT EXISTS (SELECT 1 FROM Subject)
--         BEGIN
--             SET @NextSubjectID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextSubjectID = MAX(SubjectID) + 1
--             FROM Subject;
--         END;


--         INSERT INTO Subject
--             (SubjectID, SubjectName, SubjectDescription,
--              SubjectCoordinatorID, Meetings)
--         VALUES
--             (@NextSubjectID, 
--              @SubjectName, 
--              @SubjectDescription,
--              @SubjectCoordinatorID, 
--              @Meetings);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO

-- CREATE OR ALTER PROCEDURE p_AddConvention
-- (
--     @SubjectID INT,
--     @SemesterID     INT,
--     @ConventionDate DATE,
--     @Duration       int
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM SemesterDetails WHERE SemesterID = @SemesterID)
--         BEGIN
--             RAISERROR('Invalid SemesterID: no matching semester.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching subject.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Duration < 0
--         BEGIN
--             RAISERROR('Duration cannot be negative.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @SemStart DATE, @SemEnd DATE;
--         SELECT @SemStart = StartDate, 
--                @SemEnd   = EndDate
--         FROM SemesterDetails
--         WHERE SemesterID = @SemesterID;

--         IF @ConventionDate < @SemStart OR DATEADD(DAY, @Duration, @ConventionDate) > @SemEnd
--         BEGIN
--             RAISERROR(
--                 'Convention date must fall within the semester start/end dates.',
--                 16, 4
--             );
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @NextConventionID INT;
--         IF NOT EXISTS (SELECT 1 FROM Convention)
--         BEGIN
--             SET @NextConventionID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextConventionID = MAX(ConventionID) + 1 FROM Convention;
--         END;

--         INSERT INTO Convention
--             (ConventionID, StartDate, SemesterID, Duration)
--         VALUES
--             (@NextConventionID, @ConventionDate, @SemesterID, @Duration);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO

-- CREATE OR ALTER PROCEDURE p_EnrollStudentInStudies
-- (
--     @StudentID INT,
--     @StudiesID   INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ServiceUserDetails WHERE ServiceUserID = @StudentID)
--         BEGIN
--             RAISERROR('Invalid StudentID: not found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: not found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (
--             SELECT 1
--             FROM StudiesDetails
--             WHERE StudentID = @StudentID
--               AND StudiesID   = @StudiesID
--         )
--         BEGIN
--             RAISERROR('Student is already enrolled in this Study.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @SemesterCnt INT, @SemesterID INT, @FirstSemesterID INT;
--         SET @SemesterCnt = (Select @SemesterCnt from Studies where StudiesID = @StudiesID);
--         SET @FirstSemesterID = (Select MIN(SemesterID) from SemesterDetails where StudiesID = @StudiesID);
--         SET @SemesterID = 1

--         While @SemesterID <= @SemesterCnt
--         BEGIN
--             INSERT INTO StudiesDetails
--                 (StudentID, StudiesID, StudiesGrade, SemesterID)
--             VALUES
--                 (@StudentID, @StudiesID, 0, @SemesterID + @FirstSemesterID - 1);

--             SET @SemesterID += 1;
--         END; 

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_CreateStationaryClass
-- (
--     @SubjectID     INT,
--     @TeacherID     INT,
--     @MeetingName   VARCHAR(50),
--     @TranslatorID  INT = NULL,
--     @LanguageID    INT = NULL,
--     @RoomID        INT,
--     @GroupSize     INT,
--     @StartDate     DATETIME,
--     @Duration      TIME(0),
--     @PriceStudents money,
--     @PriceOthers   money
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         DECLARE @EndDate DATETIME;
--         SET @EndDate = DATEADD(SECOND, DATEDIFF(SECOND, 0, @Duration), @StartDate);

--         IF NOT EXISTS
--         (
--             SELECT 1
--             FROM Convention c
--             WHERE c.SubjectID = @SubjectID
--               AND @StartDate >= c.StartDate
--               AND @EndDate <= DATEADD(DAY, c.Duration, c.StartDate)
--         )
--         BEGIN
--             RAISERROR(
--                 'No matching Convention covers this SubjectID and time range.',
--                 16, 1
--             );
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS
--         (
--             SELECT 1
--             FROM RoomSchedule rs
--             WHERE rs.RoomID = @RoomID
--               AND rs.ScheduleOnDate = CAST(@StartDate AS DATE)
--               AND (
--                   (rs.StartTime <= CONVERT(TIME(0), @StartDate) AND rs.EndTime > CONVERT(TIME(0), @StartDate)) OR 
--                   (rs.StartTime >= CONVERT(TIME(0), @StartDate) AND rs.EndTime <= CONVERT(TIME(0), @EndDate))
--               )
--         )
--         BEGIN
--             RAISERROR('Room is not available for the specified time range.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TeacherID and UserTypeID = 2)
--         BEGIN
--             RAISERROR('Invalid TeacherID: no matching Employee found.', 16, 4);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;
--         IF EXISTS
--         (
--             SELECT 1
--             FROM V_EmployeeSchedule es
--             WHERE es.EmployeeID = @TeacherID
--               AND (
--                   (es.StartTime < @EndDate AND es.EndTime > @StartDate)
--               )
--         )
--         BEGIN
--             RAISERROR('Teacher is not available for the specified time range.', 16, 4);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @TranslatorID IS NOT NULL
--         BEGIN
--             IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TranslatorID and UserTypeID = 3)
--             BEGIN
--                 RAISERROR('Invalid TranslatorID: no matching Employee found.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             IF EXISTS
--             (
--                 SELECT 1
--                 FROM V_EmployeeSchedule es
--                 WHERE es.EmployeeID = @TranslatorID
--                   AND (
--                       (es.StartTime < @EndDate AND es.EndTime > @StartDate)
--                   )
--             )
--             BEGIN
--                 RAISERROR('Translator is not available for the specified time range.', 16, 6);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--         END;

--         IF @LanguageID IS NOT NULL
--         BEGIN
--             IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
--             BEGIN
--                 RAISERROR('Invalid LanguageID: no matching Language found.', 16, 7);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--         END;

--         IF @Duration < CAST('00:00:00' AS TIME)
--         BEGIN
--             RAISERROR('Duration cannot be negative.', 16, 9);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @StartDate < GETDATE()
--         BEGIN
--             RAISERROR('StartDate must be in the future.', 16, 10);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @GroupSize <= 0
--         BEGIN
--             RAISERROR('GroupSize must be greater than 0.', 16, 11);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @NextMeetingID INT;
--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting)
--         BEGIN
--             SET @NextMeetingID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextMeetingID = MAX(ClassMeetingID) + 1 FROM ClassMeeting;
--         END;

--         DECLARE @ServiceID INT;
--         SELECT @ServiceID = MAX(ServiceID) + 1 FROM Services;

--         INSERT INTO ClassMeeting
--             (ClassMeetingID, SubjectID, TeacherID, MeetingName,
--              TranslatorID, LanguageID, ServiceID, MeetingType)
--         VALUES
--             (
--                 @NextMeetingID,
--                 @SubjectID,
--                 @TeacherID,
--                 @MeetingName,
--                 @TranslatorID,
--                 @LanguageID,
--                 @ServiceID,
--                 'Stationary'
--             );

--         INSERT INTO StationaryClass
--             (MeetingID, RoomID, GroupSize, StartDate, Duration)
--         VALUES
--             (
--                 @NextMeetingID,
--                 @RoomID,
--                 @GroupSize,
--                 @StartDate,
--                 @Duration
--             );

--         INSERT INTO Services
--             (ServiceID, ServiceType)
--         VALUES
--             (@ServiceID, 'ClassMeetingService');
        
--         INSERT INTO ClassMeetingService
--             (ServiceID, PriceStudents, PriceOthers)
--         VALUES
--             (@ServiceID, @PriceStudents, @PriceOthers);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO

-- CREATE OR ALTER PROCEDURE p_CreateOnlineLiveClass
-- (
--     @SubjectID     INT,
--     @TeacherID     INT,
--     @MeetingName   VARCHAR(50),
--     @TranslatorID  INT = NULL,
--     @LanguageID    INT = NULL,
--     @Link          VARCHAR(50),
--     @StartDate     DATETIME,
--     @Duration      DATETIME,
--     @PriceStudents money,
--     @PriceOthers   money
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         DECLARE @EndDate DATETIME;
--         SET @EndDate = DATEADD(SECOND, DATEDIFF(SECOND, 0, @Duration), @StartDate);

--         IF NOT EXISTS
--         (
--             SELECT 1
--             FROM Convention c
--             WHERE c.SubjectID = @SubjectID
--               AND @StartDate >= c.StartDate
--               AND @EndDate <= DATEADD(MINUTE, DATEDIFF(MINUTE, 0, c.Duration), c.StartDate)
--         )
--         BEGIN
--             RAISERROR(
--                 'No matching Convention covers this SubjectID and time range.',
--                 16, 1
--             );
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TeacherID and UserTypeID = 2)
--         BEGIN
--             RAISERROR('Invalid TeacherID: no matching Employee found.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;
--         IF EXISTS
--         (
--             SELECT 1
--             FROM V_EmployeeSchedule es
--             WHERE es.EmployeeID = @TeacherID
--               AND (
--                   (es.StartTime < @EndDate AND es.EndTime > @StartDate)
--               )
--         )
--         BEGIN
--             RAISERROR('Teacher is not available for the specified time range.', 16, 4);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @TranslatorID IS NOT NULL
--         BEGIN
--             IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TranslatorID and UserTypeID = 3)
--             BEGIN
--                 RAISERROR('Invalid TranslatorID: no matching Employee found.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             IF EXISTS
--             (
--                 SELECT 1
--                 FROM V_EmployeeSchedule es
--                 WHERE es.EmployeeID = @TranslatorID
--                   AND (
--                       (es.StartTime < @EndDate AND es.EndTime > @StartDate)
--                   )
--             )
--             BEGIN
--                 RAISERROR('Translator is not available for the specified time range.', 16, 6);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--         END;

--         IF @LanguageID IS NOT NULL
--         BEGIN
--             IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
--             BEGIN
--                 RAISERROR('Invalid LanguageID: no matching Language found.', 16, 7);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--         END;

--         IF @Link = ''
--         BEGIN
--             RAISERROR('Link cannot be empty.', 16, 8);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Duration < 0
--         BEGIN
--             RAISERROR('Duration cannot be negative.', 16, 9);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @StartDate < GETDATE()
--         BEGIN
--             RAISERROR('StartDate must be in the future.', 16, 10);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @NextMeetingID INT;
--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting)
--         BEGIN
--             SET @NextMeetingID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextMeetingID = MAX(ClassMeetingID) + 1 FROM ClassMeeting;
--         END;

--         DECLARE @ServiceID INT;
--         SELECT @ServiceID = MAX(ServiceID) + 1 FROM Services;

--         INSERT INTO ClassMeeting
--             (ClassMeetingID, SubjectID, TeacherID, MeetingName,
--              TranslatorID, LanguageID, ServiceID, MeetingType)
--         VALUES
--             (
--                 @NextMeetingID,
--                 @SubjectID,
--                 @TeacherID,
--                 @MeetingName,
--                 @TranslatorID,
--                 @LanguageID,
--                 @ServiceID,
--                 'OnlineLiveClass'
--             );

--         INSERT INTO OnlineLiveClass
--             (MeetingID, Link, StartDate, Duration)
--         VALUES
--             (
--                 @NextMeetingID,
--                 @Link,
--                 @StartDate,
--                 @Duration
--             );

--         INSERT INTO Services
--             (ServiceID, ServiceType)
--         VALUES
--         (@ServiceID, 'ClassMeetingService');

--         INSERT INTO ClassMeetingService
--             (ServiceID, PriceStudents, PriceOthers)
--         VALUES
--             (@ServiceID, @PriceStudents, @PriceOthers);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO

-- CREATE OR ALTER PROCEDURE p_CreateOfflineVideoClass
-- (
--     @SubjectID   INT,
--     @TeacherID   INT,
--     @MeetingName VARCHAR(50),
--     @TranslatorID  INT = NULL,
--     @LanguageID    INT = NULL,
--     @VideoLink   VARCHAR(50),
--     @StartDate   DATETIME,
--     @Deadline    DATETIME,
--     @PriceStudents money,
--     @PriceOthers   money
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS
--         (
--             SELECT 1
--             FROM Convention c
--             WHERE c.SubjectID = @SubjectID
--               AND @StartDate >= c.StartDate
--               AND @Deadline <= DATEADD(MINUTE, DATEDIFF(MINUTE, 0, c.Duration), c.StartDate)
--         )
--         BEGIN
--             RAISERROR(
--                 'No matching Convention covers this SubjectID and time range.',
--                 16, 1
--             );
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TeacherID and UserTypeID = 2)
--         BEGIN
--             RAISERROR('Invalid TeacherID: no matching Employee found.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @TranslatorID IS NOT NULL
--         BEGIN
--             IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TranslatorID and UserTypeID = 3)
--             BEGIN
--                 RAISERROR('Invalid TranslatorID: no matching Employee found.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--         END;

--         IF @LanguageID IS NOT NULL
--         BEGIN
--             IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
--             BEGIN
--                 RAISERROR('Invalid LanguageID: no matching Language found.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--         END;

--         IF @VideoLink = ''
--         BEGIN
--             RAISERROR('VideoLink cannot be empty.', 16, 6);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @StartDate < GETDATE()
--         BEGIN
--             RAISERROR('StartDate must be in the future.', 16, 7);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Deadline < @StartDate
--         BEGIN
--             RAISERROR('Deadline must be after StartDate.', 16, 8);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @NextMeetingID INT;
--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting)
--         BEGIN
--             SET @NextMeetingID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextMeetingID = MAX(ClassMeetingID) + 1 FROM ClassMeeting;
--         END;

--         DECLARE @ServiceID INT;
--         SELECT @ServiceID = MAX(ServiceID) + 1 FROM Services;

--         INSERT INTO ClassMeeting
--             (ClassMeetingID, SubjectID, TeacherID, MeetingName,
--              TranslatorID, LanguageID, ServiceID, MeetingType)
--         VALUES
--             (
--                 @NextMeetingID,
--                 @SubjectID,
--                 @TeacherID,
--                 @MeetingName,
--                 @TranslatorID,
--                 @LanguageID,
--                 @ServiceID,
--                 'OfflineVideo'
--             );

--         INSERT INTO OfflineVideoClass
--             (MeetingID, VideoLink, StartDate, Deadline)
--         VALUES
--             (
--                 @NextMeetingID,
--                 @VideoLink,
--                 @StartDate,
--                 @Deadline
--             );
        
--         INSERT INTO Services
--             (ServiceID, ServiceType)
--         VALUES
--             (@ServiceID, 'ClassMeetingService');
        
--         INSERT INTO ClassMeetingService
--             (ServiceID, PriceStudents, PriceOthers)
--         VALUES
--             (@ServiceID, @PriceStudents, @PriceOthers);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
