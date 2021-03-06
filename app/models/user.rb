require 'digest/md5'

##
# a person using the Indent web application. Owns all other content.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # validates :name,  presence: true
  validates :email, presence: true

  # Base content types
  has_many :universes
  has_many :characters
  has_many :items
  has_many :locations

  # Extended content types
  has_many :creatures
  has_many :races
  has_many :religions
  has_many :magics
  has_many :languages
  has_many :groups

  has_many :scenes

  has_many :attribute_fields
  has_many :attribute_categories
  has_many :attribute_values, class_name: 'Attribute'

  # as_json creates a hash structure, which you then pass to ActiveSupport::json.encode to actually encode the object as a JSON string.
  # This is different from to_json, which  converts it straight to an escaped JSON string,
  # which is undesireable in a case like this, when we want to modify it
  def as_json(options={})
    options[:except] ||= blacklisted_attributes
    super(options)
  end

  # Returns this object as an escaped JSON string
  def to_json(options={})
    options[:except] ||= blacklisted_attributes
    super(options)
  end

  def to_xml(options={})
    options[:except] ||= blacklisted_attributes
    super(options)
  end

  def name
    self[:name].blank? && self.persisted? ? 'Anonymous author' : self[:name]
  end

  def content
    {
      characters: characters,
      items: items,
      locations: locations,
      universes: universes,
      creatures: creatures,
      races: races,
      religions: religions,
      magics: magics,
      languages: languages,
      scenes: scenes,
      groups: groups
    }
  end

  def content_count
    [
      characters.length,
      items.length,
      locations.length,
      universes.length,
      creatures.length,
      races.length,
      religions.length,
      magics.length,
      languages.length,
      scenes.length,
      groups.length
    ].sum
  end

  def public_content_count
    [
      characters.is_public.length,
      items.is_public.length,
      locations.is_public.length,
      universes.is_public.length,
      creatures.is_public.length,
      races.is_public.length,
      religions.is_public.length,
      magics.is_public.length,
      languages.is_public.length,
      scenes.is_public.length,
      groups.is_public.length
    ].sum
  end

  def recent_content
    [
      characters, locations, items, universes,
      creatures, races, religions, magics, languages,
      scenes, groups
    ].flatten
      .sort_by(&:updated_at)
      .last(7)
      .reverse
  end

  def image_url(size=80)
    email_md5 = Digest::MD5.hexdigest(email.downcase)
    # 80px is Gravatar's default size
    "https://www.gravatar.com/avatar/#{email_md5}?d=identicon&s=#{size}".html_safe
  end

  private

  # Attributes that are non-public, and should be blacklisted from any public
  # export (ex. in the JSON api, or SEO meta info about the user)
  def blacklisted_attributes
    [
      :password_digest,
      :old_password,
      :encrypted_password,
      :reset_password_token,
      :email
    ]
  end
end
