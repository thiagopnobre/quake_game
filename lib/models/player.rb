# frozen_string_literal: true

module Lib
  module Models
    class Player
      attr_accessor :id, :name, :score

      def initialize(id:, name:)
        @id = id
        @name = name
        @score = 0
      end
    end
  end
end
