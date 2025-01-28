url = ENV.fetch("REDIS_URL", "redis://localhost:6379")

REDIS = RedisClient.config(url:).new_pool

def REDIS.with_lock(key, timeout: 5, &block)
  until call(:set, key, "", nx: true, ex: timeout)
    sleep 0.1
  end

  block.call
ensure
  call :del, key
end
