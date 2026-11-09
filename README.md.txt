# Crownfield Eye Hospital Database

## Setup Instructions
1. Run `01_schema.sql` — creates database & tables
2. Run `02_individual_queries.sql` — executes all 6 queries
3. Run `03_procedure_and_trigger.sql` — creates stored procedure & trigger
4. Run `04_security.sql` — applies roles & permissions

## Assumptions
- Patient IDs follow format OP001, OP002 etc.
- Appointment statuses: 'Scheduled', 'Completed', 'Follow-up Required'
- All dates are in UTC
