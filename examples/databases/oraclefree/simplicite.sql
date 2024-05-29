alter session set container = freepdb1;
create user if not exists simplicite identified by simplicite;
grant connect, resource to simplicite;
grant unlimited tablespace to simplicite;
grant create sequence to simplicite;
grant create procedure to simplicite;
grant exp_full_database, imp_full_database to simplicite;
alter profile default limit password_life_time unlimited;
alter user simplicite identified by simplicite account unlock;
