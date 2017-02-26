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

datafile = "me_at_the_zoo"


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
    endpoint = Base::Endpoint.new({index: i, dc_latency: endpoint_row[0].to_i})
    endpoints[i] = endpoint

    for i in 0..caches_count-1
      cache_latency_row = f.gets.split(' ')
      cache = Base::Cache.new({index: cache_latency_row[0].to_i, capacity: cache_capacity})
      caches[i] = cache
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

requests.each do |i,r|
  # puts "#{r.requests} r from endpoint #{r.endpoint.index} for vid #{r.video.index} "
  endpoint_caches = r.endpoint.caches()
  c_index = endpoint_caches.keys.sort.shift
  closest_cache = endpoint_caches[c_index]

  if closest_cache
    closest_cache.add_video(r.video)
  else
    puts "\tNo close cache"
  end
  # puts "\n"
end

# write result file

begin
  file = File.open("#{datafile}.out", "w")
  file.write("#{cache_count}\n")
  # grab cache server
  caches.each do |i,c|
    videos = c.videos.values.map(&:index)
    file.write("#{[c.index, videos].join(' ')}\n")
  end

rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file.nil?
end