require 'rails_helper'

describe StudentProfile do
  describe 'associtations' do
    Then { is_expected.to belong_to(:person) }
    Then { is_expected.to have_many(:group_participations ).dependent(:destroy              ) }
    Then { is_expected.to have_many(:academic_groups        ).through(  :group_participations ) }
    Then { is_expected.to have_many(:attendances          ).dependent(:destroy              ) }
    Then { is_expected.to have_many(:class_schedules      ).through(  :attendances          ) }
  end

  describe 'methods' do
    Given { @sp     = create :student_profile }
    Given { @new_ag = create :academic_group }

    describe '#move_to_group' do
      When  { @sp.move_to_group(@new_ag) }

      context 'first group' do
        Then { expect(@sp.academic_groups).to eq([@new_ag]) }
        And  { expect(@sp.group_participations.find_by(academic_group_id: @new_ag.id).leave_date).to be_nil }
      end

      context 'second group' do
        Given { @old_ag = create :academic_group }
        Given { @sp.academic_groups << @old_ag }

        Then  { expect(@sp.academic_groups).to eq([@new_ag, @old_ag]) }
        And   { expect(@sp.group_participations.find_by(academic_group_id: @new_ag.id).leave_date).to be_nil }
        And   { expect(@sp.group_participations.find_by(academic_group_id: @old_ag.id).leave_date).not_to be_nil }
      end
    end

    describe '#remove_from_groups' do
      Given { @sp.academic_groups << @new_ag }

      When  { @sp.remove_from_groups }

      Then  { expect(@sp.group_participations.find_by(academic_group_id: @new_ag.id).leave_date).not_to be_nil }
    end
  end
end
