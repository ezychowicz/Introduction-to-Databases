USE u_szymocha;
GO

-- =====================================================================
-- 1. Studies Management
-- =====================================================================

-- ---------------------------------------------------------------------
-- a. Testing p_CreateStudies procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_CreateStudies';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Employees
    (EmployeeID, DateOfHire)
VALUES
    (10001, '2010-01-01')

    Insert INTO Users
    (UserID, FirstName, LastName, DateOfBirth, UserTypeID)
VALUES
    (10001, 'John', 'Doe', '1980-01-01', 2);

    DECLARE @Deadline DATETIME;
    SET @Deadline = DATEADD(DAY, 60, GETDATE());

    DECLARE @SN NVARCHAR(50) = 'Engineering';
    DECLARE @Sdesc NVARCHAR(MAX) = 'Engineering studies encompassing various disciplines.';
    EXEC p_CreateStudies
        @StudiesName = @SN,
        @StudiesDescription = @Sdesc,
        @CoordinatorID = 10001,
        @EnrollmentLimit = 150,
        @EnrollmentDeadline = @Deadline,
        @SemesterCount = 8;

    DECLARE @StudiesID INT = (SELECT MAX(StudiesID)
FROM Studies);

    IF NOT EXISTS (
        SELECT 1
FROM Studies
WHERE StudiesID = @StudiesID
    AND StudiesName = @SN
    AND StudiesDescription = @Sdesc
    AND StudiesCoordinatorID = 10001
    AND EnrollmentLimit = 150
    AND SemesterCount = 8
    )
    BEGIN
    RAISERROR('Test Failed: Studies record was not created correctly.', 16, 1);
END

    IF (SELECT COUNT(*)
FROM SemesterDetails
WHERE StudiesID = @StudiesID) <> 8
    BEGIN
    DECLARE @CNT INT = (SELECT COUNT(*)
    FROM SemesterDetails
    WHERE StudiesID = @StudiesID);
    PRINT @CNT;
    Select *
    from SemesterDetails
    where StudiesID = @StudiesID;
    RAISERROR('Test Failed: SemesterDetails records were not created correctly.', 16, 1);
END

DECLARE @InternshipStart DATETIME;
SET @InternshipStart = '2027-09-07';
    IF NOT EXISTS (
        SELECT 1
FROM Internship
WHERE StudiesID = @StudiesID
    AND StartDate = @InternshipStart
    )
    BEGIN
    RAISERROR('Test Failed: Internship record was not created correctly.', 16, 1);
END

    PRINT 'Test Passed: p_CreateStudies executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_CreateStudies - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- b. Testing p_EditStudies procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_EditStudies';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Employees
    (EmployeeID, DateOfHire)
VALUES
    (10001, '2010-01-01')

    Insert INTO Users
    (UserID, FirstName, LastName, DateOfBirth, UserTypeID)
VALUES
    (10001, 'John', 'Doe', '1980-01-01', 2);

    DECLARE @Deadline DATETIME;
    SET @Deadline = '2025-04-01';
    DECLARE @G1 DATETIME;
    SET @G1 = '2025-06-30';

    INSERT INTO Studies
    (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID, EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate, ServiceID)
VALUES
    (201, 'Physics', 'Study of matter and energy.', 10001, 100, @Deadline, 8, @G1, 9001);

    DECLARE @Graduation DATETIME;
    SET @Graduation =  '2025-06-30';
    EXEC p_EditStudies
        @StudiesID = 201,
        @EnrollmentLimit = 120,
        @ExpectedGraduationDate = @Graduation,
        @StudiesName = NULL,
        @StudiesDescription = NULL,
        @EnrollmentDeadline = NULL;

    IF NOT EXISTS (
        SELECT 1
FROM Studies
WHERE StudiesID = 201
    AND EnrollmentLimit = 120
    and ExpectedGraduationDate = @Graduation
    )
    BEGIN

    RAISERROR('Test Failed: EnrollmentLimit or ExpectedGraduationDate was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM Studies
WHERE StudiesID = 201
    AND (StudiesName <> 'Physics' OR StudiesDescription <> 'Study of matter and energy.'
    OR StudiesCoordinatorID <> 10001 OR EnrollmentDeadline <> @Deadline
    OR SemesterCount <> 8 OR ServiceID <> 9001)
    )
    BEGIN
    RAISERROR('Test Failed: Other fields were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_EditStudies executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_EditStudies - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- c. Testing p_ChangeStudiesCoordinator procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_ChangeStudiesCoordinator';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Employees
    (EmployeeID, DateOfHire)
VALUES
    (10001, '2010-01-01'),
    (10002, '2012-01-01');

    Insert INTO Users
    (UserID, FirstName, LastName, DateOfBirth, UserTypeID)
VALUES
    (10001, 'John', 'Doe', '1980-01-01', 2),
    (10002, 'Jane', 'Smith', '1982-01-01', 2);

    DECLARE @Deadline DATETIME;
    SET @Deadline = '2025-04-01';
    DECLARE @Graduation DATETIME;
    SET @Graduation =  '2025-06-30';
    INSERT INTO Studies
    (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID, EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate, ServiceID)
VALUES
    (301, 'Chemistry', 'Study of substances and reactions.', 101, 50, @Deadline, 6, @Graduation, 9001);

    EXEC p_ChangeStudiesCoordinator
        @StudiesID = 301,
        @NewCoordinatorID = 10002;

    IF NOT EXISTS (
        SELECT 1
FROM Studies
WHERE StudiesID = 301
    AND StudiesCoordinatorID = 10002
    )
    BEGIN
    RAISERROR('Test Failed: StudiesCoordinatorID was not updated correctly.', 16, 1);
END

    PRINT 'Test Passed: p_ChangeStudiesCoordinator executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_ChangeStudiesCoordinator - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- d. Testing p_AddSubjectToStudies procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_AddSubjectToStudies';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, StudiesID, ServiceID)
VALUES
    (601, 'Machine Learning', 'Study of machine learning algorithms.', 202, 5, 701, 9001);

    INSERT INTO Studies
    (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID, EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate, ServiceID)
VALUES
    (701, 'Computer Science', 'Comprehensive computer science studies.', 101, 150, DATEADD(DAY, 60, GETDATE()), 8, DATEADD(YEAR, 4, GETDATE()), 9002);

    EXEC p_AddSubjectToStudies
        @SubjectID = 601,
        @StudiesID = 701;

    IF NOT EXISTS (
        SELECT 1
FROM SubjectStudiesAssignment
WHERE SubjectID = 601
    AND StudiesID = 701
    )
    BEGIN
    RAISERROR('Test Failed: SubjectStudiesAssignment record was not created correctly.', 16, 1);
END

    PRINT 'Test Passed: p_AddSubjectToStudies executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_AddSubjectToStudies - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- e. Testing p_DeleteSubjectFromStudies procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteSubjectFromStudies';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, ServiceID, StudiesID)
VALUES
    (701, 'Data Mining', 'Study of data mining techniques.', 202, 4, 9001, 801);

    INSERT INTO Studies
    (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID, EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate, ServiceID)
VALUES
    (801, 'Information Systems', 'Study of information systems management.', 2003, 100, DATEADD(DAY, 45, GETDATE()), 6, DATEADD(YEAR, 4, GETDATE()), 9001);

    INSERT INTO SubjectStudiesAssignment
    (SubjectID, StudiesID)
VALUES
    (701, 801);

    EXEC p_DeleteSubjectFromStudies
        @SubjectID = 701,
        @StudiesID = 801;

    IF EXISTS (
        SELECT 1
FROM SubjectStudiesAssignment
WHERE SubjectID = 701
    AND StudiesID = 801
    )
    BEGIN
    RAISERROR('Test Failed: SubjectStudiesAssignment record was not deleted.', 16, 1);
END

    PRINT 'Test Passed: p_DeleteSubjectFromStudies executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteSubjectFromStudies - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- f. Testing p_DeleteSubject procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteSubject';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, StudiesID, ServiceID)
VALUES
    (801, 'Artificial Intelligence', 'Study of AI concepts and applications.', 2004, 6, 1, 9001);

    INSERT INTO Convention
    (ConventionID, SubjectID, StartDate, SemesterID, Duration, ServiceID)
VALUES
    (1101, 801, '2025-04-01', 901, 10, 9002);

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (120010, 801, 7004, 'AI Workshop', NULL, NULL, 9005, 'Stationary'),
    (12002, 801, 7005, 'AI Lecture', NULL, NULL, 9006, 'OnlineLiveClass'),
    (12003, 801, 7006, 'AI Seminar', NULL, NULL, 9007, 'OfflineVideo');

    INSERT INTO StationaryClass
    (MeetingID, RoomID, GroupSize, StartDate, Duration)
VALUES
    (120010, 8005, 20, '2025-04-05 10:00:00', '02:00:00');

    INSERT INTO OnlineLiveClass
    (MeetingID, Link, StartDate, Duration)
VALUES
    (12002, 'https://zoom.us/ai_lecture', '2025-04-10 14:00:00', '01:30:00');

    INSERT INTO OfflineVideoClass
    (MeetingID, VideoLink, StartDate, Deadline)
VALUES
    (12003, 'https://videoserver.com/ai_seminar', '2025-04-15 09:00:00', '2025-04-15 11:00:00');

    INSERT INTO SubjectStudiesAssignment
    (SubjectID, StudiesID)
VALUES
    (801, 901);

    EXEC p_DeleteSubject 
        @SubjectID = 801;

    IF EXISTS (
        SELECT 1
FROM Subject
WHERE SubjectID = 801
    )
    BEGIN
    RAISERROR('Test Failed: Subject record was not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM Convention
WHERE SubjectID = 801
    )
    BEGIN
    RAISERROR('Test Failed: Convention records related to SubjectID 801 were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE SubjectID = 801
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeeting records related to SubjectID 801 were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM StationaryClass
WHERE MeetingID = 120010
    )
    BEGIN
    RAISERROR('Test Failed: StationaryClass records related to MeetingID 1201 were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM OnlineLiveClass
WHERE MeetingID = 12002
    )
    BEGIN
    RAISERROR('Test Failed: OnlineLiveClass records related to MeetingID 1202 were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM OfflineVideoClass
WHERE MeetingID = 12003
    )
    BEGIN
    RAISERROR('Test Failed: OfflineVideoClass records related to MeetingID 1203 were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM SubjectStudiesAssignment
WHERE SubjectID = 801
    AND StudiesID = 901
    )
    BEGIN
    RAISERROR('Test Failed: SubjectStudiesAssignment records linking SubjectID 801 and StudiesID 901 were not deleted.', 16, 1);
END

    PRINT 'Test Passed: p_DeleteSubject executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteSubject - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- =====================================================================
-- 2. Convention Management
-- =====================================================================

-- ---------------------------------------------------------------------
-- a. Testing p_AddConvention procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_AddConvention';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, StudiesID, ServiceID)
VALUES
    (1001, 'Data Science', 'Study of data analysis and interpretation.', 20010, 5, 1, 9001);

    INSERT INTO SemesterDetails
    (SemesterID, StudiesID, StartDate, EndDate)
VALUES
    (901, 701, '2025-01-01', '2025-06-30');

    EXEC p_AddConvention
        @SubjectID = 1001,
        @SemesterID = 901,
        @ConventionDate = '2025-03-15',
        @Duration = 10;
    DECLARE @ConventionID INT = (SELECT MAX(ConventionID)
FROM Convention);

    IF NOT EXISTS (
        SELECT 1
FROM Convention
WHERE ConventionID = @ConventionID
    AND SubjectID = 1001
    AND StartDate = '2025-03-15'
    AND SemesterID = 901
    AND Duration = 10
    )
    BEGIN
    RAISERROR('Test Failed: Convention record was not created correctly.', 16, 1);
END

    PRINT 'Test Passed: p_AddConvention executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_AddConvention - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- b. Testing p_DeleteConvention procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteConvention';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, ServiceID, StudiesID)
VALUES
    (1101, 'Robotics', 'Study of robotic systems.', 2002, 6, 9001, 1);

    INSERT INTO Convention
    (ConventionID, SubjectID, StartDate, SemesterID, Duration, ServiceID)
VALUES
    (1101, 1101, '2025-04-01', 901, 30, 9002);

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (120010, 1101, 7004, 'Robotics Workshop', NULL, NULL, 9005, 'Stationary'),
    (12002, 1101, 7005, 'Robotics Lecture', NULL, NULL, 9006, 'OnlineLiveClass'),
    (12003, 1101, 7006, 'Robotics Seminar', NULL, NULL, 9007, 'OfflineVideo');

    INSERT INTO StationaryClass
    (MeetingID, RoomID, GroupSize, StartDate, Duration)
VALUES
    (120010, 8005, 20, '2025-04-05 10:00:00', '02:00:00');

    INSERT INTO OnlineLiveClass
    (MeetingID, Link, StartDate, Duration)
VALUES
    (12002, 'https://zoom.us/robotics_lecture', '2025-04-10 14:00:00', '01:30:00');

    INSERT INTO OfflineVideoClass
    (MeetingID, VideoLink, StartDate, Deadline)
VALUES
    (12003, 'https://videoserver.com/robotics_seminar', '2025-04-15 09:00:00', '2025-04-15 11:00:00');

    INSERT INTO SubjectStudiesAssignment
    (SubjectID, StudiesID)
VALUES
    (1101, 901);

    EXEC p_DeleteConvention 
        @ConventionID = 1101;

    IF EXISTS (
        SELECT 1
FROM Convention
WHERE ConventionID = 1101
    )
    BEGIN
    RAISERROR('Test Failed: Convention record was not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM StationaryClass
WHERE MeetingID = 120010
    )
    BEGIN
    RAISERROR('Test Failed: StationaryClass records related to MeetingID 120010 were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM OnlineLiveClass
WHERE MeetingID = 12002
    )
    BEGIN
    RAISERROR('Test Failed: OnlineLiveClass records related to MeetingID 12002 were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM OfflineVideoClass
WHERE MeetingID = 12003
    )
    BEGIN
    RAISERROR('Test Failed: OfflineVideoClass records related to MeetingID 12003 were not deleted.', 16, 1);
END

    PRINT 'Test Passed: p_DeleteConvention executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteConvention - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- =====================================================================
-- 3. Internship Management
-- =====================================================================

-- ---------------------------------------------------------------------
-- a. Testing p_CreateInternship procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_CreateInternship';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Studies
    (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID, EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate, ServiceID)
VALUES
    (2501, 'Electrical Engineering', 'Study of electrical systems.', 2005, 120, DATEADD(DAY, 60, GETDATE()), 8, DATEADD(YEAR, 4, GETDATE()), 9001);

    DECLARE @SD DATETIME;
    SET @SD = '2025-04-01';
    EXEC p_CreateInternship
        @InternshipID = NULL,
        @StudiesID = 2501,
        @StartDate = @SD;

    DECLARE @InternshipID INT = (SELECT MAX(InternshipID)
FROM Internship);

    IF NOT EXISTS (
        SELECT 1
FROM Internship
WHERE InternshipID = @InternshipID
    AND StudiesID = 2501
    AND StartDate = @SD
    )
    BEGIN
    RAISERROR('Test Failed: Internship record was not created correctly.', 16, 1);
END

    PRINT 'Test Passed: p_CreateInternship executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_CreateInternship - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- b. Testing p_EditInternship procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_EditInternship';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Internship
    (InternshipID, StudiesID, StartDate)
VALUES
    (2601, 2501, DATEADD(DAY, 90, GETDATE()));

    DECLARE @SD DATETIME = '2025-07-15';
    EXEC p_EditInternship
        @InternshipID = 2601,
        @StartDate = @SD;

    IF NOT EXISTS (
        SELECT 1
FROM Internship
WHERE InternshipID = 2601
    AND StartDate = @SD
    )
    BEGIN
    RAISERROR('Test Failed: Internship StartDate was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM Internship
WHERE InternshipID = 2601
    AND (StudiesID <> 2501)
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in Internship were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_EditInternship executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_EditInternship - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- c. Testing p_AddStudentInternship procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_AddStudentInternship';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Users
    (UserID, FirstName, LastName, UserTypeID)
VALUES
    (2701, 'Bob', 'Williams', 1);

    INSERT INTO StudiesDetails
    (StudentID, StudiesID, StudiesGrade, SemesterID)
VALUES
    (2701, 2801, 0, 1);

    INSERT INTO Internship
    (InternshipID, StudiesID, StartDate)
VALUES
    (2701, 2801, DATEADD(DAY, 90, GETDATE()));

    EXEC p_AddStudentInternship
        @InternshipID = 2701,
        @StudiesID = 2801,
        @StudentID = 2701,
        @Duration = 14, -- Default duration
        @InternshipGrade = 0, -- Default grade
        @InternshipAttendance = 1; -- Default attendance

    IF NOT EXISTS (
        SELECT 1
FROM InternshipDetails
WHERE InternshipID = 2701
    AND StudentID = 2701
    AND Duration = 14
    AND InternshipGrade = 0
    AND InternshipAttendance = 1
    )
    BEGIN
    RAISERROR('Test Failed: InternshipDetails record was not created correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM InternshipDetails
WHERE InternshipID = 2701
    AND StudentID = 2701
    AND (Duration <> 14
    OR InternshipGrade <> 0
    OR InternshipAttendance <> 1)
    )
    BEGIN
    RAISERROR('Test Failed: InternshipDetails fields were not set to default values correctly.', 16, 1);
END

    PRINT 'Test Passed: p_AddStudentInternship executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_AddStudentInternship - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- d. Testing p_InitiateInternship procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_InitiateInternship';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Users
    (UserID, FirstName, LastName, UserTypeID)
VALUES
    (3101, 'Charlie', 'Green', 1),
    (3102, 'Diana', 'Prince', 1);
    
    INSERT INTO Studies
    (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID, EnrollmentLimit, EnrollmentDeadline, SemesterCount, ExpectedGraduationDate, ServiceID)
VALUES
    (2901, 'Computer Engineering', 'Study of computer hardware and software.', 2006, 100, DATEADD(DAY, 60, GETDATE()), 8, DATEADD(YEAR, 4, GETDATE()), 9001);

    INSERT INTO StudiesDetails
    (StudentID, StudiesID, StudiesGrade, SemesterID)
VALUES
    (3101, 2901, 0, 1),
    (3102, 2901, 0, 1);

    INSERT INTO Internship
    (InternshipID, StudiesID, StartDate)
VALUES
    (2801, 2901, DATEADD(DAY, 90, GETDATE()));

    EXEC p_InitiateInternship
        @InternshipID = 2801,
        @StudiesID = 2901,
        @Duration = 20,
        @InternshipGrade = 0,
        @InternshipAttendance = 1;

    IF NOT EXISTS (
        SELECT 1
FROM InternshipDetails
WHERE InternshipID = 2801
    AND StudentID = 3101
    AND Duration = 20
    AND InternshipGrade = 0
    AND InternshipAttendance = 1
    )
    BEGIN
    RAISERROR('Test Failed: InternshipDetails record for StudentID 3101 was not created correctly.', 16, 1);
END

    IF NOT EXISTS (
        SELECT 1
FROM InternshipDetails
WHERE InternshipID = 2801
    AND StudentID = 3102
    AND Duration = 20
    AND InternshipGrade = 0
    AND InternshipAttendance = 1
    )
    BEGIN
    RAISERROR('Test Failed: InternshipDetails record for StudentID 3102 was not created correctly.', 16, 1);
END

    PRINT 'Test Passed: p_InitiateInternship executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_InitiateInternship - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- e. Testing p_DeleteInternship procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteInternship';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Internship
    (InternshipID, StudiesID, StartDate)
VALUES
    (3001, 2902, DATEADD(DAY, 90, GETDATE()));

    INSERT INTO InternshipDetails
    (InternshipID, StudentID, Duration, InternshipGrade, InternshipAttendance)
VALUES
    (3001, 3103, 15, 1, 1),
    (3001, 3104, 20, 0, 0);

    EXEC p_DeleteInternship 
        @InternshipID = 3001;

    IF EXISTS (
        SELECT 1
FROM Internship
WHERE InternshipID = 3001
    )
    BEGIN
    RAISERROR('Test Failed: Internship record was not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM InternshipDetails
WHERE InternshipID = 3001
    )
    BEGIN
    RAISERROR('Test Failed: InternshipDetails records related to InternshipID 3001 were not deleted.', 16, 1);
END

    PRINT 'Test Passed: p_DeleteInternship executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteInternship - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- f. Testing p_DeleteInternshipDetails procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteInternshipDetails';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Users
    (UserID, FirstName, LastName, UserTypeID)
VALUES
    (3105, 'Ethan', 'Hunt', 1); -- Assuming UserTypeID 1 represents students

    INSERT INTO Internship
    (InternshipID, StudiesID, StartDate)
VALUES
    (3101, 2903, DATEADD(DAY, 90, GETDATE()));

    INSERT INTO InternshipDetails
    (InternshipID, StudentID, Duration, InternshipGrade, InternshipAttendance)
VALUES
    (3101, 3105, 10, 1, 1);

    EXEC p_DeleteInternshipDetails 
        @InternshipID = 3101,
        @StudentID = 3105;

    IF EXISTS (
        SELECT 1
FROM InternshipDetails
WHERE InternshipID = 3101
    AND StudentID = 3105
    )
    BEGIN
    RAISERROR('Test Failed: InternshipDetails record was not deleted.', 16, 1);
END

    PRINT 'Test Passed: p_DeleteInternshipDetails executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteInternshipDetails - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- =====================================================================
-- 4. ClassMeeting Management
-- =====================================================================

-- ---------------------------------------------------------------------
-- a. Testing p_CreateStationaryClass procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_CreateStationaryClass';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Services
    (ServiceID, ServiceType)
VALUES
    (9001, 'ClassMeetingService');

    INSERT INTO Convention
    (ConventionID, SubjectID, StartDate, SemesterID, Duration, ServiceID)
VALUES
    (4001, 1401, '2025-01-01', 5001, 80, 9001);

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, StudiesID, ServiceID)
VALUES
    (1401, 'Physics', 'Study of physical phenomena.', 20010, 3, 1, 9002);

    INSERT INTO Users
    (UserID, FirstName, LastName, UserTypeID)
VALUES
    (7001, 'Emily', 'Clark', 2);

    INSERT INTO Rooms
    (RoomID, Capacity)
VALUES
    (8001, 30);

    EXEC p_CreateStationaryClass
        @SubjectID = 1401,
        @TeacherID = 7001,
        @MeetingName = 'Physics Lab Session 1',
        @TranslatorID = NULL,
        @LanguageID = NULL,
        @RoomID = 8001,
        @GroupSize = 25,
        @StartDate = '2025-02-15 09:00:00',
        @Duration = '02:00:00',
        @PriceStudents = 50.00,
        @PriceOthers = 75.00;

    DECLARE @MeetingID INT = (SELECT MAX(ClassMeetingID)
FROM ClassMeeting);

    IF NOT EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = @MeetingID
    AND SubjectID = 1401
    AND TeacherID = 7001
    AND MeetingName = 'Physics Lab Session 1'
    AND MeetingType = 'Stationary'
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeeting record was not created correctly.', 16, 1);
END

    IF NOT EXISTS (
        SELECT 1
FROM StationaryClass
WHERE MeetingID = @MeetingID
    AND RoomID = 8001
    AND GroupSize = 25
    AND StartDate = '2025-02-15 09:00:00'
    AND Duration = '02:00:00'
    )
    BEGIN
    RAISERROR('Test Failed: StationaryClass record was not created correctly.', 16, 1);
END

    DECLARE @ServiceID INT = (SELECT ServiceID
FROM ClassMeeting
WHERE ClassMeetingID = @MeetingID);
    IF NOT EXISTS (
        SELECT 1
FROM ClassMeetingService
WHERE ServiceID = @ServiceID
    AND PriceStudents = 50.00
    AND PriceOthers = 75.00
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeetingService record was not linked correctly.', 16, 1);
END

    PRINT 'Test Passed: p_CreateStationaryClass executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_CreateStationaryClass - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- b. Testing p_CreateOnlineLiveClass procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_CreateOnlineLiveClass';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Services
    (ServiceID, ServiceType)
VALUES
    (9002, 'ClassMeetingService');

    INSERT INTO Convention
    (ConventionID, SubjectID, StartDate, SemesterID, Duration, ServiceID)
VALUES
    (4002, 1402, '2025-02-01', 5002, 30, 9002);

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, StudiesID, ServiceID)
VALUES
    (1402, 'Chemistry', 'Study of chemical processes.', 2002, 3, 2, 9003);

    INSERT INTO Users
    (UserID, UserTypeID, FirstName, LastName)
VALUES
    (7002, 2, 'Michael', 'Brown');

    DECLARE @SD DATETIME = '2025-02-20 10:00:00';
    DECLARE @Dur TIME = '01:30:00';
    EXEC p_CreateOnlineLiveClass
        @SubjectID = 1402,
        @TeacherID = 7002,
        @MeetingName = 'Chemistry Online Lecture',
        @TranslatorID = NULL,
        @LanguageID = NULL,
        @Link = 'https://zoom.us/chemistry101',
        @StartDate = @SD,
        @Duration = @Dur,
        @PriceStudents = 40.00,
        @PriceOthers = 60.00;

    DECLARE @MeetingID INT = (SELECT MAX(ClassMeetingID)
FROM ClassMeeting);

    IF NOT EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = @MeetingID
    AND SubjectID = 1402
    AND TeacherID = 7002
    AND MeetingName = 'Chemistry Online Lecture'
    AND MeetingType = 'OnlineLiveClass'
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeeting record was not created correctly.', 16, 1);
END

    IF NOT EXISTS (
        SELECT 1
FROM OnlineLiveClass
WHERE MeetingID = @MeetingID
    AND Link = 'https://zoom.us/chemistry101'
    AND StartDate = '2025-02-20 10:00:00'
    AND Duration = '01:30:00'
    )
    BEGIN
    RAISERROR('Test Failed: OnlineLiveClass record was not created correctly.', 16, 1);
END

    DECLARE @ServiceID INT = (SELECT ServiceID
FROM ClassMeeting
WHERE ClassMeetingID = @MeetingID);
    IF NOT EXISTS (
        SELECT 1
FROM ClassMeetingService
WHERE ServiceID = @ServiceID
    AND PriceStudents = 40.00
    AND PriceOthers = 60.00
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeetingService record was not linked correctly.', 16, 1);
END

    PRINT 'Test Passed: p_CreateOnlineLiveClass executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_CreateOnlineLiveClass - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- c. Testing p_CreateOfflineVideoClass procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_CreateOfflineVideoClass';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Services
    (ServiceID, ServiceType)
VALUES
    (9003, 'ClassMeetingService');

    INSERT INTO ClassMeetingService
    (ServiceID, PriceStudents, PriceOthers)
VALUES
    (9003, 30.00, 50.00);

    Declare @ConvStartDate DATETIME = '2025-01-15';
    INSERT INTO Convention
    (ConventionID, SubjectID, StartDate, SemesterID, Duration, ServiceID)
VALUES
    (140003, 1403, @ConvStartDate, 5003, 100, 9004);

    INSERT INTO Subject
    (SubjectID, SubjectName, SubjectDescription, SubjectCoordinatorID, Meetings, StudiesID, ServiceID)
VALUES
    (1403, 'Biology', 'Study of living organisms.', 2003, 3, 1, 9005);

    INSERT INTO Users
    (UserID, UserTypeID, FirstName, LastName)
VALUES
    (7003, 2, 'Sarah', 'Lee'),
    -- Teacher
    (1602, 3, 'Mark', 'Smith'); -- Translator

    INSERT INTO TranslatorsLanguages
    (TranslatorID, LanguageID)
VALUES
    (1602, 1701);
    
    INSERT INTO Languages
    (LanguageID, LanguageName)
VALUES
    (1701, 'OldEnglish');

    DECLARE @SD DATETIME = DATEADD(DAY, 1, GETDATE());
    DECLARE @D DATETIME = DATEADD(DAY, 7, @SD);

    EXEC p_CreateOfflineVideoClass
        @SubjectID = 1403,
        @TeacherID = 7003,
        @MeetingName = 'Biology Recorded Lecture',
        @TranslatorID = 1602,
        @LanguageID = 1701,
        @VideoLink = 'https://videoserver.com/biology101',
        @StartDate = @SD,
        @Deadline = @D,
        @PriceStudents = 30.00,
        @PriceOthers = 50.00;


    DECLARE @MeetingID INT = (SELECT MAX(ClassMeetingID)
FROM ClassMeeting);

    IF NOT EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = @MeetingID
    AND SubjectID = 1403
    AND TeacherID = 7003
    AND MeetingName = 'Biology Recorded Lecture'
    AND MeetingType = 'OfflineVideo'
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeeting record was not created correctly.', 16, 1);
END

    IF NOT EXISTS (
        SELECT 1
FROM OfflineVideoClass
WHERE MeetingID = @MeetingID
    AND VideoLink = 'https://videoserver.com/biology101' 
        --   AND StartDate = @SD
        --   AND Deadline = @D
    )
    BEGIN
    RAISERROR('Test Failed: OfflineVideoClass record was not created correctly.', 16, 2);
END

    DECLARE @ServiceID INT = (SELECT ServiceID
FROM ClassMeeting
WHERE ClassMeetingID = @MeetingID);
    IF NOT EXISTS (
        SELECT 1
FROM ClassMeetingService
WHERE ServiceID = @ServiceID
    AND PriceStudents = 30.00
    AND PriceOthers = 50.00
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeetingService record was not linked correctly.', 16, 3);
END

    PRINT 'Test Passed: p_CreateOfflineVideoClass executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_CreateOfflineVideoClass - %s', 16, 4, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- d. Testing p_EditClassMeeting procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_EditClassMeeting';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Services
    (ServiceID, ServiceType)
VALUES
    (9004, 'ClassMeetingService');

    INSERT INTO ClassMeetingService
    (ServiceID, PriceStudents, PriceOthers)
VALUES
    (9004, 50.00, 75.00);

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (19701, 1401, 7001, 'Physics Lab Session', NULL, NULL, 9004, 'Stationary');

    INSERT INTO StationaryClass
    (MeetingID, RoomID, GroupSize, StartDate, Duration)
VALUES
    (19701, 8001, 25, '2025-02-18 09:00:00', '02:00:00');

    EXEC p_EditClassMeeting
        @MeetingID = 19701,
        @MeetingName = 'Advanced Physics Lab Session',
        @PriceStudents = 55.00,
        @PriceOthers = 80.00;

    IF NOT EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 19701
    AND MeetingName = 'Advanced Physics Lab Session'
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeeting MeetingName was not updated correctly.', 16, 1);
END

    DECLARE @ServiceID INT = (SELECT ServiceID
FROM ClassMeeting
WHERE ClassMeetingID = 19701);
    IF NOT EXISTS (
        SELECT 1
FROM ClassMeetingService
WHERE ServiceID = @ServiceID
    AND PriceStudents = 55.00
    AND PriceOthers = 80.00
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeetingService prices were not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 19701
    AND (SubjectID <> 1401 OR TeacherID <> 7001
    OR TranslatorID IS NOT NULL OR LanguageID IS NOT NULL
    OR MeetingType <> 'Stationary')
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in ClassMeeting were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_EditClassMeeting executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_EditClassMeeting - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- e. Testing p_ChangeClassMeetingTeacher procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_ChangeClassMeetingTeacher';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Users
    (UserID, FirstName, LastName, UserTypeID)
VALUES
    (1501, 'Emily', 'Clark', 2),
    -- Existing Teacher
    (1504, 'Robert', 'King', 2); -- New Teacher

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (19801, 1401, 1501, 'Physics Advanced Lab', NULL, NULL, 9005, 'Stationary');

    EXEC p_ChangeClassMeetingTeacher
        @MeetingID = 19801,
        @NewTeacherID = 1504;

    IF NOT EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 19801
    AND TeacherID = 1504
    )
    BEGIN
    RAISERROR('Test Failed: TeacherID was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 19801
    AND (SubjectID <> 1401 OR MeetingName <> 'Physics Advanced Lab'
    OR TranslatorID IS NOT NULL OR LanguageID IS NOT NULL
    OR MeetingType <> 'Stationary')
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in ClassMeeting were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_ChangeClassMeetingTeacher executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_ChangeClassMeetingTeacher - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- f. Testing p_ChangeClassMeetingTranslator procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_ChangeClassMeetingTranslator';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Users
    (UserID, FirstName, LastName, UserTypeID)
VALUES
    (1602, 'Mark', 'Smith', 3),
    -- Existing Translator
    (1603, 'Lisa', 'Johnson', 3); -- New Translator

    INSERT INTO TranslatorsLanguages
    (TranslatorID, LanguageID)
VALUES
    (1602, 1701),
    (1603, 1701);

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (19010, 1401, 7001, 'Physics Seminar', 1602, 1701, 9006, 'Stationary');

    EXEC p_ChangeClassMeetingTranslator
        @MeetingID = 19010,
        @NewTranslatorID = 1603;

    IF NOT EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 19010
    AND TranslatorID = 1603
    )
    BEGIN
    RAISERROR('Test Failed: TranslatorID was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 19010
    AND (SubjectID <> 1401 OR TeacherID <> 7001
    OR LanguageID <> 1701
    OR MeetingType <> 'Stationary')
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in ClassMeeting were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_ChangeClassMeetingTranslator executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_ChangeClassMeetingTranslator - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- g. Testing p_ChangeClassMeetingLanguage procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_ChangeClassMeetingLanguage';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Languages
    (LanguageID, LanguageName)
VALUES
    (1701, 'English'),
    (1702, 'Spanish');

    INSERT INTO Users
    (UserID, FirstName, LastName, UserTypeID)
VALUES
    (1603, 'Lisa', 'Williams', 3);

    INSERT INTO TranslatorsLanguages
    (TranslatorID, LanguageID)
VALUES
    (1603, 1702); -- Translator Lisa speaks Spanish

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (20010, 1401, 7001, 'Physics Lecture', 1603, 1701, 9007, 'Stationary');

    EXEC p_ChangeClassMeetingLanguage
        @MeetingID = 20010,
        @NewLanguageID = 1702;

    IF NOT EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 20010
    AND LanguageID = 1702
    )
    BEGIN
    RAISERROR('Test Failed: LanguageID was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 20010
    AND (SubjectID <> 1401 OR TeacherID <> 7001
    OR TranslatorID <> 1603
    OR MeetingType <> 'Stationary')
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in ClassMeeting were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_ChangeClassMeetingLanguage executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_ChangeClassMeetingLanguage - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- h. Testing p_EditStationaryClass procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_EditStationaryClass';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Rooms
    (RoomID, Capacity)
VALUES
    (1601, 30),
    (1603, 35);

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (21010, 1401, 7001, 'Physics Lab Session', NULL, NULL, 9008, 'Stationary');

    INSERT INTO StationaryClass
    (MeetingID, RoomID, GroupSize, StartDate, Duration)
VALUES
    (21010, 1601, 25, '2025-02-18 09:00:00', '02:00:00');

    EXEC p_EditStationaryClass
        @MeetingID = 21010,
        @RoomID = 1603,
        @GroupSize = 28;

    IF NOT EXISTS (
        SELECT 1
FROM StationaryClass
WHERE MeetingID = 21010
    AND RoomID = 1603
    AND GroupSize = 28
    )
    BEGIN
    RAISERROR('Test Failed: StationaryClass record was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM StationaryClass
WHERE MeetingID = 21010
    AND (StartDate <> '2025-02-18 09:00:00'
    OR Duration <> '02:00:00')
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in StationaryClass were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_EditStationaryClass executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_EditStationaryClass - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- i. Testing p_EditOnlineLiveClass procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_EditOnlineLiveClass';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Services
    (ServiceID, ServiceType)
VALUES
    (90100, 'ClassMeetingService');

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (220010, 1402, 7002, 'Chemistry Live Lecture', NULL, NULL, 90100, 'OnlineLiveClass');

    INSERT INTO OnlineLiveClass
    (MeetingID, Link, StartDate, Duration)
VALUES
    (220010, 'https://zoom.us/chemistry_live', '2025-02-20 10:00:00', '01:30:00');

    INSERT INTO ClassMeetingService
    (ServiceID, PriceStudents, PriceOthers)
VALUES
    (90100, 55.00, 80.00);

    EXEC p_EditOnlineLiveClass
        @MeetingID = 220010,
        @Link = 'https://zoom.us/advancedchemistry',
        @Duration = '02:30:00';

    IF NOT EXISTS (
        SELECT 1
FROM OnlineLiveClass
WHERE MeetingID = 220010
    AND Link = 'https://zoom.us/advancedchemistry'
    AND Duration = '02:30:00'
    )
    BEGIN
    RAISERROR('Test Failed: OnlineLiveClass record was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM OnlineLiveClass
WHERE MeetingID = 220010
    AND StartDate <> '2025-02-20 10:00:00'
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in OnlineLiveClass were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_EditOnlineLiveClass executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_EditOnlineLiveClass - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- j. Testing p_EditOfflineVideoClass procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_EditOfflineVideoClass';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Services
    (ServiceID, ServiceType)
VALUES
    (90011, 'ClassMeetingService');

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (23001, 1403, 7003, 'Biology Recorded Lecture', 1602, 1701, 90011, 'OfflineVideo');

    INSERT INTO OfflineVideoClass
    (MeetingID, VideoLink, StartDate, Deadline)
VALUES
    (23001, 'https://videoserver.com/biology101', '2025-02-25 14:00:00', '2025-02-25 16:00:00');

    EXEC p_EditOfflineVideoClass
        @MeetingID = 23001,
        @VideoLink = 'https://videoserver.com/advancedbiology',
        @Deadline = '2025-02-25 18:00:00';

    IF NOT EXISTS (
        SELECT 1
FROM OfflineVideoClass
WHERE MeetingID = 23001
    AND VideoLink = 'https://videoserver.com/advancedbiology'
    AND Deadline = '2025-02-25 18:00:00'
    )
    BEGIN
    RAISERROR('Test Failed: OfflineVideoClass record was not updated correctly.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM OfflineVideoClass
WHERE MeetingID = 23001
    AND (VideoLink <> 'https://videoserver.com/advancedbiology'
    OR StartDate <> '2025-02-25 14:00:00')
    )
    BEGIN
    RAISERROR('Test Failed: Other fields in OfflineVideoClass were unexpectedly modified.', 16, 1);
END

    PRINT 'Test Passed: p_EditOfflineVideoClass executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_EditOfflineVideoClass - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- k. Testing p_DeleteClassMeeting procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteClassMeeting';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Services
    (ServiceID, ServiceType)
VALUES
    (90012, 'ClassMeetingService');

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (20401, 1401, 7001, 'Physics Advanced Lab', NULL, NULL, 90012, 'OnlineLiveClass');

    INSERT INTO OnlineLiveClass
    (MeetingID, Link, StartDate, Duration)
VALUES
    (20401, 'https://zoom.us/physics_advanced_lab', '2025-03-10 10:00:00', '02:00:00');

    INSERT INTO ClassMeetingService
    (ServiceID, PriceStudents, PriceOthers)
VALUES
    (90012, 55.00, 80.00);

    EXEC p_DeleteClassMeeting 
        @MeetingID = 20401;

    IF EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 20401
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeeting record was not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1 
        FROM ClassMeetingService 
        WHERE ServiceID = 90012
    )
    BEGIN
        RAISERROR('Test Failed: ClassMeetingService record was not deleted.', 16, 2);
    END

    PRINT 'Test Passed: p_DeleteClassMeeting executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteClassMeeting - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- g. Testing p_DeleteUserClassMeetingDetails procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteUserClassMeetingDetails';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (3201, 1401, 7001, 'Physics Workshop', NULL, NULL, 9013, 'Stationary');

    -- Assume MeetingType = 'Stationary' requires SyncClassDetails
    INSERT INTO SyncClassDetails
    (MeetingID, StudentID, Attendance)
VALUES
    (3201, 4001, 1);

    EXEC p_DeleteUserClassMeetingDetails 
        @MeetingID = 3201;

    IF EXISTS (
        SELECT 1
FROM SyncClassDetails
WHERE MeetingID = 3201
    )
    BEGIN
    RAISERROR('Test Failed: SyncClassDetails records were not deleted for Stationary meeting.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM AsyncClassDetails
WHERE MeetingID = 3201
    )
    BEGIN
    RAISERROR('Test Failed: AsyncClassDetails records were incorrectly modified.', 16, 1);
END

    PRINT 'Test Passed: p_DeleteUserClassMeetingDetails executed successfully for Stationary meeting.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteUserClassMeetingDetails - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- ---------------------------------------------------------------------
-- h. Testing p_DeleteClassMeetingDetails procedure
-- ---------------------------------------------------------------------
PRINT 'Running Test: p_DeleteClassMeetingDetails';
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO ClassMeeting
    (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, LanguageID, ServiceID, MeetingType)
VALUES
    (3301, 1401, 7001, 'Physics Seminar', NULL, NULL, 9014, 'Stationary');

    INSERT INTO StationaryClass
    (MeetingID, RoomID, GroupSize, StartDate, Duration)
VALUES
    (3301, 8006, 20, '2025-03-05 10:00:00', '02:00:00');

    INSERT INTO SyncClassDetails
    (MeetingID, StudentID, Attendance)
VALUES
    (3301, 4002, 0);

    EXEC p_DeleteClassMeetingDetails 
        @MeetingID = 3301;

    IF EXISTS (
        SELECT 1
FROM StationaryClass
WHERE MeetingID = 3301
    )
    BEGIN
    RAISERROR('Test Failed: StationaryClass record was not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM SyncClassDetails
WHERE MeetingID = 3301
    )
    BEGIN
    RAISERROR('Test Failed: SyncClassDetails records were not deleted.', 16, 1);
END

    IF EXISTS (
        SELECT 1
FROM ClassMeeting
WHERE ClassMeetingID = 3301
    )
    BEGIN
    RAISERROR('Test Failed: ClassMeeting record was not deleted.', 16, 1);
END

    PRINT 'Test Passed: p_DeleteClassMeetingDetails executed successfully.';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Test Failed: p_DeleteClassMeetingDetails - %s', 16, 1, @ErrorMessage);
END CATCH;
GO

-- =====================================================================
-- End of Test Suite
-- =====================================================================
