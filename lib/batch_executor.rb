class BatchExecutor
  def self.run(ids)
    slice_size = slice_size(ids.length)
    threads = []

    statuses = CheckStatus.where.not(code: nil).pluck(:code, :id).to_h
    Item.where(id: ids).each_slice(slice_size) do |items|
      ActiveRecord::Base.connection_pool.with_connection do
        threads << Thread.new do
          items.each do |item|
            response = LinkChecker.run(item.url)
            check_status_id = statuses[response.code] if response.code
            check_status_id ||= CheckStatus.create(code: response.code, description: response.message).id
            item.update(last_checked_at: Time.now, check_status_id: check_status_id)
          end
        end
      end
    end
    threads.map(&:join)
  end

  def self.slice_size(items_count)
    thread_count = (ENV['THREAD_COUNT']&.to_i || 10).to_f
    thread_count = 1 if thread_count < 1
    slice_size = items_count / thread_count
    slice_size = 1 if slice_size < 1
    slice_size.ceil
  end
end
