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
    attr_reader :index, :capacity, :current_capacity, :videos
    def initialize(args)
      @index = args[:index]
      @capacity = args[:capacity]
      @current_capacity = 0
      @videos = {}
    end

    def add_video(video)
      if @current_capacity + video.size > @capacity
        return false
      end
      @current_capacity += video.size
      @videos[video.index] = video
    end
  end

  class Request
    attr_reader :endpoint, :requests, :video
    def initialize(args)
      @endpoint = args[:endpoint]
      @requests = args[:requests]
      @video = args[:video]
    end
  end

end