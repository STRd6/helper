# Mark accounts to unfollow

require "./setup"
require 'iron_mq'

@ironmq = IronMQ::Client.new
@queue = @ironmq.queue("follows")
@bad_queue = @ironmq.queue("bad_follows")

def bad?(id)
  user = T.user(id)

  tweet_count = user.statuses_count
  followers_count = user.followers_count

  puts "https://twitter.com/account/redirect_by_id/#{id}: T #{tweet_count} F #{followers_count}"

  (tweet_count < 100) ||
  (followers_count < 100)
end

i = 0
while i < 200 do
  msg = @queue.get
  id = msg.body.to_i

  begin
    if bad?(id)
      @bad_queue.post msg.body
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
