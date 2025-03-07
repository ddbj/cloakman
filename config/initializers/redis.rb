url = Rails.application.config_for(:app).redis_url!

REDIS = RedisClient.config(url:).new_pool
