{{ config(materialized="bridge_incremental") }}

select hc.customer_pk,hc.customerkey,hc.load_date as hc_load_date,
       lco.order_customer_pk,lco.load_date as lco_load_date,
       ho.order_pk,ho.orderkey,ho.load_date as ho_load_date,
       lol.link_lineitem_order_pk,lol.load_date as lol_load_date,
       hl.lineitem_pk ,hl.linenumber ,hl.load_date as hl_load_date
from hub_customer hc 
  inner join link_customer_order lco
  	on hc.customer_pk = lco.customer_pk 
  inner join hub_order ho 
    on lco.order_pk = ho.order_pk
  inner join link_order_lineitem lol 
  	on ho.order_pk = lol.order_pk 
  inner join hub_lineitem hl 
  	on lol.lineitem_pk = hl.lineitem_pk 