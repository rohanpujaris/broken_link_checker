Dir["./lib/**/*.rb"].each {|file| require file }

[
  { url: 'https://linkchecker.free.beeceptor.com/link200' },
  { url: 'https://linkchecker.free.beeceptor.com/link404' },
  { url: 'https://linkchecker.free.beeceptor.com/link301-link200' },
  { url: 'https://linkchecker.free.beeceptor.com/link302-link200' },
  { url: 'https://linkchecker.free.beeceptor.com/link302-link301' },
  { url: 'https://linkchecker.free.beeceptor.com/link302another-link200' },
  { url: 'https://linkchecker.free.beeceptor.com/link302-link302another' },
  { url: 'https://linkchecker.free.beeceptor.com/timedout' },
  { url: 'https://unrechable-domain-abcd.com' },
].each do |item|
  Item.create(item)
end

[
  { code: '200', description: 'Success' },
  { code: '301', description: 'Permanent redirect' },
  { code: '302', description: 'Temporary redirect' },
].each do |check_status|
  CheckStatus.create(check_status)
end
