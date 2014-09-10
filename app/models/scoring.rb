class Scoring
  def initialize(scoring_dice)
    @scoring_dice = scoring_dice
  end

  attr_reader :scoring_dice

  def score
    tally_score = determine_scoring
    tally_score += ones_or_fives_bonus
    tally_score
  end

  private

  def set_of_a_kind?(n)
    if @scoring_dice.length > n-1
      start = 0
      finish = n-1
      decision = false
      until finish == 6 || decision == true
        decision = (@scoring_dice[start..finish].length == n && @scoring_dice[start+1..finish].all? { |scoring_die| scoring_die == @scoring_dice[start] })

        start += 1
        finish += 1
      end
    else
      decision = false
    end
    decision
  end

  def straight?
    @scoring_dice == ['1', '2', '3', '4', '5', '6']
  end

  def two_three_of_a_kind?
    (@scoring_dice[0..2].length == 3 && @scoring_dice[1..2].all? { |scoring_die| scoring_die == @scoring_dice[0] }) &&
      (@scoring_dice[3..5].length == 3 && @scoring_dice[4..5].all? { |scoring_die| scoring_die == @scoring_dice[3] })
  end

  def three_of_a_kind?
    set_of_a_kind?(3)
  end

  def four_of_a_kind?
    set_of_a_kind?(4)
  end

  def five_of_a_kind?
    set_of_a_kind?(5)
  end

  def six_of_a_kind?
    set_of_a_kind?(6)
  end

  def three_pairs?
    @scoring_dice[0] == @scoring_dice[1] && @scoring_dice[2] == @scoring_dice[3] && @scoring_dice[4] == @scoring_dice[5] &&
      @scoring_dice.length == 6 && !@scoring_dice.all? { |scoring_die| @scoring_dice[0] == scoring_die }
  end

  def kind(type)
    @scoring_dice.find { |dice| @scoring_dice.count(dice) == type }
  end

  def add_points(kind, n)
    if kind == '1'
      1000 * (n - 2)
    else
      kind.first.to_i * 100 * ( 2 ** (n - 3))
    end
  end

  def ones_or_fives_bonus
    bonus = 0
    bonus += @scoring_dice.count('1') * 100 if @scoring_dice.count('1') > 0 && @scoring_dice.count('1') < 3
    @scoring_dice.delete('1')
    bonus += @scoring_dice.count('5') * 50 if @scoring_dice.count('5') > 0 && @scoring_dice.count('5') < 3
    @scoring_dice.delete('5')
    bonus
  end

  def determine_scoring
    if straight?
      tally_score = 1500
      @scoring_dice.clear
    elsif three_pairs?
      tally_score = 750
      @scoring_dice.clear
    elsif six_of_a_kind?
      kind = kind(6)
      tally_score = add_points(kind, 6)
      @scoring_dice.delete(kind)
    elsif two_three_of_a_kind?
      kind_0 = @scoring_dice[0]
      kind_1 = @scoring_dice[3]
      if kind_0 == '1'
        tally_score = 1000 + kind_1.to_i * 100
      else
        tally_score = kind_0.to_i * 100 + kind_1.to_i * 100
      end
      @scoring_dice.clear
    elsif five_of_a_kind?
      kind = kind(5)
      tally_score = add_points(kind, 5)
      @scoring_dice.delete(kind)
    elsif four_of_a_kind?
      kind = kind(4)
      tally_score = add_points(kind, 4)
      @scoring_dice.delete(kind)
    elsif three_of_a_kind?
      kind = kind(3)
      tally_score = add_points(kind, 3)
      @scoring_dice.delete(kind)
    end
    tally_score ||= 0
  end

end