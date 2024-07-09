{{ config(materialized='view') }}

with src_vehicle as
(
    select *
    from workshop_moderno_raw.public.vehicle
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
from src_vehicle as vh