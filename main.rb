require_relative('objects')

video_count = 0
endpoint_count = 0
request_count = 0
cache_count = 0
cache_capacity = 0

videos = {}
endpoints = {}
requests = {}
caches = {}

datafile = "videos_worth_spreading"

def get_or_create_cache(attrs, caches)
  cache = caches[attrs[:index]]
  return cache if cache
  c = Base::Cache.new({index: attrs[:index], capacity: attrs[:capacity]})
  caches[attrs[:index]] = c
  return c
end

def get_or_create_endpoint(attrs, endpoints)
  endpoint = endpoints[attrs[:index]]
  return endpoint if endpoint
  # e = Base::Cache.new({index: attrs[:index], capacity: attrs[:capacity]})
  e = Base::Endpoint.new({index: attrs[:index], dc_latency: attrs[:dc_latency]})
  endpoints[attrs[:index]] = e
  return e
end

File.open("#{datafile}.in", 'r') do |f|  
  stats_row = f.gets.split(' ')
  video_count = stats_row[0].to_i
  endpoint_count = stats_row[1].to_i
  request_count = stats_row[2].to_i
  cache_count = stats_row[3].to_i
  cache_capacity = stats_row[4].to_i

  videos_row = f.gets.split(' ')
  for i in 0..videos_row.length
    videos[i] = Base::Video.new({index: i, size: videos_row[i].to_i})
  end


  for i in 0..endpoint_count-1
    endpoint_row = f.gets.split(' ')

    caches_count = endpoint_row[1].to_i
    endpoint = get_or_create_endpoint({index: i, dc_latency: endpoint_row[0].to_i}, endpoints)
    endpoints[i] = endpoint

    for i in 0..caches_count-1
      cache_latency_row = f.gets.split(' ')
      cache = get_or_create_cache({index: cache_latency_row[0].to_i, capacity: cache_capacity}, caches)
      endpoint.add_cache(cache_latency_row[1].to_i, cache)
    end
  end
  
  for i in 0..request_count-1
    request_row = f.gets.split(' ')
    requests[i] = Base::Request.new({
      endpoint: endpoints[request_row[1].to_i],
      requests: request_row[2].to_i,
      video: videos[request_row[0].to_i]
    })
  end
end

# sort requests by popularity and size
requests = requests.values.sort! do |a,b|
  relevancea = a.requests.to_f ** 10 / ((a.video.size.to_f)  + a.avg_cache_latency)
  relevanceb = b.requests.to_f ** 10 / ((b.video.size.to_f) + a.avg_cache_latency)
  relevancea <=> relevanceb
end

# requests.each do |r|
#   puts r.endpoint.caches()
# end
requests = requests.reverse
requests.each do |r|

  # puts "#{r.requests} r from endpoint #{r.endpoint.index} for vid #{r.video.index} "
  endpoint_caches = r.endpoint.caches()

  # contains a list of fastest caches for that endpoint
  cache_indecies = endpoint_caches.keys.sort
  while cache_indecies
    index = cache_indecies.shift
    if not index

      # puts "Endpoint #{r.endpoint.index} is connected to caches #{r.endpoint.caches.inspect}"
      # puts "All caches full for endpoint #{r.endpoint.index}"
      # puts "Trying to fit #{r.video.size} in #{r.endpoint.caches}"
      break
    end
    potential_cache = endpoint_caches[index]

    if potential_cache.add_video(r.video)
      # puts "video fits"
      break
    else
      # puts "dont fit"
    end
  end

end

# write result file

begin
  file = File.open("#{datafile}.out", "w")
  file.write("#{Base::Cache::get_used()}\n")
  # grab cache server
  caches.each do |i,c|
    videos = c.videos.values.map(&:index)
    if videos.any?
      file.write("#{[c.index, videos].join(' ')}\n")
    end
  end

rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file.nil?
end