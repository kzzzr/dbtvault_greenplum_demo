{{ config(materialized="bridge_incremental") }}

select
	hs.supplier_pk,
	hs.supplierkey,
	hs.load_date as hs_load_date,
	lsn.link_supplier_nation_pk,
	lsn.load_date as link_supplier_nation_load_date,
	hn.nation_pk,
	hn.load_date as hn_load_date,
	lia.inventory_allocation_pk,
	lia.load_date as link_inventory_allocation_load_date
	
from hub_supplier hs
join link_supplier_nation lsn
on hs.supplier_pk = lsn.supplier_pk
join hub_nation hn
on lsn.nation_pk = hn.nation_pk
join link_inventory_allocation lia
on hs.supplier_pk = lia.supplier_pk