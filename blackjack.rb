# I'm still not entirely sure I understand how Blackjack works entirely,
# but this is a pretty good approximation, maybe?

class Card

	attr_reader :rank
	attr_reader :suit
	attr_reader :value

	def initialize(rank, suit, value)
		@rank = rank
		@suit = suit
		@value = value
	end

	def to_s
		"#{rank}#{suit}"
	end
end

class Deck
	def initialize(number)
		@cards = []
		suits = ["H", "S", "C", "D"]
		ranks = {"A" => 11, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, "J" => 10, "Q" => 10, "K" => 10}

		# Populate deck(s) of cards
		for i in 1..number
			suits.each do |suit|
				ranks.each do |rank, value|
					@cards << Card.new(rank, suit, value)
				end
			end
		end
	end

	def shuffle
		@cards = @cards.shuffle
	end

	def deal(number)
		return @cards.pop(number)
	end
end

class Player

	attr_accessor :hand
	attr_reader :name
	attr_accessor :action
	attr_accessor :is_dealer
	attr_accessor :total

	def initialize(name)
		@hand = []
		@name = name
		@total = 0
		@action = nil
		@is_dealer = false
	end

	def calculate_total
		@total = 0
		@hand.each {|card| @total += card.value}

		@hand.select{|card| card.rank == "A"}.count.times do
			@total -= 10 if @total > 21
		end

		if @total > 21
			@action = "Busted"
		elsif @total == 21
			@action = "Blackjack"
		end

		return @total
	end

	def print_hand
		@hand.each {|card| print card.to_s+" "}
		print "\n"
	end
end

class Blackjack
	BLACKJACK = 21
	DEALER_MIN = 17

	def initialize
		@players = []
		@deck = nil
		@has_21 = nil
		play
	end

	def get_players
		@players = []
		@dealer = Player.new("Dealer")
		@dealer.is_dealer = true
		puts "How many would like to play?"
		players_num = gets.chomp.to_i
		for i in 1..players_num
			puts "What is the name of Player #{i}?"
			player_name = gets.chomp
			@players << Player.new(player_name)
		end
		@players << @dealer
	end

	def get_deck
		puts "How many decks would you like to use?"
		decks_number = gets.chomp.to_i
		@deck = Deck.new(decks_number)
		@deck.shuffle
	end

	def initial_deal
		@players.each do |player|
			player.hand += @deck.deal(2)
			current_total = player.calculate_total
		end
	end

	def all_done
		still_playing = @players.select {|player| player.action == "Hit" or player.action == nil}
		if still_playing.length > 0
			return false
		end
		return true
	end

	def turn(player)
		puts "It's #{player.name}'s turn."
		if player.action == "Stay"
			puts "#{player.name} is staying."
		elsif player.action == "Busted"
			puts "#{player.name} has busted."
		else
			# in case someone gets dealt blackjack right off the bat
			if player.total == 21
				@has_21 = player.name
				puts "#{player.name} has blackjack!"
				return
			end
			unless player.is_dealer
				puts "#{player.name}, here's your hand:"
				player.print_hand
				puts "Your total is #{player.total}.  Do you want to hit or stay?  Type 'Hit' to hit, enter anything else to stay."
				player.action = gets.chomp
				if player.action == "Hit"
					player.hand += @deck.deal(1)
					new_card = player.hand.last
					puts "You hit and draw a #{new_card.to_s}."
				else
					player.action == "Stay"
				end
			else
				if player.total < DEALER_MIN
					player.action = "Hit"
					player.hand += @deck.deal(1)
					new_card = player.hand.last
					puts "#{player.name} hits and draws a #{new_card.to_s}."
				else
					player.action = "Stay"
					puts "#{player.name} stays."
				end
			end
			current_total = player.calculate_total
			puts "#{player.name}'s score is now #{current_total}."
			if player.action == "Busted"
				puts "#{player.name} has busted!"
			elsif player.action == "Blackjack"
				puts "#{player.name} has a score of 21!"
				@has_21 = player.name
			end
		end
	end

	def determine_winner
		if @has_21 != nil
			puts "The winner is #{@has_21}!"
		else
			not_busted = @players.select{|player| player.total <= 21}
			winner = nil
			high_score = 0
			not_busted.each do |player|
				if player.total > high_score
					high_score = player.total
					winner = player.name
				end
			end
			# check for a tie
			winners = @players.select{|player| player.total == high_score}
			if winners.length > 1
				print "There was a tie between "
				winner_names = []
				winners.each do |winner|
					winner_names << winner.name
				end
				print winner_names.join(", ")+".\n"
			else
				puts "The winner is #{winner}, with a score of #{high_score}!"
			end
		end
	end

	def play
		puts "Welcome to Blackjack!"
		begin
			get_players
			get_deck
			initial_deal
			begin
				@players.each do |player|
					turn(player)
					if @has_21 or all_done
						break
					end
				end
			end while @has_21 == nil and all_done == false
			determine_winner
			puts "The game is over."
			puts "Would you like to play again?"
			continue = gets.chomp.downcase
		end while continue == "y" or continue == "yes"
		return
	end
end

blackjack_game = Blackjack.new
blackjack_game.play