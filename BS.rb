#!/usr/local/bin/ruby

require './BSConfig.rb'
require 'net/https'
require 'digest/md5'
require 'json'

class BetaSeries

	def initialize
		@token = ""
		@files = []
		@episodes = Hash.new
		@shows = Hash.new
		@cache = []
		@cacheFile
		getCache
		getToken
    end

	def getCache
		if !File.exist? "cache.bs"
			puts "No cache. Creating cache."
			@cacheFile = File.new("cache.bs", "w+")
			puts "Cache done"
		else
			@cacheFile = File.open("cache.bs", "a+")
			@cacheFile.rewind
		end
		@cache = @cacheFile.readlines
	end

	def getToken
		url = "http://api.betaseries.com/members/auth.json?key=#{BSConfig::APIkey}&login=#{BSConfig::User}&password=#{Digest::MD5.hexdigest(BSConfig::Password)}"
		response = Net::HTTP.get_response(URI.parse(url))
		print_errors_and_quit JSON.parse(response.body)['root']['errors'] if JSON.parse(response.body)['root']['code'] == "0"
		@token = JSON.parse(response.body)['root']["member"]["token"]
	end
	
	def print_errors_and_quit(errors)
		json_print errors
		Process.exit
	end
	
	def json_print(json)
		print JSON.pretty_generate(json) + "\n"
	end
	
	def scan_directory(path)
		dir = Dir.new(path)
		
		dir.each do |f|
			scan_directory("#{path}/#{f}") if f[0] != '.' and File.directory? "#{path}/#{f}"
			@files << f if f =~ /.(mkv|mp4|avi)$/
		end
	end
	
	def get_episodes
		puts "Loading not seen TV Shows..."
		url = "http://api.betaseries.com/members/episodes/all.json?token=#{@token}&key=#{BSConfig::APIkey}"
		response = Net::HTTP.get_response(URI.parse(url))
		puts "======= NOT DOWNLOADED TV SHOWS ======="
		JSON.parse(response.body)['root']['episodes'].each_value do |ep|
			@episodes[ep['show'].downcase] = Array.new unless @episodes.has_key? ep['show'].downcase
			@episodes[ep['show'].downcase].push("#{ep['season']}x#{ep['episode']}") if ep['downloaded'] === "0"
			@shows[ep['show'].downcase] = ep['url']
		end
		@shows.each do |s, url|
		  puts "#{s} #{@episodes[s.downcase]}" if !@episodes[s.downcase].empty?
		end
		puts "================================"
	end
	
	def mark_as_dowloaded(serie, season, episode)
		url = "http://api.betaseries.com/members/downloaded/#{serie}.json?season=#{season}&episode=#{episode}&token=#{@token}&key=#{BSConfig::APIkey}"
		response = Net::HTTP.get_response(URI.parse(url))
	end
	
	def get_infos episode
		Net::HTTP.start("api.betaseries.com") {|http|
			req = Net::HTTP::Get.new("/subtitles/show.json?file=#{episode}&key=#{BSConfig::APIkey}")
			response = http.request(req)
			serie = JSON.parse(response.body)['root']['subtitles']['0']['title']
			season = JSON.parse(response.body)['root']['subtitles']['0']['season']
			episode = JSON.parse(response.body)['root']['subtitles']['0']['episode']
			Hash["show", serie, "season", season, "episode", episode]
		}
	end
	
	def add_to_cache ep
		@cache << ep
		@cacheFile.puts ep
	end
	
	def mark_all_as_downloaded
		@files.each do |e|
			if !@cache.include? "#{e}\n"
				begin
					puts e
					infos = get_infos e
					puts "#{infos['show']} #{infos['season']}x#{infos['episode']}"
					if @episodes.has_key? infos['show'].downcase and @episodes[infos['show'].downcase].include? "#{infos['season']}x#{infos['episode']}"
						mark_as_dowloaded @shows[infos['show'].downcase], infos['season'], infos['episode']
						puts "=> Mark as downloaded !"
					end
					add_to_cache e 
				end
				puts "========"
			end
		end
	end
	
end

bs = BetaSeries.new
bs.scan_directory BSConfig::Folder
bs.get_episodes
bs.mark_all_as_downloaded