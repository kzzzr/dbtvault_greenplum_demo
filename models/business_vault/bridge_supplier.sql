{{ config(materialized="bridge_incremental") }}

select hs.load_date as hs_load_date,hs.supplierkey,hs.supplier_pk,
	   lia.inventory_allocation_pk,lia.load_date as link_load_date,
	   hl.lineitem_pk,hl.linenumber,hl.load_date as hl_load_date,
	   hp.part_pk,hp.partkey,hp.load_date as hp_load_date 
from hub_supplier hs 
  inner  join link_inventory_allocation lia 
  	on hs.supplier_pk = lia.supplier_pk 
  inner join hub_lineitem hl 
  	on lia.lineitem_pk = hl.lineitem_pk 
  inner join hub_part hp 
  on lia.part_pk  = hp.part_pk 