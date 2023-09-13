{{ config(materialized="bridge_incremental") }}


select supplier.SUPPLIER_PK, SatInvSuppNationDet.SUPPLIER_NATION_NAME   
from public.hub_supplier AS supplier  
  join public.link_supplier_nation AS LinkSupNation
  	on supplier.SUPPLIER_PK =LinkSupNation.SUPPLIER_PK 
  join public.sat_inv_supp_nation_details SatInvSuppNationDet
    on LinkSupNation.SUPPLIER_PK = SatInvSuppNationDet.SUPPLIER_PK
      group by supplier.SUPPLIER_PK, SatInvSuppNationDet.SUPPLIER_NATION_NAME