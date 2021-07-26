require_relative './helper.rb'

describe LinkChecker do
  it 'url returns 200 response code' do
    stub_request(:get, 'https://example.com').to_return(status: 200)
    response = described_class.run('https://example.com')

    expect(response.code).to eq('200')
  end

  it 'url returns 404 response code' do
    stub_request(:get, 'https://example.com').to_return(status: 404)
    response = described_class.run('https://example.com')

    expect(response.code).to eq('404')
  end

  it 'works with http protocol' do
    stub_request(:get, 'http://example.com').to_return(status: 200)
    response = described_class.run('http://example.com')

    expect(response.code).to eq('200')
  end

  it "for 301 permanent redirect url it doesn't follow the url and returns 301 as response code" do
    stub_request(:get, 'https://example.com').to_return(
      status: 301, headers: { 'Location' => 'https://example.com/follow' }
    )
    response = described_class.run('https://example.com')

    expect(WebMock).not_to have_requested(:get, 'https://example.com/follow')
    expect(response.code).to eq('301')
  end

  it 'for 302 temporary redirect it follows the url and returns response code of followed url' do
    stub_request(:get, 'https://example.com/follow').to_return(status: 200)
    stub_request(:get, 'https://example.com').to_return(
      status: 302, headers: { 'Location' => 'https://example.com/follow' }
    )
    response = described_class.run('https://example.com')

    expect(response.code).to eq('200')
  end

  it 'follows multiple redirects' do
    stub_request(:get, 'https://example.com').to_return(
      status: 302, headers: { 'Location' => 'https://example.com/1st_follow' }
    )
    stub_request(:get, 'https://example.com/1st_follow').to_return(
      status: 302, headers: { 'Location' => 'https://example.com/2nd_follow' }
    )
    stub_request(:get, 'https://example.com/2nd_follow').to_return(
      status: 302, headers: { 'Location' => 'https://example.com/3rd_follow' }
    )
    stub_request(:get, 'https://example.com/3rd_follow').to_return(status: 404)


    response = described_class.run('https://example.com', 3)

    expect(response.code).to eq('404')
  end

  it 'restricts follow redirect by max_limit provided' do
    stub_request(:get, 'https://example.com').to_return(
      status: 302, headers: { 'Location' => 'https://example.com/1st_follow' }
    )
    stub_request(:get, 'https://example.com/1st_follow').to_return(
      status: 302, headers: { 'Location' => 'https://example.com/2nd_follow' }
    )
    stub_request(:get, 'https://example.com/2nd_follow').to_return(status: 200)
    response = described_class.run('https://example.com', 1)

    expect(response.code).to eq('302')
  end

  it 'breaks 302 temporary redirect follow when 301 paremanent redirect is encountered' do
    stub_request(:get, 'https://example.com').to_return(
      status: 302, headers: { 'Location' => 'https://example.com/1st_follow' }
    )
    stub_request(:get, 'https://example.com/1st_follow').to_return(
      status: 301, headers: { 'Location' => 'https://example.com/2nd_follow' }
    )
    stub_request(:get, 'https://example.com/2nd_follow').to_return(status: 200)
    response = described_class.run('https://example.com', 3)

     expect(response.code).to eq('301')
  end

  it 'follows redirect even when relative path with forward slash is provided' do
    stub_request(:get, 'https://example.com/follow').to_return(status: 200)
    stub_request(:get, 'https://example.com').to_return(
      status: 302, headers: { 'Location' => '/follow' }
    )
    response = described_class.run('https://example.com')

    expect(response.code).to eq('200')
  end

  it 'follows redirect even when relative path without forward slash is provided' do
    stub_request(:get, 'https://example.com/follow').to_return(status: 200)
    stub_request(:get, 'https://example.com').to_return(
      status: 302, headers: { 'Location' => 'follow' }
    )
    response = described_class.run('https://example.com')

    expect(response.code).to eq('200')
  end

  it 'follows redirect with relative path and query parameter' do
    stub_request(:get, 'https://example.com/follow?q=10').to_return(status: 200)
    stub_request(:get, 'https://example.com').to_return(
      status: 302, headers: { 'Location' => 'follow?q=10' }
    )
    response = described_class.run('https://example.com')

    expect(response.code).to eq('200')
  end
end
