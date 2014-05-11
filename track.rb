require "./setup"
require 'iron_mq'

@ironmq = IronMQ::Client.new

queue = @ironmq.queue(params["queue"])
method = params["method"]
target = params["target"]

puts "Marking #{method} of #{target} as #{queue}"

T.send(method, target).each_slice(1000) do |ids|
  puts "Queuing #{ids.length} ids."

  messages = ids.map do |id|
    {
      :body => id.to_s
    }
  end

  queue.post messages
end
