require 'lru_redux'

class LruCacheManager
  def self.cache
    @@cache ||= LruRedux::Cache.new(2700)
  end
end
