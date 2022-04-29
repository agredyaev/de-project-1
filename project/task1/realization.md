# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте выясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------
### Что сделать:
построить витрину для RFM-классификации. Для анализа нужно отобрать только успешно выполненные заказы. Витрину нужно назвать `dm_rfm_segments`. Сохранить в хранилище данных, а именно — в схему с `analysis`
### Зачем: 
подготовить данные для команды сервиса по доставки еды, чтобы прозводить RFM-анализ клиентов.

### За какой период: 
Заказы с типом CLosed c начала 2021 года.

### Обновление данных:
 не требуется.

### Кому доступна: 
всем, но доступ только на чтение.

### Необходимая структура:
- `user_id`
- `recency` (число от 1 до 5)
- `frequency` (число от 1 до 5)
- `monetary_value` (число от 1 до 5)
  
### Описание метрик:
- Recency (пер. «давность») — сколько времени прошло с момента последнего заказа. Измеряется по последнему заказу. Распределите клиентов по шкале от одного до пяти, где значение 1 получат те, кто либо вообще не делал заказов, либо делал их очень давно, а 5 — те, кто заказывал относительно недавно
- Frequency (пер. «частота») — количество заказов. Распределение клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшим количеством заказов, а 5 — с наибольшим
- Monetary Value (пер. «денежная ценность») — сумма затрат клиента. Фактор Monetary оценивается по потраченной сумме. Распределите клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшей суммой, а 5 — с наибольшей.

### Валидация
Необходимо проверить, что количество клиентов в каждом сегменте одинаково.
Если в базе 100 клиентов, то 20 клиентов должны получить значение 1, 20 - 2 и т.д.


## 1.2. Изучите структуру исходных данных.

Полключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------
```SQL

users.id,
orders.user_id,
orders.order_ts,
orders.status,
orders.payment

```


## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------

Описание качества данных
- дубли в данных - не выявлено
- пропущенные значения в важных полях - не выявлено, только users.name допускает пропущенные значения, остальные нет
- некорректные типы данных - не выявлено
- неверные форматы записей - не выявлено, для полей timestamp указан корректный формат и тип

Описание инстументов для обеспечения качества данных
- Primary key для исключения дубликатов
- Внешние ключи для ограничения области значений
- Установка `NOT NULL` и `NOT NULL DEFAULT 0` для исключения и корректной обработки пустых значений
- Проверки значений `CHECK`:
  - согласно бизнес логике `cost = (payment + bonus_payment)`
  - положительных и ненулевых `(price >= (0)::numeric)` и `(quantity > 0)`


## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW.

>AG: Реализация доступна в соответсвующих файлах `common.py` и `create_views.py`. Запуск производился из контейнера с проектом непосредственно.

```Python
from sqlalchemy import create_engine

# Config
DB_CONNECTION = "postgresql://jovyan:jovyan@localhost:5432/de"

# Params
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

# Queries
GET_DATA = "SELECT * FROM {0}.{1}"
CREATE_VIEW = "CREATE OR REPLACE VIEW {0}.{1} as {2};"

# Create engine
engine = create_engine(DB_CONNECTION)

# Create views
def create_views_m():
    for table_name in TABLES:
        select_data = GET_DATA.format(IN_SCHEMA, table_name)
        create_v = CREATE_VIEW.format(OUT_SCHEMA, table_name, select_data)
        engine.execute(create_v)

# Run 
create_views_m()
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
CREATE TABLE de.analysis.dm_rfm_segments (
	user_id int4 NOT NULL,
	recency int4 NOT NULL,
	frequency int4 NOT NULL,
	monetary_value int4 NOT NULL,
	CONSTRAINT dm_rfm_segments_frequency_check CHECK (((frequency >= 1) AND (frequency <= 5))),
	CONSTRAINT dm_rfm_segments_monetary_value_check CHECK (((monetary_value >= 1) AND (monetary_value <= 5))),
	CONSTRAINT dm_rfm_segments_pkey PRIMARY KEY (user_id),
	CONSTRAINT dm_rfm_segments_recency_check CHECK (((recency >= 1) AND (recency <= 5)))
);


```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
INSERT INTO de.analysis.dm_rfm_segments 

WITH orders_filtered AS (
    SELECT
        user_id,
        order_ts,
        status,
        payment
    FROM
        de.analysis.orders
    WHERE
        date_part('year', order_ts) >= 2021
        AND status = 4
),
last_order AS (
    SELECT
        user_id,
        MAX(order_ts) last_order
    FROM
        orders_filtered
    GROUP BY
        user_id
),
orders_quantity AS (
    SELECT
        user_id,
        COUNT(1) AS orders_quantity
    FROM
        orders_filtered
    GROUP BY
        user_id
),
total_spent AS (
    SELECT
        user_id,
        SUM(payment) AS total_spent
    FROM
        orders_filtered
    GROUP BY
        user_id
)
SELECT
    id AS user_id,
    NTILE(5) OVER (
        ORDER BY
            COALESCE(p.last_order, '1970-01-01')
    ) recency,
    NTILE(5) OVER (
        ORDER BY
            COALESCE(o.orders_quantity, 0)
    ) frequency,
    NTILE(5) OVER (
        ORDER BY
            COALESCE(t.total_spent, 0)
    ) monetary_value
FROM
    de.analysis.users u
    LEFT JOIN last_order p ON p.user_id = u.id
    LEFT JOIN orders_quantity o ON o.user_id = u.id
    LEFT JOIN total_spent t ON t.user_id = u.id

```