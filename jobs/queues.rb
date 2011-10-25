class Queues
  @queues = {} 
  class << self; attr_accessor :queues; end

  def self.push(id, task)      
    ensure_queue(id).push(task)               
  end                           
  
  def self.pop(id)                                                     
    queues[id].pop { |job| job.call(id) } if has_queue? id
  end
            
  def self.ensure_queue(id)                          
    queues[id] = EM::Queue.new unless has_queue?(id)
    queues[id]
  end                                                                 
  
  def self.has_queue?(id)
    queues.has_key? id
  end                                                                                                 
  
  def self.all_queue_ids
    queues.keys
  end                     
  
  def self.empty?
    queues.empty?
  end       
  
  def self.tick
    Pace.logger.info load_report
  end                            
  
  def self.load_report    
    report = ["\n"]
    queues.each do |k,v| 
      bucket = find_bucket(k)
      report << "Number of queues: #{queues.size} -- Queue: #{bucket["name"]} has #{v.size} items." if bucket    
    end
    report.join("\n")
  end     
  
  def self.load_queues                      
    buckets.find().each { |bucket| ensure_queue bucket["_id"].to_s }
    Pace.logger.info "loaded #{queues.size} buckets ... "
  end                 
  
  def self.find_bucket(id)
    buckets.find_one( "_id" => BSON::ObjectId.from_string(id) )
  end
    
  def self.buckets
    MONGOLAB_DB["collectweet.tweet_buckets"]
  end
     
end