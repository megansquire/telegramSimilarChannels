# telegramSimilarChannels
Collecting similar channels data on Telegram

How to:
1. Create a new schema in your MySQL server
2. Run db_creates.sql
3. Populate the Collections table with a row in the format {collection_id, date, notes}. Example: 1,2024-07-31,first collection
4. Populate the ScrapingJobs table with rows in the format {job_id, entity_id, username, status}. Example: 1,1224624669,TelegramTips,pending
5. Run getSimliarChannels.py
