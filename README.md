# PostgreSQL Backup & Verification (Windows)

A lightweight, opinionated set of scripts and instructions to automate PostgreSQL backups on Windows, verify the backup contents, and log results. This repository contains a timestamped custom-format dump workflow, an automated verification script, and instructions for scheduling with Windows Task Scheduler.

Important: This project targets PostgreSQL installed on Windows (pg_dump/pg_restore/psql in "C:\Program Files\PostgreSQL\<version>\bin"). Do NOT commit any secrets (passwords or pgpass files) to this repository.

Status: Stable — tested on PostgreSQL 16 on Windows 10/11.

---

## Table of Contents
- Repo layout
- Quick start
- Script: verify_backup.bat
- How verification works
- Scheduling with Task Scheduler
- Restore examples
- Security notes
- Troubleshooting
- License

## Repo layout

```
/ (root)
├── README.md
├── verify_backup.bat         # main automation script (Windows batch)
├── backup_flowchart.png      # optional visuals
├── postgres-backup-guide.qmd # Quarto blog post source (optional)
└── samples/
    └── dump_contents.txt     # example output from pg_restore -l
```
## Quick start

1. Clone this repo to a machine that can connect to your PostgreSQL server.
2. Edit `verify_backup.bat` to set paths, DB name, and user.
3. Create the backup folder (example uses `C:\edb`):
```cmd
md C:\edb
```
4. Prepare passwordless authentication for automated runs (see Security notes).
5. Test manually:
```cmd
"C:\Program Files\PostgreSQL\16\bin\pg_dump.exe" -h localhost -p 5432 -U postgres -F c -b -v -f "C:\edb\analyticsscdb.dump" analyticsscdb

"C:\Program Files\PostgreSQL\16\bin\pg_restore.exe" -l "C:\edb\analyticsscdb.dump" | more
```

## Script: verify_backup.bat

- Save this file as `verify_backup.bat` in the repo root
- Edit the configuration variables at the top to match your environment (PG_BIN, BACKUP_DIR, DB_NAME, DB_USER, DB_HOST).

## How verification works

- The script performs a quantitative check:
  - It counts the number of tables in the live DB via a simple SQL query on information_schema.
  - It lists the dump contents (`pg_restore -l`) and counts "TABLE" entries.
  - If counts match, the script logs success; otherwise it logs a failure.
- Notes:
  - This check is a quick sanity test, not a substitute for a periodic trial restore.
  - For full verification, perform a test restore into a temporary database and run smoke tests.

## Scheduling with Task Scheduler

1. Open Task Scheduler -> Create Basic Task...
2. Name: PostgreSQL Daily Backup (or similar).
3. Trigger: Daily (pick a time).
4. Action: Start a program -> Program/script: browse to `C:\edb\verify_backup.bat`.
5. Before finishing, check "Open the Properties dialog for this task when I click Finish".
6. In Properties:
   - General: Select "Run whether user is logged on or not".
   - Check "Run with highest privileges".
   - Enter your Windows password when prompted.
7. (Optional) In Conditions/Settings, configure network and power behavior as needed.

## Restore examples

- Restore a custom-format dump and let pg_restore create the DB (if dump includes DB creation):
```cmd
"C:\Program Files\PostgreSQL\16\bin\pg_restore.exe" -h localhost -p 5432 -U postgres -C -d postgres -v "C:\edb\analyticsscdb_sample.dump"
```
- Restore into an existing DB:
```cmd
"C:\Program Files\PostgreSQL\16\bin\createdb.exe" -h localhost -p 5432 -U postgres restored_db
"C:\Program Files\PostgreSQL\16\bin\pg_restore.exe" -h localhost -p 5432 -U postgres -d restored_db -v "C:\edb\analyticsscdb_sample.dump"
```
- Restore a plain SQL file:
```cmd
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h localhost -p 5432 -U postgres -d restored_db -f "C:\edb\analyticsscdb_sample.sql"
```

## Security notes (must read)

- Do NOT check any password files (.pgpass.conf) into version control.
- For automation, create `%APPDATA%\postgresql\pgpass.conf` with:
  ```
  localhost:5432:*:postgres:your_password_here
  ```
  and restrict file permissions to your user account only.
- Alternatively, use integrated OS credential managers or a secrets vault rather than plaintext passwords.

## Troubleshooting & common checks

- If pg_dump fails: ensure PostgreSQL service is running:
```cmd
netstat -ano | findstr 5432
tasklist /FI "IMAGENAME eq postgres.exe"
```
- If authentication errors: confirm pgpass is present and correctly formatted, or run pg_dump interactively to verify password works.
- If permission denied writing to C:\edb: run the task as Administrator or choose a user-writable folder like `%USERPROFILE%\edb`.
- Inspect the log:
```cmd
notepad "C:\edb\backup_log.txt"
```
## Contributing

- Pull requests are welcome for improvements and additional verification checks (e.g., checksums, row counts per table).
- Please do not add any file containing live credentials.

## License
- MIT License — see LICENSE file.

## Author / Contact
- Dramane B. Salifou — dsalifou@gmail.com / d.salifou298@mybvc.ca / dsalifou@hotmail.com
  
