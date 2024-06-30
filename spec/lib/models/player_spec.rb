# frozen_string_literal: true

require './lib/models/player'

RSpec.describe Lib::Models::Player do
  describe '#initialize' do
    it 'initializes the player with the default score' do
      player = described_class.new(id: 1, name: 'Player 1')

      expect(player.id).to eq 1
      expect(player.name).to eq 'Player 1'
      expect(player.score).to eq 0
    end
  end
end
