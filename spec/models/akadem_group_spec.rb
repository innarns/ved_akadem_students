require 'rails_helper'

describe AkademGroup do
  describe 'associations' do
    Then { expect(subject).to have_many(:group_participations).dependent(:destroy) }
    Then { expect(subject).to have_many(:student_profiles).through(:group_participations) }
    Then { expect(subject).to have_many(:class_schedules).dependent(:destroy) }
  end

  describe 'validation' do
    Given (:valid_names)   { %w[ ШБ13-1 БШ12-4 ЗШБ11-1 ] }
    Given (:invalid_names) { %w[ 12-2 ШБ-1 БШ112 ШБ11- ] }

    Then { expect(subject).to validate_uniqueness_of(:group_name) }
    And  { expect(subject).to validate_presence_of(:group_name) }
    And  do
      valid_names.each do |name|
        expect(subject).to allow_value(name).for(:group_name)
      end
    end
    And  do
      invalid_names.each do |name|
        expect(subject).not_to allow_value(name).for(:group_name)
      end
    end
  end

  describe 'upcases :group_name before save' do
    Then { expect(create(:akadem_group, {group_name: 'шб13-1'}).group_name).to eq('ШБ13-1') }
  end
end
