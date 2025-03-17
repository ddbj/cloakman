module RedisTestHelper
  def reset_redis
    REDIS.call :flushdb
    REDIS.call :set, "uid_number", 1000
  end
end
