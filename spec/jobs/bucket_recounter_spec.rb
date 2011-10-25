require 'spec_helper'

describe BucketRecounter do
  
  describe ".perform" do
    it "should add a queue for the bucket" do
      Queues.empty?.should be_true
      BucketRecounter.perform(["bucket-1"])
      Queues.has_queue?("bucket-1").should be_true
    end
  end
  
  describe ".matches?" do
    it "should match is word is present" do
      bucket = {"words" => ["boycott"]}
      tweet  = {"text" => "I am going to boycott this: http://foo.com"}
      BucketRecounter.matches?(tweet,bucket).should be_true
    end                               

    it "should not match is word is not present" do
      bucket = {"words" => ["foobar"]}
      tweet  = {"text" => "I am going to boycott this: http://example.com"}
      BucketRecounter.matches?(tweet,bucket).should be_false
    end                               
    
    it "should match even if word has punctuation next to it" do
      bucket = {"words" => ["boycott"]}
      tweet  = {"text" => "I am going to boycott!!!! http://foo.com"}
      BucketRecounter.matches?(tweet,bucket).should be_true
    end                                              
    
    it "should match terms that are multiple words" do
      bucket = {"words" => ["ice cream"]}
      tweet  = {"text" => "I am boycotting ben and jerry's ice cream from now on"} 
      BucketRecounter.matches?(tweet, bucket).should be_true
    end                                                     

    it "should not match terms that are multiple words if the words are not in order" do
      bucket = {"words" => ["ice cream"]}
      tweet  = {"text" => "I am boycotting ice coffee with cream from now on"} 
      BucketRecounter.matches?(tweet, bucket).should be_false
    end                                                     
    
    it "should match if at least one word in the bucket matches" do
      bucket = {"words" => ["boycotting", "foobar"]}
      tweet  = {"text" => "I am boycotting ice coffee with cream from now on"} 
      BucketRecounter.matches?(tweet, bucket).should be_true
    end                                                     

    it "should not match if there is only a partial match" do
      bucket = {"words" => ["boycott", "foobar"]}
      tweet  = {"text" => "I am boycotting ice coffee with cream from now on"} 
      BucketRecounter.matches?(tweet, bucket).should be_false
    end                                                     
    
  end
end