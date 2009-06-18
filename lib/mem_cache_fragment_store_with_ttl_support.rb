module ActionView::Helpers::CacheHelper
  def cache(name = {}, options = nil, &block)
    @controller.cache_erb_fragment(block, name, options)
  end
end

class ActionController::Caching::Fragments::UnthreadedMemCacheFragmentStore
  def write(name, value, options = nil)
    if options.is_a?(Hash) && options.has_key?(:ttl)
      ttl = options[:ttl]
    else
      ttl = @ttl
    end
    @data.set "fragment:#{name}", value, ttl
  rescue MemCache::MemCacheError => err
    handle_error err
  end
end
