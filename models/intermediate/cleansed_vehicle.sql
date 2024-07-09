{{ config(materialized='table') }}

with cleansed_vehicle as
(
    select *
    from {{ ref('vehicle') }}
)
select vh.user_id,
       vh.CAR_OPTIONS,
       vh.CAR_TYPE,
       vh.COLOR,
       vh.DOORS,
       vh.DRIVE_TYPE,
       vh.DT_CURRENT_TIMESTAMP,
       vh.FUEL_TYPE,
       vh.KILOMETRAGE,
       vh.LICENSE_PLATE,
       vh.MAKE_AND_MODEL
from cleansed_vehicle as vh