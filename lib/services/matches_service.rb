# frozen_string_literal: true

require_relative '../models/match'
require_relative '../models/player'

module Lib
  module Services
    class MatchesService
      attr_accessor :file, :matches, :current_match, :current_players

      def initialize(file:)
        @file = file
        @matches = []
        @current_match = nil
        @current_players = {}
      end

      def parse_file
        @file.each do |line|
          parse_line(line)
        end
      end

      private

      def parse_line(line)
        line_info = player_info_changed?(line) ? line.split(' ', 4) : line.split

        if new_match?(line_info)
          create_match
          return
        end

        if new_player?(line_info)
          create_player(line_info)
          return
        end

        if player_info_changed?(line)
          update_player(line_info)
          return
        end

        if player_killed_by_world?(line_info)
          compute_world_kill(line_info)
          return
        end

        return unless player_killed?(line_info)

        compute_player_kill(line_info)
      end

      def player_info_changed?(line)
        line.include?('ClientUserinfoChanged:')
      end

      def new_match?(line_info)
        line_info.include?('InitGame:')
      end

      def new_player?(line_info)
        player_info_changed?(line_info) && !@current_players.key?(line_info[2])
      end

      def player_killed_by_world?(line_info)
        player_killed?(line_info) && line_info.include?('<world>')
      end

      def player_killed?(line_info)
        line_info.include?('Kill:')
      end

      def create_match
        @current_match = Lib::Models::Match.new
        @current_players = {}
        @matches << @current_match
      end

      def create_player(line_info)
        player_id = line_info[2]
        player_name = line_info[3].split('\\')[1]
        @current_players[player_id] = Lib::Models::Player.new(id: player_id, name: player_name)
        @current_match.players << @current_players[player_id]
      end

      def update_player(line_info)
        player_id = line_info[2]
        player_name = line_info[3].split('\\')[1]
        @current_players[player_id].name = player_name
      end

      def compute_world_kill(line_info)
        killed_id = line_info[3]
        @current_players[killed_id].score -= 1
        @current_match.total_kills += 1
      end

      def compute_player_kill(line_info)
        killer_id = line_info[2]
        killed_id = line_info[3]
        @current_players[killer_id].score += 1 if killer_id != killed_id
        @current_match.total_kills += 1
      end
    end
  end
end
