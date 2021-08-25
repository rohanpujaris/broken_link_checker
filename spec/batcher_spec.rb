require_relative './helper.rb'

describe Batcher do
  let(:item) { Item.create }

  it 'enqueues message in AWS SQS queue in production enviroment' do
    queue_url = 'https://sqs_queue.com'
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('ENV').and_return('production')
    allow(ENV).to receive(:[]).with('SQS_URL').and_return(queue_url)
    sqs_client = double(send_message: -> {})
    expect(::Aws::SQS::Client).to receive(:new).and_return(sqs_client)
    expect(sqs_client).to receive(:send_message).with({
      queue_url: queue_url,
      message_body: [item.id]
    })

    described_class.run
  end

  it 'calls BatchExecutor in development enviroment' do
    allow(ENV).to receive(:[]).with('ENV').and_return('development')
    expect(BatchExecutor).to receive(:run).with([item.id])

    described_class.run
  end

  it 'batches correctly' do
    items = (1..4).map { Item.create }
    expect(BatchExecutor).to receive(:run).with([items[0].id, items[1].id])
    expect(BatchExecutor).to receive(:run).with([items[2].id, items[3].id])

    described_class.run(2)
  end

  it 'ignores already checked item if it was checked less than 30 days ago' do
    item = Item.create(last_checked_at: 29.days.ago)
    expect(BatchExecutor).to_not receive(:run)

    described_class.run
  end

  it 'checks item status if it was checked more than or equals to 30 days ago' do
    item1 = Item.create(last_checked_at: 30.days.ago)
    item2 = Item.create(last_checked_at: 31.days.ago)
    expect(BatchExecutor).to receive(:run).with([item1.id, item2.id])

    described_class.run
  end
end
