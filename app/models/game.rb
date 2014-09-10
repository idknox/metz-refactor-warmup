class Game < ActiveRecord::Base
  serialize :last_roll, Array
  has_many :players

  def initialize(params)
    player_1_name = params.delete("player_1")
    player_2_name = params.delete("player_2")

    super(params)
    self.players.new(player_name: player_1_name, total_score: 0, current_score: 0)
    self.players.new(player_name: player_2_name, total_score: 0, current_score: 0)
    self.available_dice = 6
    self.player_iterator = 0
    # do our logic here?
  end


  #keeps track of whos turn it is
  def current_player
    if new_record?
      self.players.first
    else
      self.players.order(:id)[self.player_iterator]
    end
  end

  def roll_again(scoring_dice)
    player = current_player
    self.available_dice -= scoring_dice.length
    self.save
    score = score(scoring_dice)
    player.current_score += score
    self.available_dice = 6 if self.available_dice == 0
    self.last_roll = roll_dice if scoring_dice == [] || score > 0
    self.save
    player.save
  end

  def bust
    player = current_player
    player.current_score = 0
    player.save
  end

  def stay(scoring_dice)
    player = current_player
    self.player_iterator += 1
    self.player_iterator = 0 if self.player_iterator >= self.players.length
    self.last_roll = []
    self.available_dice = 0
    self.save
    player.total_score ||= 0
    player.current_score ||=0
    player.current_score += score(scoring_dice)
    player.total_score += player.current_score
    player.current_score = 0
    player.save
  end

  def roll_dice
    dice = {1 => '⚀',
            2 => '⚁',
            3 => '⚂',
            4 => '⚃',
            5 => '⚄',
            6 => '⚅',
    }
    (1..self.available_dice).map { rand(1..6) }.sort.map { |face| [face, dice[face]] }
  end

  def score(scoring_dice)
    score = Scoring.new(scoring_dice)
    turn_score = score.score
    rejected_dice = score.scoring_dice
    self.available_dice += rejected_dice.length
    turn_score
  end

  # def set_of_a_kind?(scoring_dice, n)
  #   if scoring_dice.length > n-1
  #     start = 0
  #     finish = n-1
  #     decision = false
  #     until finish == 6 || decision == true
  #       decision = (scoring_dice[start..finish].length == n && scoring_dice[start+1..finish].all? { |scoring_die| scoring_die == scoring_dice[start] })
  #
  #       start += 1
  #       finish += 1
  #     end
  #   else
  #     decision = false
  #   end
  #   decision
  # end
  #
  # # def straight?(scoring_dice)
  # #   scoring_dice == ['1', '2', '3', '4', '5', '6']
  # # end
  # #
  # # def two_three_of_a_kind?(scoring_dice)
  # #   (scoring_dice[0..2].length == 3 && scoring_dice[1..2].all? { |scoring_die| scoring_die == scoring_dice[0] }) &&
  # #     (scoring_dice[3..5].length == 3 && scoring_dice[4..5].all? { |scoring_die| scoring_die == scoring_dice[3] })
  # # end
  # #
  # # def three_of_a_kind?(scoring_dice)
  # #   set_of_a_kind?(scoring_dice, 3)
  # # end
  # #
  # # def four_of_a_kind?(scoring_dice)
  # #   set_of_a_kind?(scoring_dice, 4)
  # # end
  # #
  # # def five_of_a_kind?(scoring_dice)
  # #   set_of_a_kind?(scoring_dice, 5)
  # # end
  # #
  # # def six_of_a_kind?(scoring_dice)
  # #   set_of_a_kind?(scoring_dice, 6)
  # # end
  # #
  # # def three_pairs?(scoring_dice)
  # #   scoring_dice[0] == scoring_dice[1] && scoring_dice[2] == scoring_dice[3] && scoring_dice[4] == scoring_dice[5] &&
  # #   scoring_dice.length == 6 && !scoring_dice.all? { |scoring_die| scoring_dice[0] == scoring_die }
  # # end
  # #
  # # def kind(scoring_dice, type)
  # #   scoring_dice.find { |dice| scoring_dice.count(dice) == type }
  # # end
  # #
  # # def add_points(kind, n)
  # #   if kind == '1'
  # #     1000 * (n - 2)
  # #   else
  # #     kind.to_i * 100 * ( 2 ** (n - 3))
  # #   end
  # # end
  # #
  # # def ones_or_fives_bonus(scoring_dice)
  # #   bonus = 0
  # #   bonus += scoring_dice.count('1') * 100 if scoring_dice.count('1') > 0 && scoring_dice.count('1') < 3
  # #   scoring_dice.delete('1')
  # #   bonus += scoring_dice.count('5') * 50 if scoring_dice.count('5') > 0 && scoring_dice.count('5') < 3
  # #   scoring_dice.delete('5')
  # #   bonus
  # # end
  # #
  # # def determine_scoring(scoring_dice)
  # #   if straight?(scoring_dice)
  # #     tally_score = 1500
  # #     scoring_dice.clear
  # #   elsif three_pairs?(scoring_dice)
  # #     tally_score = 750
  # #     scoring_dice.clear
  # #   elsif six_of_a_kind?(scoring_dice)
  # #     kind = kind(scoring_dice, 6)
  # #     tally_score = add_points(kind, 6)
  # #     scoring_dice.delete(kind)
  # #   elsif two_three_of_a_kind?(scoring_dice)
  # #     kind_0 = scoring_dice[0]
  # #     kind_1 = scoring_dice[3]
  # #     if kind_0 == '1'
  # #       tally_score = 1000 + kind_1.to_i * 100
  # #     else
  # #       tally_score = kind_0.to_i * 100 + kind_1.to_i * 100
  # #     end
  # #     scoring_dice.clear
  # #   elsif five_of_a_kind?(scoring_dice)
  # #     kind = kind(scoring_dice, 5)
  # #     tally_score = add_points(kind, 5)
  # #     scoring_dice.delete(kind)
  # #   elsif four_of_a_kind?(scoring_dice)
  # #     kind = kind(scoring_dice, 4)
  # #     tally_score = add_points(kind, 4)
  # #     scoring_dice.delete(kind)
  # #   elsif three_of_a_kind?(scoring_dice)
  # #     kind = kind(scoring_dice, 3)
  # #     tally_score = add_points(kind , 3)
  # #     scoring_dice.delete(kind)
  # #   end
  # #   tally_score ||= 0
  # # end
  # #
  # # def score(scoring_dice)
  # #   tally_score = determine_scoring(scoring_dice)
  # #   tally_score += ones_or_fives_bonus(scoring_dice)
  # #   rejected_dice = scoring_dice
  # #   self.available_dice += rejected_dice.length
  # #   tally_score
  # # end
end
