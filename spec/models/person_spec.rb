require 'rails_helper'

describe Person do
  describe 'association' do
    Then { expect(subject).to have_one(:student_profile).dependent(:destroy) }
    Then { expect(subject).to have_one(:teacher_profile).dependent(:destroy) }
    Then { expect(subject).to have_one(:study_application).dependent(:destroy) }
    Then { expect(subject).to have_and_belong_to_many(:roles) }
    Then { expect(subject).to have_many(:telephones).dependent(:destroy) }
    Then { expect(subject).to have_many(:answers).dependent(:destroy) }
    Then { expect(subject).to have_many(:questionnaire_completenesses).dependent(:destroy) }
    Then { expect(subject).to have_many(:questionnaires).through(:questionnaire_completenesses) }
  end

  describe 'validation' do
    context 'password' do
      Then { expect(subject).to validate_confirmation_of(:password) }
      And  { expect(subject).to ensure_length_of(:password).is_at_most(128) }
      And  { expect(subject).to ensure_length_of(:password).is_at_least(6) }
    end

    describe 'should skip password validation' do
      Then { expect(build(:person, password: '', password_confirmation: '', skip_password_validation: true)).to be_valid }
    end

    context 'gender' do
      Then { expect(subject).to allow_value(true, false).for(:gender) }
      And  { expect(subject).not_to allow_value(nil).for(:gender) }
    end

    context 'email' do
      Given (:valid_addresses)   { %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn] }
      Given (:invalid_addresses) { %w[user@foo,com user_at_foo.org example.user@foo.foo@bar_baz.com foo@bar+baz.com ] }

      Then { expect(subject).to validate_uniqueness_of(:email) }
      And { expect(subject).not_to allow_value('').for(:email) }
      And do
        invalid_addresses.each do |invalid_address|
          expect(subject).not_to allow_value(invalid_address).for(:email)
        end
      end
      And do
        valid_addresses.each do |valid_address|
          expect(subject).to allow_value(valid_address).for(:email)
        end
      end
    end

    context 'name, surname, middle_name, spiritual_name' do
      Then { expect(subject).to validate_presence_of(:name) }
      And  { expect(subject).to ensure_length_of(:name).is_at_most(50) }

      Then { expect(subject).to validate_presence_of(:surname) }
      And  { expect(subject).to ensure_length_of(:surname).is_at_most(50) }

      Then { expect(subject).to ensure_length_of(:middle_name   ).is_at_most(50) }
      Then { expect(subject).to ensure_length_of(:spiritual_name).is_at_most(50) }
    end

    describe 'photo' do
      context 'less then 150x200 not valid' do
        Then { expect(build(:person, photo: File.open("#{Rails.root}/spec/fixtures/10x10.png"))).not_to be_valid }
      end

      context 'equals 150x200 valid' do
        Then { expect(build(:person, :with_photo)).to be_valid }
      end
    end
  end

  describe 'before save processing' do
    context 'downcases :email' do
      Then { expect(create(:person, {email: 'A_US-ER@f.B.org'}).email).to eq('a_us-er@f.b.org') }
    end

    describe 'downcases and titelizes :name, :surname, :middle_name, :spiritual_name' do
      Given { @person = FactoryGirl.create(:person, name: 'имЯ',surname: 'фАмИлиЯ',middle_name: 'ОтчествО',
                                           spiritual_name: 'АдиДасаДаса ДаС') }

      Then { expect(@person.name).to eq('Имя') }
      And  { expect(@person.surname).to eq('Фамилия') }
      And  { expect(@person.middle_name).to eq('Отчество') }
      And  { expect(@person.spiritual_name).to eq('Адидасадаса Дас') }
    end
  end

  describe 'methods' do
    Given { @person = create :person }

    describe '#crop_photo' do
      Then { expect(@person.photo).to receive(:recreate_versions!) }
      And  { expect(@person.crop_photo(crop_x: 0, crop_y: 1, crop_h: 2, crop_w: 3)).to be(true) }
      And  { expect(@person.crop_x).to eq(0) }
      And  { expect(@person.crop_y).to eq(1) }
      And  { expect(@person.crop_h).to eq(2) }
      And  { expect(@person.crop_w).to eq(3) }
    end

    describe 'questionnaires methods' do
      Given { @questionnaire_1    = create :questionnaire }
      Given { @questionnaire_2    = create :questionnaire }
      Given { @program            = create :program, questionnaires: [@questionnaire_1] }
      Given { @study_application  = StudyApplication.create(person_id: @person.id, program_id: @program.id) }

      describe '#add_application_questionnaires' do
        Then  { expect{@person.add_application_questionnaires}.to change{@person.questionnaires.count}.by(1) }
        And   { expect(@person.questionnaire_ids).to eq([@questionnaire_1.id]) }
      end

      describe '#remove_application_questionnaires' do
        context 'not completed' do
          Given { @person.questionnaires << [@questionnaire_1, @questionnaire_2] }

          Then  { expect{@person.remove_application_questionnaires(@study_application)}.to change{@person.questionnaires.count}.by(-1) }
        end

        context 'completed' do
          Given { QuestionnaireCompleteness.create(person_id: @person.id, questionnaire_id: @questionnaire_1.id, completed: true) }

          Then  { expect{@person.remove_application_questionnaires(@study_application)}.not_to change{@person.questionnaires.count} }
        end
      end

      describe '#not_finished_questionnaires' do
        Given { @person.questionnaire_completenesses.create(completed: true , questionnaire_id: @questionnaire_1.id) }
        Given { @person.questionnaire_completenesses.create(completed: false, questionnaire_id: @questionnaire_2.id) }

        Then  { expect(@person.not_finished_questionnaires.pluck(:id)).to eq([@questionnaire_2.id]) }
      end
    end
  end
end
