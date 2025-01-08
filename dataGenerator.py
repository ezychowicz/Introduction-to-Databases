import random
from faker import Faker
from datetime import datetime, timedelta

faker = Faker()
Faker.seed(2137)

# ==============================================================================
#                               CONFIG CONSTANTS
# ==============================================================================
# =============== USER/EMPLOYEE
NUM_USERTYPES          = 3
NUM_LOCATIONS          = 23
NUM_LANGUAGES          = 5
NUM_DEGREES            = 5

NUM_USERS              = 100   # total
NUM_USERCONTACT        = 75
NUM_USERADDRESS        = 75
NUM_EMPLOYEES          = 20   # subset of users
NUM_STUDENTS           = 80   # subset of users
NUM_TRANSLATORS        = 5    # subset of employees
MIN_EMPLOYEE_SUPERIORS = 0

# =============== COLLEGE/ACADEMIC
NUM_GRADES             = 6
NUM_STUDIES            = 3
NUM_SUBJECTS           = 20
MIN_SEMESTERS_PER_STUDY = 4
MAX_SEMESTERS_PER_STUDY = 7
MIN_SUBJECTS_PER_STUDY  = 5
MAX_SUBJECTS_PER_STUDY  = 10
NUM_INTERNSHIPS          = 4
NUM_INTERNSHIP_DETAILS   = 8
MIN_CLASSMEETINGS_PER_SUBJECT = 2
MAX_CLASSMEETINGS_PER_SUBJECT = 3
NUM_ATONEMENTS            = 0
NUM_SUBJECT_DETAILS_PER_SUBJECT = 12
MIN_CONVENTIONS_PER_SEMESTER    = 4
MAX_CONVENTIONS_PER_SEMESTER    = 10

# =============== PAYMENTS
# NUM_SERVICES           = 12 
NUM_ORDERS             = 150
MIN_SERVICES_PER_ORDER = 1
MAX_SERVICES_PER_ORDER = 3
NUM_PAYMENTS           = 2000

# ==============================================================================
#                               HELPER FUNCTIONS
# ==============================================================================
def quote_str(s: str) -> str:
    """Escape single quotes for SQL."""
    if s is None:
        return ""
    return s.replace("'", "''")

def format_date(d) -> str:
    """Format a datetime/date as 'YYYY-MM-DD', or 'NULL' if None."""
    if d is None:
        return "NULL"
    if isinstance(d, datetime):
        return d.strftime("'%Y-%m-%d'")
    return f"'{d}'"

def format_datetime(dt) -> str:
    """Format a datetime as 'YYYY-MM-DD HH:MM:SS', or 'NULL' if None."""
    if dt is None:
        return "NULL"
    return f"'{dt.strftime('%Y-%m-%d %H:%M:%S')}'"



def random_date_between(start_days=-365, end_days=365):
    start_date = datetime.now() + timedelta(days=start_days)
    end_date   = datetime.now() + timedelta(days=end_days)
    return faker.date_between(start_date=start_date, end_date=end_date)

def format_money(val) -> str:
    """Format a float as a numeric or money type. Adjust if your DB syntax differs."""
    return f"{val:.2f}"

# ==============================================================================
# 1) USERTYPE
# ==============================================================================
fixed_user_types = [
    (1, "Student"),
    (2, "Lecturer"),
    (3, "Translator")
]
user_type_records = []
for (tid, tname) in fixed_user_types[:NUM_USERTYPES]:
    user_type_records.append({
        'UserTypeID': tid,
        'UserTypeName': tname
    })

user_type_permissions = []
user_type_permissions.append({
    'UserTypeID': 3,
    'DirectTypeSupervisor': 2
})

# ==============================================================================
# 2) LOCATIONS
# ==============================================================================
location_records = []
for i in range(1, NUM_LOCATIONS+1):
    location_records.append({
        'LocationID': i,
        'CountryName': faker.country(),
        'ProvinceName': faker.state(),
        'CityName': faker.city()
    })

# ==============================================================================
# 3) LANGUAGES
# ==============================================================================
language_records = []
for i in range(1, NUM_LANGUAGES+1):
    language_records.append({
        'LanguageID': i,
        'LanguageName': faker.language_name()
    })

# ==============================================================================
# 4) DEGREES
# ==============================================================================
possible_degrees = [
    (1, "Bachelor", "BSc Something"),
    (2, "Masters",  "MSc Something"),
    (3, "PhD",      "PhD Something"),
    (4, "Prof",  "Professor Something")
]
degree_records = []
for (did, lvl, nm) in possible_degrees[:NUM_DEGREES]:
    degree_records.append({
        'DegreeID': did,
        'DegreeLevel': lvl,
        'DegreeName': nm
    })

# ==============================================================================
# 5) GRADES (for StudiesDetails, InternshipDetails, etc.)
# ==============================================================================
grade_list = [
    (1, 2.0,  "Sufficient"),
    (2, 3.0,  "Fair"),
    (3, 3.5,  "Satisfactory"),
    (4, 4.0,  "Good"),
    (5, 4.5,  "Very Good"),
    (6, 5.0,  "Excellent"),
]
grade_records = []
for (gid, val, name) in grade_list[:NUM_GRADES]:
    grade_records.append({
        'GradeID': gid,
        'GradeValue': val,
        'GradeName': name
    })

# ==============================================================================
# 6) CREATE USERS
# ==============================================================================
all_user_ids = list(range(1, NUM_USERS+1))
random.shuffle(all_user_ids)

student_user_ids = all_user_ids[:NUM_STUDENTS] #zaklada sie ze students rozlaczne z employees chyba tutaj
rest_ids = all_user_ids[NUM_STUDENTS:]
employee_user_ids = rest_ids[:NUM_EMPLOYEES]
rest_ids = rest_ids[NUM_EMPLOYEES:]

user_records = []
# STUDENT TYPE=1
for uid in student_user_ids:
    user_records.append({
        'UserID': uid,
        'FirstName': faker.first_name(),
        'LastName': faker.last_name(),
        'DateOfBirth': faker.date_of_birth(minimum_age=18, maximum_age=30),
        'UserTypeID': 1
    })
# EMPLOYEES TYPE in [2,3]
employee_type_ids = [2,3]
for uid in employee_user_ids:
    chosen_type = random.choice(employee_type_ids)
    user_records.append({
        'UserID': uid,
        'FirstName': faker.first_name(),
        'LastName': faker.last_name(),
        'DateOfBirth': faker.date_of_birth(minimum_age=25, maximum_age=60),
        'UserTypeID': chosen_type
    })
# The leftover
for uid in rest_ids:
    random_type = 2
    user_records.append({
        'UserID': uid,
        'FirstName': faker.first_name(),
        'LastName': faker.last_name(),
        'DateOfBirth': faker.date_of_birth(minimum_age=18, maximum_age=60),
        'UserTypeID': random_type
    })

# ==============================================================================
# 7) USERCONTACT
# ==============================================================================
user_contact_records = []
random_ids_for_contact = random.sample(all_user_ids, k=min(NUM_USERCONTACT, len(all_user_ids)))
for uid in random_ids_for_contact:
    user_contact_records.append({
        'UserID': uid,
        'Email': faker.email(),
        'Phone': faker.phone_number()
    })

# ==============================================================================
# 8) USERADDRESSDETAILS
# ==============================================================================
user_address_records = []
random_ids_for_address = random.sample(all_user_ids, k=min(NUM_USERADDRESS, len(all_user_ids)))
for uid in random_ids_for_address:
    loc = random.choice(location_records)
    user_address_records.append({
        'UserID': uid,
        'Address': faker.street_address()[:30],
        'PostalCode': faker.postcode()[:10],
        'LocationID': loc['LocationID']
    })

# ==============================================================================
# 9) EMPLOYEES (UserType in [2,3])
# ==============================================================================
employee_records = []
for u in user_records:
    if u['UserTypeID'] in [2,3]:
        employee_records.append({
            'EmployeeID': u['UserID'],
            'DateOfHire': faker.date_between(start_date='-10y', end_date='today')
        })

# ==============================================================================
# 10) EMPLOYEESUPERIOR
# ==============================================================================
employees_superior_records = []
if len(employee_records) > 1:
    for e in employee_records:
        if random.choice([True, False]):
            possible_superiors = [x for x in employee_records if x['EmployeeID'] != e['EmployeeID']]
            if possible_superiors:
                sup = random.choice(possible_superiors)
                employees_superior_records.append({
                    'EmployeeID': e['EmployeeID'],
                    'ReportsTo': sup['EmployeeID']
                })

# ==============================================================================
# 11) TRANSLATORS
# ==============================================================================
translator_records = []
trans_emps = [e for e in employee_records
              if next(u for u in user_records if u['UserID'] == e['EmployeeID'])['UserTypeID'] == 3]
chosen_trans = random.sample(trans_emps, k=min(NUM_TRANSLATORS, len(trans_emps)))
for ct in chosen_trans:
    translator_records.append({
        'TranslatorID': ct['EmployeeID']
    })

# 11b) TRANSLATORS LANGUAGES
translators_languages_records = []
for tr in translator_records:
    how_many_langs = random.randint(1, len(language_records))
    chosen_langs = random.sample(language_records, k=how_many_langs)
    for cl in chosen_langs:
        translators_languages_records.append({
            'TranslatorID': tr['TranslatorID'],
            'LanguageID': cl['LanguageID']
        })

# ==============================================================================
# 12) EMPLOYEEDEGREE
# ==============================================================================
employee_degree_records = []
for e in employee_records:
    how_many_degs = random.choice([0, 1, 1, 1, 1])
    if how_many_degs > 0:
        deg = random.choice(degree_records)
        employee_degree_records.append({
            'EmployeeID': e['EmployeeID'],
            'DegreeID': deg['DegreeID']
        })

# ==============================================================================
# 13) SERVICEUSERDETAILS + STUDENT (College logic)
# ==============================================================================
service_user_details_records = []
student_coll_records = []
for u in user_records:
    if u['UserTypeID'] == 1:  # student
        service_user_details_records.append({
            'ServiceUserID': u['UserID'],
            'DateOfRegistration': faker.date_between(start_date='-4y', end_date='today')
        })
        student_coll_records.append({
            'StudentID': u['UserID'],
            'FirstName': u['FirstName'],
            'LastName': u['LastName'],
            'DateOfBirth': u['DateOfBirth']
        })

# ==============================================================================
# 14) STUDIES
# ==============================================================================
possible_coordinator_emps = [e for e in employee_records
                             if next(u for u in user_records if u['UserID']==e['EmployeeID'])['UserTypeID'] in [2,4]]
studies_records = []
for i in range(1, NUM_STUDIES+1):
    coordinator = random.choice(possible_coordinator_emps) if possible_coordinator_emps else None
    enrollment_deadline_dt = faker.date_between(start_date='-3y', end_date='+1y')
    grad_dt = enrollment_deadline_dt + timedelta(days=365*random.randint(2,4))
    su = random.choice(service_user_details_records) if service_user_details_records else None
    studies_records.append({
        'StudiesID': i,
        'StudiesName': faker.word().title() + " Studies",
        'StudiesDescription': faker.sentence(nb_words=5),
        'StudiesCoordinatorID': coordinator['EmployeeID'] if coordinator else 'NULL',
        'EnrollmentLimit': random.randint(10,50),
        'EnrollmentDeadline': enrollment_deadline_dt,
        'ExpectedGraduationDate': grad_dt,
        'ServiceID': su['ServiceUserID'] if su else 1
    })

# ==============================================================================
# 15) SEMESTERDETAILS
# ==============================================================================
semester_records = []
next_sem_id = 1
for st in studies_records:
    study_id = st['StudiesID']
    num_sem = (st['ExpectedGraduationDate'] - st['EnrollmentDeadline']).days // 365
    base_dt = st['EnrollmentDeadline']
    if not isinstance(base_dt, datetime):
        base_dt = datetime.strptime(str(base_dt), '%Y-%m-%d')
    for _ in range(num_sem):
        sem_start_offset = random.randint(-90, 90)
        sem_start_dt = base_dt + timedelta(days=sem_start_offset)
        sem_end_dt   = sem_start_dt + timedelta(days=120)
        semester_records.append({
            'SemesterID': next_sem_id,
            'StudiesID': study_id,
            'StartDate': sem_start_dt,
            'EndDate': sem_end_dt
        })
        next_sem_id += 1
        base_dt = sem_end_dt + timedelta(days=20)

# ==============================================================================
# 16) SUBJECT
# ==============================================================================
possible_subject_coordinators = employee_records
subject_records = []
for i in range(1, NUM_SUBJECTS+1):
    coord_emp = random.choice(possible_subject_coordinators) if possible_subject_coordinators else None
    su = random.choice(service_user_details_records) if service_user_details_records else None
    studies_id = random.choice(studies_records)['StudiesID']
    subject_records.append({
        'SubjectID': i,
        'StudiesID': studies_id,
        'SubjectName': faker.word().capitalize(),
        'SubjectCoordinatorID': coord_emp['EmployeeID'] if coord_emp else 'NULL',
        'SubjectDescription': faker.sentence(nb_words=5),
        'ServiceID': su['ServiceUserID'] if su else 1,
        'Meetings': random.randint(5,15)
    })

# ==============================================================================
# 17) SUBJECTTOSTUDIESASSIGNMENT
# ==============================================================================
# We'll keep a map: StudiesID -> list of SubjectIDs
study_sub_map = {}

subject_to_studies_records = []
for st in studies_records:
    study_id = st['StudiesID']
    how_many_sub = random.randint(MIN_SUBJECTS_PER_STUDY, MAX_SUBJECTS_PER_STUDY)
    chosen_subs = random.sample(subject_records, k=how_many_sub)
    for sub in chosen_subs:
        subject_to_studies_records.append({
            'StudiesID': study_id,
            'SubjectID': sub['SubjectID']
        })
        if study_id not in study_sub_map:
            study_sub_map[study_id] = []
        study_sub_map[study_id].append(sub['SubjectID'])

# ==============================================================================
# 18) INTERNSHIP
# ==============================================================================
internship_records = []
for i in range(1, NUM_INTERNSHIPS+1):
    chosen_study = random.choice(studies_records)
    start_dt = faker.date_between(start_date='-2y', end_date='+1y')
    internship_records.append({
        'InternshipID': i,
        'StudiesID': chosen_study['StudiesID'],
        'StartDate': start_dt
    })

# ==============================================================================
# 19) STUDIESDETAILS
# ==============================================================================
studies_details_records = []
all_grade_ids = [g['GradeID'] for g in grade_records]
study_students_map = {}

for st in studies_records:
    study_id = st['StudiesID']
    chosen_students = random.sample(student_coll_records, k=random.randint(5, st['EnrollmentLimit']))
    for cs in chosen_students:
        assigned_grade = random.choice(all_grade_ids)
        studies_details_records.append({
            'StudiesID': study_id,
            'StudentID': cs['StudentID'],
            'StudiesGrade': assigned_grade
        })
        if study_id not in study_students_map:
            study_students_map[study_id] = []
        study_students_map[study_id].append(cs['StudentID'])

# ==============================================================================
# 20) INTERNSHIPDETAILS
# ==============================================================================
internship_details_records = []
for _ in range(NUM_INTERNSHIP_DETAILS):
    it = random.choice(internship_records)
    sid = it['StudiesID']
    studs = study_students_map.get(sid, [])
    if not studs:
        continue
    chosen_stud = random.choice(studs)
    chosen_grade = random.choice(all_grade_ids)
    internship_details_records.append({
        'InternshipID': it['InternshipID'],
        'StudentID': chosen_stud,
        'Duration': random.randint(30,180),
        'InternshipGrade': chosen_grade,
        'InternshipAttendance': random.choice([0,1])
    })

# ==============================================================================
# 21) CONVENTION (with integer Duration)
# ==============================================================================
convention_records = []
next_convention_id = 1

# subject_convention_map[subjectID] -> list of {StartDate, DurationDays, ...}
subject_convention_map = {}
idx = 1
for sem in semester_records:
    sem_id = sem['SemesterID']
    st_id  = sem['StudiesID']
    possible_subs = study_sub_map.get(st_id, [])
    if not possible_subs:
        continue

    num_convs = random.randint(MIN_CONVENTIONS_PER_SEMESTER, MAX_CONVENTIONS_PER_SEMESTER)
    for _ in range(num_convs):
        cid = next_convention_id
        next_convention_id += 1

        chosen_sub = random.choice(possible_subs)
        su = random.choice(service_user_details_records) if service_user_details_records else None

        cstart = faker.date_between(start_date=sem['StartDate'], end_date=sem['EndDate'])
        duration_days = random.randint(2, 7)
        convention_records.append({
            'ConventionID': cid,
            'SemesterID': sem_id,
            'ConventionID': idx,
            'SubjectID': chosen_sub,
            'ServiceID': su['ServiceUserID'] if su else 1,
            'StartDate': cstart,
            'Duration': duration_days
        })
        idx += 1
        if chosen_sub not in subject_convention_map:
            subject_convention_map[chosen_sub] = []
        subject_convention_map[chosen_sub].append({
            'ConventionID': cid,
            'StartDate': cstart,
            'DurationDays': duration_days
        })

# ==============================================================================
# 22) CLASSMEETING + SUBCLASSES + Sync/Async, all within a Convention window
# ==============================================================================
class_meeting_records = []
stationary_class_records = []
online_live_class_records = []
offline_video_class_records = []

sync_class_details_records = []
async_class_details_records = []

possible_teachers = [
    e for e in employee_records
    if next(u for u in user_records if u['UserID']==e['EmployeeID'])['UserTypeID'] == 2
]
translator_ids = [t['TranslatorID'] for t in translator_records]
next_meeting_id = 1

for s2s in subject_to_studies_records:
    s_id    = s2s['StudiesID']
    subj_id = s2s['SubjectID']

    # how many total meetings for this subject?
    how_many_meet = random.randint(MIN_CLASSMEETINGS_PER_SUBJECT, MAX_CLASSMEETINGS_PER_SUBJECT)

    # if the subject has NO conventions, we skip generation 
    if subj_id not in subject_convention_map or not subject_convention_map[subj_id]:
        continue

    for _ in range(how_many_meet):
        cm_id = next_meeting_id
        next_meeting_id += 1

        # pick a random Convention for this subject
        chosen_conv  = random.choice(subject_convention_map[subj_id])
        conv_start   = chosen_conv['StartDate']
        conv_dur     = chosen_conv['DurationDays']

        # pick a day within [conv_start, conv_start+dur-1]
        offset_days = random.randint(0, max(0, conv_dur - 1))
        meet_date   = conv_start + timedelta(days=offset_days)

        teacher_emp = random.choice(possible_teachers) if possible_teachers else None
        chosen_translator = random.choice(translator_ids) if translator_ids else None
        mtype = random.choice(["stationary","online","offline"])

        class_meeting_records.append({
            'ClassMeetingID': cm_id,
            'SubjectID': subj_id,
            'TeacherID': teacher_emp['EmployeeID'] if teacher_emp else 'NULL',
            'MeetingName': faker.word().capitalize() + " " + mtype,
            'TranslatorID': chosen_translator if chosen_translator else 'NULL',
            'LanguageID': 'NULL',
            'ServiceID': random.choice(service_user_details_records)['ServiceUserID']
                         if service_user_details_records else 1,
            'MeetingType': mtype,
            'MeetingDate': meet_date  # store so we can put it in the sub-table
        })

        # decide sub-type
        subtype = mtype
        # duration should be in HH:MM:SS format and equal to 01:30:00 or 00:45:00 or 02:00:00
        if subtype == "stationary":
            stationary_class_records.append({
                'MeetingID': cm_id,
                'RoomID': random.randint(100,200),
                'GroupSize': random.randint(5,30),
                'StartDate': meet_date.strftime('%Y-%m-%d %H:%M:%S'),
                'Duration': random.choice(['01:30:00', '01:30:00', '01:30:00','01:30:00','01:30:00', '02:00:00', '00:45:00', '00:45:00'])
            })
            # sync
            studs_here = study_students_map.get(s_id, [])
            # ???
            student_sample = random.sample(studs_here, k=random.randint(3, len(studs_here)))
            for s in student_sample:
                sync_class_details_records.append({
                    'MeetingID': cm_id,
                    'StudentID': s,
                    'Attendance': random.choice([0,1,1,1,1])
                })
        elif subtype == "online":
            online_live_class_records.append({
                'MeetingID': cm_id,
                'Link': faker.uri(),
                'StartDate': meet_date.strftime('%Y-%m-%d %H:%M:%S'),
                'Duration': random.choice(['01:30:00', '01:30:00', '01:30:00','01:30:00','01:30:00', '02:00:00', '00:45:00', '00:45:00'])
            })
            # sync
            studs_here = study_students_map.get(s_id, [])
            student_sample = random.sample(studs_here, k=min(5, len(studs_here)))
            for s in student_sample:
                sync_class_details_records.append({
                    'MeetingID': cm_id,
                    'StudentID': s,
                    'Attendance': random.choice([0,1])
                })
        else:
            # offline
            offline_video_class_records.append({
                'MeetingID': cm_id,
                'VideoLink': faker.uri_path(),
                'StartDate': meet_date.strftime('%Y-%m-%d'),
                'Deadline': (meet_date + timedelta(days=7)).strftime('%Y-%m-%d')
            })
            studs_here = study_students_map.get(s_id, [])
            student_sample = random.sample(studs_here, k=min(5, len(studs_here)))
            for s in student_sample:
                seen = random.choice([0,1,1,1])
                async_class_details_records.append({
                    'MeetingID': cm_id,
                    'StudentID': s,
                    'ViewDate': (meet_date + timedelta(days=random.randint(1,5))).strftime('%Y-%m-%d') if seen else 'NULL'
                })

# ==============================================================================
# 23) SUBJECTDETAILS
# ==============================================================================
subject_details_records = []
for subj in subject_records:
    how_many = random.randint(1, NUM_SUBJECT_DETAILS_PER_SUBJECT)
    chosen_students = random.sample(student_coll_records, k=min(how_many, len(student_coll_records)))
    for cst in chosen_students:
        subject_details_records.append({
            'SubjectID': subj['SubjectID'],
            'StudentID': cst['StudentID'],
            'SubjectGrade': round(random.uniform(2.0,5.0),1),
            'Attendance': round(random.uniform(0,100),2)
        })


# ==============================================================================
# COURSES
# ==============================================================================
NUM_COURSES = 5
NUM_MODULES = 30
possible_coordinator_emps = [e for e in employee_records
                             if next(u for u in user_records if u['UserID']==e['EmployeeID'])['UserTypeID'] in [2,4]]
courses_records = []
for i in range(1, NUM_COURSES + 1):
    coordinator = random.choice(possible_coordinator_emps) if possible_coordinator_emps else None
    course_date = faker.date_between(start_date='-2y', end_date='+1y')
    
    courses_records.append({
        'CourseID': i,
        'CourseName': faker.word().title() + " Course",
        'CourseDescription': faker.sentence(nb_words=10),
        'CourseCoordinatorID': coordinator['EmployeeID'] if coordinator else 'NULL',
        'ServiceID': None,
        'CourseDate': course_date,
        'EnrollmentLimit': random.randint(10,50)
    })

# ==============================================================================
# Modules
# ==============================================================================

modules_records = []
possible_coordinator_emps = [e for e in employee_records if next(u for u in user_records if u['UserID'] == e['EmployeeID'])['UserTypeID'] in [2, 4]]

possible_module_types = ['Stationary', 'Hybrid', 'Online Lives', 'Offline Videos']  # Typy modułów
possible_translators = [e['EmployeeID'] for e in employee_records if next(u for u in user_records if u['UserID'] == e['EmployeeID'])['UserTypeID'] == 3]  # Pracownicy z TranslatorID

for i in range(1, NUM_MODULES + 1):
    course = random.choice(courses_records)  # Wybór losowego kursu
    coordinator = random.choice(possible_coordinator_emps) if possible_coordinator_emps else 'NULL'
    translator = random.choice(possible_translators) if random.random() > 0.5 else 'NULL'  # Czasami może nie być tłumacza
    language = random.choice(language_records)['LanguageID']
    
    modules_records.append({
        'ModuleID': i,
        'LanguageID': language,
        'CourseID': course['CourseID'],
        'TranslatorID': translator,
        'ModuleCoordinatorID': coordinator['EmployeeID'] if coordinator else 'NULL',
        'ModuleType': random.choice(possible_module_types)
    })

# ==============================================================================
# Meetings
# ==============================================================================
NUM_MEETINGS = 50
meeting_types = ["stationary", "offline video", "online live"]
stationary_meetings_records = []
offline_video_records = []
online_live_meetings_records = []

for i in range(1, NUM_MEETINGS + 1):
    module = random.choice(modules_records) # losuj modul
    if module['ModuleType'] == 'Stationary':
        meeting_type = "stationary"
    elif module['ModuleType'] == 'Offline Videos':
        meeting_type = 'offline video'
    elif module['ModuleType'] == 'Online Lives':
        meeting_type = 'online live'
    else:
        meeting_type = random.choice(meeting_types) #losuj typ spotkania
    teacher_id = random.choice([e['EmployeeID'] for e in employee_records if next(u for u in user_records if u['UserID'] == e['EmployeeID'])['UserTypeID'] == 2]) # Losowy nauczyciel
    if meeting_type == "stationary":
        meeting_date = faker.date_time_between(start_date='-2y', end_date='+1y')
        meeting_duration = random.choice(['01:30:00', '01:30:00', '01:30:00','01:30:00','01:30:00', '01:30:00', '00:45:00', '00:45:00'])
        room_id = random.randint(100,200)  # Przykładowe ID pomieszczenia
        group_size = random.randint(5, 30)  # Rozmiar grupy
        stationary_meetings_records.append({
            'MeetingID': i,
            'MeetingDate': meeting_date,
            'MeetingDuration': meeting_duration,
            'ModuleID': module['ModuleID'],
            'RoomID': room_id,
            'GroupSize': group_size,
            'TeacherID': teacher_id
        })
    elif meeting_type == "offline video":
        video_link = faker.url()  # Generowanie linku do nagrania
        video_duration = random.choice(['01:30:00', '01:30:00', '01:30:00','01:30:00','01:30:00', '01:30:00', '00:45:00', '00:45:00'])
        offline_video_records.append({
            'MeetingID': i,
            'VideoLink': video_link,
            'ModuleID': module['ModuleID'],
            'VideoDuration': video_duration,
            'TeacherID': teacher_id
        })
    else:
        platform_name = random.choice(['Zoom', 'Teams', 'Google Meet', 'Skype', 'NULL'])  # Platforma
        link = faker.url() if platform_name else 'NULL'  # Link do spotkania
        video_link = faker.url() if random.random() > 0.5 else 'NULL'  # Link do nagrania
        meeting_date = faker.date_time_between(start_date='-2y', end_date='+1y')
        video_duration = random.choice(['01:30:00', '01:30:00', '01:30:00','01:30:00','01:30:00', '01:30:00', '00:45:00', '00:45:00'])
        online_live_meetings_records.append({
            'MeetingID': i,
            'PlatformName': platform_name,
            'Link': link,
            'VideoLink': video_link,
            'ModuleID': module['ModuleID'],
            'MeetingDate': meeting_date,
            'MeetingDuration': video_duration,
            'TeacherID': teacher_id
    })

# ==============================================================================
# CourseParticipants
# ==============================================================================
course_participants_records = []
for course in courses_records:
    course_participants = random.shuffle(service_user_details_records[::])
    course_participants_cnt = random.randint(0, course['EnrollmentLimit'])
    selected_participants = service_user_details_records[:course_participants_cnt]
    for participant in selected_participants:
        course_participants_records.append({
            'ParticipantID': participant['ServiceUserID'],
            'CourseID': course['CourseID']
        })
# ==============================================================================
# MeetingsDetails - na razie dodaje participantow tylko zapisanych do kursu, moze powinien tez dodawac kilka losowych userow
# ==============================================================================
stationary_meeting_details_records = []
offline_video_details_records = []
online_live_meeting_details_records = []

for meeting in stationary_meetings_records:
    modules = tuple(filter(lambda module: module['ModuleID'] == meeting['ModuleID'], modules_records))[0]
    course = tuple(filter(lambda course: course['CourseID'] == module['CourseID'], courses_records))[0]
    course_participantsIDs = list(map(lambda pair: pair['ParticipantID'], filter(lambda pair: pair['CourseID'] == course['CourseID'], course_participants_records)))
    for participantID in course_participantsIDs:
        stationary_meeting_details_records.append({
            'MeetingID': meeting['MeetingID'],
            'ParticipantID': participantID,
            'Attendance': random.choice([0,1,1,1,1])  # Obecność na spotkaniu
        })

for video in offline_video_records:
    modules = tuple(filter(lambda module: module['ModuleID'] == video['ModuleID'], modules_records))[0]
    course = tuple(filter(lambda course: course['CourseID'] == module['CourseID'], courses_records))[0]
    course_participantsIDs = list(map(lambda pair: pair['ParticipantID'], filter(lambda pair: pair['CourseID'] == course['CourseID'], course_participants_records)))
    for participantID in course_participantsIDs:
        offline_video_details_records.append({
            'MeetingID': video['MeetingID'],
            'ParticipantID': participantID,
            'dateOfViewing': random.choice([faker.date_time_between(start_date='-1y', end_date='now'), 'NULL'])  # Data obejrzenia
        })

for live_meeting in online_live_meetings_records:
    modules = tuple(filter(lambda module: module['ModuleID'] == live_meeting['ModuleID'], modules_records))[0]
    course = tuple(filter(lambda course: course['CourseID'] == module['CourseID'], courses_records))[0]
    course_participantsIDs = list(map(lambda pair: pair['ParticipantID'], filter(lambda pair: pair['CourseID'] == course['CourseID'], course_participants_records)))
    for participantID in course_participantsIDs:
        online_live_meeting_details_records.append({
            'MeetingID': live_meeting['MeetingID'],
            'ParticipantID': participantID,
            'Attendance': random.choice([0,1,1,1,1])  # Obecność na spotkaniu
        })

# ==============================================================================
# 24) WEBINARS
# ==============================================================================
NUM_WEBINARS           = 6      # how many webinars
MAX_PARTICIPANTS_PER_WEBINAR = 20

webinars_data = []
webinardetails_data = []

for i in range(1, NUM_WEBINARS + 1):
    # pick random teacher if available
    teacher_id = random.choice(possible_teachers)['EmployeeID'] if possible_teachers else None
    translator_id = random.choice(translator_ids) if translator_ids else None
    
    wname   = faker.word().title() + " Webinar"
    wdate   = faker.date_time_between(start_date='-1y', end_date='now')
    link    = faker.uri()
    dur_minutes = random.randint(30, 120)
    hh = dur_minutes // 60
    mm = dur_minutes % 60
    duration_str = f"{hh:02d}:{mm:02d}:00"
    
    link_video = faker.uri()
    descr   = faker.sentence(nb_words=8)
    langid  = random.choice([l['LanguageID'] for l in language_records])
    avdue   = faker.date_between(start_date='today', end_date='+20d')
    webinars_data.append({
        'WebinarID': i,
        'TeacherID': teacher_id,
        'TranslatorID': translator_id,
        'WebinarName': wname,
        'WebinarDate': wdate,
        'Link': link,
        'DurationTime': duration_str,
        'LinkToVideo': link_video,
        'WebinarDescription': descr,
        'LanguageID': langid,
        'AvailableDue': avdue,
        'ServiceID': 1
    })
    
    # pick random participants (any user with userType=1 => "students")
    student_user_ids = [u['UserID'] for u in user_records if u['UserTypeID'] == 1]
    # if no students, fallback to any user
    if not student_user_ids:
        student_user_ids = [u['UserID'] for u in user_records]
        
    num_parts = random.randint(1, MAX_PARTICIPANTS_PER_WEBINAR)
    chosen = random.sample(student_user_ids, k=min(num_parts, len(student_user_ids)))
    for part_id in chosen:
        webinardetails_data.append({
            'ParticipantID': part_id,
            'WebinarID': i
        })
# ==============================================================================
# 25) PAYMENT SYSTEM (Services, Orders, OrderDetails, Payments, etc.)
# ==============================================================================
service_types = [
    "ClassMeetingService",
    "StudiesService",
    "ConventionService",
    "WebinarService",
    "CourseService"
]
services_records = []
class_meeting_service_records = []
studies_service_records = []
convention_service_records = []
webinar_service_records = []
course_service_records = []

next_service_id = 1
lens = [len(class_meeting_records), len(studies_records), len(convention_records), len(courses_records), len(webinars_data)]# len(webinars_records) zamiast 0
prefix_lens = [sum(lens[:(i + 1)]) for i in range (len(lens))] #XD
NUM_SERVICES = sum(lens)  
for i in range(1, NUM_SERVICES + 1):
    if i <= prefix_lens[0]:
        stype = "ClassMeetingService"
        class_meeting_records[i - 1]['ServiceID'] = i
        price_students = round(random.uniform(10, 50), 2)
        price_others   = round(price_students + random.uniform(5, 30), 2)
        class_meeting_service_records.append({
            'ServiceID': i,
            'PriceStudents': price_students,
            'PriceOthers': price_others
        })
    elif i <= prefix_lens[1]:
        stype = "StudiesService"
        # class_meeting_records[i - prefix_lens[0] - 1]['ServiceID'] = i
        studies_records[i - prefix_lens[0] - 1]['ServiceID'] = i
        entry_fee = round(random.uniform(100, 500), 2)
        studies_service_records.append({
            'ServiceID': i,
            'EntryFee': entry_fee
        })
    elif i <= prefix_lens[2]:
        stype = "ConventionService"
        # class_meeting_records[i - prefix_lens[1] - 1]['ServiceID'] = i
        convention_records[i - prefix_lens[1] - 1]['ServiceID'] = i
        conv_price = round(random.uniform(50, 250), 2)
        convention_service_records.append({
            'ServiceID': i,
            'Price': conv_price
        })
    elif i <= prefix_lens[3]:
        stype = "CourseService"
        # class_meeting_records[i - prefix_lens[2] - 1]['ServiceID'] = i
        courses_records[i - prefix_lens[2] - 1]['ServiceID'] = i
        adv_val = round(random.uniform(50, 200), 2)
        full_val = adv_val + round(random.uniform(50, 300), 2)
        course_service_records.append({
            'ServiceID': i,
            'AdvanceValue': adv_val,
            'FullPrice': full_val
        })
    else:
        stype = "WebinarService"
        webinars_data[i - prefix_lens[3] - 1]['ServiceID'] = i
        web_price = round(random.uniform(20, 150), 2)
        webinar_service_records.append({
            'ServiceID': i,
            'Price': web_price
        })
    services_records.append({
        'ServiceID': i,
        'ServiceType': stype
    })

order_records = []
next_order_id = 1
student_user_ids = [u['UserID'] for u in user_records if u['UserTypeID'] == 1]
for _ in range(NUM_ORDERS):
    if not student_user_ids:
        break
    buyer_id = random.choice(student_user_ids)
    order_date = faker.date_time_between(start_date='-1y', end_date='now')
    pay_link = faker.uri()[:60] if random.choice([True, False]) else None
    order_records.append({
        'OrderID': next_order_id,
        'UserID': buyer_id,
        'OrderDate': order_date,
        'PaymentLink': pay_link
    })
    next_order_id += 1

# OrderDetails
order_details_records = []
for odr in order_records:
    how_many_srv = random.randint(MIN_SERVICES_PER_ORDER, MAX_SERVICES_PER_ORDER)
    chosen_srv = random.sample(services_records, k=how_many_srv)
    for srv in chosen_srv:
        order_details_records.append({
            'OrderID': odr['OrderID'],
            'ServiceID': srv['ServiceID']
        })

# Payments
payment_records = []
next_payment_id = 1
if order_details_records:
    for _ in range(NUM_PAYMENTS):
        od = random.choice(order_details_records)
        paid_or_not = random.choice([True, False, False])  # ~1/3 chance is unpaid
        if paid_or_not:
            pay_value = round(random.uniform(10, 500), 2)
            pay_date  = faker.date_time_between(start_date='-6m', end_date='now')
        else:
            pay_value = round(random.uniform(10, 500), 2)
            pay_date  = None
        payment_records.append({
            'PaymentID': next_payment_id,
            'PaymentValue': pay_value,
            'PaymentDate': pay_date,
            'ServiceID': od['ServiceID'],
            'OrderID': od['OrderID']
        })
        next_payment_id += 1



# ==============================================================================
# PRINTING ALL INSERT STATEMENTS
# ==============================================================================

print("use u_szymocha")
print('EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";')
print('DECLARE @sql NVARCHAR(MAX);')

print("SET @sql = (")
print("SELECT STRING_AGG('DELETE FROM [' + TABLE_NAME + '];', ' ')")
print("FROM INFORMATION_SCHEMA.TABLES")
print("WHERE TABLE_TYPE = 'BASE TABLE'")
print(");")

print("EXEC sp_executesql @sql;")

print('EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";')
print("-- =====================================")
print("-- 1) USER/EMPLOYEE-RELATED TABLES")
print("-- =====================================")

# 1a) UserType
print("\n-- INSERT INTO UserType")
for ut in user_type_records:
    print(f"INSERT INTO UserType (UserTypeID, UserTypeName) "
          f"VALUES ({ut['UserTypeID']}, '{quote_str(ut['UserTypeName'])}');")

# 1b) UserTypePermissionsHierarchy
print("\n-- INSERT INTO UserTypePermissionsHierarchy")
for perm in user_type_permissions:
    sup_val = perm['DirectTypeSupervisor'] if perm['DirectTypeSupervisor'] else 'NULL'
    print(f"INSERT INTO UserTypePermissionsHierarchy (UserTypeID, DirectTypeSupervisor) "
          f"VALUES ({perm['UserTypeID']}, {sup_val});")

# 2) Locations
print("\n-- INSERT INTO Locations")
for loc in location_records:
    print(f"INSERT INTO Locations (LocationID, CountryName, ProvinceName, CityName) "
          f"VALUES ({loc['LocationID']}, '{quote_str(loc['CountryName'])}', "
          f"'{quote_str(loc['ProvinceName'])}', '{quote_str(loc['CityName'])}');")

# 3) Languages
print("\n-- INSERT INTO Languages")
for l in language_records:
    print(f"INSERT INTO Languages (LanguageID, LanguageName) "
          f"VALUES ({l['LanguageID']}, '{quote_str(l['LanguageName'])}');")

# 4) Degrees
print("\n-- INSERT INTO Degrees")
for d in degree_records:
    print(f"INSERT INTO Degrees (DegreeID, DegreeLevel, DegreeName) "
          f"VALUES ({d['DegreeID']}, '{quote_str(d['DegreeLevel'])}', '{quote_str(d['DegreeName'])}');")

# 5) Grades
print("\n-- INSERT INTO Grades")
for gr in grade_records:
    print(f"INSERT INTO Grades (GradeID, GradeValue, GradeName) "
          f"VALUES ({gr['GradeID']}, {gr['GradeValue']}, '{quote_str(gr['GradeName'])}');")

# 6) Users
print("\n-- INSERT INTO Users")
for u in sorted(user_records, key=lambda x: x['UserID']):
    dob_str = u['DateOfBirth'].strftime('%Y-%m-%d')
    print(f"INSERT INTO Users (UserID, FirstName, LastName, DateOfBirth, UserTypeID) "
          f"VALUES ({u['UserID']}, '{quote_str(u['FirstName'])}', '{quote_str(u['LastName'])}', "
          f"'{dob_str}', {u['UserTypeID']});")

# 7) UserContact
print("\n-- INSERT INTO UserContact")
for uc in user_contact_records:
    print(f"INSERT INTO UserContact (UserID, Email, Phone) "
          f"VALUES ({uc['UserID']}, '{quote_str(uc['Email'])}', '{quote_str(uc['Phone'])}');")

# 8) UserAddressDetails
print("\n-- INSERT INTO UserAddressDetails")
for ua in user_address_records:
    print(f"INSERT INTO UserAddressDetails (UserID, Address, PostalCode, LocationID) "
          f"VALUES ({ua['UserID']}, '{quote_str(ua['Address'])}', '{quote_str(ua['PostalCode'])}', "
          f"{ua['LocationID']});")

# 9) Employees
print("\n-- INSERT INTO Employees")
for emp in employee_records:
    doh_str = emp['DateOfHire'].strftime('%Y-%m-%d')
    print(f"INSERT INTO Employees (EmployeeID, DateOfHire) "
          f"VALUES ({emp['EmployeeID']}, '{doh_str}');")

# 10) EmployeesSuperior
print("\n-- INSERT INTO EmployeesSuperior")
for es in employees_superior_records:
    print(f"INSERT INTO EmployeesSuperior (EmployeeID, ReportsTo) "
          f"VALUES ({es['EmployeeID']}, {es['ReportsTo']});")

# 11) Translators
print("\n-- INSERT INTO Translators")
for tr in translator_records:
    print(f"INSERT INTO Translators (TranslatorID) VALUES ({tr['TranslatorID']});")

# 11b) TranslatorsLanguages
print("\n-- INSERT INTO TranslatorsLanguages")
for tl in translators_languages_records:
    print(f"INSERT INTO TranslatorsLanguages (TranslatorID, LanguageID) "
          f"VALUES ({tl['TranslatorID']}, {tl['LanguageID']});")

# 12) EmployeeDegree
print("\n-- INSERT INTO EmployeeDegree")
for ed in employee_degree_records:
    print(f"INSERT INTO EmployeeDegree (EmployeeID, DegreeID) "
          f"VALUES ({ed['EmployeeID']}, {ed['DegreeID']});")

# ==============================================================================
# 13) COLLEGE/ACADEMIC TABLES
# ==============================================================================
print("\n-- INSERT INTO ServiceUserDetails")
for sud in service_user_details_records:
    reg_date = sud['DateOfRegistration'].strftime('%Y-%m-%d')
    print(f"INSERT INTO ServiceUserDetails (ServiceUserID, DateOfRegistration) "
          f"VALUES ({sud['ServiceUserID']}, '{reg_date}');")

print("\n-- INSERT INTO Studies")
for s in studies_records:
    dl_str = s['EnrollmentDeadline'].strftime('%Y-%m-%d')
    gd_str = s['ExpectedGraduationDate'].strftime('%Y-%m-%d')
    coord_val = s['StudiesCoordinatorID'] if s['StudiesCoordinatorID'] != 'NULL' else 'NULL'
    print(f"INSERT INTO Studies (StudiesID, StudiesName, StudiesDescription, StudiesCoordinatorID, "
          f"EnrollmentLimit, EnrollmentDeadline, ExpectedGraduationDate, ServiceID) "
          f"VALUES ({s['StudiesID']}, '{quote_str(s['StudiesName'])}', '{quote_str(s['StudiesDescription'])}', "
          f"{coord_val}, {s['EnrollmentLimit']}, '{dl_str}', '{gd_str}', "
          f"{s['ServiceID']});")

print("\n-- INSERT INTO SemesterDetails")
for sem in semester_records:
    sd = sem['StartDate'].strftime('%Y-%m-%d')
    ed = sem['EndDate'].strftime('%Y-%m-%d')
    print(f"INSERT INTO SemesterDetails (SemesterID, StudiesID, StartDate, EndDate) "
          f"VALUES ({sem['SemesterID']}, {sem['StudiesID']}, "
          f"'{sd}', '{ed}');")

print("\n-- INSERT INTO Subject")
for sb in subject_records:
    sc_val = sb['SubjectCoordinatorID'] if sb['SubjectCoordinatorID'] != 'NULL' else 'NULL'
    print(f"INSERT INTO Subject (SubjectID, StudiesID, SubjectName, SubjectDescription, SubjectCoordinatorID, "
          f"ServiceID, Meetings) "
          f"VALUES ({sb['SubjectID']}, {sb['SubjectID']}, '{quote_str(sb['SubjectName'])}', "
          f"'{quote_str(sb['SubjectDescription'])}', {sc_val}, {sb['ServiceID']}, {sb['Meetings']});")

print("\n-- INSERT INTO SubjectStudiesAssignment")
for s2s in subject_to_studies_records:
    print(f"INSERT INTO SubjectStudiesAssignment (StudiesID, SubjectID) "
          f"VALUES ({s2s['StudiesID']}, {s2s['SubjectID']});")

print("\n-- INSERT INTO Internship")
for it in internship_records:
    st_date = it['StartDate'].strftime('%Y-%m-%d')
    print(f"INSERT INTO Internship (InternshipID, StudiesID, StartDate) "
          f"VALUES ({it['InternshipID']}, {it['StudiesID']}, '{st_date}');")

print("\n-- INSERT INTO StudiesDetails")
for sdrec in studies_details_records:
    print(f"INSERT INTO StudiesDetails (StudiesID, StudentID, StudiesGrade) "
          f"VALUES ({sdrec['StudiesID']}, {sdrec['StudentID']}, {sdrec['StudiesGrade']});")

print("\n-- INSERT INTO InternshipDetails")
for itd in internship_details_records:
    print(f"INSERT INTO InternshipDetails (InternshipID, StudentID, Duration, InternshipGrade, InternshipAttendance) "
          f"VALUES ({itd['InternshipID']}, {itd['StudentID']}, {itd['Duration']}, "
          f"{itd['InternshipGrade']}, {itd['InternshipAttendance']});")

# 21) Convention
print("\n-- INSERT INTO Convention")
for cv in convention_records:
    cstart_str = cv['StartDate'].strftime('%Y-%m-%d')
    print(f"INSERT INTO Convention (SemesterID, SubjectID, ConventionID, ServiceID, StartDate, Duration) "
          f"VALUES ({cv['SemesterID']}, {cv['SubjectID']}, {cv['ConventionID']}, {cv['ServiceID']}, "
          f"'{cstart_str}', {cv['Duration']});")

# 22) ClassMeeting
print("\n-- INSERT INTO ClassMeeting")
for cm in class_meeting_records:
    tr_val = cm['TranslatorID'] if cm['TranslatorID'] != 'NULL' else 'NULL'
    tch_val = cm['TeacherID'] if cm['TeacherID'] != 'NULL' else 'NULL'
    meet_name = quote_str(cm['MeetingName'])
    print(f"INSERT INTO ClassMeeting (ClassMeetingID, SubjectID, TeacherID, MeetingName, TranslatorID, "
          f"LanguageID, ServiceID, MeetingType) "
          f"VALUES ({cm['ClassMeetingID']}, {cm['SubjectID']}, {tch_val}, '{meet_name}', "
          f"{tr_val}, {cm['LanguageID']}, {cm['ServiceID']}, '{cm['MeetingType']}');")

print("\n-- INSERT INTO StationaryClass")
for sc in stationary_class_records:
    print(f"INSERT INTO StationaryClass (MeetingID, RoomID, GroupSize, StartDate, Duration) "
          f"VALUES ({sc['MeetingID']}, {sc['RoomID']}, {sc['GroupSize']}, "
          f"'{sc['StartDate']}', '{sc['Duration']}');")

print("\n-- INSERT INTO OnlineLiveClass")
for oc in online_live_class_records:
    print(f"INSERT INTO OnlineLiveClass (MeetingID, Link, StartDate, Duration) "
          f"VALUES ({oc['MeetingID']}, '{quote_str(oc['Link'])}', "
          f"'{oc['StartDate']}', '{oc['Duration']}');")

print("\n-- INSERT INTO OfflineVideoClass")
for ofc in offline_video_class_records:
    print(f"INSERT INTO OfflineVideoClass (MeetingID, VideoLink, StartDate, Deadline) "
          f"VALUES ({ofc['MeetingID']}, '{quote_str(ofc['VideoLink'])}', "
          f"'{ofc['StartDate']}', '{ofc['Deadline']}');")

print("\n-- INSERT INTO SyncClassDetails")
for sdc in sync_class_details_records:
    print(f"INSERT INTO SyncClassDetails (MeetingID, StudentID, Attendance) "
          f"VALUES ({sdc['MeetingID']}, {sdc['StudentID']}, {sdc['Attendance']});")

print("\n-- INSERT INTO AsyncClassDetails")
for adc in async_class_details_records:
    print(f"INSERT INTO AsyncClassDetails (MeetingID, StudentID, ViewDate) "
          f"VALUES ({adc['MeetingID']}, {adc['StudentID']}, '{adc['ViewDate']}');")

print("\n-- INSERT INTO SubjectDetails")
for sdet in subject_details_records:
    print(f"INSERT INTO SubjectDetails (SubjectID, StudentID, SubjectGrade, Attendance) "
          f"VALUES ({sdet['SubjectID']}, {sdet['StudentID']}, {sdet['SubjectGrade']}, {sdet['Attendance']});")

# ==============================================================================
# COURSES TABLES
# ==============================================================================
print("\n-- INSERT INTO Courses")
for c in courses_records:
    course_date_str = c['CourseDate'].strftime('%Y-%m-%d')
    coord_val = c['CourseCoordinatorID'] if c['CourseCoordinatorID'] != 'NULL' else 'NULL'
    print(f"INSERT INTO Courses (CourseID, CourseName, CourseDescription, CourseCoordinatorID, "
          f"ServiceID, CourseDate, EnrollmentLimit) "
          f"VALUES ({c['CourseID']}, '{quote_str(c['CourseName'])}', '{quote_str(c['CourseDescription'])}', "
          f"{coord_val}, {c['ServiceID']}, '{course_date_str}', '{c['EnrollmentLimit']}');")
    
print("\n-- INSERT INTO Modules")
for m in modules_records:
    translator_val = m['TranslatorID'] if m['TranslatorID'] != 'NULL' else 'NULL'
    coord_val = m['ModuleCoordinatorID'] if m['ModuleCoordinatorID'] != 'NULL' else 'NULL'
    print(f"INSERT INTO Modules (ModuleID, LanguageID, CourseID, TranslatorID, ModuleCoordinatorID, ModuleType) "
          f"VALUES ({m['ModuleID']}, {m['LanguageID']}, {m['CourseID']}, {translator_val}, "
          f"{coord_val}, '{quote_str(m['ModuleType'])}');")
    
print("\n-- INSERT INTO StationaryMeeting")
for m in stationary_meetings_records:
    print(f"INSERT INTO StationaryMeeting (MeetingID, MeetingDate, MeetingDuration, ModuleID, RoomID, GroupSize, TeacherID) "
          f"VALUES ({m['MeetingID']}, '{m['MeetingDate'].strftime('%Y-%m-%d %H:%M:%S')}', '{m['MeetingDuration']}', "
          f"{m['ModuleID']}, {m['RoomID']}, {m['GroupSize']}, {m['TeacherID']});")

print("\n-- INSERT INTO StationaryMeetingDetails")
for m in stationary_meeting_details_records:
    print(f"INSERT INTO StationaryMeetingDetails (MeetingID, ParticipantID, Attendance) "
          f"VALUES ({m['MeetingID']}, {m['ParticipantID']}, {m['Attendance']});")

print("\n-- INSERT INTO OfflineVideo")
for v in offline_video_records:
    print(f"INSERT INTO OfflineVideo (MeetingID, VideoLink, ModuleID, VideoDuration, TeacherID) "
          f"VALUES ({v['MeetingID']}, '{quote_str(v['VideoLink'])}', {v['ModuleID']}, '{v['VideoDuration']}', {v['TeacherID']});")

print("\n-- INSERT INTO OfflineVideoDetails")

for v in offline_video_details_records:
    date_value = 'NULL' if v['dateOfViewing'] == 'NULL' else f"'{v['dateOfViewing'].strftime('%Y-%m-%d %H:%M:%S')}'"
    print(f"INSERT INTO OfflineVideoDetails (MeetingID, ParticipantID, dateOfViewing) "
          f"VALUES ({v['MeetingID']}, {v['ParticipantID']}, {date_value});")

print("\n-- INSERT INTO OnlineLiveMeeting")
for ol in online_live_meetings_records:
    print(f"INSERT INTO OnlineLiveMeeting (MeetingID, PlatformName, Link, VideoLink, ModuleID, MeetingDate, MeetingDuration, TeacherID) "
          f"VALUES ({ol['MeetingID']}, '{quote_str(ol['PlatformName'])}', '{quote_str(ol['Link'])}', '{quote_str(ol['VideoLink'])}', "
          f"{ol['ModuleID']}, '{ol['MeetingDate'].strftime('%Y-%m-%d %H:%M:%S')}', '{ol['MeetingDuration']}', {ol['TeacherID']});")

print("\n-- INSERT INTO OnlineLiveMeetingDetails")
for ol in online_live_meeting_details_records:
    print(f"INSERT INTO OnlineLiveMeetingDetails (MeetingID, ParticipantID, Attendance) "
          f"VALUES ({ol['MeetingID']}, {ol['ParticipantID']}, {ol['Attendance']});")

print("\n-- INSERT INTO CourseParticipants")
for cp in course_participants_records:
    print(f"INSERT INTO CourseParticipants (ParticipantID, CourseID) "
          f"VALUES ({cp['ParticipantID']}, {cp['CourseID']});")

# ==============================================================================
# 26) PAYMENT TABLES
# ==============================================================================
print("\n-- INSERT INTO Services")
for srv in services_records:
    print(f"INSERT INTO Services (ServiceID, ServiceType) "
          f"VALUES ({srv['ServiceID']}, '{srv['ServiceType']}');")

print("\n-- INSERT INTO ClassMeetingService")
for cms in class_meeting_service_records:
    print(f"INSERT INTO ClassMeetingService (ServiceID, PriceStudents, PriceOthers) "
          f"VALUES ({cms['ServiceID']}, {format_money(cms['PriceStudents'])}, {format_money(cms['PriceOthers'])});")

print("\n-- INSERT INTO StudiesService")
for sss in studies_service_records:
    print(f"INSERT INTO StudiesService (ServiceID, EntryFee) "
          f"VALUES ({sss['ServiceID']}, {format_money(sss['EntryFee'])});")

print("\n-- INSERT INTO ConventionService")
for cos in convention_service_records:
    print(f"INSERT INTO ConventionService (ServiceID, Price) "
          f"VALUES ({cos['ServiceID']}, {format_money(cos['Price'])});")

print("\n-- INSERT INTO WebinarService")
for wbs in webinar_service_records:
    print(f"INSERT INTO WebinarService (ServiceID, Price) "
          f"VALUES ({wbs['ServiceID']}, {format_money(wbs['Price'])});")

print("\n-- INSERT INTO CourseService")
for cs in course_service_records:
    print(f"INSERT INTO CourseService (ServiceID, AdvanceValue, FullPrice) "
          f"VALUES ({cs['ServiceID']}, {format_money(cs['AdvanceValue'])}, {format_money(cs['FullPrice'])});")

print("\n-- INSERT INTO Orders")
for odr in order_records:
    date_str = odr['OrderDate'].strftime('%Y-%m-%d %H:%M:%S')
    pay_link = f"'{quote_str(odr['PaymentLink'])}'" if odr['PaymentLink'] else "NULL"
    print(f"INSERT INTO Orders (OrderID, UserID, OrderDate, PaymentLink) "
          f"VALUES ({odr['OrderID']}, {odr['UserID']}, '{date_str}', {pay_link});")

print("\n-- INSERT INTO OrderDetails")
for od in order_details_records:
    print(f"INSERT INTO OrderDetails (OrderID, ServiceID) "
          f"VALUES ({od['OrderID']}, {od['ServiceID']});")

print("\n-- INSERT INTO Payments")
for p in payment_records:
    pay_val = format_money(p['PaymentValue'])
    pay_date = format_datetime(p['PaymentDate'])
    print(f"INSERT INTO Payments (PaymentID, PaymentValue, PaymentDate, ServiceID, OrderID) "
          f"VALUES ({p['PaymentID']}, {pay_val}, {pay_date}, {p['ServiceID']}, {p['OrderID']});")

print("\n-- INSERT INTO ServiceUserDetails")
for p in service_user_details_records:
    print(f"INSERT INTO ServiceUserDetails (ServiceUserID, DateOfRegistration)"
          f"VALUES ({p['ServiceUserID']}, '{p['DateOfRegistration']}');")

print("\n-- INSERT INTO Webinars")
for wb in webinars_data:
    print(f"INSERT INTO Webinars (WebinarID, TeacherID, TranslatorID, WebinarName, WebinarDate, Link, DurationTime, LinkToVideo, WebinarDescription, LanguageID, AvailableDue, ServiceID) "
          f"VALUES ({wb['WebinarID']}, {wb['TeacherID']}, {wb['TranslatorID']}, '{quote_str(wb['WebinarName'])}', '{wb['WebinarDate'].strftime('%Y-%m-%d %H:%M:%S')}', '{quote_str(wb['Link'])}', '{wb['DurationTime']}', '{quote_str(wb['LinkToVideo'])}', '{quote_str(wb['WebinarDescription'])}', {wb['LanguageID']}, '{wb['AvailableDue']}', {wb['ServiceID']});")

print("\n-- INSERT INTO WebinarDetails")
for wd in webinardetails_data:
    print(f"INSERT INTO WebinarDetails (UserID, WebinarID) "
          f"VALUES ({wd['ParticipantID']}, {wd['WebinarID']});")
print("\n-- Done generating integrated mock data (Users, Employees, College, Payments).")
