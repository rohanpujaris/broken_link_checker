require 'aws-sdk-sqs'

class Batcher
  def self.run(batch_size = 100)
    Item.where('last_checked_at < ? OR last_checked_at is NULL', 30.days.ago).
      select(:id).
      find_in_batches(batch_size: batch_size) do |items|
        enqueue_or_execute_batches(items.map(&:id))
      end
  end

  def self.enqueue_or_execute_batches(item_ids)
    if ENV['ENV'] == 'production'
      Aws::SQS::Client.new.send_message({
        queue_url: ENV['SQS_URL'],
        message_body: item_ids
      })
    else
      BatchExecutor.run(item_ids)
    end
  end
end
