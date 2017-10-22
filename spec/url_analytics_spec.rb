# Responsible for representing a room oocupancy and price
require 'url_analytics'
require 'log_parser'

describe UrlAnalytics do
  let(:parsed_log_line) { LogParser.parse('2014-01-09T06:16:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342173/count_pending_messages host=services.pocketplaylab.com fwd="94.66.255.106" dyno=web.8 connect=9ms service=9ms status=304 bytes=0')}
  let(:updated_parsed_log_line) { LogParser.parse('2014-01-09T06:16:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342173/count_pending_messages host=services.pocketplaylab.com fwd="94.66.255.106" dyno=web.8 connect=10ms service=10ms status=304 bytes=0')}
  let(:url_analytics) { described_class.new(parsed_log_line) }

  describe '.url' do
    subject { url_analytics.url }

    it { is_expected.to eq('GET /api/users/{user_id}/count_pending_messages') }
  end

  describe '.response_times' do
    subject { url_analytics.response_times }

    it { is_expected.to eq([18.0]) }
  end

  describe '.price' do
    subject { url_analytics.most_respondant_dyno }

    it { is_expected.to eq('web.8') }
  end


  describe '.dyno_count' do
    subject { url_analytics.dyno_count }

    it { is_expected.to eq({'web.8' => 1}) }
  end

  describe '.occurances' do
    subject { url_analytics.occurances }

    it { is_expected.to eq(1) }
  end

  describe '.update' do
    it "should increase occurance to two" do
      url_analytics.update(updated_parsed_log_line)
      expect(url_analytics.occurances).to eq(2)
    end

    it "should print the following output with expected mean, median & mode" do
      url_analytics.update(updated_parsed_log_line)
      expect(url_analytics.to_s.gsub(/\t|\n*/, '') ).to eq("Url GET /api/users/{user_id}/count_pending_messages:Occurences: 2Mean Response Time = 19.0 msMedian Response Time = 19.0 msMode Response Time(Latest Unimode) = 20.0 msMost Respondant Dyno = 2")
    end
  end
end
