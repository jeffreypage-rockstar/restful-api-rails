class VisitorsController < ApplicationController
  respond_to :html

  # public card page /c/:id
  def card
    @card = Card.find_by_hash_id!(params[:id])
    respond_with(@card)
  end
end
