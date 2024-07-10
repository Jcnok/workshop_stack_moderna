# Workshop: Modern Data Stack with Airbyte, Airflow, DBT, and Snowflake

## Overview

This workshop demonstrates the implementation of a modern data stack utilizing Airbyte, Airflow, DBT, and Snowflake. The goal is to provide a comprehensive, efficient, and scalable data pipeline from data extraction to transformation and orchestration.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Setup](#project-setup)
  - [MongoDB Atlas and Compass Setup](#mongodb-atlas-and-compass-setup)
  - [Airbyte Setup](#airbyte-setup)
  - [DBT Setup](#dbt-setup)
  - [Airflow Setup](#airflow-setup)
- [Project Structure](#project-structure)
  - [DBT Models](#dbt-models)
  - [Schema Testing](#schema-testing)
  - [Airflow DAG](#airflow-dag)
- [Conclusion](#conclusion)

## Prerequisites

Before starting, ensure you have the following:

- MongoDB Atlas account
- MongoDB Compass installed
- Airbyte account
- Snowflake account
- DBT Cloud account
- GitHub account
- Airflow installed

## Project Setup

### MongoDB Atlas and Compass Setup

1. **Create a MongoDB Atlas Account:**
   - Sign up at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register).

2. **Set Up MongoDB Compass:**
   - Download and install [MongoDB Compass](https://www.mongodb.com/products/compass).
   - Connect to your MongoDB Atlas cluster using the connection string.

3. **Create Database and Import Data:**
   - Create a new database and collections.
   - Import the following data files: `user`, `payments`, `stripe`, `subscriptions`, `vehicle`.

### Airbyte Setup

1. **Create an Airbyte Account:**
   - Sign up at [Airbyte](https://airbyte.io/).

2. **Configure Source (MongoDB):**
   - Source connection string: `mongodb+srv://workshop-moderno.ipxiiee.mongodb.net/`
   - Enter your MongoDB user and password.
   - Test and save the connection.

3. **Configure Destination (Snowflake):**
   - Enter your Snowflake account details.
   - Host: `<your-snowflake-host>`
   - Role: `ACCOUNTADMIN`
   - Warehouse: `COMPUTE_WH`
   - Database: `WORKSHOP_MODERNO_RAW`
   - Enter your Snowflake user and password.
   - Test and save the connection.

### DBT Setup

1. **Create a DBT Cloud Account:**
   - Sign up at [DBT Cloud](https://cloud.getdbt.com/signup/).

2. **Configure Snowflake Connection:**
   - Account: `<your-snowflake-account-id>`
   - Database: `WORKSHOP_MODERNO_RAW`
   - Warehouse: `COMPUTE_WH`
   - Authentication: Username and Password.
   - Test and save the connection.

3. **Link GitHub Repository:**
   - Create a GitHub repository.
   - Connect the DBT project to this repository.
   - Initialize the repository, creating necessary folders and files.

### Airflow Setup

1. **Install Airflow:**
   - Follow the installation guide at [Apache Airflow](https://airflow.apache.org/docs/apache-airflow/stable/installation.html).

2. **Create DAG for Orchestration:**
   - Add the following DAG script to the `dags` folder:

```python
from pendulum import datetime
from airflow.decorators import dag
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import ShortCircuitOperator
from airflow.providers.dbt.cloud.hooks.dbt import DbtCloudHook, DbtCloudJobRunStatus
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
from airflow.utils.edgemodifier import Label

DBT_CLOUD_CONN_ID = "dbt"
JOB_ID = "70403103949617"

def _check_job_not_running(job_id):
    hook = DbtCloudHook(DBT_CLOUD_CONN_ID)
    runs = hook.list_job_runs(job_definition_id=job_id, order_by="-id")
    latest_run = runs[0].json()["data"][0]
    return DbtCloudJobRunStatus.is_terminal(latest_run["status"])

@dag(
    dag_id="mds-airbyte-dbt-transforms",
    start_date=datetime(2022, 11, 30),
    schedule_interval="@daily",
    catchup=False,
    default_view="graph",
    doc_md=__doc__,
    tags=["development", "elt", "astrosdk", "transform", "python", "sql"],
)
def check_before_running_dbt_cloud_job():
    begin, end = [EmptyOperator(task_id=id) for id in ["begin", "end"]]

    check_job = ShortCircuitOperator(
        task_id="check_job_is_not_running",
        python_callable=_check_job_not_running,
        op_kwargs={"job_id": JOB_ID},
    )

    trigger_job = DbtCloudRunJobOperator(
        task_id="trigger_dbt_cloud_job",
        dbt_cloud_conn_id=DBT_CLOUD_CONN_ID,
        job_id=JOB_ID,
        check_interval=600,
        timeout=3600,
    )

    (
        begin
        >> check_job
        >> Label("Job not currently running. Proceeding.")
        >> trigger_job
        >> end
    )

dag = check_before_running_dbt_cloud_job()
```

## Project Structure

### DBT Models

Organize your DBT models into structured folders:
- **staging:** Contains views for raw data.
- **intermediate:** Contains tables with business logic transformations.
- **marts:** Contains final tables ready for consumption.

### Schema Testing

Define schema tests in `schema.yml` to ensure data quality and integrity.

```yaml
version: 2

models:
  - name: users_stg
    description: "Tabela de usuários carregada do MongoDB."
    columns:
      - name: id
        description: "ID único do usuário."
        tests:
          - unique
          - not_null
      - name: email
        description: "Endereço de email do usuário."
        tests:
          - unique
          - not_null
```

### Airflow DAG

Use Airflow to orchestrate the data pipeline, ensuring that DBT jobs run only when previous jobs have completed successfully.

## Conclusion

This workshop demonstrates a robust and scalable modern data stack setup. By leveraging Airbyte for data extraction, DBT for transformation, Snowflake for data warehousing, and Airflow for orchestration, you can build efficient and maintainable data pipelines. This project not only showcases technical expertise but also highlights best practices in modern data engineering.




### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
