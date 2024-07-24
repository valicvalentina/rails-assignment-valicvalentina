class UserSerializer < Blueprinter::Base
  identifier :id

  fields :first_name, :email, :created_at, :updated_at

  field :last_name do |user|
    user.last_name.present? ? user.last_name.capitalize : nil
  end

  view :extended do
    association :bookings, blueprint: BookingSerializer
  end
end
