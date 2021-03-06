class BaseInteraction
  attr_accessor :user, :params, :resource

  def initialize(args)
    @user     = args[:user]
    @params   = args[:params]
    @resource = args[:resource]

    init
  end

  def init
  end

  def as_json(opts = {})
    {}
  end

  private

  def photo_url(person)
    person.photo.present? ? "/people/show_photo/thumb/#{person.id}" : person.photo.thumb.url
  end
end
