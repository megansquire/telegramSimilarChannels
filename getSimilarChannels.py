from telethon import TelegramClient, sync
from telethon.errors import FloodWaitError
from telethon.tl.functions.channels import GetChannelRecommendationsRequest
from telethon.tl.functions.channels import GetFullChannelRequest
import datetime
import pymysql
import asyncio
import time


# Globals
collection_id = 1 
generation = 3

# Database Configuration
dbhost = ""
dbuser = ""
dbpw = ""
dbschema = ""

dbconn = pymysql.connect(host=dbhost,
                         user=dbuser,
                         passwd=dbpw,
                         db=dbschema,
                         use_unicode=True,
                         charset='utf8mb4',
                         autocommit=True)
cursor = dbconn.cursor()


# Telethon Configuration
phone_number = '' # start with +1 or whatever country code
api_id = ''
api_hash = ''
client = TelegramClient(phone_number, api_id, api_hash)


# Function to Fetch Pending Jobs
def get_pending_jobs():
    print("Getting list of pending jobs...")
    try:
        cursor.execute("""
            SELECT job_id, entity_id, username 
            FROM ScrapingJobs 
            WHERE status = 'pending' AND username != 'None'
        """)
        jobs = cursor.fetchall()
        return jobs
    except pymysql.Error as e:
        print(f"Error 1: {e}")
        return []


# Function to Update Job Status
def update_job_status(job_id, status):
    print("Found pending job:", job_id)
    try:
        # Update the status and start_time if the job is being set to 'in_progress'
        if status == 'in_progress':
            cursor.execute("""
                UPDATE ScrapingJobs 
                SET status = %s, start_time = %s 
                WHERE job_id = %s
            """, (status, datetime.datetime.now(), job_id))
        else:
            # For other statuses, just update the status (and end_time if applicable)
            cursor.execute("""
                UPDATE ScrapingJobs 
                SET status = %s, end_time = %s 
                WHERE job_id = %s
            """, (status, datetime.datetime.now() if status in ['completed', 'failed'] else None, job_id))

    except pymysql.Error as e:
        print(f"Error 2: {e}")
        raise


# Function to fetch channel information
async def fetch_channel_info(username):
    print("Fetching channel info for:", username)    
    
    try:
        channel = await client.get_entity(username)
        full_channel = await client(GetFullChannelRequest(channel))
        entity_info = {
            'entity_id': channel.id,
            'name': channel.title,
            'username': channel.username,
            'type': 'channel',
            'member_count': full_channel.full_chat.participants_count if hasattr(full_channel.full_chat, 'participants_count') else None,
            'status': 'public' if channel.broadcast else 'private',
            'description': full_channel.full_chat.about if hasattr(full_channel.full_chat, 'about') else None,
            'photo_id': None,  # todo
            'creation_date': channel.date,
            'last_updated': datetime.datetime.now()
        }
        print("    Found:", entity_info['entity_id'], entity_info['username'])
        return entity_info
    except FloodWaitError as e:
        print(f"Rate limited. Waiting for {e.seconds} seconds.")
        await asyncio.sleep(e.seconds)
        return await fetch_channel_info(username)

    

# Function to insert entities
def insert_entities(entity_info, collection_id):
    print("Inserting into Entities table for entity:",
            entity_info['entity_id'],
            entity_info['username'])
    
    try:
        query = """
        INSERT IGNORE INTO Entities (entity_id,
                                    name,
                                    username,
                                    type,m
                                    ember_count,
                                    status,
                                    description,
                                    photo_id,
                                    creation_date,
                                    last_updated,
                                    collection_id,
                                    generation)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (
            entity_info['entity_id'],
            entity_info['name'],
            entity_info['username'],
            entity_info['type'],
            entity_info['member_count'],
            entity_info['status'],
            entity_info['description'],
            entity_info['photo_id'],
            entity_info['creation_date'],
            entity_info['last_updated'],
            collection_id,
            generation
        ))
        print("Success")
        return
    except pymysql.Error as e:
        print(f"Error 3: {e}")
        raise



# Function to fetch similar channels for a given channel
async def fetch_suggested_channels(entity_id):
    print("Fetching suggested channels for entity:", entity_id)
    
    suggested_channels = []
    try:
        # Get the entity (channel) for which recommendations are needed
        entity = await client.get_entity(entity_id)

        # Fetch recommendations
        suggestions = await client(GetChannelRecommendationsRequest(entity))

        # Iterate through the recommendations and add to the list
        for suggestion in suggestions.chats:
            suggested_channels.append({
                'suggested_entity_id': suggestion.id,
                'recorded_at': datetime.datetime.now()
            })
    except Exception as e:
        print(f"Error fetching recommendations for channel {entity_id}: {e}")
        raise

    print("Found", len(suggested_channels), "suggested channels")
    return suggested_channels



# Function to fetch and save Suggested channel info and the Suggestion Pair
async def fetch_and_save_suggestions(entity_id, suggested_entities, collection_id):
    try:
        for suggested in suggested_entities:
            print("    Grabbing channel info for", suggested['suggested_entity_id'])
            
            # grab generic channel info, insert into Entities
            entity_info = await fetch_channel_info(suggested['suggested_entity_id'])
            insert_entities(entity_info, collection_id)
            
            # insert as suggestion pair
            cursor.execute("""
                INSERT INTO ChannelSuggestions (
                    entity_id, 
                    suggested_entity_id, 
                    recorded_at, 
                    collection_id)
                VALUES (%s, %s, %s, %s)
            """, (entity_id, suggested['suggested_entity_id'], datetime.datetime.now(), collection_id))
            
    except pymysql.Error as e:
        print(f"Error 4: {e}")
        raise


# Main Function to Process Jobs
# pending, in_progress, completed, failed
async def process_jobs():
    await client.start(phone=phone_number)
    jobs = get_pending_jobs()

    for job in jobs:
        job_id = job[0]
        entity_id = job[1]
        username = job[2]
        try:
            update_job_status(job_id, 'in_progress')
            entity_info = await fetch_channel_info(username)
            insert_entities(entity_info, collection_id)
            
            suggested_entities = await fetch_suggested_channels(entity_id)
            await fetch_and_save_suggestions(entity_id, suggested_entities, collection_id)
            update_job_status(job_id, 'completed')

        except Exception as e:
            print(f"Error processing job {job_id}: {e}")
            update_job_status(job_id, 'failed')


asyncio.run(process_jobs())
dbconn.close()
