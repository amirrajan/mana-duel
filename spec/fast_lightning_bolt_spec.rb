require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = blue, blue
(stab) = Kunai
nothing () = Wait
=end

describe 'Fast Lightning Bolt' do
  let(:game) { Game.new }

  it 'does 5 points of damage' do
    sync({ left: FastLightningBolt.new.sequence,
           right: FastLightningBolt.new.assist_sequence }, {})

    game.damage_for(:b).should be 5
  end

  it 'only register one lighting if done at the same time' do
    sync({ left: FastLightningBolt.new.sequence,
           right: FastLightningBolt.new.sequence }, {})

    summary[:a][:left][:spell][:name].should eq 'FastLightningBolt'
    summary[:a][:right][:spell][:name].should eq ''

    sync({}, { left: FastLightningBolt.new.sequence,
               right: FastLightningBolt.new.sequence })

    summary[:b][:left][:spell][:name].should eq 'FastLightningBolt'
    summary[:b][:right][:spell][:name].should eq ''
  end

  it 'can only be used once per game, by each team' do
    2.times do
      sync({ left: FastLightningBolt.new.sequence,
             right: FastLightningBolt.new.assist_sequence }, {})
    end

    game.damage_for(:b).should be 5

    2.times do
      sync({},
           { left: FastLightningBolt.new.sequence,
             right: FastLightningBolt.new.assist_sequence })
    end

    game.damage_for(:a).should be 5
  end

  it 'cannot be countered by a shield' do
    sync({ left: FastLightningBolt.new.sequence,
           right: FastLightningBolt.new.assist_sequence },
         { left: Shield.new.sequence })

    game.damage_for(:b).should be 5
  end

  it 'the final sign must be provided by both members' do
    sync({ left: FastLightningBolt.new.sequence, right: [:wait] }, {})

    game.damage_for(:b).should be 0
  end
end
