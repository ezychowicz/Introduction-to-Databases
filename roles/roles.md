### Rola: `administrator`

#### Uprawnienia:
- `grant all privileges on u_szymocha.dbo to admin`


### Rola: `director`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_UpdatePrincipalAgreement TO director;`


### Rola: `deans_office`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_EnrollStudentInStudies TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteSubject TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_EnrollStudentInConvention TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_EnrollStudentInSyncClassMeeting TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_EnrollStudentInAsyncClass TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_EnrollStudentInSubject TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_AddService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_AddStationaryMeeting TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_AddStudiesService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_AddWebinarService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteClassMeetingService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteConventionService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteCourse TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteCourseService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteOfflineVideoDetails TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteOnlineLiveMeetingDetails TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteStudiesService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteWebinarService TO deans_office;`
- `GRANT EXECUTE ON PROCEDURE p_EditPayment TO deans_office;`
- `GRANT SELECT ON VIEW CONSUMER_BASKET TO deans_office;`
- `GRANT SELECT ON VIEW V_StudentCollidingEvents TO deans_office;`
- `GRANT SELECT ON VIEW V_WebinarsWithAttendance TO deans_office;`
- `GRANT EXECUTE ON FUNCTION f_CalculateOrderValue TO deans_office;`
- `GRANT EXECUTE ON FUNCTION f_CalculatePaidOrderValue TO deans_office;`
- `GRANT EXECUTE ON FUNCTION f_CalculatePaidServiceValue TO deans_office;`


### Rola: `coordinator_studies`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_AddSubject TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_ChangeSubjectCoordinator TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_EditStudies TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_EditSubject TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_AddSubjectToStudies TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteSubjectFromStudies TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_InitiateInternship TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_CreateCourse TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_CreateModule TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteCourseParticipant TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_EditConventionService TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_EditCourses TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_EditCourseService TO coordinator_studies;`
- `GRANT EXECUTE ON PROCEDURE p_EditStudiesService TO coordinator_studies;`
- `GRANT SELECT ON VIEW CONVENTION_INCOME TO coordinator_studies;`
- `GRANT SELECT ON VIEW COURSE_INCOME TO coordinator_studies;`
- `GRANT SELECT ON VIEW FINANCIAL_REPORT TO coordinator_studies;`
- `GRANT SELECT ON VIEW FULL_PRICE TO coordinator_studies;`
- `GRANT SELECT ON VIEW IN_DEBT_USERS TO coordinator_studies;`
- `GRANT SELECT ON VIEW PARTICIPANTS_MEETINGS_FUTURE_COURSES TO coordinator_studies;`
- `GRANT SELECT ON VIEW NUM_OF_PARTICIPANTS_FUTURE_COURSES TO coordinator_studies;`
- `GRANT SELECT ON VIEW NUM_OF_PARTICIPANTS_MEETINGS_COURSES TO coordinator_studies;`
- `GRANT SELECT ON VIEW SERVICE_ID_INCOME TO coordinator_studies;`
- `GRANT SELECT ON VIEW SERVICE_USERS TO coordinator_studies;`
- `GRANT SELECT ON VIEW STUDIES_INCOME TO coordinator_studies;`
- `GRANT SELECT ON VIEW STUDIES_USERS TO coordinator_studies;`
- `GRANT SELECT ON VIEW WEBINAR_USERS TO coordinator_studies;`
- `GRANT SELECT ON VIEW WEBINAR_INCOME TO coordinator_studies;`
- `GRANT SELECT ON VIEW COURSE_PASSING_STATUS TO coordinator_studies;`
- `GRANT SELECT ON VIEW CLASS_MEETINGS_INCOME TO coordinator_studies;`
- `GRANT SELECT ON VIEW ATTENDANCE_RAPORT TO coordinator_studies;`
- `GRANT SELECT ON VIEW V_StudiesEnrollment TO coordinator_studies;`
- `GRANT SELECT ON VIEW V_EmployeeHierarchy TO coordinator_studies;`
- `GRANT SELECT ON VIEW V_EmployeeSchedule TO coordinator_studies;`
- `GRANT SELECT ON VIEW V_EmployeeWorkload TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION f_CalculateMINRoomCapacityCourse TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION f_CheckIfCourseIsPassed TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION f_GetServiceValue TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION f_IsReadyToParticipate TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION CalculateAvailableSeatsStudies TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION p_CalculateStudiesAttendance TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION p_CalculateAverageNumberOfPeopleInClass TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION p_CalculateMINRoomCapacity TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION totalTimeSpentInClass TO coordinator_studies;`
- `GRANT EXECUTE ON FUNCTION p_CalculateAvailableSeatsStudies TO coordinator_studies;`


### Rola: `coordinator_subject_module`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_ChangeSubjectCoordinator TO coordinator_subject_module;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteConvention TO coordinator_subject_module;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteModule TO coordinator_subject_module;`
- `GRANT EXECUTE ON PROCEDURE p_EditClassMeetingService TO coordinator_subject_module;`
- `GRANT EXECUTE ON PROCEDURE p_EditModules TO coordinator_subject_module;`
- `GRANT SELECT ON VIEW V_ClassAttendanceAggregate TO coordinator_subject_module;`
- `GRANT EXECUTE ON FUNCTION f_CalculateAttendancePercentageOnModule TO coordinator_subject_module;`
- `GRANT EXECUTE ON FUNCTION p_CalculateSubjectAttendance TO coordinator_subject_module;`


### Rola: `lecturer`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_AddRoom TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_ReserveRoom TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditReservation TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_CreateStudies TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_CreateStationaryClass TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_CreateOfflineVideoClass TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_ChangeStudiesCoordinator TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddConvention TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_ChangeClassMeetingTeacher TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_ChangeClassMeetingTranslator TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_ChangeClassMeetingLanguage TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditClassMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditStationaryClass TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditOnlineLiveClass TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteUserClassMeetingDetails TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteClassMeetingDetails TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteClassMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_CreateGrade TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditGrade TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteGrade TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditOrder TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddOrder TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddClassMeetingService TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddConventionService TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddCourseService TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddOfflineVideo TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddOfflineVideoDetails TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddOnlineLiveMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddOnlineLiveMeetingDetails TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_CreateOfflineVideo TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_CreateStationaryMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteOfflineVideo TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteOnlineLiveMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteStationaryMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteStationaryMeetingDetails TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditOfflineVideo TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditOnlineLiveAttendance TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditOnlineLiveMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditStationaryMeeting TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditStationaryMeetingAttendance TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_EditWebinarService TO lecturer;`
- `GRANT EXECUTE ON PROCEDURE p_AddWebinarUser TO lecturer;`
- `GRANT SELECT ON VIEW ATTENDANCE_LISTS_COURSES TO lecturer;`
- `GRANT SELECT ON VIEW ATTENDANCE_LISTS_OFFLINEVIDEO_COURSES TO lecturer;`
- `GRANT SELECT ON VIEW ATTENDANCE_MEETINGS_IN_COURSES TO lecturer;`
- `GRANT SELECT ON VIEW CLASSMEETING_USERS TO lecturer;`
- `GRANT SELECT ON VIEW CONVENTION_USERS TO lecturer;`
- `GRANT SELECT ON VIEW COURSES_USERS TO lecturer;`
- `GRANT SELECT ON VIEW COURSE_SCHEDULE TO lecturer;`
- `GRANT SELECT ON VIEW V_StudentGrades TO lecturer;`
- `GRANT SELECT ON VIEW V_ConventionSchedule TO lecturer;`
- `GRANT SELECT ON VIEW V_SubjectMeetingSchedule TO lecturer;`
- `GRANT SELECT ON VIEW V_TranslatorLanguageSkill TO lecturer;`
- `GRANT SELECT ON VIEW V_ConventionStudents TO lecturer;`
- `GRANT SELECT ON VIEW V_ClassMeetingStudents TO lecturer;`
- `GRANT SELECT ON VIEW AllEvents TO lecturer;`
- `GRANT SELECT ON VIEW V_ClassAttendanceList TO lecturer;`


### Rola: `translator`

#### Uprawnienia:



### Rola: `student_participant`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_AddCourseParticipant TO student_participant;`
- `GRANT SELECT ON VIEW START_END_OF_CLASSMEETING TO student_participant;`
- `GRANT SELECT ON VIEW START_END_OF_CONVENTION TO student_participant;`
- `GRANT SELECT ON VIEW START_END_OF_COURSES TO student_participant;`
- `GRANT SELECT ON VIEW V_SemesterSubjectsConventions TO student_participant;`
- `GRANT SELECT ON VIEW V_StudentsFinishedStudies TO student_participant;`
- `GRANT SELECT ON VIEW V_StudentSchedule TO student_participant;`


### Rola: `guest`

#### Uprawnienia:

- `GRANT SELECT ON VIEW START_END_OF_SERVICES TO guest;`
- `GRANT SELECT ON VIEW START_END_STUDIES TO guest;`
- `GRANT SELECT ON VIEW START_END_OF_WEBINAR TO guest;`
- `GRANT SELECT ON VIEW COURSE_INFO TO guest;`


### Rola: `system`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_CreateOrder TO system;`
- `GRANT EXECUTE ON PROCEDURE p_AddOrderDetail TO system;`
- `GRANT EXECUTE ON PROCEDURE p_AddPayment TO system;`
- `GRANT EXECUTE ON PROCEDURE p_AddStationaryMeetingDetails TO system;`
- `GRANT EXECUTE ON PROCEDURE p_CreateOrder TO system;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteOrder TO system;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteOrderDetails TO system;`
- `GRANT EXECUTE ON PROCEDURE p_DeletePayment TO system;`
- `GRANT EXECUTE ON PROCEDURE p_EditOfflineVideoDateOfViewing TO system;`
- `GRANT EXECUTE ON PROCEDURE p_FinalizeOrder TO system;`


### Rola: `coordinator_practices`

#### Uprawnienia:

- `GRANT EXECUTE ON PROCEDURE p_CreateInternship TO coordinator_practices;`
- `GRANT EXECUTE ON PROCEDURE p_EditInternship TO coordinator_practices;`
- `GRANT EXECUTE ON PROCEDURE p_AddStudentInternship TO coordinator_practices;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteInternship TO coordinator_practices;`
- `GRANT EXECUTE ON PROCEDURE p_DeleteInternshipDetails TO coordinator_practices;`
- `GRANT EXECUTE ON FUNCTION p_CalculateInternshipCompletion TO coordinator_practices;`

