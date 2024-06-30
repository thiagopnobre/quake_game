# frozen_string_literal: true

require './lib/models/match'

RSpec.describe Lib::Models::Match do
  describe '#initialize' do
    it 'initializes an empty match' do
      match = described_class.new

      expect(match.total_kills).to eq 0
      expect(match.players).to eq []
    end
  end
end
