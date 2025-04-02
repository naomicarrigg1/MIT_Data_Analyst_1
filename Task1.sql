-- total lobbying over $10,000000
select r.registrant_name, sum(f.amount)::numeric as total_amount
from analyst.registrants r 
join analyst.filings f on r.registrant_id = f.registrant_id
group by registrant_name
having sum(f.amount)::numeric > 10000000
order by total_amount desc limit 10;


-- five biggest registrants, five biggest clients for each

select f.client_id 
from analyst.filings f where (
select r.registrant_name, sum(f.amount) as total_amount
from analyst.registrants r 
join analyst.filings f on r.registrant_id =f.registrant_id
where amount is not null
group by r.registrant_name)
order by total_amount desc limit 5;

-- identify registrant who lobbied most for MMM, want bill ids of registrant

with top_lobbyist as (
select r.registrant_id, r.registrant_name, COUNT(distinct(filing_uuid)) as filing_total
from analyst.registrants r 
join analyst.filings f on r.registrant_id = f.registrant_id
join analyst.filings_bills fb on f.filing_uuid = fb.filing_uuid
where fb.general_issue_code = 'MMM'
group by r.registrant_id, r.registrant_name
order by filing_total desc limit 1)
select distinct f.filing_uuid
from analyst.filings f  join top_lobbyist t on t.registrant_id =f.registrant_id;

-- count bills that have standard titles and those that don't

with standard_titles as (
select b.title 
from analyst.bills b
where b.title like '%Act%' or '%Law%' or '%Resolution'
) select count(standard_titles) as standard_titles, count(*)-standard_titles as non_standard
from analyst.bills;

