# Assumptions :-
# Mode :- Assuming that expected solution will always have 1 mode, if multiple found, latest mode is used.
# Latest Dyno :- Assuming that there will only one dyno, if multiple found, latest dyno is used.

class UrlAnalytics
	attr_accessor :url, :response_times, :most_respondant_dyno
	attr_reader :dyno_count

	ROUND_OFF_VALUE = 2

	def initialize(parsed_url_data)
		@url = parsed_url_data.url
		@response_times = [parsed_url_data.connect_time + parsed_url_data.service_time]
		@dyno_count = Hash.new(0)
		@dyno_count[parsed_url_data.dyno] += 1
		@most_respondant_dyno = parsed_url_data.dyno
	end

	def update(parsed_url_data)
		@response_times.push(parsed_url_data.connect_time + parsed_url_data.service_time)
		update_dyno_information(parsed_url_data)
	end

	def to_s
		"Url #{ url }:
			\nOccurences: #{ occurances }
			\nMean Response Time = #{ calculate_mean_response_time.round(ROUND_OFF_VALUE) } ms
			\nMedian Response Time = #{ calculate_median_response_time.round(ROUND_OFF_VALUE) } ms
			\nMode Response Time(Latest Unimode) = #{ calculate_mode_response_time.round(ROUND_OFF_VALUE) } ms
			\nMost Respondant Dyno = #{ most_respondant_dyno }
			\n\n
		"
	end

	def occurances
		response_times.length
	end

	private

	def calculate_mean_response_time
		response_times.inject(0.0) { |sum, response_time| sum + response_time } / response_times.length
	end

	def calculate_median_response_time
		sorted_response_times = response_times.sort
		(sorted_response_times[(sorted_response_times.length - 1) / 2] + sorted_response_times[sorted_response_times.length / 2]) / 2.0
	end

	def calculate_mode_response_time
		mode = response_times[0]
		count_duplicates = Hash.new(0)
		response_times.each do |response_time|
			count_duplicates[response_time] += 1
			mode = response_time if count_duplicates[response_time] >= count_duplicates[mode]
		end
		mode
	end

	def update_dyno_information(parsed_url_data)
		dyno_count[parsed_url_data.dyno] += 1
		@most_respondant_dyno = dyno_count[parsed_url_data.dyno] if dyno_count[most_respondant_dyno] <= dyno_count[parsed_url_data.dyno]
	end
end