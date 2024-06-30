# frozen_string_literal: true

require 'json'

module Lib
  module Serializers
    class MatchesSerializer
      def to_json(matches)
        reports = matches.map.with_index(1) do |match, index|
          {
            "game_#{index}": {
              total_kills: match.total_kills,
              players: match.players.map(&:name).sort,
              kills: match.players.each_with_object({}) do |player, kills|
                kills[player.name] = player.score
              end.sort.to_h
            }
          }
        end

        JSON.pretty_generate(reports)
      end
    end
  end
end
