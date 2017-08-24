class Api::V1::GamesController < ApplicationController

  def index

    games = Game.all
    render json: games
  end

  def create_or_update_game
  	game = Game.find_by(frontend_id: game_params[:id])
    if game
      game.update(game_params)
      update_snake_head_and_tail(game)
    else
      game = Game.create(game_params)
      create_snake_head_and_tail(game)
    end
    # remember to call private helper methods

    render json: game
  end


  private

  def create_snake_head_and_tail(game)
    snake_head = SnakeHead.new(game_id: game.id)
    snake_head.bearing = game_params[:snakeCoordinatesAndBearing][:snake][:bearing]
    snake_head.x = game_params[:snakeCoordinatesAndBearing][:snake][:coordinates][0]
    snake_head.y = game_params[:snakeCoordinatesAndBearing][:snake][:coordinates][1]
    snake_head.save
    create_tail(snake_head)
  end

  def update_snake_head_and_tail(game)
    snake_head = game.snake_head
    snake_head.bearing = game_params[:snakeCoordinatesAndBearing][:snake][:bearing]
    snake_head.x = game_params[:snakeCoordinatesAndBearing][:snake][:coordinates][0]
    snake_head.y = game_params[:snakeCoordinatesAndBearing][:snake][:coordinates][1]
    snake_head.save
    update_tail(snake_head)
  end

  # {snake: snakeHead.coordinatesAndBearing(), tail: snakeHead.tailCoordinatesAndBearing()}

  def create_tail(snake_head)
    tail_array_of_hashes = game_params[:snakeCoordinatesAndBearing][:tail]
    tail_array_of_hashes.each do |tail_hash|
      tail_block = Tail.new(snake_head_id: snake_head.id)
      tail_block.bearing = tail_hash[:bearing]
      tail_block.x = tail_hash[:x]
      tail_block.y = tail_hash[:y]
      tail_block.save
    end
  end

  def update_tail(snake_head)
    snake_head.tail = []
    snake_head.save
    create_tail(snake_head)
  end

  def game_params
  	params.require(:game).permit(:user, :snakeCoordinatesAndBearing, :id)
  end

end