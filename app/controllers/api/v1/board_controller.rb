class Api::V1::BoardController < Api::V1::ApiController
  doorkeeper_for :all, scopes: [:board]
  after_action :expire_cache, only: [:create]

  def create
    board = Board.new board_params
    if board.creatable_by?(current_resource_owner)
      board.user = current_resource_owner.user
      board.user_agent = doorkeeper_token.application.name
      board.save
      render json: { id: board.id }
    else
      render json: { error: "You cannot post on this board" }
    end
  end

protected

  def board_params
    params.permit(:object_type, :object_id, :message)
  end

  def expire_cache
    expire_page controller: '/boards', action: :show, format: :xml
  end
end
