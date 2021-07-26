# require 'activesupport'
require 'net/http'
require 'net/https'

class Benchmarks1
  def self.schedule_batches(threads)
    # Item.where("last_checked_at > ?", 30.days.ago).select(:id).find_in_batches(batch_size: batch_size) do |items|
    #   Aws::SQS::Client.new.send_message({
    #     queue_url: url,
    #     message_body: items.map(&:id)
    #   })
    uris = ["https://google.com", "https://facebook.com", "https://twitter.com"].map {|url| URI.parse url }
    uris = uris.concat(uris)
    uris = uris.concat(uris)
    uris = uris.concat(uris)
    uris = uris.concat(uris)
    uris = uris.concat(uris)
    uris = uris.concat(uris)
    uris = uris.concat(uris)
    puts uris.count
    Benchmark.bm do |x|
      # x.report do
      #   uris.map do |uri|
      #     Net::HTTP.get_response(uri)
      #   end
      # end

      x.report do
        uris.map do |uri|
          Thread.new { Net::HTTP.get_response(uri) }
        end.join
      end

      slices = uris.count / threads
      threads = []
      x.report do
        uris.each_slice(slices) do |uris_group|
          threads << Thread.new do
            uris_group.map do |uri|
              Net::HTTP.get_response(uri)
            end
          end
        end
        threads.join
      end
    end
  end
end
