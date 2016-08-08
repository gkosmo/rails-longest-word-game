
class GameController < ApplicationController

  def game
     @grids = []
     10.times do
      @grids << generate_grid(10)
    end
      session[:score]  = 0   if session[:score].nil?
      @score = session[:score]
  end

  def score
    grid = params[:grid]
    answer = params[:answer]
    @score_final = run_game(answer, grid)
    session[:score] = @score_final[:score] + session[:score]
  end

  private



  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    res = []
    letters_array= ("A".."Z").to_a
    (grid_size).times { res << letters_array[rand(0...26)] }
    res
  end



  def included?(guess, grid)
    the_grid = grid.split('')
    guess.chars.each do |letter|
      the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
    end
    grid.size == guess.size + the_grid.size
  end

  def compute_score(attempt)
     attempt.size
  end

  def run_game(attempt, grid)
    result = {}
    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
    attempt, result[:translation], grid)
    result
  end

  def score_and_message(attempt, translation, grid)
    if translation
      if included?(attempt.upcase, grid)
        score = compute_score(attempt)
        [score, "well done"]
      else
        [0, "not in the grid"]
      end
    else
      [0, "not an english word"]
    end
  end


  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end
=begin
  def run_game(attempt, grid)
    # TODO: runs the game and return detailed hash of result

    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    quote_serialized = open(api_url).read
    quote = JSON.parse(quote_serialized)
    res = {}
    if quote["Error"] == "NoTranslation"
      res[:score] = 0
      res[:translation] = nil
      res[:message] = "not an english word"
      return res
    else
      if (grid & attempt.split('').sort.map(&:upcase)).sort == attempt.split('').sort.map(&:upcase)
        res[:translation] = quote["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
        if  attempt.length <= grid.length
          res[:message] ="well done"
          res[:score] = attempt.length
          return res
        else
          res[:message] ="well done"
          res[:score] = res[:translation].length
          res[:message] = "Looser ! "
          return res
        end
      else
        res[:score] = 0
        res[:translation] = nil
        res[:message] = "not in the grid"
        return res
      end
    end
  end
=end

end
