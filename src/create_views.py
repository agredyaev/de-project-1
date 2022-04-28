
from common import *
from sqlalchemy import create_engine

engine = create_engine(DB_CONNECTION)

def create_views_m():
    for table_name in TABLES:
        select_data = GET_DATA.format(IN_SCHEMA, table_name)
        create_v = CREATE_VIEW.format(OUT_SCHEMA, table_name, select_data)
        engine.execute(create_v)


create_views_m()


