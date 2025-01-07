CREATE VIEW CONVENTION_USERS AS
SELECT
    c.ConventionID,
	c.ServiceID,
    c.SemesterID,
    c.SubjectID,
    sub.SubjectName,
    st.ServiceUserID,
	u.FirstName,
    u.LastName
FROM Convention c
JOIN SemesterDetails sem
    ON sem.SemesterID = c.SemesterID
JOIN StudiesDetails sd
    ON sd.StudiesID = sem.StudiesID
JOIN ServiceUserDetails st
    ON st.ServiceUserID = sd.StudentID
JOIN Users u
    ON u.UserID = st.ServiceUserID
JOIN SubjectStudiesAssignment s2s
    ON s2s.StudiesID = sem.StudiesID
    AND s2s.SubjectID = c.SubjectID
JOIN Subject sub
    ON sub.SubjectID = c.SubjectID
;
