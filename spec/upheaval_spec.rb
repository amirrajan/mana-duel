require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = [blue, blue]
(stab) = orange
nothing () = Wait
=end

describe 'Upheaval: :green, red, violet' do
  let(:game) { Game.new }

  specify 'forces team to restart all spells' do
    game.turn({ left: :yellow }, {})
    game.turn({ left: :violet }, { left: :green })
    game.turn({ left: :violet }, { left: :red })
    game.turn({ left: :yellow }, { left: :violet })

    summary[:a][:left][:command].should eq :yellow
    summary[:b][:left][:spell][:name].should eq 'Upheaval'
    next_sequence[:a][:left][:by_spell][LightningBolt][:command].should eq :yellow
    next_sequence[:a][:left][:by_spell][LightningBolt][:countdown].should eq 5
  end

  specify 'it cannot be shielded' do
    game.turn({}, { left: :green })
    game.turn({}, { left: :red })
    game.turn({ left: :red }, { left: :violet })

    summary[:b][:left][:spell][:name].should eq 'Upheaval'
    summary[:b][:left][:spell][:nullified].should eq false
  end

  specify 'it can be counter spelled' do
    game.turn({ left: :yellow }, {})
    game.turn({ left: :violet, right: :indigo }, { left: :green })
    game.turn({ left: :violet, right: :red }, { left: :red })
    game.turn({ left: :yellow, right: :red }, { left: :violet })

    next_sequence[:a][:left][:by_spell][LightningBolt][:command].should eq :yellow
    next_sequence[:a][:left][:by_spell][LightningBolt][:countdown].should eq 1
  end

  specify 'it can be reflected' do
    game.turn({},
              { left: :green,  right: :yellow })

    game.turn({ left: :blue,     right: :blue },
              { left: :red, right: :yellow })

    game.turn({ left: :indigo,    right: :indigo },
              { left: :violet,  right: :violet })

    summary[:a][:left][:spell][:name].should eq 'Reflect'
    summary[:b][:left][:spell][:name].should eq 'Upheaval'
    summary[:b][:left][:spell][:nullified].should eq true

    next_sequence[:b][:right][:by_spell][LightningBolt][:command].should eq :yellow
    next_sequence[:b][:right][:by_spell][LightningBolt][:countdown].should eq 5
  end

  def summary
    game.turn_summaries.last
  end

  def next_sequence
    game.next_sequence_for_turn[game.current_turn]
  end
end
