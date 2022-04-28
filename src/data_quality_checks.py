from create_views import *


def duplicates():
    print(f'{"-"*20} Is there duplicates?')

    for table_name in TABLES:
        id = ['id', 'order_id'][table_name == 'orders']
        check = DUPLICATES.format(IN_SCHEMA, table_name, id)

        print('-'*20)
        print(f"{table_name}: {engine.execute(check).fetchall()[0][0]}")

def info(query):
    print(f'{"-"*20} Information')

    table = sorted(engine.execute(query).fetchall(), key=lambda x: x[0])
    for row in table:
        if row[3] == 'YES':
            print('>>>>> Allows nulls:', row)
        
        print(row)


duplicates()
info(INFORMATION)
info(CONSTRAINTS)




