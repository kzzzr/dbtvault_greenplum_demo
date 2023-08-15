{{ config(materialized="bridge_incremental") }}


select c.customer_pk, socnd.customer_nation_name   
from public.hub_customer c  
  join public.link_customer_nation lcn
  	on c.customer_pk =lcn.customer_pk 
  join public.sat_order_cust_nation_details socnd
    on lcn.customer_pk = socnd.customer_pk
      group by c.customer_pk, socnd.customer_nation_name