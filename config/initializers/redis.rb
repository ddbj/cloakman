url = ENV.fetch("REDIS_URL", "redis://localhost:6379")

REDIS = RedisClient.config(url:).new_pool
