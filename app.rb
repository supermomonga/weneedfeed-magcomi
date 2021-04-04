require 'bundler'
Bundler.require
require 'erb'
require 'nokogiri'
require 'open-uri'
require 'ostruct'

series_url = 'https://magcomi.com/series'

html = URI.open(series_url) {|f| f.read}
doc = Nokogiri::HTML.parse(html, nil)

pages = []
doc.search('.series-item').each do |item|
  url = item.at('a').attr(:href)
  next if url.empty?
  id = url.split('/').last
  pages << OpenStruct.new(
      id: id,
      title: item.at('.series-title').text,
      url: url
  )
end

template = open('./weneedfeed.yml.erb') {|f| f.read}
result = ERB.new(template, trim_mode: '<>').result_with_hash(pages: pages)
File.open('./weneedfeed.yml', mode='w') do |f|
    f.write(result)
end


