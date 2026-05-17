set sql_safe_updates=0;
start transaction;
update world.clinical_trials
set nct_id=trim(regexp_replace(nct_id,'[[:space:]]+',' ')),
brief_title=trim(regexp_replace(brief_title,'[[:space:]]+',' ')),
status=trim(regexp_replace(status,'[[:space:]]+',' ')),
phase=trim(regexp_replace(phase,'[[:space:]]+',' ')),
study_type=trim(regexp_replace(study_type,'[[:space:]]+',' ')),
`condition`=trim(regexp_replace(`condition`,'[[:space:]]+',' ')),
intervention_name=trim(regexp_replace(intervention_name,'[[:space:]]+',' ')),
intervention_type=trim(regexp_replace(intervention_type,'[[:space:]]+',' ')),
lead_sponsor_name=trim(regexp_replace(lead_sponsor_name,'[[:space:]]+',' ')),
sponsor_class=trim(regexp_replace(sponsor_class,'[[:space:]]+',' ')),
start_date=trim(regexp_replace(start_date,'[[:space:]]+',' ')),
enrollment_count=trim(regexp_replace(enrollment_count,'[[:space:]]+',' ')),
enrollment_type=trim(regexp_replace(enrollment_type,'[[:space:]]+',' ')),
duration_days=trim(regexp_replace(duration_days,'[[:space:]]+',' ')),
countries=trim(regexp_replace(countries,'[[:space:]]+',' ')),
study_first_submit_date=trim(regexp_replace(study_first_submit_date,'[[:space:]]+',' ')),
results_first_submit_date=trim(regexp_replace(results_first_submit_date,'[[:space:]]+',' ')),
minimum_age=trim(regexp_replace(minimum_age,'[[:space:]]+',' ')),
maximum_age=trim(regexp_replace(maximum_age,'[[:space:]]+',' ')),
std_ages=trim(regexp_replace(std_ages,'[[:space:]]+',' '));
commit;
select nct_id,study_type,countries, count(*) from world.clinical_trials group by nct_id,study_type,countries having count(*)>1;
select 
sum(case when nct_id is null or nct_id in ('','N/A') then 1 else 0 end),
sum(case when brief_title is null or brief_title in ('','N/A') then 1 else 0 end),
sum(case when status is null or status in ('','N/A') then 1 else 0 end),
sum(case when phase is null or phase in ('','N/A') then 1 else 0 end),
sum(case when study_type is null or study_type in ('','N/A') then 1 else 0 end),
sum(case when `condition` is null or `condition` in ('','N/A') then 1 else 0 end),
sum(case when intervention_name is null or intervention_name in ('','N/A') then 1 else 0 end),
sum(case when intervention_type is null or intervention_type in ('','N/A') then 1 else 0 end),
sum(case when lead_sponsor_name is null or lead_sponsor_name in ('','N/A') then 1 else 0 end),
sum(case when sponsor_class is null or sponsor_class in ('','N/A') then 1 else 0 end),
sum(case when start_date is null or start_date in ('','N/A') then 1 else 0 end),
sum(case when primary_completion_date is null or primary_completion_date in ('','N/A') then 1 else 0 end),
sum(case when completion_date is null or completion_date in ('','N/A') then 1 else 0 end),
sum(case when start_year is null or start_year in ('','N/A') then 1 else 0 end),
sum(case when enrollment_count is null or enrollment_count in ('','N/A') then 1 else 0 end),
sum(case when enrollment_type is null or enrollment_type in ('','N/A') then 1 else 0 end),
sum(case when duration_days is null or duration_days in ('','N/A') then 1 else 0 end),
sum(case when countries is null or countries in ('','N/A') then 1 else 0 end),
sum(case when study_first_submit_date is null or study_first_submit_date in ('','N/A') then 1 else 0 end),
sum(case when results_first_submit_date is null or results_first_submit_date in ('','N/A') then 1 else 0 end),
sum(case when minimum_age is null or minimum_age in ('','N/A') then 1 else 0 end),
sum(case when maximum_age is null or maximum_age in ('','N/A') then 1 else 0 end),
sum(case when std_ages is null or std_ages in ('','N/A') then 1 else 0 end) from world.clinical_trials;
update world.clinical_trials
set phase='Other/Unknown' where phase='N/A';
update world.clinical_trials
set intervention_name= 'Unknown' where intervention_name='';
select distinct(primary_completion_date) from world.clinical_trials;
update world.clinical_trials
set start_date= NULL where start_date in ('','Italy"');
update world.clinical_trials
set primary_completion_date= NULL where primary_completion_date ='';
update world.clinical_trials
set start_year= NULL where start_year ='';
update world.clinical_trials
set duration_days= NULL where duration_days ='';
update world.clinical_trials
set study_first_submit_date= NULL where  study_first_submit_date ='';
update world.clinical_trials
set results_first_submit_date= NULL where  results_first_submit_date in ('','France; Germany; Greece; Israel; Italy; Poland; Romania; Slovenia; Spain');
select distinct(countries) from world.clinical_trials;
update world.clinical_trials
set enrollment_type='Unknwon' where enrollment_type='';
delete from world.clinical_trials
where nct_id='NCT02310061';
update world.clinical_trials
set enrollment_count= NULL where  enrollment_count ='';
update world.clinical_trials
set countries= 'Unknown' where  countries ='';
select count(minimum_age) from world.clinical_trials where minimum_age in (null);
select count(maximum_age) from world.clinical_trials where maximum_age in (null);
select count(std_ages) from world.clinical_trials where std_ages in ('',null);
update world.clinical_trials
set minimum_age= NULL where  minimum_age ='';
update world.clinical_trials
set maximum_age= NULL where  maximum_age ='';
alter table world.clinical_trials
modify enrollment_count bigint;

