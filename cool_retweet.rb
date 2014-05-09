require "./setup"

recent = T.home_timeline(count: 200)

cool = recent.select do |tweet|
  !tweet.retweet? && (tweet.retweet_count <= 20) && (tweet.retweet_count >= 2)
end

tweet = cool.sample

puts "Retweeting: #{tweet.user.name} #{tweet.text}"

T.retweet tweet
