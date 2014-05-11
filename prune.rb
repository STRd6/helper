require "./setup"
require 'iron_mq'

ironmq = IronMQ::Client.new
queue = ironmq.queue("bad_follows")

i = 0
while (i < 15) && (msg = queue.get) do
  id = msg.body.to_i

  puts "Unfollowing: #{id}"

  begin
    T.unfollow(id)
    msg.delete
    i += 1
    puts "Unfollowed: #{id}"
  rescue Twitter::Error::Forbidden => e
    puts e.message
    msg.delete
  rescue Twitter::Error::NotFound => e
    puts "Not found: id"
    msg.delete
  rescue Twitter::Error::TooManyRequests
    puts "Rate limit exceeded"
    break
  end
end
