import json
import redis.asyncio as redis
from app.core.config import settings


class RedisCache:
    def __init__(self):
        self.client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            db=0,
            decode_responses=True
        )

    async def get(self, key: str):
        value = await self.client.get(key)
        return json.loads(value) if value else None

    async def set(self, key: str, value, ttl: int = 3600 * 2):
        await self.client.setex(key, ttl, json.dumps(value))

    async def delete(self, key: str):
        await self.client.delete(key)
