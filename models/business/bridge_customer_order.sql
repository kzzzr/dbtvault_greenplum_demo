{{ config(materialized="bridge_incremental") }}


select c.customer_pk,customerkey,sum(Totalprice)   
from public.hub_customer c  
  inner join public.link_customer_order lco
  	on c.customer_pk =lco.customer_pk 
  inner join public.sat_order_order_details soo
    on lco.order_pk = soo.order_pk
      group by c.customer_pk,customerkey
