require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

class Spec::Rails::Example::ViewExampleGroupController
  set_view_path File.join(File.dirname(__FILE__), "..", "spec_resources", "views")
end

describe 'TTL en declaraciones de cache de fragmentos en vistas', :type => :view do
  before do
    @ttl = 45.seconds
    assigns[:fragment_ttl] = @ttl
  end
  
  it 'cuando facilitamos la opcion :ttl debe ser pasada al controlador' do
    @controller.should_receive(:cache_erb_fragment).with(anything, anything, {:ttl => @ttl})
    render 'the_shaker_cache_fragments_spec/with_ttl_option'
  end

  it 'cuando no facilitamos la opcion :ttl debe pasarse al controlador un nulo' do
    @controller.should_receive(:cache_erb_fragment).with(anything, anything, nil)
    render 'the_shaker_cache_fragments_spec/without_ttl_option'
  end
end



describe 'Redefinicion de write para que contemple el paso de un TTL entre las opciones' do
  
  def key(name)
    "fragment:#{name}"
  end

  before do
    @name, @value = '/home', '<div>Hello!</div>'
    @default_ttl = 1.hours
    @memcache_client = mock(MemCache)
    @fragment_store = ActionController::Caching::Fragments::UnthreadedMemCacheFragmentStore.new(
      @memcache_client, @default_ttl)
  end
    
  it 'si no recibe opciones deberá utilizar el @ttl genérico' do
    @memcache_client.should_receive(:set).with(key(@name), @value, @default_ttl)
    @fragment_store.write(@name, @value)
  end
  
  it 'si no recibe la opción :ttl deberá utilizar el @ttl genérico' do
    @memcache_client.should_receive(:set).with(key(@name), @value, @default_ttl)
    @fragment_store.write(@name, @value, { :dummy => '4' })
  end
  
  it 'si recibe la opción :ttl deberá utilizarla al establecer la cache' do
    ttl = 5.minutes
    @memcache_client.should_receive(:set).with(key(@name), @value, ttl)
    @fragment_store.write(@name, @value, { :ttl => ttl })
  end
end
