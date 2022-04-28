# ---------------CONFIG---------------
DB_CONNECTION = "postgresql://jovyan:jovyan@localhost:5432/de"

## ---------------PARAMS---------------
IN_SCHEMA = "production"
OUT_SCHEMA = "analysis"

TABLES = [
    "orderitems",
    "orders",
    "orderstatuses",
    "orderstatuslog",
    "products",
    "users"
]

# ---------------QUERIES---------------

# Data quality checks
DUPLICATES = """
SELECT
	CASE
		WHEN COUNT(DISTINCT {2}) != COUNT(1) THEN 'YEP'
		ELSE 'NOPE'
	END IS_THERE_DUPLICATES
FROM
	{0}.{1};
"""

INFORMATION = """
select
	table_name,
	column_name,
	data_type,
	is_nullable,
	character_maximum_length,
	numeric_precision
from
	information_schema."columns" c
where
	table_schema = 'production'
"""


CONSTRAINTS = """
SELECT
	table_name,
	constraint_name,
	constraint_type,
	table_catalog
FROM
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
WHERE
	CONSTRAINT_SCHEMA = 'production'
"""

# Create views
GET_DATA = "SELECT * FROM {0}.{1}"
CREATE_VIEW = "CREATE OR REPLACE VIEW {0}.{1} as {2};"

