{{ config(materialized='table') }}

{{ config(materialized='table') }}

with cleansed_stripe as
(
    select *
    from {{ ref('stripe')}}

)

select st.user_id,
       st.month,
       st.year,
       st.ccv,
       st.ccv_amex,
       st.dt_current_timestamp       
from cleansed_stripe as st