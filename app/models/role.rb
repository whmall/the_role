class Role < ApplicationRecord
  include TheRole::BaseMethods

  has_many :who_roles, dependent: :destroy
  has_many :whos, through: :who_roles
  has_many :role_rules, dependent: :destroy, inverse_of: :role
  has_many :rules, through: :role_rules, dependent: :destroy
  has_many :sections, ->{ distinct }, through: :role_rules, source: 'section', dependent: :nullify

  def the_role
    Rails.cache.fetch("roles/#{self.id}") do
      result = {}
      sections.each do |section|
        result[section.code] ||= {}
        rules.where(section_id: section.id).each do |rule|
          if rule.serialize_params.blank?
            result[section.code].merge! rule.code => true
          else
            result[section.code].merge! rule.code => rule.serialize_params
          end
        end
      end

      result
    end
  end

end