class PinboardBookmark
  include Bookmark

  API_KEY = CONFIG['services']['pinboard_api_key']
  REJECT_TAGS = %w(facebook twitter objective-c)
  MAX_POST_AGE = 90 # oldest age we consider a bookmark for "toread"
  
  attr_accessor :url, :title, :tags, :description, :date_added, :to_read
  attr_accessor :remote # Pinboard::Post (https://github.com/ryw/pinboard/)

  # initialize with SafariBookmark instance or hash
  def initialize(bookmark)
    self.url = bookmark.url
    self.title = bookmark.title
    self.description = bookmark.preview_text
    self.date_added = bookmark.date_added
    self.tags = []
    self
  end

  def suggested_tags
    begin
      tag_hash = self.class.client.suggest(url)
      return tag_hash[:recommended]
    rescue NoMethodError
      return []
    end
  end

  def add_tags(list, new_tags)
    if new_tags.is_a?(String)
      new_tags = [new_tags]
    end
    (list + new_tags).flatten.uniq
  end

  def smart_tags
    tags = self.class.all_tags & self.suggested_tags - REJECT_TAGS
    domain_map = {
      "youtube.com" => %w(video),
      "boxtec|adafruit" => %w(hardware),
      'slideshare' => %(presentation)
    }
    uri = URI.parse(self.url)
    domain_map.each do |matcher, tag_list|
      tags = add_tags(tags, tag_list) if uri.hostname.match(matcher)
    end
    tags = add_tags(tags, 'reference') if uri.hostname.match(/wikipedia|guide|diy/i)
    %w(hacking ruby rails arduino news photos).each do |word|
      keyword = Regexp.new(word, 'i')
      tags = add_tags(tags, word) if title.match(keyword) or description.to_s.match(keyword)
    end
    tags
  end

  def exists?
    if self.remote
      self.tags = self.remote.tag
      true
    else
      false
    end
  end

  def remote
    @remote ||= self.class.client.get(url: url).first
  end

  def post_age
    return 9999 unless self.date_added
    Date.today.mjd - Date.parse(self.date_added).mjd
  end

  def to_read
    if (self.post_age < MAX_POST_AGE)
      return true
    end
  end

  def save!
    self.class.client.add({
      url: url,
      description: title,
      extended: description,
      tags: self.tags,
      dt: self.date_added,
      replace: false,
      toread: self.to_read
    })
  end

  def delete!
    self.class.client.delete(self.url)
  end

  def self.all_tags
    @tags ||= self.client.tags_get.map(&:tag)
  end

  def self.client
    @client ||= Pinboard::Client.new(token: API_KEY)
  end
end
