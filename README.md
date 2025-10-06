# PostgreSQL Backup & Verification (Windows)

A lightweight, opinionated set of scripts and instructions to automate PostgreSQL backups on Windows, verify the backup contents, and log results. This repository contains a timestamped custom-format dump workflow, an automated verification script, and instructions for scheduling with Windows Task Scheduler.

Important: This project targets PostgreSQL installed on Windows (pg_dump/pg_restore/psql in "C:\Program Files\PostgreSQL\<version>\bin"). Do NOT commit any secrets (passwords or pgpass files) to this repository.

Status: Stable — tested on PostgreSQL 16 on Windows 10/11.

---

Table of Contents
- Repo layout
- Quick start
- Script: verify_backup.bat
- How verification works
- Scheduling with Task Scheduler
- Restore examples
- Security notes
- Troubleshooting
- License

Repo layout
