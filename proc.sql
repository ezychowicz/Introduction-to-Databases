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
CREATE OR ALTER PROCEDURE p_CreateStudies
(
    @StudiesName         VARCHAR(200),
    @StudiesDescription  VARCHAR(1000),
    @CoordinatorID       INT,
    @EnrollmentLimit     INT,
    @EnrollmentDeadline  DATE,
    @SemesterCount       INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @CoordinatorID)
        BEGIN
            RAISERROR('Invalid CoordinatorID: no matching Employee found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF @SemesterCount < 2
        BEGIN
            RAISERROR('SemesterCount must be at least 2.', 16, 2);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF @EnrollmentLimit <= 0
        BEGIN
            RAISERROR('EnrollmentLimit must be greater than 0.', 16, 3);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF @EnrollmentDeadline < GETDATE()
        BEGIN
            RAISERROR('EnrollmentDeadline must be in the future.', 16, 4);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        DECLARE @NextStudiesID INT;

        IF NOT EXISTS (SELECT 1 FROM Studies)
        BEGIN
            SET @NextStudiesID = 1;
        END
        ELSE
        BEGIN
            SELECT @NextStudiesID = MAX(StudiesID) + 1 FROM Studies;
        END;

        DECLARE @GraduationDate DATE;
        SET @GraduationDate = DATEADD(DAY, 150 * @SemesterCount, @EnrollmentDeadline);

        DECLARE @NextServiceID INT;
        IF NOT EXISTS (SELECT 1 FROM Services)
        BEGIN
            SET @NextServiceID = 1;
        END
        ELSE
        BEGIN
            SELECT @NextServiceID = MAX(ServiceID) + 1 FROM Services;
        END;

        INSERT INTO Studies
            (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID,
             EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate, ServiceID)
        VALUES
            (
                @NextStudiesID,
                @StudiesName,
                @StudiesDescription,
                @CoordinatorID,
                @EnrollmentLimit,
                @EnrollmentDeadline,
                @SemesterCount,
                @GraduationDate,
                @NextServiceID
            );

        DECLARE @SemesterIndex INT = 1;
        DECLARE @StartDate     DATE = DATEADD(DAY, 1, @EnrollmentDeadline);
        DECLARE @EndDate       DATE;
        DECLARE @InternshipStart DATE = NULL;

        DECLARE @NextSemesterID INT;

        IF NOT EXISTS (SELECT 1 FROM SemesterDetails)
        BEGIN
            SET @NextSemesterID = 1;
        END
        ELSE
        BEGIN
            SELECT @NextSemesterID = MAX(SemesterID) + 1 FROM SemesterDetails;
        END;

        WHILE @SemesterIndex <= @SemesterCount
        BEGIN
            SET @EndDate = DATEADD(DAY, 120, @StartDate);

            INSERT INTO SemesterDetails
                (SemesterID, StudiesID, StartDate, EndDate)
            VALUES
                (
                    @NextSemesterID,
                    @NextStudiesID,
                    @StartDate,
                    @EndDate
                );

            IF @SemesterIndex = @SemesterCount - 1
            BEGIN
                SET @InternshipStart = @StartDate;
            END;

            SET @SemesterIndex += 1;
            SET @NextSemesterID += 1;

            IF @SemesterIndex <= @SemesterCount
            BEGIN
                SET @StartDate = DATEADD(DAY, 30 , @EndDate);
            END;
        END;

        UPDATE Studies
            SET ExpectedGraduationDate = @EndDate
        WHERE StudiesID = @NextStudiesID;

        DECLARE @NextInternshipID INT;
        IF NOT EXISTS (SELECT 1 FROM Internship)
        BEGIN
            SET @NextInternshipID = 1;
        END
        ELSE
        BEGIN
            SELECT @NextInternshipID = MAX(InternshipID) + 1 FROM Internship;
        END;

        INSERT INTO Internship
            (InternshipID, StudiesID, StartDate)
        VALUES
            (
                @NextInternshipID,
                @NextStudiesID,
                @InternshipStart
            );

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


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
--     @PriceStudents MONEY,
--     @PriceOthers   MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         DECLARE @DurationSeconds INT;
--         SET @DurationSeconds = DATEDIFF(SECOND, '00:00:00', CAST(@Duration AS DATETIME));

--         DECLARE @EndDate DATETIME;
--         SET @EndDate = DATEADD(SECOND, @DurationSeconds, @StartDate);

--         IF NOT EXISTS
--         (
--             SELECT 1
--             FROM Convention c
--             WHERE c.SubjectID = @SubjectID
--               AND @StartDate >= CAST(c.StartDate AS DATETIME)
--               AND @EndDate <= DATEADD(DAY, ISNULL(c.Duration, 0), CAST(c.StartDate AS DATETIME))
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
--                   (rs.StartTime < CONVERT(TIME(0), @EndDate) AND rs.EndTime >= CONVERT(TIME(0), @EndDate))
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

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TeacherID AND UserTypeID = 2)
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
--             IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TranslatorID AND UserTypeID = 3)
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
--     @Duration      TIME(0),
--     @PriceStudents MONEY,
--     @PriceOthers   MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         DECLARE @DurationSeconds INT;
--         SET @DurationSeconds = DATEDIFF(SECOND, '00:00:00', CAST(@Duration AS DATETIME));

--         DECLARE @EndDate DATETIME;
--         SET @EndDate = DATEADD(SECOND, @DurationSeconds, @StartDate);

--         IF NOT EXISTS
--         (
--             SELECT 1
--             FROM Convention c
--             WHERE c.SubjectID = @SubjectID
--               AND @StartDate >= CAST(c.StartDate AS DATETIME)
--               AND @EndDate <= DATEADD(DAY, ISNULL(c.Duration, 0), CAST(c.StartDate AS DATETIME))
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

--         IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TeacherID AND UserTypeID = 2)
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
--             IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @TranslatorID AND UserTypeID = 3)
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
--               AND @Deadline <= DATEADD(DAY, ISNULL(c.Duration, 0), CAST(c.StartDate AS DATETIME))
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
--     (
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

--         IF NOT EXISTS (SELECT 1
--     FROM SemesterDetails
--     WHERE SemesterID = @SemesterID)
--         BEGIN
--         RAISERROR('Invalid SemesterID: no matching semester.', 16, 1);
--         ROLLBACK TRANSACTION;
--         RETURN;
--     END;

--         IF NOT EXISTS (SELECT 1
--     FROM Subject
--     WHERE SubjectID = @SubjectID)
--         BEGIN
--         RAISERROR('Invalid SubjectID: no matching subject.', 16, 2);
--         ROLLBACK TRANSACTION;
--         RETURN;
--     END;

--         IF @Duration < 0
--         BEGIN
--         RAISERROR('Duration cannot be negative.', 16, 3);
--         ROLLBACK TRANSACTION;
--         RETURN;
--     END;

--         DECLARE @SemStart DATE, @SemEnd DATE;
--         SELECT @SemStart = StartDate,
--         @SemEnd   = EndDate
--     FROM SemesterDetails
--     WHERE SemesterID = @SemesterID;

--         IF @ConventionDate < @SemStart OR DATEADD(DAY, @Duration, @ConventionDate) > @SemEnd
--         BEGIN
--         RAISERROR(
--                 'Convention date must fall within the semester start/end dates.',
--                 16, 4
--             );
--         ROLLBACK TRANSACTION;
--         RETURN;
--     END;

--         DECLARE @NextConventionID INT;
--         IF NOT EXISTS (SELECT 1
--     FROM Convention)
--         BEGIN
--         SET @NextConventionID = 1;
--     END
--         ELSE
--         BEGIN
--         SELECT @NextConventionID = MAX(ConventionID) + 1
--         FROM Convention;
--     END;

--         DECLARE @NextServiceID INT;
--         IF NOT EXISTS (SELECT 1
--     FROM Services)
--         BEGIN
--         SET @NextServiceID = 1;
--     END
--         ELSE
--         BEGIN
--         SELECT @NextServiceID = MAX(ServiceID) + 1
--         FROM Services;
--     END;

--         INSERT INTO Convention
--         (ConventionID, SubjectID, StartDate, SemesterID, Duration, ServiceID)
--     VALUES
--         (@NextConventionID, @SubjectID, @ConventionDate, @SemesterID, @Duration, @NextServiceID);

--         INSERT INTO Services
--         (ServiceID, ServiceType)
--     VALUES
--         (@NextServiceID, 'ConventionService');
        
--         INSERT INTO ConventionService
--         (ServiceID, Price)
--     VALUES
--         (@NextServiceID, 0);


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
--         ELSE IF @MeetingType LIKE '%Online%'
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
--         AND MeetingType LIKE '%Online%'
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

--         DECLARE @MeetingID INT;
--         DECLARE MeetingCursor CURSOR FOR
--         SELECT ClassMeetingID
--         FROM ClassMeeting
--         WHERE SubjectID = @SubjectID;

--         OPEN MeetingCursor;
--         FETCH NEXT FROM MeetingCursor INTO @MeetingID;
--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             EXEC [dbo].p_DeleteClassMeeting @MeetingID;
--             FETCH NEXT FROM MeetingCursor INTO @MeetingID;
--         END;

--         CLOSE MeetingCursor;
--         DEALLOCATE MeetingCursor;

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






































-- EMIL=============================================================================
-- CREATE OR ALTER PROCEDURE p_EditClassMeetingService
-- (
--     @ServiceID INT,
--     @PriceStudents MONEY = NULL,  -- Domyślnie NULL
--     @PriceOthers MONEY = NULL     -- Domyślnie NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

       
--         IF NOT EXISTS (SELECT 1 FROM ClassMeetingService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in ClassMeetingService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

        
--         IF @PriceStudents IS NOT NULL AND @PriceStudents <= 0
--         BEGIN
--             RAISERROR('PriceStudents must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @PriceOthers IS NOT NULL AND @PriceOthers <= 0
--         BEGIN
--             RAISERROR('PriceOthers must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

       
--         UPDATE ClassMeetingService
--         SET 
--             PriceStudents = CASE WHEN @PriceStudents IS NOT NULL THEN @PriceStudents ELSE PriceStudents END,
--             PriceOthers = CASE WHEN @PriceOthers IS NOT NULL THEN @PriceOthers ELSE PriceOthers END
--         WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditConventionService
-- (
--     @ServiceID INT,
--     @Price MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;


--         IF NOT EXISTS (SELECT 1 FROM ConventionService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in ConventionService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

 
--         IF @Price <= 0
--         BEGIN
--             RAISERROR('Price must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

     
--         UPDATE ConventionService
--         SET Price = @Price
--         WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditCourses
-- (
--     @CourseID INT,
--     @CourseName VARCHAR(40) = NULL,
--     @CourseDescription VARCHAR(255) = NULL,
--     @CourseCoordinatorID INT = NULL,
--     @CourseDate DATE = NULL,
--     @EnrollmentLimit INT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

      
--         IF NOT EXISTS (SELECT 1 FROM Courses WHERE CourseID = @CourseID)
--         BEGIN
--             RAISERROR('Invalid CourseID: no matching course found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

      
--         IF @CourseName IS NOT NULL
--         BEGIN
--             IF @CourseName = ''
--             BEGIN
--                 RAISERROR('CourseName cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Courses
--             SET CourseName = @CourseName
--             WHERE CourseID = @CourseID;
--         END;


--         IF @CourseDescription IS NOT NULL
--         BEGIN
--             UPDATE Courses
--             SET CourseDescription = @CourseDescription
--             WHERE CourseID = @CourseID;
--         END;


--         IF @CourseCoordinatorID IS NOT NULL
--         BEGIN
--             IF @CourseCoordinatorID <= 0
--             BEGIN
--                 RAISERROR('Invalid CourseCoordinatorID: must be greater than 0.', 16, 3);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Courses
--             SET CourseCoordinatorID = @CourseCoordinatorID
--             WHERE CourseID = @CourseID;
--         END;


--         IF @CourseDate IS NOT NULL
--         BEGIN
--             IF @CourseDate <= '2015-01-01' OR @CourseDate >= '2030-01-01'
--             BEGIN
--                 RAISERROR('CourseDate must be between 01-01-2015 and 01-01-2030.', 16, 5);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Courses
--             SET CourseDate = @CourseDate
--             WHERE CourseID = @CourseID;
--         END;

 
--         IF @EnrollmentLimit IS NOT NULL
--         BEGIN
--             IF @EnrollmentLimit <= 1
--             BEGIN
--                 RAISERROR('EnrollmentLimit must be greater than 1.', 16, 6);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Courses
--             SET EnrollmentLimit = @EnrollmentLimit
--             WHERE CourseID = @CourseID;
--         END;

     
--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditCourseService
-- (
--     @ServiceID INT,
--     @AdvanceValue MONEY = NULL,  -- Domyślnie NULL
--     @FullPrice MONEY = NULL      -- Domyślnie NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM CourseService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in CourseService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

     
--         IF @AdvanceValue IS NOT NULL AND @AdvanceValue <= 0
--         BEGIN
--             RAISERROR('AdvanceValue must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @FullPrice IS NOT NULL AND @FullPrice < @AdvanceValue
--         BEGIN
--             RAISERROR('FullPrice must be greater than or equal to AdvanceValue.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

       
--         UPDATE CourseService
--         SET 
--             AdvanceValue = CASE WHEN @AdvanceValue IS NOT NULL THEN @AdvanceValue ELSE AdvanceValue END,
--             FullPrice = CASE WHEN @FullPrice IS NOT NULL THEN @FullPrice ELSE FullPrice END
--         WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditModules
-- (
--     @ModuleID INT,
--     @LanguageID INT = NULL,
--     @CourseID INT = NULL,
--     @TranslatorID INT = NULL,
--     @ModuleCoordinatorID INT = NULL,
--     @ModuleType VARCHAR(30) = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Modules WHERE ModuleID = @ModuleID)
--         BEGIN
--             RAISERROR('Invalid ModuleID: no matching module found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @LanguageID IS NOT NULL
--         BEGIN
--             UPDATE Modules
--             SET LanguageID = @LanguageID
--             WHERE ModuleID = @ModuleID;
--         END;

--         IF @CourseID IS NOT NULL
--         BEGIN
--             UPDATE Modules
--             SET CourseID = @CourseID
--             WHERE ModuleID = @ModuleID;
--         END;

--         IF @TranslatorID IS NOT NULL
--         BEGIN
--             UPDATE Modules
--             SET TranslatorID = @TranslatorID
--             WHERE ModuleID = @ModuleID;
--         END;

--         IF @ModuleCoordinatorID IS NOT NULL
--         BEGIN
--             UPDATE Modules
--             SET ModuleCoordinatorID = @ModuleCoordinatorID
--             WHERE ModuleID = @ModuleID;
--         END;

--         IF @ModuleType IS NOT NULL
--         BEGIN
--             IF @ModuleType = ''
--             BEGIN
--                 RAISERROR('ModuleType cannot be empty.', 16, 2);
--                 ROLLBACK TRANSACTION;
--                 RETURN;
--             END;
--             UPDATE Modules
--             SET ModuleType = @ModuleType
--             WHERE ModuleID = @ModuleID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditOfflineVideo
-- (
--     @MeetingID INT,
--     @VideoLink VARCHAR(60) = NULL,
--     @VideoDuration TIME(0) = NULL,
--     @TeacherID INT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM OfflineVideo WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching offline video found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @VideoLink IS NOT NULL
--         BEGIN
--             UPDATE OfflineVideo
--             SET VideoLink = @VideoLink
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @VideoDuration IS NOT NULL
--         BEGIN
--             UPDATE OfflineVideo
--             SET VideoDuration = @VideoDuration
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @TeacherID IS NOT NULL
--         BEGIN
--             UPDATE OfflineVideo
--             SET TeacherID = @TeacherID
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
-- CREATE OR ALTER PROCEDURE p_EditOfflineVideoDateOfViewing
-- (
--     @MeetingID INT,
--     @ParticipantID INT,
--     @DateOfViewing DATE 
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM OfflineVideoDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid MeetingID or ParticipantID: no matching record found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

       
--         UPDATE OfflineVideoDetails
--         SET DateOfViewing = @DateOfViewing
--         WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID;
       

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditOnlineLiveMeeting
-- (
--     @MeetingID INT,
--     @PlatformName VARCHAR(20) = NULL,
--     @Link VARCHAR(60) = NULL,
--     @VideoLink VARCHAR(60) = NULL,
--     @MeetingDate DATETIME = NULL,
--     @MeetingDuration TIME(0) = NULL,
--     @TeacherID INT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM OnlineLiveMeeting WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching online live meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @PlatformName IS NOT NULL
--         BEGIN
--             UPDATE OnlineLiveMeeting
--             SET PlatformName = @PlatformName
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @Link IS NOT NULL
--         BEGIN
--             UPDATE OnlineLiveMeeting
--             SET Link = @Link
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @VideoLink IS NOT NULL
--         BEGIN
--             UPDATE OnlineLiveMeeting
--             SET VideoLink = @VideoLink
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @MeetingDate IS NOT NULL
--         BEGIN
--             UPDATE OnlineLiveMeeting
--             SET MeetingDate = @MeetingDate
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @MeetingDuration IS NOT NULL
--         BEGIN
--             UPDATE OnlineLiveMeeting
--             SET MeetingDuration = @MeetingDuration
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @TeacherID IS NOT NULL
--         BEGIN
--             UPDATE OnlineLiveMeeting
--             SET TeacherID = @TeacherID
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

-- CREATE OR ALTER PROCEDURE p_EditOnlineLiveAttendance
-- (
--     @MeetingID INT,
--     @ParticipantID INT,
--     @Attendance BIT 
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM OnlineLiveMeetingDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid MeetingID or ParticipantID: no matching record found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

     
--         UPDATE OnlineLiveMeetingDetails
--         SET Attendance = @Attendance
--         WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID;
    

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;


-- CREATE OR ALTER PROCEDURE p_EditPayment
-- (
--     @PaymentID INT,
--     @PaymentValue MONEY = NULL,  -- Domyślnie NULL
--     @PaymentDate DATETIME = NULL -- Domyślnie NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

        
--         IF NOT EXISTS (SELECT 1 FROM Payments WHERE PaymentID = @PaymentID)
--         BEGIN
--             RAISERROR('Invalid PaymentID: no matching payment found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

       
--         IF @PaymentValue IS NOT NULL AND @PaymentValue <= 0
--         BEGIN
--             RAISERROR('PaymentValue must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

       
--         UPDATE Payments
--         SET 
--             PaymentValue = CASE WHEN @PaymentValue IS NOT NULL THEN @PaymentValue ELSE PaymentValue END,
--             PaymentDate = CASE WHEN @PaymentDate IS NOT NULL THEN @PaymentDate ELSE PaymentDate END
--         WHERE PaymentID = @PaymentID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditStationaryMeeting
-- (
--     @MeetingID INT,
--     @MeetingDate DATETIME = NULL,
--     @MeetingDuration TIME(0) = NULL,
--     @RoomID INT = NULL,
--     @GroupSize INT = NULL,
--     @TeacherID INT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM StationaryMeeting WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @MeetingDate IS NOT NULL
--         BEGIN
--             UPDATE StationaryMeeting
--             SET MeetingDate = @MeetingDate
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @MeetingDuration IS NOT NULL
--         BEGIN
--             UPDATE StationaryMeeting
--             SET MeetingDuration = @MeetingDuration
--             WHERE MeetingID = @MeetingID;
--         END;


-- 		IF @GroupSize <= (SELECT Capacity FROM Rooms WHERE RoomID = @RoomID)
--         BEGIN
--             RAISERROR('Incompatible Room: not enough capacity', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @RoomID IS NOT NULL
--         BEGIN
--             UPDATE StationaryMeeting
--             SET RoomID = @RoomID
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @GroupSize IS NOT NULL
--         BEGIN
--             UPDATE StationaryMeeting
--             SET GroupSize = @GroupSize
--             WHERE MeetingID = @MeetingID;
--         END;

--         IF @TeacherID IS NOT NULL
--         BEGIN
--             UPDATE StationaryMeeting
--             SET TeacherID = @TeacherID
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
-- CREATE OR ALTER PROCEDURE p_EditStationaryMeetingAttendance
-- (
--     @MeetingID INT,
--     @ParticipantID INT,
--     @Attendance BIT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM StationaryMeetingDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid MeetingID or ParticipantID: no matching record found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Attendance IS NOT NULL
--         BEGIN
--             UPDATE StationaryMeetingDetails
--             SET Attendance = @Attendance
--             WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID;
--         END;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditStudiesService
-- (
--     @ServiceID INT,
--     @EntryFee MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

    
--         IF NOT EXISTS (SELECT 1 FROM StudiesService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in StudiesService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

  
--         IF @EntryFee <= 0
--         BEGIN
--             RAISERROR('EntryFee must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

  
--         UPDATE StudiesService
--         SET EntryFee = @EntryFee
--         WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_EditWebinarService
-- (
--     @ServiceID INT,
--     @Price MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

      
--         IF NOT EXISTS (SELECT 1 FROM WebinarService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in WebinarService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

      
--         IF @Price <= 0
--         BEGIN
--             RAISERROR('Price must be greater than 0.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

   
--         UPDATE WebinarService
--         SET Price = @Price
--         WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_EditOrder
-- (
--     @OrderID INT,
--     @PaymentLink VARCHAR(60) = NULL,  
--     @OrderDate DATETIME = NULL 
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
--         BEGIN
--             RAISERROR('Invalid OrderID: no matching order found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @OrderDate IS NOT NULL AND @OrderDate > GETDATE()
--         BEGIN
--             RAISERROR('OrderDate cannot be in the future.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         UPDATE Orders
--         SET 
--             PaymentLink = CASE WHEN @PaymentLink IS NOT NULL THEN @PaymentLink ELSE PaymentLink END,
--             OrderDate = CASE WHEN @OrderDate IS NOT NULL THEN @OrderDate ELSE OrderDate END
--         WHERE OrderID = @OrderID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_DeleteClassMeetingService
-- (
--     @ServiceID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

      
--         IF NOT EXISTS (SELECT 1 FROM ClassMeetingService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in ClassMeetingService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

 
--         DELETE FROM ClassMeetingService WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeleteConventionService
-- (
--     @ServiceID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

    
--         IF NOT EXISTS (SELECT 1 FROM ConventionService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in ConventionService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

     
--         DELETE FROM ConventionService WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeleteCourse
-- (
--     @CourseID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

   
--         IF NOT EXISTS (SELECT 1 FROM Courses WHERE CourseID = @CourseID)
--         BEGIN
--             RAISERROR('Invalid CourseID: no matching course found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

-- 		DECLARE @ModuleID INT;
-- 		DECLARE ModulesCursor CURSOR FOR
-- 		SELECT ModuleID
-- 		FROM Modules
-- 		WHERE CourseID = @CourseID;

-- 		OPEN ModulesCursor;
-- 		FETCH NEXT FROM ModulesCursor INTO @ModuleID;
-- 		WHILE @@FETCH_STATUS = 0
-- 		BEGIN
-- 			EXEC p_DeleteModule @ModuleID;
-- 			FETCH NEXT FROM ModulesCursor INTO @ModuleID;
-- 		END;

-- 		CLOSE ModulesCursor;
-- 		DEALLOCATE ModulesCursor;


     
--         DELETE FROM Modules
--         WHERE CourseID = @CourseID;

  
--         DELETE FROM Courses
--         WHERE CourseID = @CourseID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteCourseParticipant
-- (
--     @ParticipantID INT,
--     @CourseID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

     
--         IF NOT EXISTS (SELECT 1 FROM CourseParticipants WHERE ParticipantID = @ParticipantID AND CourseID = @CourseID)
--         BEGIN
--             RAISERROR('Invalid ParticipantID or CourseID: no matching course participant found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;


--         DELETE FROM CourseParticipants
--         WHERE ParticipantID = @ParticipantID AND CourseID = @CourseID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteCourseService
-- (
--     @ServiceID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

       
--         IF NOT EXISTS (SELECT 1 FROM CourseService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in CourseService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

 
--         DELETE FROM CourseService WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeleteModule
-- (
--     @ModuleID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;


--         IF NOT EXISTS (SELECT 1 FROM Modules WHERE ModuleID = @ModuleID)
--         BEGIN
--             RAISERROR('Invalid ModuleID: no matching module found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;


-- 		DECLARE @MeetingID INT;
-- 		DECLARE MeetingsCursor CURSOR FOR
		
-- 		SELECT MeetingID 
-- 		FROM StationaryMeeting
-- 		WHERE ModuleID = @ModuleID

-- 		OPEN MeetingsCursor;
-- 		FETCH NEXT FROM MeetingsCursor INTO @MeetingID

--         WHILE @@FETCH_STATUS = 0
-- 			BEGIN
-- 				EXEC p_DeleteStationaryMeeting @MeetingID;
-- 				FETCH NEXT FROM MeetingsCursor INTO @MeetingID;
-- 			END;
-- 		CLOSE MeetingsCursor;
-- 		DEALLOCATE MeetingsCursor;




-- 		DECLARE @MeetingID1 INT;
-- 		DECLARE MeetingsCursor CURSOR FOR

-- 		SELECT MeetingID 
-- 		FROM OfflineVideo
-- 		WHERE ModuleID = @ModuleID

-- 		OPEN MeetingsCursor;
-- 		FETCH NEXT FROM MeetingsCursor INTO @MeetingID1

--         WHILE @@FETCH_STATUS = 0
-- 			BEGIN
-- 				EXEC p_DeleteOfflineVideo @MeetingID1;
-- 				FETCH NEXT FROM MeetingsCursor INTO @MeetingID1;
-- 			END;
-- 		CLOSE MeetingsCursor;
-- 		DEALLOCATE MeetingsCursor;



-- 		DECLARE @MeetingID2 INT;
-- 		DECLARE MeetingsCursor CURSOR FOR


-- 		SELECT MeetingID 
-- 		FROM OnlineLiveMeeting
-- 		WHERE ModuleID = @ModuleID

-- 		OPEN MeetingsCursor;
-- 		FETCH NEXT FROM MeetingsCursor INTO @MeetingID2

--         WHILE @@FETCH_STATUS = 0
-- 			BEGIN
-- 				EXEC p_DeleteOnlineLiveMeeting @MeetingID2;
-- 				FETCH NEXT FROM MeetingsCursor INTO @MeetingID2;
-- 			END;
-- 		CLOSE MeetingsCursor;
-- 		DEALLOCATE MeetingsCursor;


--         DELETE FROM Modules
--         WHERE ModuleID = @ModuleID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO

-- exec delete
-- CREATE OR ALTER PROCEDURE p_DeleteOfflineVideo
-- (
--     @MeetingID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;


--         IF NOT EXISTS (SELECT 1 FROM OfflineVideo WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching offline video found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;


--         DELETE FROM OfflineVideoDetails
--         WHERE MeetingID = @MeetingID;

--         DELETE FROM OfflineVideo
--         WHERE MeetingID = @MeetingID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteOfflineVideoDetails
-- (
--     @MeetingID INT,
--     @ParticipantID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

     
--         IF NOT EXISTS (SELECT 1 FROM OfflineVideoDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid MeetingID or ParticipantID: no matching offline video details found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

      
--         DELETE FROM OfflineVideoDetails
--         WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteOnlineLiveMeeting
-- (
--     @MeetingID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

  
--         IF NOT EXISTS (SELECT 1 FROM OnlineLiveMeeting WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching online live meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM OnlineLiveMeetingDetails
--         WHERE MeetingID = @MeetingID;

       
--         DELETE FROM OnlineLiveMeeting
--         WHERE MeetingID = @MeetingID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteOnlineLiveMeetingDetails
-- (
--     @MeetingID INT,
--     @ParticipantID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

   
--         IF NOT EXISTS (SELECT 1 FROM OnlineLiveMeetingDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid MeetingID or ParticipantID: no matching online live meeting details found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

    
--         DELETE FROM OnlineLiveMeetingDetails
--         WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteOrder
-- (
--     @OrderID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

      
--         IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
--         BEGIN
--             RAISERROR('Invalid OrderID: no matching order found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

		
	
-- 		DECLARE @ServiceID INT;
-- 		DECLARE OrdersDetailsCursor CURSOR FOR
-- 		SELECT ServiceID 
-- 		FROM OrderDetails 
-- 		WHERE OrderID = @OrderID;

-- 		OPEN OrdersDetailsCursor;
-- 		FETCH NEXT FROM OrdersDetailsCursor INTO @ServiceID;
-- 		WHILE @@FETCH_STATUS = 0
-- 		BEGIN
			
-- 			EXEC p_DeleteOrderDetails @ServiceID, @OrderID;
-- 			FETCH NEXT FROM OrdersDetailsCursor INTO @ServiceID;
-- 		END;
-- 		CLOSE OrdersDetailsCursor;
-- 		DEALLOCATE OrdersDetailsCursor;

	
-- 		DELETE FROM Orders WHERE OrderID = @OrderID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeleteOrderDetails
-- (
--     @ServiceID INT,
--     @OrderID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

   
--         IF NOT EXISTS (SELECT 1 FROM OrderDetails WHERE ServiceID = @ServiceID AND OrderID = @OrderID)
--         BEGIN
--             RAISERROR('Invalid ServiceID or OrderID: no matching order details found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

-- 		DELETE FROM Payments WHERE ServiceID = @ServiceID AND OrderID = @OrderID


      
--         DELETE FROM OrderDetails WHERE ServiceID = @ServiceID AND OrderID = @OrderID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeletePayment
-- (
--     @PaymentID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

      
--         IF NOT EXISTS (SELECT 1 FROM Payments WHERE PaymentID = @PaymentID)
--         BEGIN
--             RAISERROR('Invalid PaymentID: no matching payment found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

        
--         DELETE FROM Payments WHERE PaymentID = @PaymentID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeleteService
-- (
--     @ServiceID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

        
--         IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;
		
-- 		DECLARE @ServiceType VARCHAR(30);

		
-- 		SELECT @ServiceType = ServiceType
-- 		FROM Services
-- 		WHERE ServiceID = @ServiceID;

		
-- 		IF @ServiceType = 'CourseService'
-- 		BEGIN
-- 			EXEC p_DeleteCourseService @ServiceID;
-- 		END
-- 		ELSE IF @ServiceType = 'ClassMeetingService'
-- 		BEGIN
-- 			EXEC p_DeleteClassMeetingService @ServiceID;
-- 		END
-- 		ELSE IF @ServiceType = 'StudiesService'
-- 		BEGIN
-- 			EXEC p_DeleteStudiesService @ServiceID;
-- 		END
-- 		ELSE IF @ServiceType = 'WebinarService'
-- 		BEGIN
-- 			EXEC p_DeleteWebinarService @ServiceID;
-- 		END
-- 		ELSE IF @ServiceType = 'ConventionService'
-- 		BEGIN
-- 			EXEC p_DeleteConventionService @ServiceID;
-- 		END

-- 		DECLARE @OrderID INT;
-- 		DECLARE OrdersCursor CURSOR FOR
-- 		SELECT OrderID 
-- 		FROM OrderDetails 
-- 		WHERE ServiceID = @ServiceID;

-- 		OPEN OrdersCursor;
-- 		FETCH NEXT FROM OrdersCursor INTO @OrderID;
-- 		WHILE @@FETCH_STATUS = 0
-- 		BEGIN
-- 			EXEC p_DeleteOrderDetails @ServiceID, @OrderID
-- 			FETCH NEXT FROM OrdersCursor INTO @OrderID;
-- 		END;
-- 		CLOSE OrdersCursor;
-- 		DEALLOCATE OrdersCursor;
-- 		DELETE FROM Services WHERE ServiceID = @ServiceID;

-- 		COMMIT TRANSACTION;
-- 	END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeleteStationaryMeeting
-- (
--     @MeetingID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM StationaryMeeting WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching stationary meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM StationaryMeetingDetails
--         WHERE MeetingID = @MeetingID;

--         DELETE FROM StationaryMeeting
--         WHERE MeetingID = @MeetingID;
		
		
--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteStationaryMeetingDetails
-- (
--     @MeetingID INT,
--     @ParticipantID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM StationaryMeetingDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid MeetingID or ParticipantID: no matching details found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM StationaryMeetingDetails
--         WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID;

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_DeleteStudiesService
-- (
--     @ServiceID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM StudiesService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in StudiesService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM StudiesService WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_DeleteWebinarService
-- (
--     @ServiceID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM WebinarService WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found in WebinarService.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         DELETE FROM WebinarService WHERE ServiceID = @ServiceID;

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_AddClassMeetingService
-- (
--     @ServiceID INT,
--     @PriceStudents MONEY,
--     @PriceOthers MONEY = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @PriceStudents <= 0
--         BEGIN
--             RAISERROR('PriceStudents must be greater than zero.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO ClassMeetingService (ServiceID, PriceStudents, PriceOthers)
--         VALUES (@ServiceID, @PriceStudents, @PriceOthers);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_AddConventionService
-- (
--     @ServiceID INT,
--     @Price MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;


--         IF @Price <= 0
--         BEGIN
--             RAISERROR('Price must be greater than zero.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;


--         INSERT INTO ConventionService (ServiceID, Price)
--         VALUES (@ServiceID, @Price);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_AddCourseParticipant
-- (
--     @ParticipantID INT,
--     @CourseID      INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM ServiceUserDetails WHERE ServiceUserID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid ParticipantID: no matching participant found in ServiceUserDetails.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Courses WHERE CourseID = @CourseID)
--         BEGIN
--             RAISERROR('Invalid CourseID: no matching course found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (SELECT 1 FROM CourseParticipants WHERE ParticipantID = @ParticipantID AND CourseID = @CourseID)
--         BEGIN
--             RAISERROR('The participant is already enrolled in this course.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO CourseParticipants
--             (ParticipantID, CourseID)
--         VALUES
--             (@ParticipantID, @CourseID);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_AddCourseService
-- (
--     @ServiceID INT,
--     @AdvanceValue MONEY,
--     @FullPrice MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @AdvanceValue <= 0
--         BEGIN
--             RAISERROR('AdvanceValue must be greater than zero.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @FullPrice < @AdvanceValue
--         BEGIN
--             RAISERROR('FullPrice must be greater than or equal to AdvanceValue.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO CourseService (ServiceID, AdvanceValue, FullPrice)
--         VALUES (@ServiceID, @AdvanceValue, @FullPrice);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_AddOfflineVideoDetails
-- (
--     @MeetingID     INT,
--     @ParticipantID INT,
--     @DateOfViewing DATE = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM OfflineVideo WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching offline video found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM ServiceUserDetails WHERE ServiceUserID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid ParticipantID: no matching participant found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (SELECT 1 FROM OfflineVideoDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('The participant is already added to this offline video.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO OfflineVideoDetails
--             (MeetingID, ParticipantID, DateOfViewing)
--         VALUES
--             (@MeetingID, @ParticipantID, @DateOfViewing);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_AddOnlineLiveMeetingDetails
-- (
--     @MeetingID     INT,
--     @ParticipantID INT,
--     @Attendance    BIT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM OnlineLiveMeeting WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching online live meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM ServiceUserDetails WHERE ServiceUserID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid ParticipantID: no matching participant found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (SELECT 1 FROM OnlineLiveMeetingDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('The participant is already added to this online live meeting.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO OnlineLiveMeetingDetails
--             (MeetingID, ParticipantID, Attendance)
--         VALUES
--             (@MeetingID, @ParticipantID, @Attendance);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_AddOrder
-- (
--     @OrderID INT,
--     @UserID INT,
--     @OrderDate DATETIME = NULL,
--     @PaymentLink VARCHAR(60) = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

  
--         IF NOT EXISTS (SELECT 1 FROM ServiceUserDetails WHERE ServiceUserID = @UserID)
--         BEGIN
--             RAISERROR('Invalid UserID: no matching user found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @OrderDate > GETDATE()
--         BEGIN
--             RAISERROR('OrderDate cannot be in the future.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO Orders (OrderID, UserID, OrderDate, PaymentLink)
--         VALUES (@OrderID, @UserID, @OrderDate, @PaymentLink);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_AddOrderDetail
-- (
--     @OrderID INT,
--     @ServiceID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
--         BEGIN
--             RAISERROR('Invalid OrderID: no matching order found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (SELECT 1 FROM OrderDetails WHERE OrderID = @OrderID AND ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('This combination of OrderID and ServiceID already exists in OrderDetails.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO OrderDetails (OrderID, ServiceID)
--         VALUES (@OrderID, @ServiceID);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_AddPayment
-- (
--     @PaymentID INT,
--     @PaymentValue MONEY,
--     @PaymentDate DATETIME = NULL,
--     @ServiceID INT,
--     @OrderID INT
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

-- 		IF NOT EXISTS (SELECT 1 FROM OrderDetails WHERE OrderID = @OrderID AND ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('No matching pair (OrderID, ServiceID) in OrderDetails', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;


--         IF @PaymentValue <= 0
--         BEGIN
--             RAISERROR('PaymentValue must be greater than zero.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO Payments (PaymentID, PaymentValue, PaymentDate, ServiceID, OrderID)
--         VALUES (@PaymentID, @PaymentValue, @PaymentDate, @ServiceID, @OrderID);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_AddService
-- (
--     @ServiceID INT,
--     @ServiceType VARCHAR(30)
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF @ServiceType NOT IN ('ClassMeetingService', 'StudiesService', 'CourseService', 'WebinarService', 'ConventionService')
--         BEGIN
--             RAISERROR('Invalid ServiceType: must be one of the allowed types.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO Services (ServiceID, ServiceType)
--         VALUES (@ServiceID, @ServiceType);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

-- CREATE OR ALTER PROCEDURE p_AddStationaryMeetingDetails
-- (
--     @MeetingID     INT,
--     @ParticipantID INT,
--     @Attendance    BIT = NULL
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM StationaryMeeting WHERE MeetingID = @MeetingID)
--         BEGIN
--             RAISERROR('Invalid MeetingID: no matching stationary meeting found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF NOT EXISTS (SELECT 1 FROM ServiceUserDetails WHERE ServiceUserID = @ParticipantID)
--         BEGIN
--             RAISERROR('Invalid ParticipantID: no matching participant found.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF EXISTS (SELECT 1 FROM StationaryMeetingDetails WHERE MeetingID = @MeetingID AND ParticipantID = @ParticipantID)
--         BEGIN
--             RAISERROR('The participant is already added to this stationary meeting.', 16, 3);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO StationaryMeetingDetails
--             (MeetingID, ParticipantID, Attendance)
--         VALUES
--             (@MeetingID, @ParticipantID, @Attendance);

--         COMMIT TRANSACTION;
--     END TRY

--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--         THROW;
--     END CATCH;
-- END;
-- GO
-- CREATE OR ALTER PROCEDURE p_AddStudiesService
-- (
--     @ServiceID INT,
--     @EntryFee MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @EntryFee <= 0
--         BEGIN
--             RAISERROR('EntryFee must be greater than zero.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO StudiesService (ServiceID, EntryFee)
--         VALUES (@ServiceID, @EntryFee);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- CREATE OR ALTER PROCEDURE p_AddWebinarService
-- (
--     @ServiceID INT,
--     @Price MONEY
-- )
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = @ServiceID)
--         BEGIN
--             RAISERROR('Invalid ServiceID: no matching service found.', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         IF @Price <= 0
--         BEGIN
--             RAISERROR('Price must be greater than zero.', 16, 2);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END;

--         INSERT INTO WebinarService (ServiceID, Price)
--         VALUES (@ServiceID, @Price);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;

















-- Jakub=============================================================================
--CREATE OR ALTER PROCEDURE p_CreateWebinar
--(
--    @WebinarName VARCHAR(30),
--    @TeacherID INT,
--    @TranslatorID INT = NULL,
--    @WebinarDate DATETIME,
--    @Link VARCHAR(100),
--    @DurationTime TIME(0) = NULL,
--    @LinkToVideo VARCHAR(100),
--    @WebinarDescription TEXT = NULL,
--    @LanguageID INT = NULL,
--    @AvailableDue DATE,
--    @ServiceID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        BEGIN TRANSACTION;

--        IF @AvailableDue <= @WebinarDate
--        BEGIN
--            RAISERROR('AvailableDue must be later than WebinarDate.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        INSERT INTO Webinars (
--            WebinarName, TeacherID, TranslatorID, WebinarDate,
--            Link, DurationTime, LinkToVideo, WebinarDescription,
--            LanguageID, AvailableDue, ServiceID
--        ) VALUES (
--            @WebinarName, @TeacherID, @TranslatorID, @WebinarDate,
--            @Link, @DurationTime, @LinkToVideo, @WebinarDescription,
--            @LanguageID, @AvailableDue, @ServiceID
--        );

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;

--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_EditWebinar
--(
--    @WebinarID INT,
--    @WebinarName VARCHAR(30) = NULL,
--    @WebinarDate DATETIME = NULL,
--    @AvailableDue DATE = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        BEGIN TRANSACTION;

--        IF NOT EXISTS (SELECT 1 FROM Webinars WHERE WebinarID = @WebinarID)
--        BEGIN
--            RAISERROR('Invalid WebinarID: no matching Webinar found.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        IF @WebinarDate IS NOT NULL AND @AvailableDue IS NOT NULL AND @AvailableDue <= @WebinarDate
--        BEGIN
--            RAISERROR('AvailableDue must be later than WebinarDate.', 16, 2);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        UPDATE Webinars
--        SET WebinarName = ISNULL(@WebinarName, WebinarName),
--            WebinarDate = ISNULL(@WebinarDate, WebinarDate),
--            AvailableDue = ISNULL(@AvailableDue, AvailableDue)
--        WHERE WebinarID = @WebinarID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;

--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddUserToWebinar
--(
--    @UserID INT,
--    @WebinarID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        BEGIN TRANSACTION;

--        IF NOT EXISTS (SELECT 1 FROM Webinars WHERE WebinarID = @WebinarID)
--        BEGIN
--            RAISERROR('Invalid WebinarID: no matching Webinar found.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        IF EXISTS (SELECT 1 FROM WebinarDetails WHERE UserID = @UserID AND WebinarID = @WebinarID)
--        BEGIN
--            RAISERROR('User is already added to this Webinar.', 16, 2);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        INSERT INTO WebinarDetails (UserID, WebinarID)
--        VALUES (@UserID, @WebinarID);

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;

--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteWebinar
--(
--    @WebinarID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        BEGIN TRANSACTION;

--        -- Sprawdzenie, czy webinar istnieje
--        IF NOT EXISTS (SELECT 1 FROM Webinars WHERE WebinarID = @WebinarID)
--        BEGIN
--            RAISERROR('Invalid WebinarID: no matching webinar found.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        -- Usuwanie powiązanych danych z tabeli WebinarDetails
--        DELETE FROM WebinarDetails
--        WHERE WebinarID = @WebinarID;

--        -- Usuwanie webinaru z tabeli Webinars
--        DELETE FROM Webinars
--        WHERE WebinarID = @WebinarID;

--        COMMIT TRANSACTION;
--    END TRY

--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;

--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddUser
--(
--    @FirstName VARCHAR(30),
--    @LastName VARCHAR(30),
--    @DateOfBirth DATE = NULL,
--    @UserTypeID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        IF @DateOfBirth > GETDATE()
--        BEGIN
--            RAISERROR('DateOfBirth cannot be in the future.', 16, 1);
--            RETURN;
--        END;

--        INSERT INTO Users (FirstName, LastName, DateOfBirth, UserTypeID)
--        VALUES (@FirstName, @LastName, @DateOfBirth, @UserTypeID);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateUser
--(
--    @UserID INT,
--    @FirstName VARCHAR(30) = NULL,
--    @LastName VARCHAR(30) = NULL,
--    @DateOfBirth DATE = NULL,
--    @UserTypeID INT = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        IF @DateOfBirth IS NOT NULL AND @DateOfBirth > GETDATE()
--        BEGIN
--            RAISERROR('DateOfBirth cannot be in the future.', 16, 1);
--            RETURN;
--        END;

--        UPDATE Users
--        SET
--            FirstName = COALESCE(@FirstName, FirstName),
--            LastName = COALESCE(@LastName, LastName),
--            DateOfBirth = COALESCE(@DateOfBirth, DateOfBirth),
--            UserTypeID = COALESCE(@UserTypeID, UserTypeID)
--        WHERE UserID = @UserID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteUser
--(
--    @UserID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        -- Usuwanie zależnych danych w powiązanych tabelach
--        DELETE FROM UserAddressDetails WHERE UserID = @UserID;
--        DELETE FROM UserContact WHERE UserID = @UserID;

--        -- Usuwanie użytkownika
--        DELETE FROM Users WHERE UserID = @UserID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddEmployee
--(
--    @EmployeeID INT,
--    @DateOfHire DATE = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        IF @DateOfHire IS NOT NULL AND @DateOfHire > GETDATE()
--        BEGIN
--            RAISERROR('DateOfHire cannot be in the future.', 16, 1);
--            RETURN;
--        END;

--        INSERT INTO Employees (EmployeeID, DateOfHire)
--        VALUES (@EmployeeID, @DateOfHire);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateEmployee
--(
--    @EmployeeID INT,
--    @DateOfHire DATE = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        IF @DateOfHire IS NOT NULL AND @DateOfHire > GETDATE()
--        BEGIN
--            RAISERROR('DateOfHire cannot be in the future.', 16, 1);
--            RETURN;
--        END;

--        UPDATE Employees
--        SET DateOfHire = COALESCE(@DateOfHire, DateOfHire)
--        WHERE EmployeeID = @EmployeeID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('EmployeeID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteEmployee
--(
--    @EmployeeID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        -- Usuwanie zależnych danych w powiązanych tabelach
--        DELETE FROM EmployeesSuperior WHERE EmployeeID = @EmployeeID;
--        DELETE FROM EmployeeDegree WHERE EmployeeID = @EmployeeID;

--        -- Usuwanie pracownika
--        DELETE FROM Employees WHERE EmployeeID = @EmployeeID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('EmployeeID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AssignSupervisor
--(
--    @EmployeeID INT,
--    @SupervisorID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        -- Sprawdzenie, czy przełożony istnieje
--        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @SupervisorID)
--        BEGIN
--            RAISERROR('SupervisorID not found.', 16, 1);
--            RETURN;
--        END;

--        -- Aktualizacja tabeli przełożonych
--        UPDATE EmployeesSuperior
--        SET ReportsTo = @SupervisorID
--        WHERE EmployeeID = @EmployeeID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            INSERT INTO EmployeesSuperior (EmployeeID, ReportsTo)
--            VALUES (@EmployeeID, @SupervisorID);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddUserAddress
--(
--    @UserID INT,
--    @Address VARCHAR(30),
--    @PostalCode VARCHAR(10),
--    @LocationID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO UserAddressDetails (UserID, Address, PostalCode, LocationID)
--        VALUES (@UserID, @Address, @PostalCode, @LocationID);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateUserAddress
--(
--    @UserID INT,
--    @Address VARCHAR(30) = NULL,
--    @PostalCode VARCHAR(10) = NULL,
--    @LocationID INT = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        UPDATE UserAddressDetails
--        SET 
--            Address = COALESCE(@Address, Address),
--            PostalCode = COALESCE(@PostalCode, PostalCode),
--            LocationID = COALESCE(@LocationID, LocationID)
--        WHERE UserID = @UserID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteUserAddress
--(
--    @UserID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM UserAddressDetails WHERE UserID = @UserID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddUserContact
--(
--    @UserID INT,
--    @Email VARCHAR(30),
--    @Phone VARCHAR(30) = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        -- Walidacja numeru telefonu (jeśli nie jest NULL)
--        IF @Phone IS NOT NULL AND NOT (@Phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
--        BEGIN
--            RAISERROR('Phone number must be exactly 9 digits.', 16, 1);
--            RETURN;
--        END;

--        INSERT INTO UserContact (UserID, Email, Phone)
--        VALUES (@UserID, @Email, @Phone);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateUserContact
--(
--    @UserID INT,
--    @Email VARCHAR(30) = NULL,
--    @Phone VARCHAR(30) = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        -- Walidacja numeru telefonu (jeśli nie jest NULL)
--        IF @Phone IS NOT NULL AND NOT (@Phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
--        BEGIN
--            RAISERROR('Phone number must be exactly 9 digits.', 16, 1);
--            RETURN;
--        END;

--        UPDATE UserContact
--        SET 
--            Email = COALESCE(@Email, Email),
--            Phone = COALESCE(@Phone, Phone)
--        WHERE UserID = @UserID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteUserContact
--(
--    @UserID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM UserContact WHERE UserID = @UserID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddUserType
--(
--    @UserTypeID INT,
--    @UserTypeName VARCHAR(30)
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO UserType (UserTypeID, UserTypeName)
--        VALUES (@UserTypeID, @UserTypeName);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateUserType
--(
--    @UserTypeID INT,
--    @UserTypeName VARCHAR(30)
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        UPDATE UserType
--        SET UserTypeName = @UserTypeName
--        WHERE UserTypeID = @UserTypeID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserTypeID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteUserType
--(
--    @UserTypeID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM UserType WHERE UserTypeID = @UserTypeID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('UserTypeID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddDegree
--(
--    @DegreeID INT,
--    @DegreeLevel VARCHAR(30),
--    @DegreeName VARCHAR(30)
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO Degrees (DegreeID, DegreeLevel, DegreeName)
--        VALUES (@DegreeID, @DegreeLevel, @DegreeName);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateDegree
--(
--    @DegreeID INT,
--    @DegreeLevel VARCHAR(30),
--    @DegreeName VARCHAR(30)
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        UPDATE Degrees
--        SET 
--            DegreeLevel = @DegreeLevel,
--            DegreeName = @DegreeName
--        WHERE DegreeID = @DegreeID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('DegreeID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteDegree
--(
--    @DegreeID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM Degrees WHERE DegreeID = @DegreeID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('DegreeID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddEmployeeDegree
--(
--    @EmployeeID INT,
--    @DegreeID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO EmployeeDegree (EmployeeID, DegreeID)
--        VALUES (@EmployeeID, @DegreeID);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateEmployeeDegree
--(
--    @EmployeeID INT,
--    @OldDegreeID INT,
--    @NewDegreeID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        BEGIN TRANSACTION;

--        -- Sprawdzenie, czy stary stopień istnieje dla pracownika
--        IF NOT EXISTS (
--            SELECT 1
--            FROM EmployeeDegree
--            WHERE EmployeeID = @EmployeeID AND DegreeID = @OldDegreeID
--        )
--        BEGIN
--            RAISERROR('Old degree not found for the specified employee.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        -- Sprawdzenie, czy nowy stopień istnieje w tabeli Degrees
--        IF NOT EXISTS (
--            SELECT 1
--            FROM Degrees
--            WHERE DegreeID = @NewDegreeID
--        )
--        BEGIN
--            RAISERROR('New degree does not exist.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        -- Aktualizacja stopnia naukowego pracownika
--        UPDATE EmployeeDegree
--        SET DegreeID = @NewDegreeID
--        WHERE EmployeeID = @EmployeeID AND DegreeID = @OldDegreeID;

--        COMMIT TRANSACTION;
--    END TRY

--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;

--        THROW;
--    END CATCH;
--END;


--CREATE OR ALTER PROCEDURE p_DeleteEmployeeDegree
--(
--    @EmployeeID INT,
--    @DegreeID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        BEGIN TRANSACTION;

--        -- Sprawdzenie, czy wpis istnieje w tabeli EmployeeDegree
--        IF NOT EXISTS (
--            SELECT 1
--            FROM EmployeeDegree
--            WHERE EmployeeID = @EmployeeID AND DegreeID = @DegreeID
--        )
--        BEGIN
--            RAISERROR('No matching record found in EmployeeDegree.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END;

--        -- Usunięcie wpisu z tabeli EmployeeDegree
--        DELETE FROM EmployeeDegree
--        WHERE EmployeeID = @EmployeeID AND DegreeID = @DegreeID;

--        COMMIT TRANSACTION;
--    END TRY

--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;

--        -- Rzucenie błędu dalej
--        THROW;
--    END CATCH;
--END;


--CREATE OR ALTER PROCEDURE p_AddTranslator
--(
--    @TranslatorID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO Translators (TranslatorID)
--        VALUES (@TranslatorID);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteTranslator
--(
--    @TranslatorID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM Translators WHERE TranslatorID = @TranslatorID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('TranslatorID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddLanguage
--(
--    @LanguageID INT,
--    @LanguageName VARCHAR(30)
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO Languages (LanguageID, LanguageName)
--        VALUES (@LanguageID, @LanguageName);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateLanguage
--(
--    @LanguageID INT,
--    @LanguageName VARCHAR(30)
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        UPDATE Languages
--        SET LanguageName = @LanguageName
--        WHERE LanguageID = @LanguageID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('LanguageID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteLanguage
--(
--    @LanguageID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM Languages WHERE LanguageID = @LanguageID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('LanguageID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddTranslatorLanguage
--(
--    @TranslatorID INT,
--    @LanguageID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO TranslatorsLanguages (TranslatorID, LanguageID)
--        VALUES (@TranslatorID, @LanguageID);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteTranslatorLanguage
--(
--    @TranslatorID INT,
--    @LanguageID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM TranslatorsLanguages
--        WHERE TranslatorID = @TranslatorID AND LanguageID = @LanguageID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('TranslatorID and/or LanguageID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_AddLocation
--(
--    @LocationID INT,
--    @CountryName VARCHAR(30),
--    @ProvinceName VARCHAR(50) = NULL,
--    @CityName VARCHAR(50)
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        INSERT INTO Locations (LocationID, CountryName, ProvinceName, CityName)
--        VALUES (@LocationID, @CountryName, @ProvinceName, @CityName);
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_UpdateLocation
--(
--    @LocationID INT,
--    @CountryName VARCHAR(30) = NULL,
--    @ProvinceName VARCHAR(50) = NULL,
--    @CityName VARCHAR(50) = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        UPDATE Locations
--        SET 
--            CountryName = COALESCE(@CountryName, CountryName),
--            ProvinceName = COALESCE(@ProvinceName, ProvinceName),
--            CityName = COALESCE(@CityName, CityName)
--        WHERE LocationID = @LocationID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('LocationID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER PROCEDURE p_DeleteLocation
--(
--    @LocationID INT
--)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    BEGIN TRY
--        DELETE FROM Locations WHERE LocationID = @LocationID;

--        IF @@ROWCOUNT = 0
--        BEGIN
--            RAISERROR('LocationID not found.', 16, 1);
--        END;
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH;
--END;

--CREATE OR ALTER FUNCTION f_CalculateAverageUserAge()
--RETURNS FLOAT
--AS
--BEGIN
--    DECLARE @AverageAge FLOAT;

--    SET @AverageAge = (
--        SELECT AVG(DATEDIFF(YEAR, DateOfBirth, GETDATE()))
--        FROM Users
--        WHERE DateOfBirth IS NOT NULL
--    );

--    RETURN @AverageAge;
--END;
--SELECT dbo.f_CalculateAverageUserAge() AS AverageUserAge;


--CREATE OR ALTER FUNCTION f_CountEmployeesUnderSupervisor
--(
--    @SupervisorID INT
--)
--RETURNS INT
--AS
--BEGIN
--    DECLARE @EmployeeCount INT;

--    SET @EmployeeCount = (
--        SELECT COUNT(*)
--        FROM EmployeesSuperior
--        WHERE ReportsTo = @SupervisorID
--    );

--    RETURN @EmployeeCount;
--END;
--SELECT dbo.f_CountEmployeesUnderSupervisor(5) AS EmployeeCount;


--CREATE OR ALTER FUNCTION f_HasUserAddress
--(
--    @UserID INT
--)
--RETURNS BIT
--AS
--BEGIN
--    DECLARE @HasAddress BIT;

--    SET @HasAddress = CASE
--        WHEN EXISTS (
--            SELECT 1
--            FROM UserAddressDetails
--            WHERE UserID = @UserID
--        ) THEN 1
--        ELSE 0
--    END;

--    RETURN @HasAddress;
--END;
--SELECT dbo.f_HasUserAddress(3) AS HasAddress;


--CREATE OR ALTER FUNCTION f_CountTranslatorLanguages
--(
--    @TranslatorID INT
--)
--RETURNS INT
--AS
--BEGIN
--    DECLARE @LanguageCount INT;

--    SET @LanguageCount = (
--        SELECT COUNT(*)
--        FROM TranslatorsLanguages
--        WHERE TranslatorID = @TranslatorID
--    );

--    RETURN @LanguageCount;
--END;
--SELECT dbo.f_CountTranslatorLanguages(2) AS LanguageCount;

--CREATE OR ALTER FUNCTION f_CountWebinarParticipants
--(
--    @WebinarID INT
--)
--RETURNS INT
--AS
--BEGIN
--    DECLARE @ParticipantCount INT;

--    SET @ParticipantCount = (
--        SELECT COUNT(*)
--        FROM WebinarDetails
--        WHERE WebinarID = @WebinarID
--    );

--    RETURN @ParticipantCount;
--END;
--SELECT dbo.f_CountWebinarParticipants(1) AS ParticipantCount;

--CREATE OR ALTER FUNCTION f_IsUserRegisteredForWebinar
--(
--    @UserID INT,
--    @WebinarID INT
--)
--RETURNS BIT
--AS
--BEGIN
--    DECLARE @IsRegistered BIT;

--    SET @IsRegistered = CASE
--        WHEN EXISTS (
--            SELECT 1
--            FROM WebinarDetails
--            WHERE UserID = @UserID AND WebinarID = @WebinarID
--        ) THEN 1
--        ELSE 0
--    END;

--    RETURN @IsRegistered;
--END;
--SELECT dbo.f_IsUserRegisteredForWebinar(3, 1) AS IsRegistered;

--CREATE OR ALTER FUNCTION f_IsUserEmployee
--(
--    @UserID INT
--)
--RETURNS BIT
--AS
--BEGIN
--    DECLARE @IsEmployee BIT;

--    SET @IsEmployee = CASE
--        WHEN EXISTS (
--            SELECT 1
--            FROM Employees
--            WHERE EmployeeID = @UserID
--        ) THEN 1
--        ELSE 0
--    END;

--    RETURN @IsEmployee;
--END;
--SELECT dbo.f_IsUserEmployee(3) AS IsEmployee;