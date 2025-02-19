USE u_szymocha;

BEGIN TRY
    BEGIN TRANSACTION;

    -- TWORZENIE NOWEGO WEBINARU
    EXEC p_CreateWebinar 'Nowy Webinar', 144, NULL, '2026-01-01 15:00:00', 'https://link.com', '01:30:00', 'https://video.com', 'Opis webinaru', 1, 50.00;
    SELECT * FROM WEBINARS WHERE WebinarName = 'Nowy Webinar';

    -- EDYCJA WEBINARU
    SELECT * FROM WEBINARS WHERE WebinarID = 2;
    EXEC p_EditWebinar 2, 'Zaktualizowany Webinar Dwa', '2026-01-10 16:00:00';
    SELECT * FROM WEBINARS WHERE WebinarID = 2;

    -- USUWANIE WEBINARU
    EXEC p_DeleteWebinar 1;
    SELECT * FROM WEBINARS WHERE WebinarID = 1;

    -- DODANIE UCZESTNIKA DO WEBINARU
    EXEC p_AddWebinarUser 10, 3
    SELECT * FROM WebinarDetails WHERE UserID = 10;

    -- INFORMACJE O DOSTĘPNOŚCI WEBINARÓW
    SELECT * FROM WebinarDetails WHERE AvailableDue > GETDATE();

    -- TWORZENIE NOWEGO UŻYTKOWNIKA
    EXEC p_AddUser 'Nowy', 'Użytkownik', '1990-05-20', 2;
    SELECT * FROM USERS WHERE FirstName = 'Nowy' AND LastName = 'Użytkownik';

    -- EDYCJA UŻYTKOWNIKA
    EXEC p_UpdateUser 1501, 'Stary', 'Użytkownik', '1991-06-15', 3;
    SELECT * FROM USERS WHERE UserID = 1501;

    -- USUWANIE UŻYTKOWNIKA
    EXEC p_DeleteUser 1501;
    SELECT * FROM USERS WHERE UserID = 1501;

    -- ZARZĄDZANIE ADRESAMI UŻYTKOWNIKA
    EXEC p_AddUserAddress 1501, 'Ul. Przykladowa 1', '00-000', 1;
    SELECT * FROM UserAddressDetails WHERE UserID = 1501;
    EXEC p_UpdateUserAddress 1501, 'Ul. Nowa 2', '11-111', 2;
    SELECT * FROM UserAddressDetails WHERE UserID = 1501;
    EXEC p_DeleteUserAddress 1501;
	SELECT * FROM UserAddressDetails WHERE UserID = 1501;

    -- ZARZĄDZANIE KONTAKTAMI UŻYTKOWNIKA
    EXEC p_AddUserContact 1501, 'email@example.com', '123456789';
    SELECT * FROM UserContact WHERE UserID = 1501;
    EXEC p_UpdateUserContact 1501, 'newemail@example.com', '987654321';
    SELECT * FROM UserContact WHERE UserID = 1501;
    EXEC p_DeleteUserContact 1501;

    -- PRZYPISYWANIE RÓL UŻYTKOWNIKOM
	SELECT * FROM UserType
    EXEC p_AddUserType 4, 'VIP';
	SELECT * FROM UserType
    EXEC p_UpdateUserType 4, 'SuperVIP';
	SELECT * FROM UserType
    EXEC p_DeleteUserType 4;
	SELECT * FROM UserType

	 -- DODAWANIE PRACOWNIKA
    EXEC p_AddEmployee 10, '2025-01-01';
    SELECT * FROM EMPLOYEES WHERE EmployeeID = 10;
    EXEC p_AddEmployeeDegree 10, 1;
    SELECT * FROM EmployeeDegree WHERE EmployeeID = 10;
	SELECT * FROM Degrees WHERE DegreeID = 1;
	SELECT * FROM EmployeesSuperior;
    EXEC p_AssignSupervisor 10, 131;
    SELECT * FROM EmployeesSuperior WHERE EmployeeID = 10;

    -- TESTOWANIE DODAWANIA STOPNI NAUKOWYCH
	SELECT * FROM Degrees;
    EXEC p_AddDegree 'PhD', 'Artificial Intelligence';
    SELECT * FROM DEGREES WHERE DegreeID = 5;
    EXEC p_UpdateDegree 5, 'Doctorate', 'Machine Learning';
    SELECT * FROM DEGREES WHERE DegreeID = 5;
    EXEC p_DeleteDegree 2;

    -- TESTOWANIE PRZYPISYWANIA JĘZYKÓW DO TŁUMACZY
	SELECT * FROM Languages;
    EXEC p_AddLanguage 'Spanish';
    SELECT * FROM LANGUAGES WHERE LanguageID = 7;
    EXEC p_UpdateLanguage 7, 'Español';
    SELECT * FROM LANGUAGES WHERE LanguageID = 7;
    EXEC p_DeleteLanguage 7;

	-- DODAWANIE TŁUMACZA
    EXEC p_AddTranslator 10;
    SELECT * FROM TRANSLATORS WHERE TranslatorID = 10;
    EXEC p_AddTranslatorLanguage 10, 2;
    SELECT * FROM TranslatorsLanguages WHERE TranslatorID = 10;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Failed: %s', 16, 1, @ErrorMessage);
END CATCH;
GO
