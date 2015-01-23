require 'rubygems'
require 'nokogiri'   
require 'open-uri'
require 'restclient'
require 'twilio-ruby' 
 
# Configuration
# Twilio account
twilio_account_sid = '12345678910'
twilio_auth_token = '12345678910'
twilio_personal_phone_number = '+1415123456789'

# Your info
personal_phone_number = '+1415123456789'

cache_file = '/tmp/current_github_jobs'

page = Nokogiri::HTML(RestClient.get("https://github.com/about/jobs"))

current_github_jobs = []
fetched_github_jobs = []

# Fetch jobs from the previous run
begin
  file = File.open(cache_file, 'r')
rescue
  file = File.open(cache_file, "w") {}
else 
  file.each do |line| 
    current_github_jobs.push(eval(line))
  end
  file.close  
end

# Fetch jobs from the github page
page.css('div.jobs-open-positions ul li').each do |job|
  puts job
  job_name = job.text
  job_url = job.css('a')[0]['href']
  fetched_github_jobs.push( { job_name: job_name, job_url: job_url } )
end

if (current_github_jobs != fetched_github_jobs)
  puts 'New Jobs!'
  pretty_msg = ""
  fetched_github_jobs.each do |job|
    pretty_msg += 'Job name: ' + job[:job_name] + ', url: ' + job[:job_url] + '   '
  end
  # something different
  # set up a client to talk to the Twilio REST API 
  @client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token 
   
  @client.account.messages.create({
    :from => twilio_personal_phone_number,  
    :to => personal_phone_number, 
    :body => pretty_msg,  
  })
  puts 'sending text: ' + pretty_msg

  # Cache new jobs
  file = File.open(cache_file, 'w')
  file.puts fetched_github_jobs
  file.close
else
  puts 'No new Jobs!'
end

