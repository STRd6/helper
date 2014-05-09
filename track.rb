require "./setup"
require 'iron_mq'

@ironmq = IronMQ::Client.new

@queue = @ironmq.queue("peeps")

target = params["target"]
puts "Marking followers of #{target}"

T.follower_ids(target).each_slice(1000) do |ids|
  puts "Queuing #{ids.length} ids to follow."

  messages = ids.map do |id|
    {
      :body => id.to_s
    }
  end

  @queue.post messages
end
