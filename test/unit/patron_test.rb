require 'test_helper'

class PatronTest < ActiveSupport::TestCase
  fixtures :patrons, :realizes, :produces, :expressions, :manifestations, :patron_types, :languages, :countries

  # Replace this with your real tests.
  def test_patron_should_be_author
    assert patrons(:patron_00001).author?(expressions(:expression_00001))
  end

  def test_patron_should_not_be_author
    assert_nil patrons(:patron_00010).author?(expressions(:expression_00001))
  end

  def test_patron_should_be_publisher
    assert patrons(:patron_00001).publisher?(manifestations(:manifestation_00001))
  end

  def test_patron_should_not_be_publisher
    assert_nil patrons(:patron_00010).publisher?(manifestations(:manifestation_00001))
  end

  def test_patron_full_name
    assert_equal 'Kosuke Tanabe', patrons(:patron_00003).full_name
  end

end
# == Schema Information
#
# Table name: patrons
#
#  id                                  :integer         not null, primary key
#  user_id                             :integer
#  last_name                           :string(255)
#  middle_name                         :string(255)
#  first_name                          :string(255)
#  last_name_transcription             :string(255)
#  middle_name_transcription           :string(255)
#  first_name_transcription            :string(255)
#  corporate_name                      :string(255)
#  corporate_name_transcription        :string(255)
#  full_name                           :string(255)
#  full_name_transcription             :text
#  full_name_alternative               :text
#  created_at                          :datetime        not null
#  updated_at                          :datetime        not null
#  deleted_at                          :datetime
#  zip_code_1                          :string(255)
#  zip_code_2                          :string(255)
#  address_1                           :text
#  address_2                           :text
#  address_1_note                      :text
#  address_2_note                      :text
#  telephone_number_1                  :string(255)
#  telephone_number_2                  :string(255)
#  fax_number_1                        :string(255)
#  fax_number_2                        :string(255)
#  other_designation                   :text
#  place                               :text
#  street                              :text
#  locality                            :text
#  region                              :text
#  date_of_birth                       :datetime
#  date_of_death                       :datetime
#  language_id                         :integer         default(1), not null
#  country_id                          :integer         default(1), not null
#  patron_type_id                      :integer         default(1), not null
#  lock_version                        :integer         default(0), not null
#  note                                :text
#  creates_count                       :integer         default(0), not null
#  realizes_count                      :integer         default(0), not null
#  produces_count                      :integer         default(0), not null
#  owns_count                          :integer         default(0), not null
#  required_role_id                    :integer         default(1), not null
#  required_score                      :integer         default(0), not null
#  state                               :string(255)
#  full_name_alternative_transcription :text
#  email                               :text
#  url                                 :text
#  title                               :string(255)
#  birth_date                          :string(255)
#  death_date                          :string(255)
#  patron_identifier                   :string(255)
#

