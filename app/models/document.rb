class Document < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :title, presence: true
  validate :file_attached

  private

  def file_attached
    errors.add(:file, "must be attached") unless file.attached?
  end
end
