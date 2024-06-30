# frozen_string_literal: true

module Lib
  module Models
    class Match
      attr_accessor :total_kills, :players, :deaths

      def initialize
        @total_kills = 0
        @players = []
        @deaths = {}
      end
    end
  end
end
