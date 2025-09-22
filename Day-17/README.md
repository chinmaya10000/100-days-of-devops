# Day17: PostgreSQL Database Setup for Nautilus Application

## Objective
Set up a PostgreSQL database and user as a prerequisite for deploying the Nautilus application in Stratos DC.

---

## Requirements
- PostgreSQL is already installed on the Nautilus database server.
- Create a database user **kodekloud_gem** with password **8FmzjvFU6S**.
- Create a database **kodekloud_db7** and grant full permissions to **kodekloud_gem**.
- Do **not** restart the PostgreSQL service.

---

## Steps to Implement

### 1. Switch to PostgreSQL user
```bash
sudo -i -u postgres
```

### 2. Access PostgreSQL prompt
```bash
psql
```

### 3. Create database user
```sql
CREATE USER kodekloud_gem WITH PASSWORD '8FmzjvFU6S';
```

### 4. Create database
```sql
CREATE DATABASE kodekloud_db7;
```

### 5. Grant privileges
```sql
GRANT ALL PRIVILEGES ON DATABASE kodekloud_db7 TO kodekloud_gem;
```

### 6. Verify
```sql
\l      -- list all databases
\du     -- list all users
```

### 7. Exit PostgreSQL
```sql
\q
exit
```

---

## Reference

- [PostgreSQL Documentation - Database Roles](https://www.postgresql.org/docs/current/user-manag.html)
- [PostgreSQL Documentation - CREATE DATABASE](https://www.postgresql.org/docs/current/sql-createdatabase.html)