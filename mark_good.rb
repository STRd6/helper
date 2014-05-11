# Mark accounts to unfollow

require "./setup"
require 'iron_mq'

ironmq = IronMQ::Client.new
queue = ironmq.queue("peeps")
good_queue = ironmq.queue("good_follows")

def good?(id)
  user = T.user(id)

  tweet_count = user.statuses_count
  friends_count = user.friends_count
  followers_count = user.followers_count

  ratio = friends_count.to_f / followers_count.to_f

  puts "https://twitter.com/account/redirect_by_id/#{id}"
  puts "#{friends_count}/#{followers_count} = #{ratio.round(2)}; T:#{tweet_count}"

  (followers_count > 100) && (ratio > 1.25) && (tweet_count > 100)
end

i = 0
while i < 50 do
  msg = queue.get
  id = msg.body.to_i

  begin
    if good?(id)
      good_queue.post msg.body
    end
    msg.delete
    i += 1
    puts "Processed: #{id}"
  rescue Twitter::Error::Forbidden => e
    puts e.message
    msg.delete
  rescue Twitter::Error::NotFound => e
    puts "Not found: #{id}"
    msg.delete
  rescue Twitter::Error::TooManyRequests
    puts "Rate limit exceeded"
    break
  end
end
