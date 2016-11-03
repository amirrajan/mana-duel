require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = Blood Seal
(stab) = Kunai
nothing () = Wait
=end

describe 'Reflect: [:blue, :blue], [:indigo, :indigo]' do
  let(:game) { Game.new }

  it 'returns damage given by spells, :b reflects' do
    sync({ left: LightningBolt.new.sequence },
         { left: Reflect.new.sequence,
           right: Reflect.new.assist_sequence })

    summary[:b][:left][:spell][:name].should eq 'Reflect'
    summary[:b][:left][:spell][:nullified].should eq false
    summary[:b][:right][:spell][:name].should eq 'Reflect'
    summary[:b][:right][:spell][:nullified].should eq false

    summary[:a][:left][:spell][:name].should eq 'LightningBolt'
    summary[:a][:left][:spell][:nullified].should eq true

    game.damage_for(:b).should be 0
    game.damage_for(:a).should be 5
  end

  it 'returns damage given by spells, :a reflects' do
    sync({ left: Reflect.new.sequence,
           right: Reflect.new.assist_sequence },
         { left: LightningBolt.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Reflect'
    summary[:a][:left][:spell][:nullified].should eq false
    summary[:a][:right][:spell][:name].should eq 'Reflect'
    summary[:a][:right][:spell][:nullified].should eq false

    summary[:b][:left][:spell][:name].should eq 'LightningBolt'
    summary[:b][:left][:spell][:nullified].should eq true

    game.damage_for(:b).should be 5
    game.damage_for(:a).should be 0
  end

  it 'doesn\'t work on shock' do
    sync({ left: Reflect.new.sequence,
           right: Reflect.new.assist_sequence },
         { left: Shock.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Reflect'
    summary[:a][:left][:spell][:nullified].should eq false
    summary[:a][:right][:spell][:name].should eq 'Reflect'
    summary[:a][:right][:spell][:nullified].should eq false

    summary[:b][:left][:spell][:name].should eq 'Shock'
    summary[:b][:left][:spell][:nullified].should eq false

    game.damage_for(:a).should be 1
    game.damage_for(:b).should be 0
  end

  it 'cannot be shielded against' do
    sync({ left: Reflect.new.sequence,
           right: Reflect.new.assist_sequence },
         { left: Shield.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Reflect'
    summary[:a][:left][:spell][:nullified].should eq false
    summary[:a][:right][:spell][:name].should eq 'Reflect'
    summary[:a][:right][:spell][:nullified].should eq false
    summary[:b][:left][:spell][:name].should eq 'Shield'
  end
end
