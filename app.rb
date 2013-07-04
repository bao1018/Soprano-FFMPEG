require 'bundler/setup'
require 'streamio-ffmpeg'
require 'uri'

Bundler.require
class App < Sinatra::Base

  set :root, File.dirname(__FILE__)

  register Sinatra::AssetPack
  register Mustache::Sinatra

  assets do
    serve '/js', from: '/scripts'
    serve '/css', from: '/styles'
    js :app, '/js/app.js', [
      '/js/vendor/*.js',
      '/js/*.js' ]
    css :app, '/css/app.css', [
      '/css/reset.css',
      '/css/*.css' ]
  end

  set :mustache, {
    views: './views/',
    templates: './templates/' }
  require_relative 'views/layout'

  set :scss, {
    load_paths: [ "#{root}/styles" ],
    cache: false }

  before do
    @css = css :app
    @js  = js  :app
  end

  get '/' do
    erb :upload
  end

  post '/' do
    if params['upfile'].nil?
      @text = "Please select a file!"
      erb :result
    else
      File.open('uploads/' + params['upfile'][:filename], "w") do |f|
        f.write(params['upfile'][:tempfile].read)
      end
      inFile = FFMPEG::Movie.new('uploads/' + params['upfile'][:filename])
      options = {audio_sample_rate: 16000}
      @text = inFile.audio_sample_rate
      inFile.transcode("uploads/result_16khz.wav", options)
      send_file("uploads/result_16khz.wav", :type => "audio/wav", :disposition => 'attachment')
    end

    

  end

  run! if app_file == $0
end
