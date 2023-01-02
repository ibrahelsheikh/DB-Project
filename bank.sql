create database MyBank
go

use MyBank;

CREATE TABLE employee
(
    ssn         CHAR(9) primary key,
    name        VARCHAR(20) NOT NULL,
    phone_num   INT unique,
    start_date  date        NOT NULL,
    manager_ssn CHAR(9),
    FOREIGN KEY (manager_ssn) REFERENCES employee (ssn)
)


/* create a table for the customer */
create table customar
(
    ssn          char(9) primary key,
    name         varchar(20) not null,
    address      varchar(30),
    employee_ssn char(9) foreign key references employee (ssn)
)

create table dependent
(
    name         varchar(20),
    age          int,
    employee_ssn char(9) foreign key references employee (ssn),
    primary key (name, employee_ssn)
)

create table account
(
    number    int primary key identity (1,1),
    balance   float default 0,
    owner_ssn char(9),
    foreign key (owner_ssn) references customar (ssn) on delete cascade
)


create table saving_account
(
    number        int not null,
    interest_rate float default 0.05,
    foreign key (number) references account (number) on delete cascade
)

create table checking_account
(
    number           int not null,
    overdraft_amount float default 500,
    foreign key (number) references account (number) on delete cascade
)

create table branch
(
    name           varchar(10) primary key,
    city           varchar(10),
    available_cash float
)

create table loan
(
    number       int primary key identity (1,1),
    amount       float not null,
    customar_ssn char(9) foreign key references customar (ssn),
    branch_name  varchar(10) foreign key references branch (name),
    borrow_date  date
)

create table payment
(
    number  int primary key identity (1,1),
    loan_no int   not null foreign key references loan (number),
    amount  float not null,
    date    date
)

/* create a table for transactions */
create table trans
(
    customar_ssn char(9) not null foreign key references customar (ssn),
    account_no   int     not null foreign key references account (number),
    date         date,
    type         char    not null,
    amount       float   not null
)

/* create function to make the account for existing customar*/
create procedure new_account @ssn char(9),
                             @type char
as
begin
    insert into account (owner_ssn) values (@ssn)

    declare @account_number int

    set @account_number = (select max(number) from account where owner_ssn = @ssn)
    if (@type = 's')
        insert into saving_account (number) values (@account_number)
    else
        insert into checking_account (number) values (@account_number)
end;


-- changing dateformat:
set dateformat dmy;


-- trigger to decrease the branch-cash when applying new loan from that branch

    create trigger branch_cash
        on loan
        after insert
        as
    begin
        update branch
        set available_cash = available_cash - loan.amount
        FROM loan
    end
        insert into branch
        values ('tanta', 'tanta', 5000)
        update branch
        set available_cash = 50000
        where name = 'tanta'
        insert into loan (amount, customar_ssn, branch_name, borrow_date)
        values (2000, '123456789', 'tanta', '25/1/2011')
        select *
        from loan
        select *
        from branch

        ---------------------------------------------------------------


--drop trigger update_balance_on_transaction


-- trigger to update balance on transaction


        CREATE TRIGGER update_balance_on_transaction
            ON trans
            AFTER INSERT
            AS
        BEGIN
            IF EXISTS(SELECT 1 FROM inserted WHERE [type] = 'd')
                BEGIN
                    UPDATE a
                    SET a.balance = a.balance + t.amount
                    FROM account a,
                         trans t
                    where a.number = t.account_no
                    -- INNER JOIN inserted i ON a.number = i.account_no
                END
            ELSE
                IF EXISTS(SELECT 1 FROM inserted WHERE [type] = 'w')
                    BEGIN
                        UPDATE a
                        SET a.balance = a.balance - t.amount
                        FROM account a,
                             trans t
                        where a.number = t.account_no
                        -- INNER JOIN inserted i ON a.number = i.account_no
                    END
        END
            update account
            set balance = 5000
            where owner_ssn = '444444444'
            insert into trans
            values ('444444444', 2, '25/1/2011', 'w', 500)
            select *
            from account
            select *
            from trans



/* Create procedure to add a new customar "Our rules says any customar must have an account" */
/*  1. Add the customar data
	2. Add the customar account
	3. Choose the type of the account */
            create procedure add_new_customar @ssn char(9),
                                              @name varchar(20),
                                              @address varchar(30),
                                              @employee_ssn char(9),
                                              @account_type char
            as
            begin
                declare @account_number int
                insert into customar values (@ssn, @name, @address, @employee_ssn)

                execute new_account @ssn, @account_type
            end


                execute add_new_customar 910758468, 'Thomas Shelby', 'England', 333333333, 'c';
                execute add_new_customar 444444444, 'Mohamed Abohend', 'Gharbia', 780924598, 's';
                execute add_new_customar 555555555, 'Mohamed Elshorbagy', 'Menofia', 193702892, 'c';
                execute add_new_customar 666666666, 'Ebrahim', 'Alexandria', 193702892, 's';
                execute add_new_customar 999999999, 'Mohamed Elsha7at', 'Marsa Matro7', 222222222, 'c';
                execute add_new_customar 123456789, 'Mohamed Konsowa', 'El3lmeen', 333333333, 's';
                execute new_account 910758468, 's'


