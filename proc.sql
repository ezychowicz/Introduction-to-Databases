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

-- CREATE OR ALTER PROCEDURE p_ReserveRoom
-- (
--     @RoomID     INT,
--     @Date      DATE,
--     @StartTime TIME(0),
--     @EndTime   TIME(0)
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Rooms WHERE RoomID = @RoomID)
--         BEGIN
--             RAISERROR('Invalid RoomID: no matching Room found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Date < GETDATE()
--         BEGIN
--             RAISERROR('Date must be in the future.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @StartTime >= @EndTime
--         BEGIN
--             RAISERROR('StartTime must be before EndTime.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS
--         (
--             SELECT 1
--             FROM RoomScheduleOnDate rs
--             WHERE rs.RoomID = @RoomID
--               AND rs.ScheduleOnDate = @Date
--               AND (
--                   (rs.StartTime < @EndTime AND rs.EndTime > @StartTime) OR
--                   (rs.StartTime >= @StartTime AND rs.EndTime <= @EndTime)
--               )
--         )
--         BEGIN
--             RAISERROR('Room is not available for the specified time range.', 16, 4);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @NextSlotID INT;
--         IF NOT EXISTS (SELECT 1 FROM RoomScheduleOnDate)
--         BEGIN
--             SET @NextSlotID = 1;
--         END
--         ELSE
--         BEGIN
--             SELECT @NextSlotID = MAX(SlotID) + 1 FROM RoomScheduleOnDate;
--         END;
--         DECLARE @availability bit;
--         SET @availability = 0;
--         INSERT INTO RoomScheduleOnDate
--             (SlotID, RoomID, ScheduleOnDate, StartTime, EndTime, SlotAvailability)
--         VALUES
--             (@NextSlotID, @RoomID, @Date, @StartTime, @EndTime, @availability);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;

-- CREATE or Alter Procedure p_EditReservation
-- (
--     @SlotID INT,
--     @RoomID INT,
--     @Date DATE,
--     @StartTime TIME(0) = NULL,
--     @EndTime TIME(0) = NULL,
--     @Remove BIT = 0
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM RoomScheduleOnDate WHERE SlotID = @SlotID and RoomID = @RoomID and ScheduleOnDate = @Date)
--         BEGIN
--             RAISERROR('Invalid SlotID: no matching Slot found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @StartTime IS NOT NULL OR @EndTime IS NOT NULL
--         BEGIN
--             IF @StartTime is NULL
--             BEGIN
--                 SET @StartTime = (SELECT StartTime FROM RoomScheduleOnDate WHERE SlotID = @SlotID and RoomID = @RoomID and ScheduleOnDate = @Date);
--             END;
--             IF @EndTime is NULL
--             BEGIN
--                 SET @EndTime = (SELECT EndTime FROM RoomScheduleOnDate WHERE SlotID = @SlotID and RoomID = @RoomID and ScheduleOnDate = @Date);
--             END;
--             IF @StartTime >= @EndTime
--             BEGIN
--                 RAISERROR('StartTime must be before EndTime.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;

--             IF EXISTS
--             (
--                 SELECT 1
--                 FROM RoomScheduleOnDate rs
--                 WHERE rs.RoomID = @RoomID
--                   AND rs.ScheduleOnDate = @Date
--                   AND rs.SlotID <> @SlotID
--                   AND (
--                       (rs.StartTime < @EndTime AND rs.EndTime > @StartTime) OR
--                       (rs.StartTime >= @StartTime AND rs.EndTime <= @EndTime)
--                   )
--             )
--             BEGIN
--                 RAISERROR('Room is not available for the specified time range.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--         END;

--         IF @Remove = 1
--         BEGIN
--             DELETE FROM RoomScheduleOnDate
--             WHERE SlotID = @SlotID;
--         END
--         ELSE
--         BEGIN
--             UPDATE RoomScheduleOnDate
--             SET RoomID = @RoomID,
--                 ScheduleOnDate = @Date,
--                 StartTime = @StartTime,
--                 EndTime = @EndTime
--             WHERE SlotID = @SlotID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;
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
--          TODO: Enroll on all meetings assigned to this study

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
--             FROM RoomScheduleOnDate rs
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

-- CREATE OR ALTER PROCEDURE p_ChangeSubjectCoordinator
-- (
--     @SubjectID           INT,
--     @NewCoordinatorID    INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @NewCoordinatorID)
--         BEGIN
--             RAISERROR('Invalid NewCoordinatorID: no matching Employee found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;
--         Update Subject
--         Set SubjectCoordinatorID = @NewCoordinatorID
--         Where SubjectID = @SubjectID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_ChangeStudiesCoordinator
-- (
--     @StudiesID           INT,
--     @NewCoordinatorID    INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @NewCoordinatorID)
--         BEGIN
--             RAISERROR('Invalid NewCoordinatorID: no matching Employee found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: no matching Studies found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;
--         Update Studies
--         Set StudiesCoordinatorID = @NewCoordinatorID
--         Where StudiesID = @StudiesID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditStudies
-- (
--     @StudiesID INT,
--     @EnrollmentDeadline DATE = NULL,
--     @EnrollmentLimit INT = NULL,
--     @SemesterCnt INT = NULL,
--     @StudiesDescription VARCHAR(50) = NULL,
--     @ExpectedGraduationDate DATE = NULL,
--     @StudiesName VARCHAR(50) = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: no matching Studies found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @EnrollmentDeadline IS NOT NULL
--         BEGIN
--             IF @EnrollmentDeadline < GETDATE()
--             BEGIN
--                 RAISERROR('EnrollmentDeadline must be in the future.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Studies
--             SET EnrollmentDeadline = @EnrollmentDeadline
--             WHERE StudiesID = @StudiesID;
--         END;

--         IF @EnrollmentLimit IS NOT NULL
--         BEGIN
--             IF @EnrollmentLimit <= 0
--             BEGIN
--                 RAISERROR('EnrollmentLimit must be greater than 0.', 16, 3);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Studies
--             SET EnrollmentLimit = @EnrollmentLimit
--             WHERE StudiesID = @StudiesID;
--         END;

--         IF @SemesterCnt IS NOT NULL
--         BEGIN
--             IF @SemesterCnt < 2
--             BEGIN
--                 RAISERROR('SemesterCount must be at least 2.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Studies
--             SET SemesterCount = @SemesterCnt
--             WHERE StudiesID = @StudiesID;
--         END;

--         IF @StudiesDescription IS NOT NULL
--         BEGIN
--             IF @StudiesDescription = ''
--             BEGIN
--                 RAISERROR('StudiesDescription cannot be empty.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Studies
--             SET StudiesDescription = @StudiesDescription
--             WHERE StudiesID = @StudiesID;
--         END;

--         IF @ExpectedGraduationDate IS NOT NULL
--         BEGIN
--             IF @ExpectedGraduationDate < DATEADD(day, (Select SemesterCount from Studies where StudiesID = @StudiesID),GETDATE())
--             BEGIN
--                 RAISERROR('ExpectedGraduationDate must be in the future.', 16, 6);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Studies
--             SET ExpectedGraduationDate = @ExpectedGraduationDate
--             WHERE StudiesID = @StudiesID;
--         END;

--         IF @StudiesName IS NOT NULL
--         BEGIN
--             IF @StudiesName = ''
--             BEGIN
--                 RAISERROR('StudiesName cannot be empty.', 16, 7);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Studies
--             SET StudiesName = @StudiesName
--             WHERE StudiesID = @StudiesID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditSubject
-- (
--     @SubjectID INT,
--     @SubjectName VARCHAR(50) = NULL,
--     @SubjectDescription VARCHAR(50) = NULL,
--     @Meetings INT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @SubjectName IS NOT NULL
--         BEGIN
--             if @SubjectName = ''
--             BEGIN
--                 RAISERROR('SubjectName cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Subject
--             SET SubjectName = @SubjectName
--             WHERE SubjectID = @SubjectID;
--         END;

--         IF @SubjectDescription IS NOT NULL
--         BEGIN
--             if @SubjectDescription = ''
--             BEGIN
--                 RAISERROR('SubjectDescription cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Subject
--             SET SubjectDescription = @SubjectDescription
--             WHERE SubjectID = @SubjectID;
--         END;

--         IF @Meetings IS NOT NULL
--         BEGIN
--             IF @Meetings <= 0
--             BEGIN
--                 RAISERROR('Meetings must be positive.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Subject
--             SET Meetings = @Meetings
--             WHERE SubjectID = @SubjectID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_ChangeSubjectCoordinator
-- (
--     @SubjectID           INT,
--     @NewCoordinatorID    INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @NewCoordinatorID)
--         BEGIN
--             RAISERROR('Invalid NewCoordinatorID: no matching Employee found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;
--         Update Subject
--         Set SubjectCoordinatorID = @NewCoordinatorID
--         Where SubjectID = @SubjectID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

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

-- CREATE or alter procedure p_AddSubjectToStudies
-- (
--     @SubjectID INT,
--     @StudiesID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: no matching Studies found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (
--             SELECT 1
--             FROM SubjectStudiesAssignment
--             WHERE SubjectID = @SubjectID
--               AND StudiesID = @StudiesID
--         )
--         BEGIN
--             RAISERROR('Subject is already added to this Studies.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO SubjectStudiesAssignment
--             (SubjectID, StudiesID)
--         VALUES
--             (@SubjectID, @StudiesID);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_ChangeClassMeetingTeacher
-- (
--     @MeetingID INT,
--     @NewTeacherID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @NewTeacherID and UserTypeID = 2)
--         BEGIN
--             RAISERROR('Invalid NewTeacherID: no matching Employee found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         UPDATE ClassMeeting
--         SET TeacherID = @NewTeacherID
--         WHERE ClassMeetingID = @MeetingID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_ChangeClassMeetingTranslator
-- (
--     @MeetingID INT,
--     @NewTranslatorID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @NewTranslatorID and UserTypeID = 3)
--         BEGIN
--             RAISERROR('Invalid NewTranslatorID: no matching Employee found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         Declare @LanguageID INT;
--         SET @LanguageID = (Select LanguageID from ClassMeeting where ClassMeetingID = @MeetingID);
--         IF NOT EXISTS (SELECT 1 FROM TranslatorsLanguages WHERE LanguageID = @LanguageID and TranslatorID = @NewTranslatorID)
--         BEGIN
--             RAISERROR('Translator does not speak the required language.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         UPDATE ClassMeeting
--         SET TranslatorID = @NewTranslatorID
--         WHERE ClassMeetingID = @MeetingID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_ChangeClassMeetingLanguage
-- (
--     @MeetingID INT,
--     @NewLanguageID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @NewLanguageID)
--         BEGIN
--             RAISERROR('Invalid NewLanguageID: no matching Language found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         Declare @TranslatorID INT;
--         SET @TranslatorID = (Select TranslatorID from ClassMeeting where ClassMeetingID = @MeetingID);
--         IF NOT EXISTS (SELECT 1 FROM TranslatorsLanguages WHERE LanguageID = @NewLanguageID and TranslatorID = @TranslatorID)
--         BEGIN
--             RAISERROR('Translator does not speak the required language.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         UPDATE ClassMeeting
--         SET LanguageID = @NewLanguageID
--         WHERE ClassMeetingID = @MeetingID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditClassMeeting
-- (
--     @MeetingID INT,
--     @MeetingName VARCHAR(50) = NULL,
--     @MeetingType VARCHAR(50) = NULL,
--     @PriceStudents MONEY = NULL,
--     @PriceOthers MONEY = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @MeetingName IS NOT NULL
--         BEGIN
--             IF @MeetingName = ''
--             BEGIN
--                 RAISERROR('MeetingName cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE ClassMeeting
--             SET MeetingName = @MeetingName
--             WHERE ClassMeetingID = @MeetingID;
--         END;

--         IF @MeetingType IS NOT NULL
--         BEGIN
--             IF @MeetingType = ''
--             BEGIN
--                 RAISERROR('MeetingType cannot be empty.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE ClassMeeting
--             SET MeetingType = @MeetingType
--             WHERE ClassMeetingID = @MeetingID;
--         END;

--         IF @PriceStudents IS NOT NULL
--         BEGIN
--             IF @PriceStudents < 0
--             BEGIN
--                 RAISERROR('PriceStudents cannot be negative.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE ClassMeetingService
--             SET PriceStudents = @PriceStudents
--             WHERE ServiceID = (SELECT ServiceID FROM ClassMeeting WHERE ClassMeetingID = @MeetingID);
--         END;

--         IF @PriceOthers IS NOT NULL
--         BEGIN
--             IF @PriceOthers < 0
--             BEGIN
--                 RAISERROR('PriceOthers cannot be negative.', 16, 6);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE ClassMeetingService
--             SET PriceOthers = @PriceOthers
--             WHERE ServiceID = (SELECT ServiceID FROM ClassMeeting WHERE ClassMeetingID = @MeetingID);
--         END;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditStationaryClass
-- (
--     @MeetingID INT,
--     @RoomID INT = NULL,
--     @GroupSize INT = NULL,
--     @StartDate DATETIME = NULL,
--     @Duration DATETIME = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @RoomID IS NOT NULL
--         BEGIN
--             IF NOT EXISTS (SELECT 1 FROM Rooms WHERE RoomID = @RoomID)
--             BEGIN
--                 RAISERROR('Invalid RoomID: no matching Room found.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE StationaryClass
--             SET RoomID = @RoomID
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @GroupSize IS NOT NULL
--         BEGIN
--             IF @GroupSize <= 0
--             BEGIN
--                 RAISERROR('GroupSize must be greater than 0.', 16, 3);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;

--             DECLARE @RoomCapacity INT;
--             SET @RoomCapacity = (SELECT Capacity FROM Rooms WHERE RoomID = (SELECT RoomID FROM StationaryClass WHERE MeetingID = @MeetingID));

--             IF @GroupSize > @RoomCapacity
--             BEGIN
--                 RAISERROR('GroupSize cannot exceed Room capacity.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;

--             UPDATE StationaryClass
--             SET GroupSize = @GroupSize
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @StartDate IS NOT NULL
--         BEGIN
--             IF @StartDate < GETDATE()
--             BEGIN
--                 RAISERROR('StartDate must be in the future.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE StationaryClass
--             SET StartDate = @StartDate
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @Duration IS NOT NULL
--         BEGIN
--             IF CAST(@Duration AS TIME(0)) < CAST('00:00:00' AS TIME(0))
--             BEGIN
--                 RAISERROR('Duration cannot be negative.', 16, 6);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;

--             UPDATE StationaryClass
--             SET Duration = @Duration
--             WHERE MeetingID = @MeetingID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditOnlineLiveClass
-- (
--     @MeetingID INT,
--     @Link VARCHAR(50) = NULL,
--     @StartDate DATETIME = NULL,
--     @Duration DATETIME = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Link IS NOT NULL
--         BEGIN
--             IF @Link = ''
--             BEGIN
--                 RAISERROR('Link cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE OnlineLiveClass
--             SET Link = @Link
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @StartDate IS NOT NULL
--         BEGIN
--             IF @StartDate < GETDATE()
--             BEGIN
--                 RAISERROR('StartDate must be in the future.', 16, 3);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE OnlineLiveClass
--             SET StartDate = @StartDate
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @Duration IS NOT NULL
--         BEGIN
--             IF CAST(@Duration AS TIME(0)) < CAST('00:00:00' AS TIME(0))
--             BEGIN
--                 RAISERROR('Duration cannot be negative.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;

--             UPDATE OnlineLiveClass
--             SET Duration = @Duration
--             WHERE MeetingID = @MeetingID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditOfflineVideoClass
-- (
--     @MeetingID INT,
--     @VideoLink VARCHAR(50) = NULL,
--     @StartDate DATETIME = NULL,
--     @Deadline DATETIME = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @VideoLink IS NOT NULL
--         BEGIN
--             IF @VideoLink = ''
--             BEGIN
--                 RAISERROR('VideoLink cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE OfflineVideoClass
--             SET VideoLink = @VideoLink
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @StartDate IS NOT NULL
--         BEGIN
--             IF @StartDate < GETDATE()
--             BEGIN
--                 RAISERROR('StartDate must be in the future.', 16, 3);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE OfflineVideoClass
--             SET StartDate = @StartDate
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @Deadline IS NOT NULL
--         BEGIN
--             DECLARE @StartDt DATETIME;
--             SELECT @StartDt = StartDate FROM OfflineVideoClass WHERE MeetingID = @MeetingID;
--             IF @Deadline < @StartDt
--             BEGIN
--                 RAISERROR('Deadline must be after StartDate.', 16, 4);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;

--             UPDATE OfflineVideoClass
--             SET Deadline = @Deadline
--             WHERE MeetingID = @MeetingID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE or alter procedure p_DeleteUserClassMeetingDetails
-- (
--     @MeetingID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @MeetingType VARCHAR(50);
--         SET @MeetingType = (SELECT MeetingType FROM ClassMeeting WHERE ClassMeetingID = @MeetingID);

--         IF @MeetingType = 'Stationary' OR @MeetingType = 'OnlineLive'
--         BEGIN
--             DELETE FROM SyncClassDetails
--             WHERE MeetingID = @MeetingID;
--         END
--         ELSE IF @MeetingType = 'OfflineVideo'
--         BEGIN
--             DELETE FROM AsyncClassDetails
--             WHERE MeetingID = @MeetingID;
--         END
--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE or alter procedure p_DeleteClassMeetingDetails
-- (
--     @MeetingID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @MeetingType VARCHAR(50);
--         SET @MeetingType = (SELECT MeetingType FROM ClassMeeting WHERE ClassMeetingID = @MeetingID);

--         IF @MeetingType = 'Stationary'
--         BEGIN
--             DELETE FROM StationaryClass
--             WHERE MeetingID = @MeetingID;
--         END
--         ELSE IF @MeetingType = 'OnlineLive'
--         BEGIN
--             DELETE FROM OnlineLiveClass
--             WHERE MeetingID = @MeetingID;
--         END
--         ELSE IF @MeetingType = 'OfflineVideo'
--         BEGIN
--             DELETE FROM OfflineVideoClass
--             WHERE MeetingID = @MeetingID;
--         END

--         exec [dbo].p_DeleteUserClassMeetingDetails @MeetingID;

--         DELETE FROM ClassMeeting
--         WHERE ClassMeetingID = @MeetingID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- Create or alter PROCEDURE p_DeleteClassMeeting
-- (
--     @MeetingID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ClassMeeting WHERE ClassMeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching Meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @ServiceID INT;
--         SET @ServiceID = (SELECT ServiceID FROM ClassMeeting WHERE ClassMeetingID = @MeetingID);

--         DELETE FROM ClassMeetingService
--         WHERE ServiceID = @ServiceID;

--         DELETE FROM Services
--         WHERE ServiceID = @ServiceID;

--         DECLARE @MeetingType VARCHAR(50);
--         SET @MeetingType = (SELECT MeetingType FROM ClassMeeting WHERE ClassMeetingID = @MeetingID);

--         IF @MeetingType = 'Stationary'
--         BEGIN
--             DELETE FROM StationaryClass
--             WHERE MeetingID = @MeetingID;
--         END
--         ELSE IF @MeetingType = 'OnlineLive'
--         BEGIN
--             DELETE FROM OnlineLiveClass
--             WHERE MeetingID = @MeetingID;
--         END
--         ELSE IF @MeetingType = 'OfflineVideo'
--         BEGIN
--             DELETE FROM OfflineVideoClass
--             WHERE MeetingID = @MeetingID;
--         END

--         exec [dbo].p_DeleteClassMeetingDetails @MeetingID;

--         DELETE FROM ClassMeeting
--         WHERE ClassMeetingID = @MeetingID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_DeleteConvention
-- (
--     @ConventionID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Convention WHERE ConventionID = @ConventionID)
--         BEGIN
--             RAISERROR('Invalid ConventionID: no matching Convention found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @TargetSubject INT;
--         SET @TargetSubject = (SELECT SubjectID FROM Convention WHERE ConventionID = @ConventionID);
--         DECLARE @ConventionStartDate DATE, @ConventionEndDate DATE;
--         SET @ConventionStartDate = (SELECT StartDate FROM Convention WHERE ConventionID = @ConventionID);
--         SET @ConventionEndDate = DATEADD(DAY, (SELECT Duration FROM Convention WHERE ConventionID = @ConventionID), @ConventionStartDate);

--         DECLARE @MeetingID INT;
--         DECLARE OfflineCursor CURSOR FOR
--         SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID = @TargetSubject
--         AND MeetingType = 'OfflineVideo'
--         AND ClassMeetingID IN (
--             SELECT MeetingID
--             FROM OfflineVideoClass
--             WHERE Deadline >= @ConventionStartDate AND Deadline <= @ConventionEndDate
--         );

--         OPEN OfflineCursor;
--         FETCH NEXT FROM OfflineCursor INTO @MeetingID;
--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             EXEC [dbo].p_DeleteClassMeeting @MeetingID;
--             FETCH NEXT FROM OfflineCursor INTO @MeetingID;
--         END;
--         CLOSE OfflineCursor;
--         DEALLOCATE OfflineCursor;

--         DECLARE OnlineCursor CURSOR FOR
--         SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID = @TargetSubject
--         AND MeetingType = 'OnlineLive'
--         AND ClassMeetingID IN (
--             SELECT MeetingID
--             FROM OnlineLiveClass
--             WHERE StartDate >= @ConventionStartDate AND StartDate <= @ConventionEndDate
--         );

--         OPEN OnlineCursor;
--         FETCH NEXT FROM OnlineCursor INTO @MeetingID;
--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             EXEC [dbo].p_DeleteClassMeeting @MeetingID;
--             FETCH NEXT FROM OnlineCursor INTO @MeetingID;
--         END;
--         CLOSE OnlineCursor;
--         DEALLOCATE OnlineCursor;

--         DECLARE StationaryCursor CURSOR FOR
--         SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID = @TargetSubject
--         AND MeetingType = 'Stationary'
--         AND ClassMeetingID IN (
--             SELECT MeetingID
--             FROM StationaryClass
--             WHERE StartDate >= @ConventionStartDate AND StartDate <= @ConventionEndDate
--         );

--         OPEN StationaryCursor;
--         FETCH NEXT FROM StationaryCursor INTO @MeetingID;
--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             EXEC [dbo].p_DeleteClassMeeting @MeetingID;
--             FETCH NEXT FROM StationaryCursor INTO @MeetingID;
--         END;
--         CLOSE StationaryCursor;
--         DEALLOCATE StationaryCursor;
--         DELETE FROM Convention
--         WHERE ConventionID = @ConventionID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- Create or alter procedure p_DeleteSubjectFromStudies
-- (
--     @SubjectID INT,
--     @StudiesID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: no matching Studies found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (
--             SELECT 1
--             FROM SubjectStudiesAssignment
--             WHERE SubjectID = @SubjectID
--               AND StudiesID = @StudiesID
--         )
--         BEGIN
--             RAISERROR('Subject is not added to this Studies.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM SubjectStudiesAssignment
--         WHERE SubjectID = @SubjectID
--           AND StudiesID = @StudiesID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_DeleteSubject
-- (
--     @SubjectID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @SubjectID)
--         BEGIN
--             RAISERROR('Invalid SubjectID: no matching Subject found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM Subject
--         WHERE SubjectID = @SubjectID;

--         DECLARE @ConventionID INT;
--         DECLARE ConventionCursor CURSOR FOR
--         SELECT ConventionID
--         FROM Convention
--         WHERE SubjectID = @SubjectID;

--         OPEN ConventionCursor;
--         FETCH NEXT FROM ConventionCursor INTO @ConventionID;
--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             EXEC [dbo].p_DeleteConvention @ConventionID;
--             FETCH NEXT FROM ConventionCursor INTO @ConventionID;
--         END;
--         CLOSE ConventionCursor;
--         DEALLOCATE ConventionCursor;

--         DELETE FROM SubjectStudiesAssignment
--         WHERE SubjectID = @SubjectID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_CreateInternship
-- (
--     @InternshipID INT,
--     @StudiesID INT,
--     @StartDate DATE
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: no matching Studies found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @StartDate < GETDATE()
--         BEGIN
--             RAISERROR('StartDate must be in the future.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

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
--             (@NextInternshipID, @StudiesID, @StartDate);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditInternship
-- (
--     @InternshipID INT,
--     @StartDate DATE = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Internship WHERE InternshipID = @InternshipID)
--         BEGIN
--             RAISERROR('Invalid InternshipID: no matching Internship found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @StartDate IS NOT NULL
--         BEGIN
--             IF @StartDate < GETDATE()
--             BEGIN
--                 RAISERROR('StartDate must be in the future.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Internship
--             SET StartDate = @StartDate
--             WHERE InternshipID = @InternshipID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- Create or alter procedure p_AddStudentInternship
-- (
--     @InternshipID INT,
--     @StudiesID INT,
--     @StudentID INT,
--     @Duration INT = 14,
--     @InternshipGrade INT = 0,
--     @InternshipAttendance bit = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Internship WHERE InternshipID = @InternshipID)
--         BEGIN
--             RAISERROR('Invalid InternshipID: no matching Internship found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID and UserTypeID = 1)
--         BEGIN
--             RAISERROR('Invalid StudentID: no matching Student found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM StudiesDetails WHERE StudiesID = @StudiesID and StudentID = @StudentID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: no matching Studies found for this student.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (
--             SELECT 1
--             FROM InternshipDetails
--             WHERE InternshipID = @InternshipID
--               AND StudentID = @StudentID
--         )

--         BEGIN
--             RAISERROR('Student is already added to this Internship.', 16, 4);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Duration < 0
--         BEGIN
--             RAISERROR('Duration cannot be negative.', 16, 5);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @InternshipGrade NOT in (-1, 0, 1)
--         BEGIN
--             RAISERROR('Invalid InternshipGrade: no matching Grade found.', 16, 6);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO InternshipDetails
--             (InternshipID, StudentID, Duration, InternshipGrade, InternshipAttendance)
--         VALUES
--             (@InternshipID, @StudentID, @Duration, @InternshipGrade, @InternshipAttendance);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- Create or alter procedure p_InitiateInternship
-- (
--     @InternshipID INT,
--     @StudiesID INT,
--     @Duration INT = 14,
--     @InternshipGrade INT = 0,
--     @InternshipAttendance bit = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Internship WHERE InternshipID = @InternshipID)
--         BEGIN
--             RAISERROR('Invalid InternshipID: no matching Internship found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--         BEGIN
--             RAISERROR('Invalid StudiesID: no matching Studies found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DECLARE @StudentID INT;
--         DECLARE StudentCursor CURSOR FOR
--         SELECT StudentID
--         FROM StudiesDetails
--         WHERE StudiesID = @StudiesID;

--         OPEN StudentCursor;
--         FETCH NEXT FROM StudentCursor INTO @StudentID;
--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             IF NOT EXISTS (
--                 SELECT 1
--                 FROM InternshipDetails
--                 WHERE InternshipID = @InternshipID
--                   AND StudentID = @StudentID
--             )
--             BEGIN
--                 INSERT INTO InternshipDetails
--                     (InternshipID, StudentID, Duration, InternshipGrade, InternshipAttendance)
--                 VALUES
--                     (@InternshipID, @StudentID, @Duration, @InternshipGrade, @InternshipAttendance);
--             END;
--             FETCH NEXT FROM StudentCursor INTO @StudentID;
--         END;
--         CLOSE StudentCursor;
--         DEALLOCATE StudentCursor;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- Create or Alter Procedure p_DeleteInternship
-- (
--     @InternshipID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Internship WHERE InternshipID = @InternshipID)
--         BEGIN
--             RAISERROR('Invalid InternshipID: no matching Internship found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM InternshipDetails
--         WHERE InternshipID = @InternshipID;

--         DELETE FROM Internship
--         WHERE InternshipID = @InternshipID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_DeleteInternshipDetails
-- (
--     @InternshipID INT,
--     @StudentID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Internship WHERE InternshipID = @InternshipID)
--         BEGIN
--             RAISERROR('Invalid InternshipID: no matching Internship found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID and UserTypeID = 1)
--         BEGIN
--             RAISERROR('Invalid StudentID: no matching Student found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (
--             SELECT 1
--             FROM InternshipDetails
--             WHERE InternshipID = @InternshipID
--               AND StudentID = @StudentID
--         )
--         BEGIN
--             RAISERROR('Student is not added to this Internship.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM InternshipDetails
--         WHERE InternshipID = @InternshipID
--           AND StudentID = @StudentID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_CreateGrade
-- (
--     @GradeID INT,
--     @GradeName VARCHAR(50),
--     @GradeValue INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF @GradeValue < 0
--         BEGIN
--             RAISERROR('GradeValue cannot be negative.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (SELECT 1 FROM Grades WHERE GradeID = @GradeID)
--         BEGIN
--             RAISERROR('GradeID already exists.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO Grades
--             (GradeID, GradeName, GradeValue)
--         VALUES
--             (@GradeID, @GradeName, @GradeValue);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditGrade
-- (
--     @GradeID INT,
--     @GradeName VARCHAR(50) = NULL,
--     @GradeValue INT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Grades WHERE GradeID = @GradeID)
--         BEGIN
--             RAISERROR('Invalid GradeID: no matching Grade found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @GradeName IS NOT NULL
--         BEGIN
--             IF @GradeName = ''
--             BEGIN
--                 RAISERROR('GradeName cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Grades
--             SET GradeName = @GradeName
--             WHERE GradeID = @GradeID;
--         END;

--         IF @GradeValue IS NOT NULL
--         BEGIN
--             IF @GradeValue < 0
--             BEGIN
--                 RAISERROR('GradeValue cannot be negative.', 16, 3);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Grades
--             SET GradeValue = @GradeValue
--             WHERE GradeID = @GradeID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_DeleteGrade
-- (
--     @GradeID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Grades WHERE GradeID = @GradeID)
--         BEGIN
--             RAISERROR('Invalid GradeID: no matching Grade found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM Grades
--         WHERE GradeID = @GradeID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;


-- Create or alter FUNCTION p_CalculateSubjectAttendance
-- (
--     @SubjectID INT,
--     @StudentID INT
-- )
-- returns FLOAT
-- AS
-- BEGIN
--     DECLARE @TotalClasses INT;
--     DECLARE @AttendedClasses INT;
--     DECLARE @Attendance FLOAT;

--     SET @TotalClasses = (SELECT COUNT(*)
--     FROM SyncClassDetails
--     WHERE MeetingID IN (SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID = @SubjectID) AND StudentID = @StudentID);
--     SET @AttendedClasses = (SELECT COUNT(*)
--     FROM SyncClassDetails
--     WHERE Attendance = 1 and MeetingID IN (SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID = @SubjectID) AND StudentID = @StudentID);

--     IF @TotalClasses = 0
--     BEGIN
--         SET @Attendance = 0;
--     END
--     ELSE
--     BEGIN
--         SET @Attendance = (@AttendedClasses * 100.0) / @TotalClasses;
--     END

--     RETURN @Attendance;
-- END;

-- Create or alter FUNCTION p_CalculateStudiesAttendance
-- (
--     @StudiesID INT,
--     @StudentID INT
-- )
-- returns FLOAT
-- AS
-- BEGIN
--     DECLARE @TotalClasses INT;
--     DECLARE @AttendedClasses INT;
--     DECLARE @Attendance FLOAT;

--     IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
--     BEGIN
--         RETURN 0.0;
--     END;

--     IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID and UserTypeID = 1)
--     BEGIN
--         RETURN 0.0;
--     END;

--     IF NOT EXISTS (SELECT 1 FROM StudiesDetails WHERE StudiesID = @StudiesID and StudentID = @StudentID)
--     BEGIN
--         RETURN 0.0;
--     END;

--     SET @TotalClasses = (SELECT COUNT(*)
--     FROM SyncClassDetails
--     WHERE MeetingID IN (SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID IN (SELECT SubjectID
--             FROM SubjectStudiesAssignment
--             WHERE StudiesID = @StudiesID)) AND StudentID = @StudentID);
--     SET @AttendedClasses = (SELECT COUNT(*)
--     FROM SyncClassDetails
--     WHERE Attendance = 1 and MeetingID IN (SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID IN (SELECT SubjectID
--             FROM SubjectStudiesAssignment
--             WHERE StudiesID = @StudiesID)) AND StudentID = @StudentID);

--     IF @TotalClasses = 0
--     BEGIN
--         SET @Attendance = 0;
--     END
--     ELSE
--     BEGIN
--         SET @Attendance = (@AttendedClasses * 100.0) / @TotalClasses;
--     END

--     RETURN @Attendance;
-- END;

-- use u_szymocha
-- SELECT dbo.p_CalculateStudiesAttendance(1, 4) AS AttendancePercentage;

-- Create or alter function p_CalculateInternshipCompletion
-- (
--     @InternshipID INT,
--     @StudiesID INT
-- )
-- returns FLOAT
-- AS
-- BEGIN
--     DECLARE @TotalStudents INT;
--     DECLARE @CompletedStudents INT;
--     DECLARE @Completion FLOAT;

--     SET @TotalStudents = (SELECT COUNT(*)
--     FROM InternshipDetails
--     WHERE InternshipID = @InternshipID);
--     SET @CompletedStudents = (SELECT COUNT(*)
--     FROM InternshipDetails
--     WHERE InternshipAttendance = 1 and InternshipID = @InternshipID);

--     IF @TotalStudents = 0
--     BEGIN
--         SET @Completion = 0;
--     END
--     ELSE
--     BEGIN
--         SET @Completion = (@CompletedStudents * 100.0) / @TotalStudents;
--     END

--     RETURN @Completion;
-- END;

-- Create or alter function p_CalculateAverageNumberOfPeopleInClass
-- (
--     @StudiesID INT
-- )
-- returns FLOAT
-- AS
-- BEGIN
--     DECLARE @TotalClasses INT;
--     DECLARE @TotalStudents INT;
--     DECLARE @Average FLOAT;

--     SET @TotalClasses = (SELECT COUNT(*)
--     FROM ClassMeeting
--     WHERE MeetingType in ('Stationary', 'OnlineLive') and SubjectID IN (SELECT SubjectID
--             FROM SubjectStudiesAssignment
--             WHERE StudiesID = @StudiesID));
--     SET @TotalStudents = (SELECT COUNT(*)
--     FROM SyncClassDetails
--     WHERE Attendance = 1 and MeetingID IN (SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID IN (SELECT SubjectID
--             FROM SubjectStudiesAssignment
--             WHERE StudiesID = @StudiesID)));

--     IF @TotalClasses = 0
--     BEGIN
--         SET @Average = 0;
--     END
--     ELSE
--     BEGIN
--         SET @Average = @TotalStudents / @TotalClasses;
--     END

--     RETURN @Average;
-- END;

-- CREATE or ALTER FUNCTION p_CalculateMINRoomCapacity
-- (
--     @StudiesID INT
-- )
-- RETURNS INT
-- AS
-- BEGIN
--     DECLARE @MINCapacity INT;

--     SET @MINCapacity = (SELECT MIN(Capacity)
--     FROM Rooms
--     where RoomID in (Select RoomID
--     from StationaryClass
--     WHERE MeetingID IN (SELECT ClassMeetingID
--     FROM ClassMeeting
--     where SubjectID IN (SELECT SubjectID
--     from SubjectStudiesAssignment
--     WHERE StudiesID = @StudiesID))));
--     RETURN @MINCapacity;
-- END;

-- Select dbo.p_CalculateMINRoomCapacity(1) as MINRoomCapacity;
