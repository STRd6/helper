require "./setup"
require 'iron_mq'

@ironmq = IronMQ::Client.new
@queue = @ironmq.queue("peeps")

i = 0
while i < 15 do
  msg = @queue.get
  id = msg.body.to_i

  puts "Following: #{id}"

  begin
    T.follow(id)
    msg.delete
    i += 1
    puts "Followed: #{id}"
  rescue Twitter::Error::Forbidden => e
    if e.message.match /You've already requested to follow/
      puts "Already following: #{id}"
      msg.delete
    end
  rescue Twitter::Error::NotFound => e
    puts "Not found: id"
    msg.delete
  rescue Twitter::Error::TooManyRequests
    puts "Rate limit exceeded"
    break
  end
end
