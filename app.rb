require './lib/services/matches_service'
require './lib/serializers/matches_serializer'

class App
  def run
    File.open("#{__dir__}/log/qgames.log") do |file|
      service = Lib::Services::MatchesService.new(file:)
      service.parse_file

      serializer = Lib::Serializers::MatchesSerializer.new
      puts(serializer.to_json(service.matches))
      puts(serializer.to_kill_by_means_json(service.matches))
    end
  end
end

App.new.run
