{{ config(materialized='view') }}

with src_stripe as
(
    select *
    from workshop_moderno_raw.public.stripe
)
select st.user_id,
       st.index,
       st.id,
       st.invalid_card,
       st.month,
       st.year,
       st.ccv,
       st.ccv_amex,
       st.dt_current_timestamp       
from src_stripe as st