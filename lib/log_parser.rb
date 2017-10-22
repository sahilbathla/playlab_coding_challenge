#Assuming all logs will follow a strict sequence like :-
#2014-01-09T06:16:53.748849+00:00 heroku[router]: at=info method=POST path=/api/online/platforms/facebook_canvas/users/100002266342173/add_ticket host=services.pocketplaylab.com fwd="94.66.255.106" dyno=web.12 connect=12ms service=21ms status=200 bytes=78
class LogParser
	attr_accessor :timestamp, :hosting, :log_type, :request_method, :url, :host, :fwd, :dyno, :connect_time, :service_time, :status, :bytes

	InvalidLogFileContents = Class.new(StandardError)

	def initialize(log_data)
		@timestamp = log_data[0]
		@hosting = log_data[1]
		# Better code can be to split by = & then use switch case to get path, status etc
		# That will be optimal as it will remove any ordering issue
		@log_type = log_data[2].gsub('at=', '')
		@request_method = log_data[3].gsub('method=', '')
		@url = log_data[4].gsub('path=', '').gsub(/\/users\/\d+/, '/users/{userId}')
		@host = log_data[5].gsub('host=', '')
		@fwd = log_data[6].gsub('fwd=', '')
		@dyno = log_data[7].gsub('dyno=', '')
		@connect_time = log_data[8].gsub('connect=', '').gsub('ms', '').to_i
		@service_time = log_data[9].gsub('service=', '').gsub('ms', '').to_i
		@status = log_data[10].gsub('status=', '').to_i
		@bytes = log_data[11].gsub('bytes=', '').to_i
	end

	def self.parse(log_line)
		log_data = log_line.split(' ')
		raise InvalidLogFileContents if (log_data.length != 12)
		LogParser.new(log_data)
	end
end