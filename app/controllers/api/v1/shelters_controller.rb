class Api::V1::SheltersController < ApplicationController

  before_action do
    request.format = :json
  end

  def index
    @shelters, @filters = apply_params(Shelter.all)
  end

  def outdated
    @outdated, @filters = apply_params(Shelter.outdated.order('updated_at DESC'))
  end

  private

  def apply_params(shelters)
    filters = {}

    if params[:lat].present? && params[:lon].present?
      filters[:lon] = params[:lon]
      filters[:lat] = params[:lat]
      shelters = shelters.near([params[:lat], params[:lon]], 100)
    end

    if params[:county].present?
      filters[:county] = params[:county]
      shelters = shelters.where("county ILIKE ?", "%#{@filters[:county]}%")
    end

    if params[:shelter].present?
      filters[:shelter] = params[:shelter]
      shelters = shelters.where("shelter ILIKE ?", "%#{@filters[:shelter]}%")
    end

    if params[:accepting].present?
      val = case params[:accepting]
            when 'yes', 'no', 'unknown'
              params[:accepting].to_sym
            when 'true'
              :yes
            when 'false'
              :no
            else
              :yes
            end
      @filters[:accepting] = val
      @shelters = @shelters.where(accepting: val)
    end

    if params[:special_needs].present?
      filters[:special_needs] = params[:special_needs]
      shelters = shelters.where(special_needs: true)
    end

    if params[:accessibility].present?
      @filters[:accessibility] = params[:accessibility]
      @shelters = @shelters.where("accessibility ILIKE ?", "%#{@filters[:accessibility]}%")
    end

    if params[:unofficial].present?
      filters[:unofficial] = params[:unofficial]
      shelters = shelters.where(unofficial: true)
    end

    if params[:limit].to_i.positive?
      shelters = shelters.limit(params[:limit].to_i)
    end

    [shelters, filters]
  end
end
