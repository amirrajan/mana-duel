require './spec/spec_helper.rb'

=begin
F = Tiger
P = Dragon
S = Snake
W = Rat
D = Dog
C = [Ox, Ox]
(stab) = Ram
nothing () = Wait
=end

describe 'Upheaval: :snake, dragon, tiger' do
  let(:game) { Game.new }

  specify 'forces team to restart all spells' do
    game.turn({ left: :dog }, {})
    game.turn({ left: :tiger }, { left: :snake })
    game.turn({ left: :tiger }, { left: :dragon })
    game.turn({ left: :dog }, { left: :tiger })

    summary[:a][:left][:command].should eq :dog
    summary[:b][:left][:spell][:name].should eq 'Upheaval'
    next_sequence[:a][:left][:by_spell][LightningBolt][:command].should eq :dog
    next_sequence[:a][:left][:by_spell][LightningBolt][:countdown].should eq 5
  end

  specify 'it cannot be shielded' do
    game.turn({}, { left: :snake })
    game.turn({}, { left: :dragon })
    game.turn({ left: :dragon }, { left: :tiger })

    summary[:b][:left][:spell][:name].should eq 'Upheaval'
    summary[:b][:left][:spell][:nullified].should eq false
  end

  specify 'it can be counter spelled' do
    game.turn({ left: :dog }, {})
    game.turn({ left: :tiger, right: :rat }, { left: :snake })
    game.turn({ left: :tiger, right: :dragon }, { left: :dragon })
    game.turn({ left: :dog, right: :dragon }, { left: :tiger })

    next_sequence[:a][:left][:by_spell][LightningBolt][:command].should eq :dog
    next_sequence[:a][:left][:by_spell][LightningBolt][:countdown].should eq 1
  end

  specify 'it can be reflected' do
    game.turn({},
              { left: :snake,  right: :dog })

    game.turn({ left: :ox,     right: :ox },
              { left: :dragon, right: :dog })

    game.turn({ left: :rat,    right: :rat },
              { left: :tiger,  right: :tiger })

    summary[:a][:left][:spell][:name].should eq 'Reflect'
    summary[:b][:left][:spell][:name].should eq 'Upheaval'
    summary[:b][:left][:spell][:nullified].should eq true

    next_sequence[:b][:right][:by_spell][LightningBolt][:command].should eq :dog
    next_sequence[:b][:right][:by_spell][LightningBolt][:countdown].should eq 5
  end

  def summary
    game.turn_summaries.last
  end

  def next_sequence
    game.next_sequence_for_turn[game.current_turn]
  end
end
