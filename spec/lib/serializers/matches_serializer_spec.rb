# frozen_string_literal: true

require 'json'

require './lib/models/match'
require './lib/models/player'
require './lib/serializers/matches_serializer'

RSpec.describe Lib::Serializers::MatchesSerializer do
  let(:first_player) do
    new_player = Lib::Models::Player.new(id: '1', name: 'Player 1')
    new_player.score = -1
    new_player
  end

  let(:second_player) do
    new_player = Lib::Models::Player.new(id: '2', name: 'Isgalamido')
    new_player.score = 1
    new_player
  end

  let(:match) do
    new_match = Lib::Models::Match.new
    new_match.players = [first_player, second_player]
    new_match.total_kills = 2
    new_match.deaths = { 'MOD_TRIGGER_HURT' => 1, 'MOD_ROCKET_SPLASH' => 1 }
    new_match
  end

  describe '#to_json' do
    context 'when there are no matches' do
      it 'returns an empty array JSON' do
        expected_json = JSON.pretty_generate([])
        expect(described_class.new.to_json([])).to eq(expected_json)
      end
    end

    context 'when there are matches' do
      it 'returns the matches as the default JSON' do
        # rubocop:disable Naming/VariableNumber
        expected_report = [
          {
            game_1: {
              total_kills: 2,
              players: ['Isgalamido', 'Player 1'],
              kills: {
                'Isgalamido' => 1,
                'Player 1' => -1
              }
            }
          }
        ]
        # rubocop:enable Naming/VariableNumber

        expected_json = JSON.pretty_generate(expected_report)

        expect(described_class.new.to_json([match])).to eq(expected_json)
      end
    end
  end

  describe '#to_kill_by_means_json' do
    context 'when there are no matches' do
      it 'returns an empty array JSON' do
        expected_json = JSON.pretty_generate([])
        expect(described_class.new.to_kill_by_means_json([])).to eq(expected_json)
      end
    end

    context 'when there are matches' do
      it 'returns the matches as the kill by means JSON' do
        expected_report = [
          {
            "game-1": {
              kills_by_means: { 'MOD_TRIGGER_HURT' => 1, 'MOD_ROCKET_SPLASH' => 1 }
            }
          }
        ]

        expected_json = JSON.pretty_generate(expected_report)

        expect(described_class.new.to_kill_by_means_json([match])).to eq(expected_json)
      end
    end
  end
end
