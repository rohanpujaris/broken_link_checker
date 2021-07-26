require 'json'
Dir["./lib/**/*.rb"].each { |file| require file }

def broken_link_batcher(event:, context:)
  Batcher.run(ENV['BATCH_SIZE']&.to_i || 100)

  {
    statusCode: 200,
    body: {
      message: 'Batching successful',
      input: event
    }.to_json
  }
end

def broken_link_batch_executor(event:, context:)
  # SQS and api endpoint passes response body in different format
  body = event['body'] || event.dig('Records', 0, 'body')

  BatchExecutor.run(JSON.parse(body))

  {
    statusCode: 200,
    body: {
      message: 'Batching execution successful',
      input: event
    }.to_json
  }
end
