--stan zaliczenia osob zapisanych na zakonczone kursy
--czyli 100% obecnosci na spotkaniach z 80% modulow
create view COURSE_PASSING_STATUS as
SELECT 
    T1.ServiceUserID,
    T1.CourseID,
    T1.ServiceID,
    T1.FirstName,
    T1.LastName,
    COUNT(T1.ModuleID) AS TotalModules,       
    SUM(CASE WHEN T1.ModulePassed = 'True' THEN 1 ELSE 0 END) AS PassedModules, 
    ROUND(CAST(SUM(CASE WHEN T1.ModulePassed = 'True' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(T1.ModuleID) * 100,2) AS CompletionPercentage,
	CASE WHEN ROUND(CAST(SUM(CASE WHEN T1.ModulePassed = 'True' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(T1.ModuleID) * 100,2) > 80 THEN 'PASSED' ELSE 'NOT PASSED' END as CourseCompletion
FROM (
    SELECT 
        cu.ServiceUserID,
        cu.CourseID,
        alc.ModuleID,
        cu.ServiceID,
        cu.FirstName,
        cu.LastName, 
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM ATTENDANCE_LISTS_COURSES alc1
                WHERE alc1.ParticipantID = cu.ServiceUserID
                  AND alc1.CourseID = cu.CourseID
                  AND alc1.ModuleID = alc.ModuleID
                GROUP BY alc1.ParticipantID, alc1.CourseID, alc1.ModuleID
                HAVING COUNT(*) = SUM(CAST(alc1.Attendance AS INT))
            ) THEN 'True'
            ELSE 'False'
        END AS ModulePassed
    FROM COURSES_USERS AS cu
    INNER JOIN ATTENDANCE_LISTS_COURSES AS alc
        ON alc.CourseID = cu.CourseID
    GROUP BY 
        cu.ServiceUserID,
        cu.CourseID,
        alc.ModuleID,
        cu.ServiceID,
        cu.FirstName,
        cu.LastName
) AS T1
INNER JOIN START_END_OF_COURSES as seoc
	on seoc.ServiceID = T1.ServiceID
WHERE seoc.StartOfService < CONVERT(DATE, GETDATE())
GROUP BY 
    T1.ServiceUserID, 
    T1.CourseID, 
    T1.ServiceID, 
    T1.FirstName, 
    T1.LastName;