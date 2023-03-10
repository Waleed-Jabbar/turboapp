class Room < ApplicationRecord
  validates_uniqueness_of :name
  scope :public_rooms, -> { where(is_private: false) }
  after_create_commit { broadcast_if_public }
  has_many :messages
  has_many :participants, dependent: :destroy

  def broadcast_if_public
    broadcast_append_to "rooms" unless self.is_private
  end

  def self.create_private_room(users, private_room)
    private_room = Room.create(name: private_room, is_private: true)
    users.each do |user|
      Participant.create(user_id: user.id, room_id: private_room.id)
    end
    private_room
  end
end
