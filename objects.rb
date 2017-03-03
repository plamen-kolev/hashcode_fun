module Base
  class Video
    attr_reader :size, :index

    def initialize(args)
      @index = args[:index]
      @size = args[:size]
    end
  end

  class Endpoint
    attr_reader :index

    def initialize(args)
      @index = args[:index]
      @dc_latency = args[:dc_latency]
      @caches = {}
    end

    def add_cache(latency, cache_obj)
      @caches[latency] = cache_obj
    end

    def caches()
      return @caches
    end
  end

  class Cache
    attr_reader :index, :capacity, :current_capacity, :videos, :used_count
    attr_writer :used

    def initialize(args)
      @index = args[:index]
      @capacity = args[:capacity]
      @current_capacity = 0
      @used = false
      @@used_count = 0
      @videos = {}
    end

    def add_video(video)
      if @current_capacity + video.size > @capacity
        return false
      end


      if not @used
        @used = true
        @@used_count += 1
        # puts "adding video #{video.index} to cache #{@index}, used counter is #{@@used_count}"
      end
      @current_capacity += video.size
      @videos[video.index] = video
    end

    def self.get_used()
      return @@used_count
    end
  end

  class Request
    attr_reader :endpoint, :requests, :video, :avg_cache_latency
    # attr_writer :avg_cache_latency

    def initialize(args)
      @endpoint = args[:endpoint]
      @requests = args[:requests]
      @video = args[:video]
      @avg_cache_latency = 0
      set_avg_latency()
    end

    def set_avg_latency
      latencies = @endpoint.caches().keys
      for i in 0..latencies.length-1
        @avg_cache_latency += latencies[i]
      end

      lat_length = latencies.length == 0 ? 1 : latencies.length
      @avg_cache_latency /= lat_length
      # puts "Avg of #{latencies.inspect} is #{@avg_cache_latency}"
    end
  end

end