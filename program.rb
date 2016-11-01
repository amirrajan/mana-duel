require_relative 'lib/spell.rb'
require_relative 'lib/available_commands.rb'
require_relative 'lib/activated_spells.rb'
require_relative 'lib/wait.rb'
require_relative 'lib/paralysis.rb'
require_relative 'lib/fast_lightning_bolt.rb'
require_relative 'lib/lightning_bolt.rb'
require_relative 'lib/silence.rb'
require_relative 'lib/ultimate_defense.rb'
require_relative 'lib/shock.rb'
require_relative 'lib/upheaval.rb'
require_relative 'lib/amnesia.rb'
require_relative 'lib/heal.rb'
require_relative 'lib/greater_heal.rb'
require_relative 'lib/counter_spell.rb'
require_relative 'lib/light_wounds.rb'
require_relative 'lib/shield.rb'
require_relative 'lib/reflect.rb'
require_relative 'lib/missile.rb'
require_relative 'lib/seppuku.rb'
require_relative 'lib/heavy_wounds.rb'
require_relative 'lib/sokushi.rb'
require_relative 'lib/next_sequence.rb'
require_relative 'lib/game.rb'
require 'io/console'
require 'pp'

game = Game.new
continue = true

def paralysis
  {
    :name => "Paralysis",
    :short => "violet (3x)",
    :command => "violet, violet, violet",
    :description => "Forces one wizard to repeat the hand sign he performed last turn. The target depends on which mana pool executes the spell (left targets left, right targets right). Paralysis can only affect one mana pool at a time. Some hand signs will be changed to another to prevent complete impairment (blue changes to violet, yellow to green, and indigo to red).",
    :countered_by => "Counter Spell, Reflect, Ultimate Defense"
  }
end

def shield
  {
    :name => "Shield",
    :short => "red",
    :command => "red",
    :description => "Stops shock and missle damage from opponent's wizard for one turn.",
    :countered_by => nil
  }
end

def shock
  {
    :name => "Shock",
    :short => "orange",
    :command => "orange",
    :description => "Does one point of damage.",
    :countered_by => "Shield, Ultimate Defense"
  }
end

def missile
  {
    :name => "Missile",
    :short => "yellow, green",
    :command => "yellow, green",
    :description => "Does one point of damage.",
    :countered_by => "Shield, Reflect, Counter Spell, Ultimate Defense"
  }
end

def light_wound
  {
    :name => "Light Wounds",
    :short => "indigo, violet, red",
    :command => "indigo, violet, red (this spell will take three turns to execute, a wizard needs to execute indigo, then violet, then red)",
    :description => "Does two points of damage.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def heavy_wound
  {
    :name => "Heavy Wounds",
    :short => "indigo, red, violet, green",
    :command => "indigo, red, violet, green (this spell will take four turns to execute, a wizard needs to execute indigo, then red, then violet, then green)",
    :description => "Does three points of damage.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def lighting_bolt
  {
    :name => "Lightning Bolt",
    :short => "green, violet, violet, green, green",
    :command => "green, violet, violet, green, green (the last command doubles up as the first command if executed one after another)",
    :description => "Does five points of damage.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def fast_lighting_bolt
  {
    :name => "Fast Lightning Bolt",
    :short => "indigo, green, green, [blue, blue] (once per game)",
    :command => "indigo, green, green, [blue, blue] (both mana pools of the wizard must cast the last color for spell to execute)",
    :description => "Does five points of damage. This spell can only be used once per match by each wizard.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def seppuku
  {
    :name => "Seppuku",
    :short => "[orange, orange] or [red, red] (instant forfeit)",
    :command => "[orange, orange] or [red, red] (if both mana pools on the wizard cast either orange or red, it's instant death for that wizard)",
    :description => "Curse does 30 points of damage to the wizard that casts the spell. Instant death.",
    :countered_by => nil
  }
end

def reflect
  {
    :name => "Reflect",
    :short => "[blue, blue], [indigo, indigo]",
    :command => "[blue, blue], [indigo, indigo] (both mana pools must issue both commands in unison)",
    :description => "Reflects spell back at opponent. Will not reflect Shock however.",
    :countered_by => nil
  }
end

def counter_spell
  {
    :name => "Counter Spell",
    :short => "indigo, red, red or indigo, indigo, yellow",
    :command => "indigo, red, red or indigo, indigo, yellow",
    :description => "Nullifies all attack spell except Shock or Sokushi.",
    :countered_by => nil
  }
end

def ultimate_defense
  {
    :name => "Ultimate Defense",
    :short => "[blue, blue], green, red, indigo",
    :command => "[blue, blue], green, red, indigo",
    :description => "Nullifies all attack spell.",
    :countered_by => nil
  }
end

def sokushi
  {
    :name => "Sokushi",
    :short => "red, indigo, red, violet, yellow (3x), green",
    :command => "red, indigo, red, violet, yellow, yellow, yellow, green",
    :description => "Does 100 points of damage.",
    :countered_by => "Ultimate Defense"
  }
end

def heal
  {
    :name => "Heal",
    :short => "green, violet, indigo",
    :command => "green, violet, indigo",
    :description => "Removes one point of damage.",
    :countered_by => nil
  }
end

def amnesia
  {
    :name => "Amnesia",
    :short => "green, red, red",
    :command => "green, red, red",
    :description => "When Amnesia is cast, opponent will be forced to repeat the same signs he performed before.",
    :countered_by => "Reflects, Counter Spell, Ultimate Defense"
  }
end

def upheaval
  {
    :name => "Upheaval",
    :short => "yellow, red, violet",
    :command => "yellow, red, violet",
    :description => "When Upheaval is cast, opponent will have all of his sequences reset.",
    :countered_by => "Reflects, Counter Spell, Ultimate Defense"
  }
end

def silence
  {
    :name => "Silence",
    :short => "yellow, indigo, green",
    :command => "yellow, indigo, green",
    :description => "Disables the opponents ability to cast blue, green, violet, yellow.",
    :countered_by => "Reflects, CounterSpell, UltimateDefense"
  }
end

def greater_heal
  {
    :name => "Greater Heal",
    :short => "green, violet, red, indigo",
    :command => "green, violet, red, indigo",
    :description => "Removes two points of damage.",
    :countered_by => nil
  }
end

def color_to_hand_sign_map
  {
    dragon: 'red (r)',
    ram: 'orange (o)',
    snake: 'yellow (y)',
    dog: 'green (g)',
    ox: 'blue (b)',
    rat: 'indigo (i)',
    tiger: 'tiger (v)'
  }
end

def class_to_display_name
  {
    Sokushi => 'Sokushi',
    Silence => 'Silence',
    Paralysis => 'Paralysis',
    Upheaval => 'Upheaval',
    Amnesia => 'Amnesia',
    Heal => 'Heal',
    GreaterHeal => 'Greater Heal',
    UltimateDefense => 'Ultimate Defence',
    CounterSpell => 'Counter Spell',
    HeavyWounds => 'Heavy Wounds',
    LightWounds => 'Light Wounds',
    Shock => 'Shock',
    Shield => 'Shield',
    Missile => 'Missle',
    LightningBolt => 'Lightning Bolt',
    Reflect => 'Reflect',
    FastLightningBolt => 'Fast Lightning Bolt'
  }
end

def pretty_print_spells_by_command k, v
  puts color_to_hand_sign_map[k]

  v.sort_by { |s| s[:countdown] }.each do |s|
    puts "  #{class_to_display_name[s[:spell]]}, Countdown: #{s[:countdown]}"
  end

  puts ""
end

def pretty_print_mins k, v
  puts "#{class_to_display_name[k]}, Countdown: #{v[:countdown]}"
end

current_turn = :player_1
turn = { player_1: { }, player_2: { } }

while continue
  if current_turn == :player_1
    puts 'Player 1, enter one of the commands below:'
    puts 'cast!, status, list'
  else
    puts 'Player 2, enter one of the commands below:'
    puts 'cast!, status, list'
  end

  text = STDIN.noecho(&:gets).chomp

  if text == 'status'
    next_sequence = game.next_sequence_for_turn[game.current_turn]
    puts 'Player 1 Left:'

    # next_sequence[:a][:left][:by_command].each do |k, v|
    #   pretty_print_spells_by_command k, v
    # end

    next_sequence[:a][:left][:mins]
      .sort_by { |k, v| v[:countdown] }
      .each { |k, v| pretty_print_mins k, v }

    puts ""

    puts 'Player 1 Right:'

    # next_sequence[:a][:right][:by_command].each do |k, v|
    #   pretty_print_spells_by_command k, v
    # end

    next_sequence[:a][:right][:mins]
      .sort_by { |k, v| v[:countdown] }
      .each { |k, v| pretty_print_mins k, v }

    puts ""

    puts 'Player 2 Left:'

    # next_sequence[:b][:left][:by_command].each do |k, v|
    #   pretty_print_spells_by_command k, v
    # end

    next_sequence[:b][:left][:mins]
      .sort_by { |k, v| v[:countdown] }
      .each { |k, v| pretty_print_mins k, v }

    puts ""

    puts 'Player 2 Right:'

    # next_sequence[:b][:right][:by_command].each do |k, v|
    #   pretty_print_spells_by_command k, v
    # end

    next_sequence[:b][:right][:mins]
      .sort_by { |k, v| v[:countdown] }
      .each { |k, v| pretty_print_mins k, v }

    puts ""
  elsif text == 'list'
    [shock,
     shield,
     seppuku,
     missile,
     light_wound,
     heavy_wound,
     lighting_bolt,
     fast_lighting_bolt,
     amnesia,
     upheaval,
     paralysis,
     silence,
     heal,
     greater_heal,
     reflect,
     counter_spell,
     ultimate_defense,
     sokushi,
    ].each { |s|
      puts "=== #{s[:name]}  ==="
      puts "#{s[:command]}"
      puts "Countered/Nullified by: #{s[:countered_by]}" if s[:countered_by]
      puts "#{s[:description]}"
      puts "\n"
    }
  elsif text == 'cast!'
    casted = false
    mana_pool = :left

    while !casted
      if(mana_pool == :left)
        puts "What mana do you want to infuse for the LEFT spell? (roygbiv)"
        turn[current_turn][:left] = STDIN.noecho(&:gets).chomp
        mana_pool = :right
      else
        puts "What mana do you want to infuse for the Right spell? (roygbiv)"
        turn[current_turn][:right] = STDIN.noecho(&:gets).chomp
        casted = true
        if(current_turn == :player_1)
          current_turn = :player_2
        else
          pp turn
          current_turn = :player_1
        end
      end
    end
  elsif text == 'exit'
    continue = false
  end
end
