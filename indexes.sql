use u_szymocha;
-----------------------------
-- 1) SERVICEUSERDETAILS
-----------------------------
-- ALTER TABLE dbo.ServiceUserDetails
-- ADD CONSTRAINT PK_ServiceUserDetails
--     PRIMARY KEY CLUSTERED (ServiceID);

-- CREATE NONCLUSTERED INDEX IX_ServiceUserDetails_DateOfRegistration
--     ON dbo.ServiceUserDetails (DateOfRegistration);

-----------------------------
-- 2) USERS
-----------------------------
-- ALTER TABLE dbo.Users
-- ADD CONSTRAINT PK_Users
--     PRIMARY KEY CLUSTERED (UserID);

-- CREATE NONCLUSTERED INDEX IX_Users_DateOfBirth
--     ON dbo.Users (DateOfBirth);

-----------------------------
-- 3) USERCONTACT
-----------------------------   
-- ALTER TABLE dbo.UserContact
-- ADD CONSTRAINT PK_UserContact
--     PRIMARY KEY CLUSTERED (UserID);

-- CREATE NONCLUSTERED INDEX IX_UserContact_Email
--     ON dbo.UserContact (Email);

-----------------------------
-- 4) USERADDRESSDETAILS
-----------------------------
-- ALTER TABLE dbo.UserAddressDetails
-- ADD CONSTRAINT PK_UserAddressDetails
--     PRIMARY KEY CLUSTERED (UserID);

-- CREATE NONCLUSTERED INDEX IX_UserAddressDetails_PostalCode  
--     ON dbo.UserAddressDetails (PostalCode);

-- CREATE NONCLUSTERED INDEX IX_UserAddressDetails_LocationID
--     ON dbo.UserAddressDetails (LocationID);

-----------------------------
-- 5) GRADES
-----------------------------
-- ALTER TABLE dbo.Grades
-- ADD CONSTRAINT PK_Grades
--     PRIMARY KEY CLUSTERED (GradeID);

-----------------------------
-- 6) STUDIES
-----------------------------
-- ALTER TABLE dbo.Studies
-- ADD CONSTRAINT PK_Studies
--     PRIMARY KEY CLUSTERED (StudiesID);

-- CREATE NONCLUSTERED INDEX IX_Studies_EnrollmentDate
--     ON dbo.Studies (EnrollmentDeadline);

-----------------------------
-- 7) SUBJECTSTUDIESASSIGNMENT
-----------------------------
-- ALTER TABLE dbo.SubjectStudiesAssignment
-- ADD CONSTRAINT PK_SubjectStudiesAssignment
--     PRIMARY KEY CLUSTERED (Studies, SubjectID);

-----------------------------
-- 8) SUBJECT
-----------------------------
-- ALTER TABLE dbo.Subject
-- ADD CONSTRAINT PK_Subject
--     PRIMARY KEY CLUSTERED (SubjectID);

-- CREATE NONCLUSTERED INDEX IX_Subject_SubjectCoordinatorID
--     ON dbo.Subject (SubjectCoordinatorID);

-----------------------------
-- 9) SEMESTERDETAILS
-----------------------------
-- ALTER TABLE dbo.SemesterDetails
-- ADD CONSTRAINT PK_SemesterDetails
--     PRIMARY KEY CLUSTERED (SemesterID);

-- CREATE NONCLUSTERED INDEX IX_SemesterDetails_StudiesID
--     ON dbo.SemesterDetails (StudiesID);

-- CREATE NONCLUSTERED INDEX IX_SemesterDetails_StartDate
--     ON dbo.SemesterDetails (StartDate);

-- CREATE NONCLUSTERED INDEX IX_SemesterDetails_EndDate
--     ON dbo.SemesterDetails (EndDate);

-----------------------------
-- 10) CLASSMEETING
-----------------------------
-- ALTER TABLE dbo.ClassMeeting
-- ADD CONSTRAINT PK_ClassMeeting
--     PRIMARY KEY CLUSTERED (ClassMeetingID);

-- CREATE NONCLUSTERED INDEX IX_ClassMeeting_SubjectID
--     ON dbo.ClassMeeting (SubjectID);

-- CREATE NONCLUSTERED INDEX IX_ClassMeeting_TeacherID
--     ON dbo.ClassMeeting (TeacherID);

-----------------------------
-- 11) STATIONARYCLASS
-----------------------------
-- ALTER TABLE dbo.StationaryClass
-- ADD CONSTRAINT PK_StationaryClass
--     PRIMARY KEY CLUSTERED (StationaryClassID);

-- CREATE NONCLUSTERED INDEX IX_StationaryClass_StartDate
--     ON dbo.StationaryClass (StartDate);

-----------------------------
-- 12) ONLINELIVEMEETINGDETAILS
-----------------------------
-- ALTER TABLE dbo.OnlineLiveMeetingDetails
-- ADD CONSTRAINT PK_OnlineLiveMeetingDetails
--     PRIMARY KEY CLUSTERED (MeetingID); 

-----------------------------
-- 13) OFFLINEVIDEODETAILS
-----------------------------
-- ALTER TABLE dbo.OfflineVideoDetails
-- ADD CONSTRAINT PK_OfflineVideoDetails
--     PRIMARY KEY CLUSTERED (MeetingID);

-----------------------------
-- 14) COURSES
-----------------------------
-- ALTER TABLE dbo.Courses
-- ADD CONSTRAINT PK_Courses
--     PRIMARY KEY CLUSTERED (CourseID);

-- CREATE NONCLUSTERED INDEX IX_Courses_ServiceID
--     ON dbo.Courses (ServiceID);

-----------------------------
-- 15) COURSEPARTICIPANTS
-----------------------------
-- ALTER TABLE dbo.CourseParticipants
-- ADD CONSTRAINT PK_CourseParticipants
--     PRIMARY KEY CLUSTERED (ParticipantID, CourseID);

-----------------------------
-- 16) PAYMENTS
-----------------------------
-- ALTER TABLE dbo.Payments
-- ADD CONSTRAINT PK_Payments
--     PRIMARY KEY CLUSTERED (PaymentID);

-- CREATE NONCLUSTERED INDEX IX_Payments_OrderID
--     ON dbo.Payments (OrderID);

-----------------------------
-- 17) ORDERS
-----------------------------
-- ALTER TABLE dbo.Orders
-- ADD CONSTRAINT PK_Orders
--     PRIMARY KEY CLUSTERED (OrderID);

-- CREATE NONCLUSTERED INDEX IX_Orders_UserID
--     ON dbo.Orders (UserID);

-----------------------------
-- 18) SERVICES
-----------------------------
-- ALTER TABLE dbo.Services
-- ADD CONSTRAINT PK_Services
--     PRIMARY KEY CLUSTERED (ServiceID);

-----------------------------
-- 19) EMPLOYEES
-----------------------------
-- ALTER TABLE dbo.Employees
-- ADD CONSTRAINT PK_Employees
--     PRIMARY KEY CLUSTERED (EmployeeID);

-- CREATE NONCLUSTERED INDEX IX_Employees_UserID
--     ON dbo.Employees (DateOfHire);

-----------------------------
-- 20) EMPLOYEEDEGREE
-- ALTER TABLE dbo.EmployeeDegree
-- ADD CONSTRAINT PK_EmployeeDegree
--     PRIMARY KEY CLUSTERED (EmployeeID, DegreeID);

-----------------------------
-- 21) DEGREES
-----------------------------
-- ALTER TABLE dbo.Degrees
-- ADD CONSTRAINT PK_Degrees
--     PRIMARY KEY CLUSTERED (DegreeID);

-----------------------------
-- 22) TRANSLATORS
-----------------------------
-- ALTER TABLE dbo.Translators
-- ADD CONSTRAINT PK_Translators
--     PRIMARY KEY CLUSTERED (TranslatorID);

-----------------------------
-- 23) TRANSLATORSLANGUAGES
-----------------------------
-- ALTER TABLE dbo.TranslatorsLanguages
-- ADD CONSTRAINT PK_TranslatorsLanguages
--     PRIMARY KEY CLUSTERED (TranslatorID, LanguageID);

-----------------------------
-- 24) LANGUAGES
-----------------------------
-- ALTER TABLE dbo.Languages
-- ADD CONSTRAINT PK_Languages
--     PRIMARY KEY CLUSTERED (LanguageID);

-----------------------------
-- 25) USERTYPE
-----------------------------
-- ALTER TABLE dbo.UserType
-- ADD CONSTRAINT PK_UserType
--     PRIMARY KEY CLUSTERED (UserTypeID);

-----------------------------
-- 26) USERTYPEPERMISSIONSHIERARCHY
-----------------------------
-- ALTER TABLE dbo.UserTypePermissionsHierarchy
-- ADD CONSTRAINT PK_UserTypePermissionsHierarchy
--     PRIMARY KEY CLUSTERED (UserTypeID);

-----------------------------
-- 27) COUNTRY / PROVINCE / CITY
-----------------------------
-- ALTER TABLE dbo.Country
-- ADD CONSTRAINT PK_Country
--     PRIMARY KEY CLUSTERED (CountryID);

-- ALTER TABLE dbo.Province
-- ADD CONSTRAINT PK_Province
--     PRIMARY KEY CLUSTERED (ProvinceID);

-- ALTER TABLE dbo.City
-- ADD CONSTRAINT PK_City
--     PRIMARY KEY CLUSTERED (CityID);
