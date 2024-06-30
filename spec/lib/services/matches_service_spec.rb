# frozen_string_literal: true

require './lib/models/match'
require './lib/models/player'
require './lib/services/matches_service'

RSpec.describe Lib::Services::MatchesService do
  describe '#initialize' do
    it 'initializes the service with the given file and an empty state to other attrs' do
      file = ['  0:00 InitGame: ...']
      service = described_class.new(file:)

      expect(service.file).to eq file
      expect(service.matches).to eq []
      expect(service.current_match).to be_nil
      expect(service.current_players).to eq({})
    end
  end

  describe '#parse_file' do
    let(:match) { Lib::Models::Match.new }
    let(:first_player) { Lib::Models::Player.new(id: '1', name: 'Player 1') }
    let(:second_player) { Lib::Models::Player.new(id: '2', name: 'Isgalamido') }

    context 'when the file has a new match' do
      it 'creates the first new match' do
        file = ['  0:00 InitGame: ...']
        service = described_class.new(file:)

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches.size).to eq 1
        expect(service.current_match).not_to be_nil
        expect(service.current_players).to eq({})

        expected_match = service.matches[0]
        expect(expected_match.total_kills).to eq 0
        expect(expected_match.players).to eq []
        expect(expected_match.deaths).to eq({})
      end

      it 'creates a new match and set the current match and players to an empty state' do
        file = ['  0:00 InitGame: ...']
        service = described_class.new(file:)
        service.current_players = { '1' => first_player }
        service.current_match = match
        service.current_match.total_kills = 1
        service.current_match.players = [first_player]
        service.matches = [match]

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches.size).to eq 2
        expect(service.current_match).not_to be_nil
        expect(service.current_players).to eq({})

        expected_match = service.matches[1]
        expect(expected_match.total_kills).to eq 0
        expect(expected_match.players).to eq []
        expect(expected_match.deaths).to eq({})
      end
    end

    context 'when the file has a new player' do
      it 'creates a new player' do
        file = [' 20:34 ClientUserinfoChanged: 2 n\Isgalamido\t...']
        service = described_class.new(file:)
        service.current_match = match
        service.matches = [match]

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches.size).to eq 1
        expect(service.current_match).not_to be_nil
        expect(service.current_players.size).to eq 1

        expected_player = service.current_players['2']
        expect(expected_player.id).to eq '2'
        expect(expected_player.name).to eq 'Isgalamido'
        expect(expected_player.score).to eq 0

        expected_match = service.matches[0]
        expect(expected_match.total_kills).to eq 0
        expect(expected_match.players).to eq [expected_player]
        expect(expected_match.deaths).to eq({})
      end
    end

    context 'when the file changes an existing player' do
      it 'the player is updated' do
        file = [' 20:34 ClientUserinfoChanged: 1 n\New Name\t...']
        service = described_class.new(file:)
        service.current_players = { '1' => first_player }
        service.current_match = match
        service.current_match.players = [first_player]
        service.matches = [match]

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches).to eq [match]
        expect(service.current_match.total_kills).to eq 0
        expect(service.current_match.players).to eq [first_player]
        expect(service.current_players).to eq({ '1' => first_player })
        expect(first_player.name).to eq 'New Name'
      end
    end

    context 'when the player is killed by the world' do
      it 'computes the world kill' do
        file = [' 21:07 Kill: 1022 1 22: <world> killed Player 1 by MOD_TRIGGER_HURT']
        service = described_class.new(file:)
        service.current_players = { '1' => first_player }
        service.current_match = match
        service.current_match.players = [first_player]
        service.matches = [match]

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches.size).to eq 1
        expect(service.current_match).not_to be_nil
        expect(service.current_players.size).to eq 1

        expected_player = service.current_players['1']
        expect(expected_player.id).to eq '1'
        expect(expected_player.name).to eq 'Player 1'
        expect(expected_player.score).to eq(-1)

        expected_match = service.matches[0]
        expect(expected_match.total_kills).to eq 1
        expect(expected_match.players).to eq [expected_player]
        expect(expected_match.deaths).to eq({ 'MOD_TRIGGER_HURT' => 1 })
      end
    end

    context 'when one player kills another' do
      it 'computes the player kill' do
        file = [' 22:06 Kill: 2 1 7: Isgalamido killed Player 1 by MOD_ROCKET_SPLASH']
        service = described_class.new(file:)
        service.current_players = { '1' => first_player, '2' => second_player }
        service.current_match = match
        service.current_match.players = [first_player, second_player]
        service.matches = [match]

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches.size).to eq 1
        expect(service.current_match).not_to be_nil
        expect(service.current_players.size).to eq 2

        expected_player1 = service.current_players['1']
        expect(expected_player1.id).to eq '1'
        expect(expected_player1.name).to eq 'Player 1'
        expect(expected_player1.score).to eq 0

        expected_player2 = service.current_players['2']
        expect(expected_player2.id).to eq '2'
        expect(expected_player2.name).to eq 'Isgalamido'
        expect(expected_player2.score).to eq 1

        expected_match = service.matches[0]
        expect(expected_match.total_kills).to eq 1
        expect(expected_match.players).to eq [expected_player1, expected_player2]
        expect(expected_match.deaths).to eq({ 'MOD_ROCKET_SPLASH' => 1 })
      end
    end

    context 'when the player commits suicide' do
      it 'does not compute the score but it computes the total kills' do
        file = [' 22:06 Kill: 1 1 7: Isgalamido killed Player 1 by MOD_ROCKET_SPLASH']
        service = described_class.new(file:)
        service.current_players = { '1' => first_player }
        service.current_match = match
        service.current_match.players = [first_player]
        service.matches = [match]

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches.size).to eq 1
        expect(service.current_match).not_to be_nil
        expect(service.current_players.size).to eq 1

        expected_player = service.current_players['1']
        expect(expected_player.id).to eq '1'
        expect(expected_player.name).to eq 'Player 1'
        expect(expected_player.score).to eq 0

        expected_match = service.matches[0]
        expect(expected_match.total_kills).to eq 1
        expect(expected_match.players).to eq [expected_player]
        expect(expected_match.deaths).to eq({ 'MOD_ROCKET_SPLASH' => 1 })
      end
    end

    context 'when the line has an ignored operation' do
      it 'the match remains unchanged' do
        file = [' 20:38 ClientBegin: 1']
        service = described_class.new(file:)
        service.current_players = { '1' => first_player }
        service.current_match = match
        service.current_match.players = [first_player]
        service.matches = [match]

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches).to eq [match]
        expect(service.current_match.total_kills).to eq 0
        expect(service.current_match.players).to eq [first_player]
        expect(service.current_players).to eq({ '1' => first_player })
      end
    end

    context 'when the file has a full match' do
      it 'creates a full match' do
        file = [
          '  0:00 InitGame: ...',
          ' 20:34 ClientUserinfoChanged: 1 n\Player 1\t...',
          ' 20:38 ClientBegin: 1',
          ' 20:34 ClientUserinfoChanged: 2 n\Isgalamido\t...',
          ' 20:38 ClientBegin: 2',
          ' 21:07 Kill: 1022 1 22: <world> killed Player 1 by MOD_TRIGGER_HURT',
          ' 22:06 Kill: 2 1 7: Isgalamido killed Player 1 by MOD_ROCKET_SPLASH',
          ' 22:07 ShutdownGame:'
        ]
        service = described_class.new(file:)

        service.parse_file

        expect(service.file).to eq file
        expect(service.matches.size).to eq 1
        expect(service.current_match).not_to be_nil
        expect(service.current_players.size).to eq 2

        expected_player1 = service.current_players['1']
        expect(expected_player1.id).to eq '1'
        expect(expected_player1.name).to eq 'Player 1'
        expect(expected_player1.score).to eq(-1)

        expected_player2 = service.current_players['2']
        expect(expected_player2.id).to eq '2'
        expect(expected_player2.name).to eq 'Isgalamido'
        expect(expected_player2.score).to eq 1

        expected_match = service.matches[0]
        expect(expected_match.total_kills).to eq 2
        expect(expected_match.players).to eq [expected_player1, expected_player2]
        expect(expected_match.deaths).to eq({ 'MOD_TRIGGER_HURT' => 1, 'MOD_ROCKET_SPLASH' => 1 })
      end
    end
  end
end
