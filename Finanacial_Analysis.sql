create schema financial_analysis;
use financial_analysis;

-- 1. What are the names of all the customers who live in New York?
select concat(firstname," ",lastname) as Customer_name from customers 
where city = "New York";
-- 2. What is the total number of accounts in the Accounts table?
select count(distinct accountid) as total_accounts 
from accounts;
-- 3. What is the total balance of all checking accounts?
select sum(balance) as total_balance
from accounts
where accounttype = "checking";
-- 4. What is the total balance of all accounts associated with customers who live in Los Angeles?
select c.customerid as Customer_ID,concat(firstname," ",lastname) as Customer_Name,
 sum(balance) as total_balance 
from customers c
join accounts a 
on c.customerid = a.customerid
where c.city = "Los Angeles"
group by c.customerid,Customer_Name;
-- 5. Which branch has the highest average account balance?
with branch_with_highest_average_balance as
	(select branchname as Branch_Name , round(avg(balance),2) as avg_balance ,
	rank() over(order by round(avg(balance),2) desc) as branch_rank
	from branches b 
	join accounts a 
	on b.branchid = a.branchid
	group by Branch_Name)
select Branch_Name,avg_balance
from branch_with_highest_average_balance
where branch_rank =1 ;

-- 6. Which customer has the highest current balance in their accounts?
with customer_with_highest_currenct_balance_table as
	(select c.customerid as Customer_ID , concat(firstname," ",lastname) as Customer_Name,
    sum(a.balance) as total_balance ,
	rank() over(order by  sum(a.balance) desc) as customer_rank_based_on_balance
	from customers c 
	join accounts a 
	on c.customerid = a.customerid
	group by c.customerid,Customer_Name)
select Customer_ID,Customer_Name,total_balance
from customer_with_highest_currenct_balance_table
where customer_rank_based_on_balance = 1;
-- 7. Which customer has made the most transactions in the Transactions table?
with transactions_table as(select a.customerid as Customer_ID , count(distinct t.transactionid) as total_transactions,
rank() over(order by count(distinct t.transactionid) desc ) as customer_rank_based_on_transactions
from accounts a 
join transactions t 
on a.accountid = t.accountid
group by a.customerid)
select Customer_ID,total_transactions 
from transactions_table
where customer_rank_based_on_transactions = 1 ;
-- 8.Which branch has the highest total balance across all of its accounts?
with branch_with_maximum_total_balance as
	(select b.branchid as Branch_ID,b.branchname as Branch_Name ,
	sum(a.balance) as branch_total_balance,
	rank() over(order by sum(balance) desc) as branch_rank 
	from branches b 
	join accounts a
	on b.branchid = a.branchid
	group by Branch_ID,Branch_Name)
select Branch_ID,Branch_Name,branch_total_balance
from branch_with_maximum_total_balance
where branch_rank = 1 ;
-- 9. Which customer has the highest total balance across all of their accounts, 
#including savings and checking accounts?
with customer_with_highest_total_balance_table as
	(select c.customerid as Customer_ID , concat(firstname," ",lastname) as Customer_Name,
    sum(a.balance) as total_balance ,
	rank() over(order by  sum(a.balance) desc) as customer_rank_based_on_balance
	from customers c 
	join accounts a 
	on c.customerid = a.customerid
	group by c.customerid,Customer_Name)
select Customer_ID,Customer_Name,total_balance
from customer_with_highest_total_balance_table
where customer_rank_based_on_balance = 1;
-- 10. Which branch has the highest number of transactions in the Transactions table?

SELECT t1.Branch_ID, b.branchname AS Branch_Name, t1.total_transactions
FROM (
    SELECT a.branchid AS Branch_ID,
           COUNT(DISTINCT transactionid) AS total_transactions,
           DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT transactionid) DESC) AS trans_rank
    FROM accounts a
    JOIN transactions t ON a.accountid = t.accountid
    GROUP BY Branch_ID
) t1
JOIN branches b ON t1.Branch_ID = b.branchid
where t1.trans_rank = 1;

