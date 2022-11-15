select * from project.dataset1;
select * from project.dataset2;

-- number of rows into our dataset

select count(*) from project.dataset1;
select count(*) from project.dataset2;

-- dataset for Andhra PradeshMadhya Pradesh Uttar Pradesh Arunachal Pradesh


select * from project.dataset1 where state ='Andhra Pradesh' or state ='Arunachal Pradesh';

-- population of India

select sum(population) as Population from project.dataset2;

-- avg growth 

select state,avg(growth)*100 avg_growth from project.dataset1 group by state;

-- avg sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from project.dataset1
 group by state order by avg_sex_ratio desc;

-- avg literacy rate
 
select state,round(avg(literacy),0) avg_literacy_ratio from project.dataset1
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;

-- top 5 state showing highest growth ratio


select state,avg(growth)*100 avg_growth from project.dataset1
 group by state order by avg_growth desc limit 5;


-- bottom 5 state showing lowest sex ratio

select  state,round(avg(sex_ratio),0) avg_sex_ratio from project.dataset1
 group by state order by avg_sex_ratio asc limit 5;


-- states starting with letter a

select distinct state from project.dataset1 where lower(state) like 'm%' or state like 'C%' ;

select distinct state from project.dataset1 where lower(state) like 'a%' and lower(state) like '%h' ;


-- joining both table

-- total males and females

select e.state,sum(e.males) total_males,sum(e.females) total_females from
    ( 
    select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males,
     round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
       (
       select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population
       from project.dataset1 a inner join project.dataset2 b on a.District=b.District
       ) c
	) e
group by e.state;

-- total literacy rate


select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(
  select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
    round((1-d.literacy_ratio)* d.population,0) illiterate_people from
      (
            select a.district,a.state,a.literacy/100 literacy_ratio,b.population 
            from project.dataset1 a inner join project.dataset2 b on a.district=b.district
       ) 
    d) 
c
group by c.state

-- population in previous census
  select sum(m.previous_census_population) previous_census_population,
     sum(m.current_census_population) current_census_population
   from(
      select e.state,sum(e.previous_census_population) previous_census_population,
           sum(e.current_census_population) current_census_population
      from(
           select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,
           d.population current_census_population 
           from(
                 select a.district,a.state,a.growth growth,b.population
                 from project.dataset1 a inner join project.dataset2 b on a.district=b.district
                 )d
			) e
        group by e.state
        )m



-- window 

output top 3 districts from each state with highest literacy rate


select a.* from(
                select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project.dataset1) a
where a.rnk in (1,2,3) order by state