use u_szymocha

-------------------------------------------------------------------------------
-- 1) SERVICEUSERDETAILS
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_ServiceUserDetails_DateOfRegistration ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Placeholder Query: "Which users registered after 2023?"
SELECT *
FROM dbo.ServiceUserDetails
WHERE DateOfRegistration > '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_ServiceUserDetails_DateOfRegistration...';
CREATE NONCLUSTERED INDEX IX_ServiceUserDetails_DateOfRegistration
    ON dbo.ServiceUserDetails (DateOfRegistration);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.ServiceUserDetails
WHERE DateOfRegistration > '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 2) USERS
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Users_DateOfBirth ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Placeholder Query: "Find all users born before 2000"
SELECT *
FROM dbo.Users
WHERE DateOfBirth < '2000-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Users_DateOfBirth...';
CREATE NONCLUSTERED INDEX IX_Users_DateOfBirth
    ON dbo.Users (DateOfBirth);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Users
WHERE DateOfBirth < '2000-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 3) USERCONTACT
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_UserContact_Email ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Placeholder Query: "Find user by Email"
SELECT *
FROM dbo.UserContact
WHERE Email = 'someone@example.com';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_UserContact_Email...';
CREATE NONCLUSTERED INDEX IX_UserContact_Email
    ON dbo.UserContact (Email);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.UserContact
WHERE Email = 'someone@example.com';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 4) USERADDRESSDETAILS (PostalCode, LocationID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_UserAddressDetails_PostalCode ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Placeholder Query: "Users in a certain PostalCode"
SELECT *
FROM dbo.UserAddressDetails
WHERE PostalCode = '30-055';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_UserAddressDetails_PostalCode...';
CREATE NONCLUSTERED INDEX IX_UserAddressDetails_PostalCode
    ON dbo.UserAddressDetails (PostalCode);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.UserAddressDetails
WHERE PostalCode = '30-055';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_UserAddressDetails_LocationID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Placeholder Query: "Users by location"
SELECT *
FROM dbo.UserAddressDetails
WHERE LocationID = 101;  -- example ID

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_UserAddressDetails_LocationID...';
CREATE NONCLUSTERED INDEX IX_UserAddressDetails_LocationID
    ON dbo.UserAddressDetails (LocationID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.UserAddressDetails
WHERE LocationID = 101;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 5) STUDIES (EnrollmentDeadline)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Studies_EnrollmentDeadline ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "Find studies whose enrollment deadline is in the future"
SELECT *
FROM dbo.Studies
WHERE EnrollmentDeadline > GETDATE();

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Studies_EnrollmentDeadline...';
CREATE NONCLUSTERED INDEX IX_Studies_EnrollmentDeadline
    ON dbo.Studies (EnrollmentDeadline);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Studies
WHERE EnrollmentDeadline > GETDATE();

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 6) SUBJECT (SubjectCoordinatorID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Subject_SubjectCoordinatorID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "Which subjects are coordinated by Coordinator X?"
SELECT *
FROM dbo.Subject
WHERE SubjectCoordinatorID = 123;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Subject_SubjectCoordinatorID...';
CREATE NONCLUSTERED INDEX IX_Subject_SubjectCoordinatorID
    ON dbo.Subject (SubjectCoordinatorID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Subject
WHERE SubjectCoordinatorID = 123;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 7) SEMESTERDETAILS (StudiesID, StartDate, EndDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_SemesterDetails_StudiesID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "All semesters for a given StudiesID"
SELECT *
FROM dbo.SemesterDetails
WHERE StudiesID = 200;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_SemesterDetails_StudiesID...';
CREATE NONCLUSTERED INDEX IX_SemesterDetails_StudiesID
    ON dbo.SemesterDetails (StudiesID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.SemesterDetails
WHERE StudiesID = 200;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_SemesterDetails_StartDate ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "Semesters starting after 2023"
SELECT *
FROM dbo.SemesterDetails
WHERE StartDate >= '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_SemesterDetails_StartDate...';
CREATE NONCLUSTERED INDEX IX_SemesterDetails_StartDate
    ON dbo.SemesterDetails (StartDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.SemesterDetails
WHERE StartDate >= '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_SemesterDetails_EndDate ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "Semesters that end before 2025"
SELECT *
FROM dbo.SemesterDetails
WHERE EndDate < '2025-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_SemesterDetails_EndDate...';
CREATE NONCLUSTERED INDEX IX_SemesterDetails_EndDate
    ON dbo.SemesterDetails (EndDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.SemesterDetails
WHERE EndDate < '2025-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 8) CLASSMEETING (SubjectID, TeacherID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_ClassMeeting_SubjectID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "All class meetings for a subject"
SELECT *
FROM dbo.ClassMeeting
WHERE SubjectID = 222;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_ClassMeeting_SubjectID...';
CREATE NONCLUSTERED INDEX IX_ClassMeeting_SubjectID
    ON dbo.ClassMeeting (SubjectID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.ClassMeeting
WHERE SubjectID = 222;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_ClassMeeting_TeacherID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "All class meetings taught by teacher #99"
SELECT *
FROM dbo.ClassMeeting
WHERE TeacherID = 99;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_ClassMeeting_TeacherID...';
CREATE NONCLUSTERED INDEX IX_ClassMeeting_TeacherID
    ON dbo.ClassMeeting (TeacherID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.ClassMeeting
WHERE TeacherID = 99;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 9) STATIONARYCLASS (StartDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_StationaryClass_StartDate ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- "Upcoming stationaries from now"
SELECT *
FROM dbo.StationaryClass
WHERE StartDate >= GETDATE();

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_StationaryClass_StartDate...';
CREATE NONCLUSTERED INDEX IX_StationaryClass_StartDate
    ON dbo.StationaryClass (StartDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryClass
WHERE StartDate >= GETDATE();

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 10) STATIONARYMEETING (ModuleID, TeacherID, MeetingDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_StationaryMeeting_Module ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeeting
WHERE ModuleID = 10;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_StationaryMeeting_Module...';
CREATE NONCLUSTERED INDEX IX_StationaryMeeting_Module
    ON dbo.StationaryMeeting (ModuleID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeeting
WHERE ModuleID = 10;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_StationaryMeeting_Teacher ===';

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeeting
WHERE TeacherID = 555;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_StationaryMeeting_Teacher...';
CREATE NONCLUSTERED INDEX IX_StationaryMeeting_Teacher
    ON dbo.StationaryMeeting (TeacherID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeeting
WHERE TeacherID = 555;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_StationaryMeeting_Date ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeeting
WHERE MeetingDate BETWEEN '2025-01-01' AND '2025-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_StationaryMeeting_Date...';
CREATE NONCLUSTERED INDEX IX_StationaryMeeting_Date
    ON dbo.StationaryMeeting (MeetingDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeeting
WHERE MeetingDate BETWEEN '2025-01-01' AND '2025-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 11) STATIONARYMEETINGDETAILS (ParticipantID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_StationaryMeetingDetails_Participant ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeetingDetails
WHERE ParticipantID = 3001;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_StationaryMeetingDetails_Participant...';
CREATE NONCLUSTERED INDEX IX_StationaryMeetingDetails_Participant
    ON dbo.StationaryMeetingDetails (ParticipantID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StationaryMeetingDetails
WHERE ParticipantID = 3001;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 12) ONLINELIVEMEETING (ModuleID, TeacherID, MeetingDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_OnlineLiveMeeting_Module ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeeting
WHERE ModuleID = 888;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OnlineLiveMeeting_Module...';
CREATE NONCLUSTERED INDEX IX_OnlineLiveMeeting_Module
    ON dbo.OnlineLiveMeeting (ModuleID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeeting
WHERE ModuleID = 888;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_OnlineLiveMeeting_Teacher ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeeting
WHERE TeacherID = 111;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OnlineLiveMeeting_Teacher...';
CREATE NONCLUSTERED INDEX IX_OnlineLiveMeeting_Teacher
    ON dbo.OnlineLiveMeeting (TeacherID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeeting
WHERE TeacherID = 111;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_OnlineLiveMeeting_Date ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeeting
WHERE MeetingDate < '2025-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OnlineLiveMeeting_Date...';
CREATE NONCLUSTERED INDEX IX_OnlineLiveMeeting_Date
    ON dbo.OnlineLiveMeeting (MeetingDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeeting
WHERE MeetingDate < '2025-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 13) ONLINELIVEMEETINGDETAILS (ParticipantID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_OnlineLiveMeetingDetails_Participant ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeetingDetails
WHERE ParticipantID = 501;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OnlineLiveMeetingDetails_Participant...';
CREATE NONCLUSTERED INDEX IX_OnlineLiveMeetingDetails_Participant
    ON dbo.OnlineLiveMeetingDetails (ParticipantID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveMeetingDetails
WHERE ParticipantID = 501;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 14) OFFLINEVIDEO (ModuleID, TeacherID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_OfflineVideo_Module ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideo
WHERE ModuleID = 777;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OfflineVideo_Module...';
CREATE NONCLUSTERED INDEX IX_OfflineVideo_Module
    ON dbo.OfflineVideo (ModuleID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideo
WHERE ModuleID = 777;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_OfflineVideo_Teacher ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideo
WHERE TeacherID = 999;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OfflineVideo_Teacher...';
CREATE NONCLUSTERED INDEX IX_OfflineVideo_Teacher
    ON dbo.OfflineVideo (TeacherID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideo
WHERE TeacherID = 999;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 15) OFFLINEVIDEODETAILS (ParticipantID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_OfflineVideoDetails_Participant ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideoDetails
WHERE ParticipantID = 111;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OfflineVideoDetails_Participant...';
CREATE NONCLUSTERED INDEX IX_OfflineVideoDetails_Participant
    ON dbo.OfflineVideoDetails (ParticipantID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideoDetails
WHERE ParticipantID = 111;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 16) COURSES (ServiceID, CourseCoordinatorID, CourseDate, CourseName)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Courses_ServiceID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE ServiceID = 1001;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Courses_ServiceID...';
CREATE NONCLUSTERED INDEX IX_Courses_ServiceID
    ON dbo.Courses (ServiceID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE ServiceID = 1001;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Courses_CourseCoordinatorID ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE CourseCoordinatorID = 46;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Courses_CourseCoordinatorID...';
CREATE NONCLUSTERED INDEX IX_Courses_CourseCoordinatorID
    ON dbo.Courses (CourseCoordinatorID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE CourseCoordinatorID = 46;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Courses_CourseDate ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE CourseDate BETWEEN '2025-01-01' AND '2025-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Courses_CourseDate...';
CREATE NONCLUSTERED INDEX IX_Courses_CourseDate
    ON dbo.Courses (CourseDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE CourseDate BETWEEN '2025-01-01' AND '2025-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Courses_CourseName ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE CourseName LIKE '%SQL%';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Courses_CourseName...';
CREATE NONCLUSTERED INDEX IX_Courses_CourseName
    ON dbo.Courses (CourseName);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Courses
WHERE CourseName LIKE '%SQL%';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 17) MODULES (CourseID, ModuleCoordinatorID, LanguageID, TranslatorID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Modules_CourseID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE CourseID = 101;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Modules_CourseID...';
CREATE NONCLUSTERED INDEX IX_Modules_CourseID
    ON dbo.Modules (CourseID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE CourseID = 101;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Modules_ModuleCoordinatorID ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE ModuleCoordinatorID = 47;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Modules_ModuleCoordinatorID...';
CREATE NONCLUSTERED INDEX IX_Modules_ModuleCoordinatorID
    ON dbo.Modules (ModuleCoordinatorID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE ModuleCoordinatorID = 47;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Modules_LanguageID ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE LanguageID = 4;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Modules_LanguageID...';
CREATE NONCLUSTERED INDEX IX_Modules_LanguageID
    ON dbo.Modules (LanguageID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE LanguageID = 4;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Modules_TranslatorID ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE TranslatorID = 5;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Modules_TranslatorID...';
CREATE NONCLUSTERED INDEX IX_Modules_TranslatorID
    ON dbo.Modules (TranslatorID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Modules
WHERE TranslatorID = 5;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 18) COURSEPARTICIPANTS (CourseID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_CourseParticipants_CourseID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.CourseParticipants
WHERE CourseID = 500;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_CourseParticipants_CourseID...';
CREATE NONCLUSTERED INDEX IX_CourseParticipants_CourseID
    ON dbo.CourseParticipants (CourseID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.CourseParticipants
WHERE CourseID = 500;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 19) PAYMENTS (OrderID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Payments_OrderID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Payments
WHERE OrderID = 2024;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Payments_OrderID...';
CREATE NONCLUSTERED INDEX IX_Payments_OrderID
    ON dbo.Payments (OrderID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Payments
WHERE OrderID = 2024;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 20) ORDERS (UserID, OrderDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Orders_UserID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Orders
WHERE UserID = 7777;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Orders_UserID...';
CREATE NONCLUSTERED INDEX IX_Orders_UserID
    ON dbo.Orders (UserID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Orders
WHERE UserID = 7777;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Orders_OrderDate ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Orders
WHERE OrderDate BETWEEN '2024-01-01' AND '2024-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Orders_OrderDate...';
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
    ON dbo.Orders (OrderDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Orders
WHERE OrderDate BETWEEN '2024-01-01' AND '2024-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 21) EMPLOYEES (DateOfHire)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Employees_DateOfHire ===';

DROP INDEX IF EXISTS IX_Employees_DateOfHire ON dbo.Employees;

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Employees
WHERE DateOfHire < '2024-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Employees_DateOfHire...';
CREATE NONCLUSTERED INDEX IX_Employees_DateOfHire
    ON dbo.Employees (DateOfHire);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Employees
WHERE DateOfHire < '2024-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 22) ATONEMENTS (Atoned)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Atonements_Atoned ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Atonements
WHERE Atoned = 600;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Atonements_Atoned...';
CREATE NONCLUSTERED INDEX IX_Atonements_Atoned
    ON dbo.Atonements (Atoned);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Atonements
WHERE Atoned = 600;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 23) ASYNCCLASSDETAILS (StudentID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_AsyncClassDetails_StudentID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.AsyncClassDetails
WHERE StudentID = 404;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_AsyncClassDetails_StudentID...';
CREATE NONCLUSTERED INDEX IX_AsyncClassDetails_StudentID
    ON dbo.AsyncClassDetails (StudentID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.AsyncClassDetails
WHERE StudentID = 404;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 24) SYNCCLASSDETAILS (StudentID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_SyncClassDetails_StudentID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.SyncClassDetails
WHERE StudentID = 9999;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_SyncClassDetails_StudentID...';
CREATE NONCLUSTERED INDEX IX_SyncClassDetails_StudentID
    ON dbo.SyncClassDetails (StudentID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.SyncClassDetails
WHERE StudentID = 9999;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 25) STUDIESDETAILS (StudiesID, SemesterID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_StudiesDetails_Studies_Semester ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StudiesDetails
WHERE StudiesID = 201 AND SemesterID = 1;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_StudiesDetails_Studies_Semester...';
CREATE NONCLUSTERED INDEX IX_StudiesDetails_Studies_Semester
    ON dbo.StudiesDetails (StudiesID, SemesterID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.StudiesDetails
WHERE StudiesID = 201 AND SemesterID = 1;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 26) INTERNSHIP (StudiesID, StartDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Internship_StudiesID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Internship
WHERE StudiesID = 1010;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Internship_StudiesID...';
CREATE NONCLUSTERED INDEX IX_Internship_StudiesID
    ON dbo.Internship (StudiesID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Internship
WHERE StudiesID = 1010;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Internship_StartDate ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Internship
WHERE StartDate > '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Internship_StartDate...';
CREATE NONCLUSTERED INDEX IX_Internship_StartDate
    ON dbo.Internship (StartDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Internship
WHERE StartDate > '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 27) INTERNSHIPDETAILS (StudentID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_InternshipDetails_StudentID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.InternshipDetails
WHERE StudentID = 404;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_InternshipDetails_StudentID...';
CREATE NONCLUSTERED INDEX IX_InternshipDetails_StudentID
    ON dbo.InternshipDetails (StudentID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.InternshipDetails
WHERE StudentID = 404;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 28) CONVENTION (SemesterID, StartDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Convention_SemesterID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Convention
WHERE SemesterID = 11;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Convention_SemesterID...';
CREATE NONCLUSTERED INDEX IX_Convention_SemesterID
    ON dbo.Convention (SemesterID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Convention
WHERE SemesterID = 11;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Convention_StartDate ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Convention
WHERE StartDate >= '2025-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Convention_StartDate...';
CREATE NONCLUSTERED INDEX IX_Convention_StartDate
    ON dbo.Convention (StartDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Convention
WHERE StartDate >= '2025-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 29) OFFLINEVIDEOCLASS (StartDate, Deadline)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_OfflineVideoClass_StartDate ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideoClass
WHERE StartDate > '2024-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OfflineVideoClass_StartDate...';
CREATE NONCLUSTERED INDEX IX_OfflineVideoClass_StartDate
    ON dbo.OfflineVideoClass (StartDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideoClass
WHERE StartDate > '2024-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_OfflineVideoClass_Deadline ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideoClass
WHERE Deadline < '2025-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OfflineVideoClass_Deadline...';
CREATE NONCLUSTERED INDEX IX_OfflineVideoClass_Deadline
    ON dbo.OfflineVideoClass (Deadline);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OfflineVideoClass
WHERE Deadline < '2025-12-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 30) ONLINELIVECLASS (StartDate)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_OnlineLiveClass_StartDate ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveClass
WHERE StartDate > '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_OnlineLiveClass_StartDate...';
CREATE NONCLUSTERED INDEX IX_OnlineLiveClass_StartDate
    ON dbo.OnlineLiveClass (StartDate);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.OnlineLiveClass
WHERE StartDate > '2023-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 31) EMPLOYEESSUPERIOR (ReportsTo)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_EmployeesSuperior_ReportsTo ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.EmployeesSuperior
WHERE ReportsTo = 10;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_EmployeesSuperior_ReportsTo...';
CREATE NONCLUSTERED INDEX IX_EmployeesSuperior_ReportsTo
    ON dbo.EmployeesSuperior (ReportsTo);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.EmployeesSuperior
WHERE ReportsTo = 10;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 32) USERTYPEPERMISSIONSHIERARCHY (DirectTypeSupervisor)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_UserTypePermissionsHierarchy_DirectSupervisor ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.UserTypePermissionsHierarchy
WHERE DirectTypeSupervisor = 2;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_UserTypePermissionsHierarchy_DirectSupervisor...';
CREATE NONCLUSTERED INDEX IX_UserTypePermissionsHierarchy_DirectSupervisor
    ON dbo.UserTypePermissionsHierarchy (DirectTypeSupervisor);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.UserTypePermissionsHierarchy
WHERE DirectTypeSupervisor = 2;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 33) WEBINARS (TeacherID, TranslatorID, LanguageID)
-------------------------------------------------------------------------------
PRINT '=== Testing Index: IX_Webinars_TeacherID ===';

PRINT '--- Before Creating Index (NO INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Webinars
WHERE TeacherID = 1234;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Webinars_TeacherID...';
CREATE NONCLUSTERED INDEX IX_Webinars_TeacherID
    ON dbo.Webinars (TeacherID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Webinars
WHERE TeacherID = 1234;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Webinars_TranslatorID ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Webinars
WHERE TranslatorID = 100;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Webinars_TranslatorID...';
CREATE NONCLUSTERED INDEX IX_Webinars_TranslatorID
    ON dbo.Webinars (TranslatorID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Webinars
WHERE TranslatorID = 100;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=== Testing Index: IX_Webinars_LanguageID ===';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Webinars
WHERE LanguageID = 2;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Creating index IX_Webinars_LanguageID...';
CREATE NONCLUSTERED INDEX IX_Webinars_LanguageID
    ON dbo.Webinars (LanguageID);

PRINT '--- After Creating Index (WITH INDEX) ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Webinars
WHERE LanguageID = 2;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

