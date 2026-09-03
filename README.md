# MCA Placement Management System — ER Model

![ER Diagram](ER_Diagram.png)

## Overview

This system tracks the full placement lifecycle for MCA students: companies visiting campus, the drives/job postings they run, student applications, interview rounds, and final offers. A placement coordinator (TPO) manages drives, and students maintain a skill profile used for eligibility matching.

## ER Diagram

```mermaid
erDiagram
    COMPANY ||--o{ PLACEMENT_DRIVE : posts
    COORDINATOR ||--o{ PLACEMENT_DRIVE : manages
    STUDENT ||--o{ APPLICATION : submits
    PLACEMENT_DRIVE ||--o{ APPLICATION : receives
    APPLICATION ||--o{ INTERVIEW_ROUND : "goes through"
    APPLICATION ||--o| OFFER : results_in
    STUDENT }o--o{ SKILL : possesses

    STUDENT {
        int student_id PK
        string name
        string roll_no
        string email
        string phone
        date dob
        string department
        int batch_year
        float cgpa
        string resume_link
        int backlog_count
    }

    COMPANY {
        int company_id PK
        string company_name
        string industry_type
        string website
        string hr_contact_name
        string hr_email
        string hr_phone
        string address
    }

    COORDINATOR {
        int coordinator_id PK
        string name
        string email
        string phone
        string designation
    }

    PLACEMENT_DRIVE {
        int drive_id PK
        int company_id FK
        int coordinator_id FK
        string job_role
        string job_type
        float package_ctc
        float eligibility_cgpa
        string eligible_departments
        date drive_date
        string venue
        string status
    }

    APPLICATION {
        int application_id PK
        int student_id FK
        int drive_id FK
        date application_date
        string status
    }

    INTERVIEW_ROUND {
        int round_id PK
        int application_id FK
        int round_number
        string round_type
        date interview_date
        string interviewer_name
        string result
        string feedback
    }

    OFFER {
        int offer_id PK
        int application_id FK
        date offer_date
        float ctc_offered
        date joining_date
        string offer_status
    }

    SKILL {
        int skill_id PK
        string skill_name
    }
```

## Entities

| Entity | Purpose |
|---|---|
| **Student** | An MCA student eligible to apply for placements |
| **Company** | A recruiting organization |
| **Coordinator** | Placement cell staff who manage drives |
| **Placement_Drive** | A specific hiring event/job posting run by a company |
| **Application** | Links a student to a drive they applied for |
| **Interview_Round** | One round (technical/HR/GD/aptitude) within an application's process |
| **Offer** | The outcome if an application succeeds |
| **Skill** | A skill a student can list on their profile |

## Relationships & Cardinality

| Relationship | Cardinality | Notes |
|---|---|---|
| Company → Placement_Drive | 1 : N | One company can run many drives over time |
| Coordinator → Placement_Drive | 1 : N | Each drive is managed by one coordinator |
| Student → Application | 1 : N | A student can apply to many drives |
| Placement_Drive → Application | 1 : N | A drive receives many applications |
| Application → Interview_Round | 1 : N | An application can have multiple rounds |
| Application → Offer | 1 : 0..1 | An application results in at most one offer |
| Student ↔ Skill | M : N | Resolved via a `Student_Skill` junction table (student_id, skill_id, proficiency_level) |

`Application` is intentionally modeled as its own entity (not just a join table) because it carries its own status and lifecycle (Applied → Shortlisted → Interviewed → Selected/Rejected), and both `Interview_Round` and `Offer` depend on it.

## Design Notes / Assumptions

- A student can have multiple applications across different drives, but only one application per (student, drive) pair — enforce with a unique constraint on (student_id, drive_id).
- `Offer` is separated from `Application` rather than merged in, since not every application produces one, and an offer has its own fields (CTC offered, joining date) that may differ from the drive's advertised package.
- `eligible_departments` on `Placement_Drive` is kept as a simple field here; if you need strict many-to-many eligibility rules, split it into a `Drive_Eligible_Department` junction table instead.
- Backlogs/CGPA are stored on `Student` since eligibility filtering in most systems checks these directly.

## Suggested Relational Schema Mapping

Each entity above maps 1:1 to a table with the listed attributes. The only extra table needed beyond what's diagrammed is the junction table for the M:N relationship:

```sql
Student_Skill (
    student_id INT REFERENCES Student(student_id),
    skill_id   INT REFERENCES Skill(skill_id),
    proficiency_level VARCHAR(20),
    PRIMARY KEY (student_id, skill_id)
);
```

All other foreign keys (`company_id`, `coordinator_id`, `student_id`, `drive_id`, `application_id`) are as shown in the diagram's entity attribute lists.
