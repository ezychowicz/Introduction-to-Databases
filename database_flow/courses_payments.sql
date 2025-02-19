--WIDOKI POPRAWIONE
--raporty finansowe
select * from COURSE_INCOME
select * from STUDIES_INCOME
select * from WEBINAR_INCOME
select * from CLASS_MEETINGS_INCOME
select * from CONVENTION_INCOME

select * from FINANCIAL_REPORT
select * from SERVICE_ID_INCOME

--lista osob zapisanych na przyszle kursy            (3)
select * from PARTICIPANTS_MEETINGS_FUTURE_COURSES
select * from V_FutureStudentSchedule
-- liczba osob zapisanych na przyszle kursy          (3)
select * from NUM_OF_PARTICIPANTS_FUTURE_COURSES 


--informacje o kursach
select * from COURSE_INFO

--stan zaliczenia kursow
select * from COURSE_PASSING_STATUS

--raport obecnosci na przeszlych wydarzeniach         (4)
select * from ATTENDANCE_RAPORT
select * from ATTENDANCE_MEETINGS_IN_COURSES
--osobno                                              (5)
select * from ATTENDANCE_LISTS_COURSES
select * from V_ClassAttendanceList

--lista dluznikow
select * from IN_DEBT_USERS


--PROCEDURY



--KURSY I PLATNOSCI
--dodawanie kursu -> dodawanie modułów kursowi -> dodawanie spotkań modułom -> dodawanie użytkownika do kursu

--dodanie kursu
select * from Courses

select * from Employees
order by EmployeeID
exec p_CreateCourse 'Nowy kurs', 'Opis nowego kursu...', 144, '2026-01-01', 80, 1000.00, 100.00

select * from Courses
	where CourseName = 'Nowy kurs'

--dodanie modułów
select * from Translators
exec p_CreateModule 1, 21, NULL, 67, 'Hybrid'
exec p_CreateModule 1, 21, 315, 80, 'Stationary'
exec p_CreateModule 2, 21, NULL, 122, 'Online Lives'

select * from Modules 
	where CourseID = 21 
 
--dodanie zajęć
select * from Rooms
exec p_AddStationaryMeeting '2026-01-02 10:00:00', '01:30:00', 101, 100, 30, 202
exec p_AddStationaryMeeting '2026-01-03 10:00:00', '01:00:00', 102, 103, 40, 213
exec p_AddStationaryMeeting '2026-01-04 10:00:00', '01:30:00', 102, 105, 30, 216
exec p_AddOnlineLiveMeeting 'Zoom', 'www.zoom.com', 'www.videolink.com', 101, '2026-01-02 10:00:00', '01:30:00', 248 
exec p_AddOnlineLiveMeeting 'Microsoft Teams', 'www.mt.com', 'www.videolink.com', 103, '2026-01-02 10:00:00', '01:30:00', 282
exec p_AddOnlineLiveMeeting 'Microsoft Teams', 'www.mt.com', 'www.videolink.com', 103, '2026-01-02 10:00:00', '01:30:00', 344
exec p_AddOfflineVideo 'www.videolink.com', 101, '01:30:00', 367

--zmiana jednego ze spotkań stacjonarnych
select * from StationaryMeeting
where ModuleID = 101

exec p_EditStationaryMeeting 992, NULL, '03:30:00', NULL

select * from StationaryMeeting
where ModuleID = 101

--struktura kursu:
select * from COURSE_INFO
where CourseName = 'Nowy kurs'

--dodanie uczestników kursu (automatycznie dodaje ich do spotkan w kursie)
exec p_AddCourseParticipant 1, 21
exec p_AddCourseParticipant 2, 21
exec p_AddCourseParticipant 3, 21
exec p_AddCourseParticipant 4, 21
exec p_AddCourseParticipant 5, 21
exec p_AddCourseParticipant 6, 21
exec p_AddCourseParticipant 7, 21
exec p_AddCourseParticipant 8, 21
exec p_AddCourseParticipant 9, 21

select * from PARTICIPANTS_MEETINGS_FUTURE_COURSES --dla spotkan na zywo
where CourseID = 21 

select * from NUM_OF_PARTICIPANTS_MEETINGS_COURSES
where CourseID = 21

select * from ATTENDANCE_LISTS_OFFLINEVIDEO_COURSES --dla nagran offline
where CourseID = 21 

select * from COURSE_SCHEDULE
where CourseID = 21
--to samo ale funkcją
select * from dbo.f_CourseSchedule(21)


-- ustawianie obecności
exec p_EditStationaryMeetingAttendance 992, 1, 1  
exec p_EditStationaryMeetingAttendance 993, 1, 1

exec p_EditOnlineLiveAttendance 1002, 1, 1  

exec p_EditOfflineVideoDateOfViewing 1000, 1, '2025-01-21' 


--czy już zdał (kurs sie nie skonczyl wiec sie nic nie pokaze)
--select * from COURSE_PASSING_STATUS
--	where CourseID = 21 

--select top 1 dbo.f_CheckIfCourseIsPassed(1, 21) from courses
--aktualne listy obecności:

select * from StationaryMeetingDetails
where MeetingID = 992 OR MeetingID = 993

select * from OfflineVideoDetails
where MeetingID = 1000

select * from OnlineLiveMeetingDetails
where MeetingID = 1002



-- część płatnicza:
select * from Orders

--tworzenie koszyka dla uzytkownika
exec p_CreateOrder 10, 2724, NULL, NULL -- userID = 10 dodaje usługe serviceID = 2724 do koszyka
exec p_AddToOrder 751, 1500 --class meeting offline
exec p_AddToOrder 751, 2430 --webinar
exec p_AddToOrder 751, 2122 -- studia
exec p_FinalizeOrder 751, 'paymentlink.com' -- składanie zamówienia (link do płatności i data aktualna)
--trigger addPayment - dodanie do kursu automatyczne na podstawie płatności:


exec p_AddPayment 300, '2025-01-21 12:44:00', 2724, 751 --pierwsza opłata za kurs (większa od zaliczki)

select * from CONSUMER_BASKET
where UserID = 10 AND OrderID = 751
--jeszcze nie oplacil wiec nie dodany
select * from StationaryMeetingDetails
where ParticipantID = 10 AND MeetingID = 992


exec p_AddPayment 700, '2025-01-21 12:44:00', 2724, 751 --oplacenie kursu
exec p_AddPayment 97.27, '2025-01-21 12:44:00', 2430, 751 --oplacenie webinaru
exec p_AddPayment 67.45, '2025-01-21 12:44:00', 1500, 751 --oplacenie classmeetingu 
select * from StudiesService where ServiceID = 2122
exec p_AddPayment 359.97, '2025-01-27 22:54:00', 2122, 751 

--oplacił: IsReadyToParticipate = 1 => uruchomił trigger trg_AddPayment i został dodany do spotkań
select * from CONSUMER_BASKET
where UserID = 10 AND OrderID = 751


--dodany do listy zapisanych na spotkania:
select * from V_StudentSchedule where ParticipantID = 10 --jego aktualny plan zajęć

-- w listach obecności:
--dodany do kursu
select * from StationaryMeetingDetails 
where ParticipantID = 10 AND MeetingID = 992
--dodany do listy webinaru 
select * from WebinarDetails as wd where wd.UserID = 10 AND (SELECT ServiceID FROM Webinars as w WHERE wd.WebinarID = w.WebinarID) = 2430 --Nagranie dostępne przez 30dni od daty Paymentu
--dodany do listy classmeetingu
select * from AsyncClassDetails as acd where acd.StudentID = 10 --AND acd.MeetingID = (SELECT ClassMeetingID FROM ClassMeeting WHERE ServiceID = 1500)


--error gdy kurs za mniej niż 3 dni
--zamowienie 
exec p_CreateOrder 101, 2724, '2025-01-19 12:44:00', NULL
exec p_AddPayment 1000, '2025-12-31 12:44:00', 2724, 752

--error gdy kurs nie ma już wolnych miejsc (vacancies)
select distinct CourseID, ServiceID, CourseName, Vacancies, AdvanceValue, FullPrice from COURSE_INFO Order by Vacancies 
exec p_AddToOrder 752, 2415
exec p_AddPayment 256.47, '2025-01-19 12:44:00', 2415, 752

--usuwanie kursu
exec p_DeleteCourse 21 --usuwa rekurencyjnie moduly i spotkania do nich nalezace a takze liste uczestnikow kursu;









