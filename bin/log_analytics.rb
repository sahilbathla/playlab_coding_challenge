require_relative '../lib/url_analytics'
require_relative '../lib/log_parser'

result = {}

#Process logs
ARGF.each do |line|
  begin
    line = line.chomp
    parsed_url_data = LogParser.parse(line)
    if (result[parsed_url_data.url])
        result[parsed_url_data.url].update(parsed_url_data)
    else
        result[parsed_url_data.url] = UrlAnalytics.new(parsed_url_data)
    end
  rescue InvalidLogFileContents => error
    p "Invalid Log Line #{ line }. Failed with error #{ error.backtrace.inspect } Please check it!!"
  end
end

result.each do |url, url_data|
  puts url_data.to_s
end
