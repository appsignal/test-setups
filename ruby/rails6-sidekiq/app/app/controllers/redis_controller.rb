class RedisController < ApplicationController
  def restful
    5.times do |i|
      client.time
      client.set("my_key_#{i}", "value_#{i}")
      client.get("my_key_#{i}")
      client.del("my_key_#{i}")
    end

    redirect_to redis_path, :notice => "Redis queries performed"
  end

  def eval
    5.times do |i|
      # The most basic eval script I could find
      client.eval("return { KEYS, ARGV }", ["k1", "k2"], ["a1", "a2"])
      client.eval("return { KEYS, ARGV }", :keys => ["k1", "k2"], :argv => ["a1", "a2"])
      # Lua script redis custom queries
      key = "eval_key_#{i}"
      client.eval("return redis.call('set',KEYS[1],KEYS[2])", [key, "my_value_#{i}"])
      client.eval("return redis.call('get',KEYS[1])", [key])
      client.eval("return redis.call('del',KEYS[1])", [key])
    end

    redirect_to redis_path, :notice => "Redis queries performed"
  end

  def client
    @client ||= Redis.new
  end
end
