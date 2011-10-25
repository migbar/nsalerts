class Push

  def self.queue; "buckets"; end  

  def self.perform(args)    
    channel = args[0]
    message_name = args[1]
    payload = args[2]      
    puts "trigerring async: channel #{channel}, name: #{message_name} payload: #{payload.inspect}"
    Pusher[channel].trigger_async(message_name, payload)
  end
  
end
