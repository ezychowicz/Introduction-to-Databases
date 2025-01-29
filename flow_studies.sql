use u_szymocha

BEGIN TRY
    BEGIN TRANSACTION;

    exec p_CreateStudies "Math studies", "Some description", 144, 240, '2025-10-10', 7
    -- select * FROM Studies
    -- Semesters 41-47
    -- Studies ID 16

    -- Select * from SemesterDetails
    exec p_AddSubject 'Math Fundamentals', 'Calculus etc.', 1322, 5
    -- Subject ID 41

    -- Select SubjectID, SubjectName, SubjectCoordinatorID, SubjectDescription,  Meetings from Subject

    exec p_AddSubjectToStudies 41, 16
    
    -- Select * from SubjectStudiesAssignment

    exec p_AddConvention 41, 41, '2025-10-20', 7

    -- ConventionID 270

    -- Select * from Employees
    -- Select * from Convention
    exec p_CreateStationaryClass 41, 562, 'Calculus 1', NULL, NULL, 100, 10, '2025-10-21', '01:30:00', 0, 100

    -- Select * from StationaryClass
    -- Select * from ClassMeeting

    exec p_CreateOnlineLiveClass 41, 562, 'Calculus 1', NULL, NULL, 'www.zoom.com', '2025-10-22', '01:20:00', 0, 100

    -- Select * from OnlineLiveClass
    -- Select * from ClassMeetingService
    Select * from ClassMeeting

    exec p_EnrollStudentInStudies 378, 16

    -- Select * from StudiesDetails
    Select * from InternshipDetails

    -- Select * from SubjectDetails
    -- Select * from SyncClassDetails
    -- Select * from InternshipDetails
    -- Select * from SyncClassDetails

    Delete from StudiesDetails where StudentID = 378 and StudiesID = 16

    -- Select * from StudiesDetails

    -- SELECT * from SubjectDetails

    -- Select * from SyncClassDetails WHERE StudentID = 378

    -- SELECT * from InternshipDetails WHERE StudentID = 378

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Failed: %s', 16, 1, @ErrorMessage);
END CATCH;
GO
