class VisitorsController < ApplicationController
  respond_to :html
  layout "pages", only: [:page]

  # public card page /c/:id
  def card
    @card = Card.find_by_hash_id!(params[:id])
    respond_with(@card)
  end

  # load page contents based on a slug
  def page
    @page = Page.find_by!(slug: params[:id])
    respond_with(@page)
  end
end
