use u_szymocha
------------------------------------------------------------------------------
-- TABLE: ServiceUserDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_ServiceUserDetails_DateOfRegistration
    ON dbo.ServiceUserDetails (DateOfRegistration);
GO

------------------------------------------------------------------------------
-- TABLE: Users
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Users_DateOfBirth
    ON dbo.Users (DateOfBirth);
GO

------------------------------------------------------------------------------
-- TABLE: UserContact
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_UserContact_Email
    ON dbo.UserContact (Email);
GO

------------------------------------------------------------------------------
-- TABLE: UserAddressDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_UserAddressDetails_PostalCode  
    ON dbo.UserAddressDetails (PostalCode);

CREATE NONCLUSTERED INDEX IX_UserAddressDetails_LocationID
    ON dbo.UserAddressDetails (LocationID);
GO

------------------------------------------------------------------------------
-- TABLE: Studies
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Studies_EnrollmentDeadline
    ON dbo.Studies (EnrollmentDeadline);
GO

------------------------------------------------------------------------------
-- TABLE: Subject
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Subject_SubjectCoordinatorID
    ON dbo.Subject (SubjectCoordinatorID);
GO

------------------------------------------------------------------------------
-- TABLE: SemesterDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_SemesterDetails_StudiesID
    ON dbo.SemesterDetails (StudiesID);

CREATE NONCLUSTERED INDEX IX_SemesterDetails_StartDate
    ON dbo.SemesterDetails (StartDate);

CREATE NONCLUSTERED INDEX IX_SemesterDetails_EndDate
    ON dbo.SemesterDetails (EndDate);

CREATE NONCLUSTERED INDEX IX_SemesterDetails_StudiesID_DateRange
    ON dbo.SemesterDetails (StudiesID, StartDate, EndDate);
GO

------------------------------------------------------------------------------
-- TABLE: ClassMeeting
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_ClassMeeting_SubjectID
    ON dbo.ClassMeeting (SubjectID);

CREATE NONCLUSTERED INDEX IX_ClassMeeting_TeacherID
    ON dbo.ClassMeeting (TeacherID);

CREATE NONCLUSTERED INDEX IX_ClassMeeting_TranslatorID
    ON dbo.ClassMeeting (TranslatorID);

CREATE NONCLUSTERED INDEX IX_ClassMeeting_LanguageID
    ON dbo.ClassMeeting (LanguageID);
GO

------------------------------------------------------------------------------
-- TABLE: StationaryClass
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_StationaryClass_StartDate
    ON dbo.StationaryClass (StartDate);

CREATE NONCLUSTERED INDEX IX_StationaryClass_RoomID
    ON dbo.StationaryClass (RoomID);
GO

------------------------------------------------------------------------------
-- TABLE: StationaryMeeting
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_StationaryMeeting_Module
    ON dbo.StationaryMeeting (ModuleID);

CREATE NONCLUSTERED INDEX IX_StationaryMeeting_Teacher
    ON dbo.StationaryMeeting (TeacherID);

CREATE NONCLUSTERED INDEX IX_StationaryMeeting_Date
    ON dbo.StationaryMeeting (MeetingDate);
GO

------------------------------------------------------------------------------
-- TABLE: StationaryMeetingDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_StationaryMeetingDetails_Participant
    ON dbo.StationaryMeetingDetails (ParticipantID);
GO

------------------------------------------------------------------------------
-- TABLE: OnlineLiveMeeting
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OnlineLiveMeeting_Module
    ON dbo.OnlineLiveMeeting (ModuleID);

CREATE NONCLUSTERED INDEX IX_OnlineLiveMeeting_Teacher
    ON dbo.OnlineLiveMeeting (TeacherID);

CREATE NONCLUSTERED INDEX IX_OnlineLiveMeeting_Date
    ON dbo.OnlineLiveMeeting (MeetingDate);
GO

------------------------------------------------------------------------------
-- TABLE: OnlineLiveMeetingDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OnlineLiveMeetingDetails_Participant
    ON dbo.OnlineLiveMeetingDetails (ParticipantID);
GO

------------------------------------------------------------------------------
-- TABLE: OfflineVideo
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OfflineVideo_Module
    ON dbo.OfflineVideo (ModuleID);

CREATE NONCLUSTERED INDEX IX_OfflineVideo_Teacher
    ON dbo.OfflineVideo (TeacherID);
GO

------------------------------------------------------------------------------
-- TABLE: OfflineVideoDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OfflineVideoDetails_Participant
    ON dbo.OfflineVideoDetails (ParticipantID);
GO

------------------------------------------------------------------------------
-- TABLE: Courses
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Courses_ServiceID
    ON dbo.Courses (ServiceID);

CREATE NONCLUSTERED INDEX IX_Courses_CourseCoordinatorID
    ON dbo.Courses (CourseCoordinatorID);

CREATE NONCLUSTERED INDEX IX_Courses_CourseDate
    ON dbo.Courses (CourseDate);

CREATE NONCLUSTERED INDEX IX_Courses_CourseName
    ON dbo.Courses (CourseName);
GO

------------------------------------------------------------------------------
-- TABLE: Modules
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Modules_CourseID
    ON dbo.Modules (CourseID);

CREATE NONCLUSTERED INDEX IX_Modules_ModuleCoordinatorID
    ON dbo.Modules (ModuleCoordinatorID);

CREATE NONCLUSTERED INDEX IX_Modules_LanguageID
    ON dbo.Modules (LanguageID);

CREATE NONCLUSTERED INDEX IX_Modules_TranslatorID
    ON dbo.Modules (TranslatorID);
GO

------------------------------------------------------------------------------
-- TABLE: CourseParticipants
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_CourseParticipants_CourseID
    ON dbo.CourseParticipants (CourseID);
GO

------------------------------------------------------------------------------
-- TABLE: Payments
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Payments_OrderID
    ON dbo.Payments (OrderID);

CREATE NONCLUSTERED INDEX IX_Payments_OrderID_Status
    ON dbo.Payments (OrderID)
    INCLUDE (PaymentStatus);
GO

------------------------------------------------------------------------------
-- TABLE: Orders
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Orders_UserID
    ON dbo.Orders (UserID);

CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
    ON dbo.Orders (OrderDate);

CREATE NONCLUSTERED INDEX IX_Orders_UserID_OrderDate
    ON dbo.Orders (UserID, OrderDate)
    INCLUDE (OrderTotal);
GO

------------------------------------------------------------------------------
-- TABLE: Employees
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Employees_DateOfHire
    ON dbo.Employees (DateOfHire DESC);
GO

------------------------------------------------------------------------------
-- TABLE: AsyncClassDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_AsyncClassDetails_StudentID
    ON dbo.AsyncClassDetails (StudentID);
GO

------------------------------------------------------------------------------
-- TABLE: SyncClassDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_SyncClassDetails_StudentID
    ON dbo.SyncClassDetails (StudentID);
GO

------------------------------------------------------------------------------
-- TABLE: StudiesDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_StudiesDetails_Studies_Semester
    ON dbo.StudiesDetails (StudiesID, SemesterID);
GO

------------------------------------------------------------------------------
-- TABLE: Internship
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Internship_StudiesID
    ON dbo.Internship (StudiesID);

CREATE NONCLUSTERED INDEX IX_Internship_StartDate
    ON dbo.Internship (StartDate);
GO

CREATE NONCLUSTERED INDEX IX_Internship_SemesterID
    ON dbo.Internship (SemesterID);
GO

------------------------------------------------------------------------------
-- TABLE: InternshipDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_InternshipDetails_StudentID
    ON dbo.InternshipDetails (StudentID);
GO

------------------------------------------------------------------------------
-- TABLE: Convention
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Convention_SemesterID
    ON dbo.Convention (SemesterID);

CREATE NONCLUSTERED INDEX IX_Convention_StartDate
    ON dbo.Convention (StartDate);
GO

------------------------------------------------------------------------------
-- TABLE: OfflineVideoClass
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OfflineVideoClass_StartDate
    ON dbo.OfflineVideoClass (StartDate);

CREATE NONCLUSTERED INDEX IX_OfflineVideoClass_Deadline
    ON dbo.OfflineVideoClass (Deadline);
GO

------------------------------------------------------------------------------
-- TABLE: OnlineLiveClass
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OnlineLiveClass_StartDate
    ON dbo.OnlineLiveClass (StartDate);
GO

------------------------------------------------------------------------------
-- TABLE: EmployeesSuperior
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_EmployeesSuperior_ReportsTo
    ON dbo.EmployeesSuperior (ReportsTo);
GO

------------------------------------------------------------------------------
-- TABLE: UserTypePermissionsHierarchy
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_UserTypePermissionsHierarchy_DirectSupervisor
    ON dbo.UserTypePermissionsHierarchy (DirectTypeSupervisor);
GO

------------------------------------------------------------------------------
-- TABLE: Webinars
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Webinars_TeacherID
    ON dbo.Webinars (TeacherID);

CREATE NONCLUSTERED INDEX IX_Webinars_TranslatorID
    ON dbo.Webinars (TranslatorID);

CREATE NONCLUSTERED INDEX IX_Webinars_LanguageID
    ON dbo.Webinars (LanguageID);
GO

------------------------------------------------------------------------------
-- TABLE: WebinarDetails
------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_WebinarDetails_UserID
    ON dbo.WebinarDetails (UserID);

CREATE NONCLUSTERED INDEX IX_WebinarDetails_WebinarID
    ON dbo.WebinarDetails (WebinarID);

GO
