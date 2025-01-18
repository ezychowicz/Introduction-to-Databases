--WIDOKI POPRAWIONE
--raporty finansowe
select * from COURSE_INCOME
select * from STUDIES_INCOME
select * from WEBINAR_INCOME
select * from CLASS_MEETINGS_INCOME
select * from CONVENTION_INCOME

select * from FINANCIAL_REPORT
select * from SERVICE_ID_INCOME

--lista osob zapisanych na przyszle kursy
select * from PARTICIPANTS_MEETINGS_FUTURE_COURSES

-- liczba osob zapisanych na przyszle kursy
select * from NUM_OF_PARTICIPANTS_FUTURE_COURSES 

--informacje o kursach
select * from COURSE_INFO

--stan zaliczenia kursow
select * from COURSE_PASSING_STATUS

--raport obecnosci na przeszlych wydarzeniach
select * from ATTENDANCE_RAPORT
--osobno
select * from ATTENDANCE_LISTS_COURSES
select * from V_ClassAttendanceList

--lista dluznikow
select * from IN_DEBT_USERS





--PROCEDURY

--KURSY I PLATNOSCI
--dodawanie kursu -> dodawanie modułów kursowi -> dodawanie spotkań modułom -> dodawanie użytkownika do kursu

--dodanie kursu
exec p_CreateCourse 'Nowy kurs', 'Opis nowego kursu...', 31, '2026-01-01', 80, 1000.00, 100.00

select * from Courses
	where CourseName = 'Nowy kurs'

--dodanie modułów
exec p_CreateModule 1, 21, NULL, 49, 'Hybrid'
exec p_CreateModule 1, 21, 389, 53, 'Stationary'
exec p_CreateModule 2, 21, NULL, 100, 'Online Lives'

select * from Modules 
where CourseID = 21 
 
--dodanie zajęć
exec p_AddStationaryMeeting '2026-01-02 10:00:00', '01:30:00', 101, 104, 30, 49  
exec p_AddStationaryMeeting '2026-01-03 10:00:00', '01:00:00', 102, 111, 40, 53  
exec p_AddStationaryMeeting '2026-01-04 10:00:00', '01:30:00', 102, 104, 30, 31
exec p_AddOnlineLiveMeeting 'Zoom', 'www.zoom.com', 'www.videolink.com', 101, '2026-01-02 10:00:00', '01:30:00', 49     
exec p_AddOnlineLiveMeeting 'Microsoft Teams', 'www.mt.com', 'www.videolink.com', 103, '2026-01-02 10:00:00', '01:30:00', 53
exec p_AddOnlineLiveMeeting 'Microsoft Teams', 'www.mt.com', 'www.videolink.com', 103, '2026-01-02 10:00:00', '01:30:00', 53

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

select * from PARTICIPANTS_MEETINGS_FUTURE_COURSES
where CourseID = 21


--struktura kursu:
select * from COURSE_INFO
where CourseID = 21



-- część płatnicza:
select * from Orders

--tworzenie koszyka dla uzytkownika
exec p_CreateOrder 1, NULL, NULL

select * from Orders
where UserID = 1


--dodawanie usług do koszyka
exec p_AddOrderDetail 1001, 2146  
exec p_AddOrderDetail 1001, 1500
exec p_AddOrderDetail 1001, 100
exec p_AddOrderDetail 1001, 1000

select * from OrderDetails
where OrderID = 1001

--składanie zamówienia
exec p_FinalizeOrder 1001, 'www.paymentlink.com' --ustawia date zamowienia na aktualną i dodaje rekordy do Payments 

select * from Payments
where OrderID = 1001

--zgoda dyrektora
exec p_UpdatePrincipalAgreement 1001, 2149, 1

select * from OrderDetails
where OrderID = 1001

--usuwanie kursu
exec p_DeleteCourse 21 --usuwa rekurencyjnie moduly i spotkania do nich nalezace a takze liste uczestnikow kursu;