require './spec/spec_helper.rb'

describe 'Missile' do
  let(:game) { Game.new }

  it 'does one damage, the sequence is :green, :yellow for one ninja on the team' do
    sync({ left: Missile.new.sequence }, {})

    game.damage_for(:b).should be 1
  end

  it 'signs done by different ninjas on the same team doesnt activate the missile' do
    game.turn({ right: :green },
              {})

    game.turn({ left: :yellow },
              {})

    game.damage_for(:b).should be 0
  end
end
