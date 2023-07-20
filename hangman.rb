class Hangman
    def initialize
    # set a random secret word from the list.  Must be between 5 and 12 characters
    @secret_word = File.read('words.txt').chomp.split.select {|word| word.length in 5..12}.sample
    # game_over is true when you run out of guesses (6) or you correctly guess the secret word
    @game_over = false
    # wrong_guesses tracks how many incorrect guesses you have made
    @wrong_guesses = 0
    # man is used to draw the hangman.  First element is head, the left arm, then body etc 
    @man = [" O \n","\/", "|", "\\\n", "\/", " \\"]
    # progress shows which letters have been correctly guessed and their position in the word
    # progress is initialised as "- " for each letter in the word as at the begining no guesses have been made
    # helps the user to see how long the word is also
    @progress = Array.new(@secret_word.length, "- ")
    # tracks letters the user has guessed so they cant waste guesses on letters they have already tried
    @guesses = []
    end

def guess
    # guess gets the users input and validates it
    validated = false
    until validated 
    puts "Please enter a letter:"
    guess = gets.chomp
    if guess.nil? || guess.empty?
        # check is the user has enters a blank string
        puts "You entered an empty string. Try again."
    elsif guess.downcase == "save"
        # if user wants to save the game they enter save and it calls #save
        save
    elsif @guesses.include?(guess.downcase)
        # checks if the user has tried this letter before
        puts "You have tried that guess before.  Try again."
    elsif guess.length > 1 || !guess.downcase.ord.between?(97,122)
        # checks is the user has entererd multiple characters or anything other than a letter
        puts "You entered - #{guess.downcase}"
        puts "You may only enter one letter at a time, no numbers or punctuation are allow. Try again."
    else
        # user input validated and added to the guesses array
        puts "You entered - #{guess.downcase}"
        @guesses.push(guess.downcase)
        validated = true
    end
    
    end
    # returns the validated guess
    guess.downcase
end

def check_guess(guess)
    # split the secret word into its constituent characters
    letters = @secret_word.split("")
    # hits tracks how many successfull guesses have been found.  
    # it will store the index of the letter.  i.e. first letter [0], second letter [1]
    # this is used to updated progress with the positions on the characters
    hits = []
    letters.each_with_index do |letter, index|
        if letter == guess 
            hits.push(index)
        end
    end
    if hits.empty?
        # if there are no correct letters, update the wrong guesses count
        puts "Unlucky, your guess was not in the secret word!"
        @wrong_guesses += 1
    else
        # update @progress with what letter and where.
        # the concat (<<) is to add a space after the letter
        #  this just makes it a little easier on the eye when printing later 
        hits.each {|hit| @progress[hit] = guess << " "}
    end
    # call show progress to show how many letters are correct in out word so far andto draw the hangman
    show_progress()
    # call check for end to check for a win or lose condition
    check_for_end()
end

def show_progress
    # shows progress so far:  i.e  _ _ _ i _
    puts "Progress so far:  #{@progress.join}"
    #if no wrong answer dont draw hangman
    if @wrong_guesses == 0
        puts ""
    elsif @wrong_guesses == 1
        # if one wrong just draw his head
        puts @man[0]        
    elsif @wrong_guesses > 1
        # if more than one wrong draw each element of the hangman up to where you are now
        puts @man[0..(@wrong_guesses - 1)].join
    end
end

def check_for_end
    # remove spaces and check if user has got it
    check_string = @progress.join.gsub(" ", "")
    if check_string == @secret_word
        puts "YOU WIN!"
        @game_over = true
    elsif @wrong_guesses >5
        # if user has not got the word yet and has failed 6 times
        # lose the game
        puts "You have run out of guesses!"
        puts "You lose"
        puts "The secret word was: #{@secret_word}"
        @game_over = true
    end
end

def save
    # save the game state to a txt file then end the program
    File.write('save.txt', "#{@secret_word}/#{@wrong_guesses}/#{@guesses}/#{@progress}")
    puts "Game Saved:"
    exit
end

def load 
    # load from save file
    if File.exist?('save.txt')
        puts "Save Found"
        game_state = File.read("save.txt").split("/")
        @secret_word = game_state[0]
        @wrong_guesses = game_state[1].to_i
        @guesses = game_state[2].gsub(/[\[\]\"]/, "").split(",") # the arrays were saved as strings in a difficult to handle way
        @progress = game_state[3].gsub(/[\[\]\"]/, "").split(",")# this is my current solution. Will come up with something better
        # once the game state is loaded, start the game
        start()
    else
        # if no save file is found
        puts "No save data found."
    end
end

def start
    # start the game and loop until the game is over
    puts "Game Started!"
    show_progress
    until @game_over do
        check_guess(guess())
    end
end

def menu
    # opening menu
    puts "Welcome to the game!"
    validated = false
    until validated
    # enter start or load
    puts "Enter \"Start\" to begin or \"load\" to load a previously saved game"
    input = gets.chomp
    if input.downcase == "start"
        validated = true
        # call start to begin the game
        start()
    elsif input.downcase == "load"
        validated = true
        # call load to load the game
        load()
    else
        # if user enters anything other than start or load
        puts "Unrecognised command.  Try again."
    end
end
end

end
game = Hangman.new
game.menu


    
    
