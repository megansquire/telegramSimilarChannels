# telegramSimilarChannels
Collecting similar channels data on Telegram

How to collect the data:
1. Create a new schema in your MySQL server
2. Run db_creates.sql
3. Populate the Collections table with a row in the format {collection_id, date, notes}. Example: 1,2024-07-31,first collection
4. Populate the ScrapingJobs table with rows in the format {job_id, entity_id, username, status}. Example: 1,1224624669,TelegramTips,pending
5. Run getSimliarChannels.py. It will get the list of similar channels for every Entity marked "pending" in the ScrapingJobs table. It will add them to the Entities table and add the pair of channels (channel, suggested channel) to the ChannelSuggestions table.
8. Repeat steps 4-5 for as many generations as you want to run.

Some tips for analyzing the data:
1. You can create a directed social network with each channel as a node and the suggestion relationship as the edges.
2. Since there may be up to 100 similar channels for each channel, the number of edges will be very large, so you may want to prune the data by generation, or by degree (number of edges that a node has).
3. See the db_queries.sql file for some suggestions of helpful queries
