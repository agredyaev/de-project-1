# Проект 1
### Что сделать:
---
построить витрину для RFM-классификации. Для анализа нужно отобрать только успешно выполненные заказы. Витрину нужно назвать `dm_rfm_segments`. Сохранить в хранилище данных, а именно — в схему с `analysis`
### Зачем: 
---
подготовить данные для команды сервиса по доставки еды, чтобы прозводить RFM-анализ клиентов.

### За какой период: 
---
Заказы с типом CLosed c начала 2021 года.

### Обновление данных:
---
 не требуется.

### Кому доступна: 
---
всем, но доступ только на чтение.

### Необходимая структура:
---
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