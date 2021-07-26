require_relative './helper.rb'

describe BatchExecutor do
  let(:response_200) { Response::Know.new(double(code: '200')) }

  it 'updates last_checked_at for a item' do
    allow(LinkChecker).to receive(:run).and_return(response_200)
    item = Item.create(last_checked_at: nil)
    described_class.run([item.id])

    expect(item.reload.last_checked_at).to be_within(2.second).of Time.now
  end

  it 'updates check_status_id for a item depending on the response code' do
    url = 'https://example.com'
    item = Item.create(url: url)
    check_status_401 = CheckStatus.create(code: '401')
    check_status_200 = CheckStatus.create(code: '200')
    allow(LinkChecker).to receive(:run).with(url).and_return(response_200)
    described_class.run([item.id])

    expect(item.reload.check_status_id).to eq(check_status_200.id)
  end

  it 'creates new check_status record if response code is not already present' do
    item = Item.create
    allow(LinkChecker).to receive(:run).and_return(response_200)

    expect do
      described_class.run([item.id])
    end.to change(CheckStatus, :count).by(1)
    expect(item.reload.check_status.code).to eq('200')
  end

  describe '.slice_size' do
    it 'returns size of each batch to be run on each thread' do
      allow(ENV).to receive(:[]).with('THREAD_COUNT').and_return(2)
      expect(described_class.slice_size(7)).to eq(4)
      expect(described_class.slice_size(8)).to eq(4)
      expect(described_class.slice_size(9)).to eq(5)
    end

    it 'considers thread count to be 10 if THREAD_COUNT env is not set' do
      expect(described_class.slice_size(9)).to eq(1)
      expect(described_class.slice_size(10)).to eq(1)
      expect(described_class.slice_size(11)).to eq(2)
      expect(described_class.slice_size(21)).to eq(3)
    end
  end
end
