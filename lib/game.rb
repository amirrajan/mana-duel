class Game
  attr_reader :turn_summaries, :next_sequence_for_turn,
              :enchantment_status, :winner

  def initialize spell_registry = nil, starting_damage = nil
    @turn = 0
    @enchantment_status = {
      a: { left: nil, right: nil },
      b: { left: nil, right: nil }
    }
    @enchantment_status_history = []
    @all_activated_spells = []
    @damage = {}
    @damage[:a] = 0
    @damage[:b] = 0
    @damage = starting_damage if starting_damage
    @command_history = {}
    @command_history[:a] = { left: [], right: [] }
    @command_history[:b] = { left: [], right: [] }
    @working_command_history = {}
    @working_command_history[:a] = { left: [], right: [] }
    @working_command_history[:b] = { left: [], right: [] }
    @next_sequence_for_turn = {}
    @turn_summaries = []
    @next_sequence = NextSequence.new
    @spell_registry = spell_registry || [
      Sokushi.new,
      Silence.new,
      Paralysis.new,
      Upheaval.new,
      Amnesia.new,
      Heal.new,
      GreaterHeal.new,
      UltimateDefense.new,
      CounterSpell.new,
      HeavyWounds.new,
      LightWounds.new,
      Seppuku.new,
      Shock.new,
      Shield.new,
      Missile.new,
      LightningBolt.new,
      Reflect.new,
      FastLightningBolt.new,
      Wait.new
    ]

    generate_next_sequence_for_current_turn
  end

  def current_turn
    @turn
  end

  def available_commands
    AvailableCommands.new.for @spell_registry.sort_by { |s| s.sequence.count }
  end

  def generate_next_sequence_for_current_turn
    reco = {}

    unit_combinations.each do |combo|
      team = combo[:team]
      unit = combo[:unit]
      assist = combo[:assist]

      reco[team] ||= {}
      reco[team][unit] ||= {}
      reco[team][unit] = next_sequence_for_unit team, unit, assist
    end

    @next_sequence_for_turn[@turn] = reco
  end

  def next_sequence_for_unit team, primary, assist
    @next_sequence.for({
                         primary: @working_command_history[team][primary],
                         assist: @working_command_history[team][assist]
                       },
                       @spell_registry)
  end

  def amnesia? team
    @enchantment_status[team][:left] == Amnesia &&
      @enchantment_status[team][:right] == Amnesia
  end

  def silence? team
    @enchantment_status[team][:left] == Silence &&
      @enchantment_status[team][:right] == Silence
  end

  def paralysis? team, unit
    @enchantment_status[team][unit] == Paralysis
  end

  def apply_command_constraints commands
    team_combinations.each do |combo|
      team = combo[:team]

      if amnesia? team
        commands[team][:left] = @working_command_history[team][:left].last
        commands[team][:right] = @working_command_history[team][:right].last
      end

      [:left, :right].each do |unit|
        if paralysis? team, unit
          commands[team][unit] = @turn_summaries.last[team][unit][:restrictions][:commands].first
        end
      end

      if silence? team
        [:left, :right].each do |unit|
          if Silence.disables.include? commands[team][unit]
            commands[team][unit] = :wait
          end
        end
      end
    end
  end

  def apply_command_defaults commands
    unit_combinations.each do |combo|
      commands[combo[:team]][combo[:unit]] ||= :wait
    end
  end

  def turn a, b
    @turn += 1

    commands = { a: a, b: b }

    apply_command_defaults commands

    apply_command_constraints commands

    expire_enchantments

    update_command_history commands

    activated_spells = ActivatedSpells.new @turn, @spell_registry

    activated_spells.init_spells @working_command_history

    apply_damage activated_spells, @all_activated_spells

    apply_enchantments activated_spells

    activated_spells.each { |report| @all_activated_spells << report }

    generate_next_sequence_for_current_turn

    assign_winner

    @turn_summaries << activated_spells.summary(@command_history, @enchantment_status_history)

    @turn_summaries.last
  end

  def expire_enchantments
    @enchantment_status_history << @enchantment_status.clone
    @enchantment_status[:a] = { left: nil, right: nil }
    @enchantment_status[:b] = { left: nil, right: nil }
  end

  def team_combinations
    [
      { team: :a, opposing_team: :b },
      { team: :b, opposing_team: :a }
    ]
  end

  def unit_combinations
    [
      { team: :a, unit: :left, assist: :right },
      { team: :a, unit: :right, assist: :left },
      { team: :b, unit: :left, assist: :right },
      { team: :b, unit: :right, assist: :left }
    ]
  end

  def update_command_history commands
    unit_combinations.each do |combo|
      team = combo[:team]
      unit = combo[:unit]

      @command_history[team][unit] << commands[team][unit]
      @working_command_history[team][unit] << commands[team][unit]
    end
  end

  def assign_winner
    @winner = :b if dead? :a

    @winner = :a if dead? :b

    @winner = :draw if dead?(:a) && dead?(:b)
  end

  def apply_damage activated_spells, all_activated_spells
    team_combinations.each do |combo|
      team = combo[:team]
      opposing = combo[:opposing_team]

      @damage[team] += activated_spells.total_damage_for(team,
                                                         opposing,
                                                         all_activated_spells)

      @damage[opposing] += activated_spells.total_reflected_damage_for(team)

      @damage[team] = 0 if @damage[team] < 0
    end
  end

  def apply_enchantments activated_spells
    team_combinations.each do |combo|
      team = combo[:team]
      opposing = combo[:opposing_team]

      apply_amnesia team,
                    opposing,
                    activated_spells

      apply_upheavel team,
                     opposing,
                     activated_spells

      apply_paralysis team,
                      opposing,
                      activated_spells

      apply_silence team,
                    opposing,
                    activated_spells
    end
  end

  def nullification_summary spell,
                            team,
                            opposing,
                            activated_spells

    activated_spells.nullification_summary spell, team, opposing
  end

  def apply_silence team,
                    opposing,
                    activated_spells

    status = nullification_summary Silence, team, opposing, activated_spells

    return unless status[:apply_enchantment]

    target_team = status[:target_team]

    @enchantment_status[target_team][:left] = Silence
    @enchantment_status[target_team][:right] = Silence
  end

  def apply_paralysis team,
                      opposing,
                      activated_spells

    status = nullification_summary Paralysis, team, opposing, activated_spells

    return unless status[:apply_enchantment]

    target_team = status[:target_team]

    if activated_spells.was_casted_by_unit? team, :left, Paralysis
      target = :left

      if @enchantment_status_history.last[target_team][:right] == Paralysis
        target = :right
      end
    else
      target = :right

      if @enchantment_status_history.last[target_team][:left] == Paralysis
        target = :left
      end
    end

    @enchantment_status[target_team][target] = Paralysis
  end

  def apply_upheavel team,
                     opposing,
                     activated_spells

    status = nullification_summary Upheaval, team, opposing, activated_spells

    return unless status[:apply_enchantment]

    target_team = status[:target_team]

    @enchantment_status[target_team][:left] = Upheaval
    @enchantment_status[target_team][:right] = Upheaval
    @working_command_history[target_team][:left] = []
    @working_command_history[target_team][:right] = []
  end

  def apply_amnesia team,
                    opposing,
                    activated_spells

    status = nullification_summary Amnesia, team, opposing, activated_spells

    return unless status[:apply_enchantment]

    target_team = status[:target_team]

    @enchantment_status[target_team][:left] = Amnesia
    @enchantment_status[target_team][:right] = Amnesia
  end

  def damage_for team
    @damage[team]
  end

  def over?
    dead?(:a) || dead?(:b)
  end

  def dead? team
    @damage[team] >= 15
  end
end
