-- Required for Oracle 18c XE
alter session set "_ORACLE_SCRIPT"=true;

create user simplicite identified by simplicite;
grant connect, resource to simplicite;
grant unlimited tablespace to simplicite;
grant create sequence to simplicite;
grant create procedure to simplicite;
grant exp_full_database, imp_full_database to simplicite;
alter profile default limit password_life_time unlimited;
alter user simplicite identified by simplicite account unlock;
