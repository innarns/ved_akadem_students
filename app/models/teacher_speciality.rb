class TeacherSpeciality < ActiveRecord::Base
  belongs_to :course
  belongs_to :teacher_profile

  validates :teacher_profile_id, uniqueness: { scope: :course_id }
  validates :course_id, uniqueness: { scope: :teacher_profile_id }
end
