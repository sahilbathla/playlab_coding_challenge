require_relative '../lib/url_analytics'
require_relative '../lib/log_parser'

result = {}

VALID_URLS = [
  'GET /api/users/{user_id}/count_pending_messages',
  'GET /api/users/{user_id}/get_messages',
  'GET /api/users/{user_id}/get_friends_progress',
  'GET /api/users/{user_id}/get_friends_score',
  'POST /api/users/{user_id}',
  'GET /api/users/{user_id}'
]

#Process logs
ARGF.each do |line|
  begin
    line = line.chomp
    parsed_url_data = LogParser.parse(line)
    if (result[parsed_url_data.url])
        result[parsed_url_data.url].update(parsed_url_data)
    else
        result[parsed_url_data.url] = UrlAnalytics.new(parsed_url_data) if VALID_URLS.include? parsed_url_data.url
    end
  rescue LogParser::InvalidLogFileContents => error
    p "Invalid Log Line => #{ line }. Please check it!!"
  end
end

result.each do |url, url_data|
  puts url_data.to_s
end
