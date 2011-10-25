# require 'spec_helper'
#                             
# describe 'index page', :type => :request do     
#   
#   it "should work" do
#     get "/"     
#     last_response.should be_ok
#   end  
# end      


require 'spec_helper'

feature 'User visits the homepage', %q{
  In order to get the tweets 
  As a user
  I want to see the homepage
} do
                                  
    scenario 'User sees the authentication challenge' do 
      visit "/"                           
      page.status_code.should be 401
    end
    
    scenario "User logs in" do
      name = "boycott"
      password = "boycott123"
      page.driver.browser.basic_authorize(name, password)
      visit "/"
      page.status_code.should be 200
    end  
    
    
end
