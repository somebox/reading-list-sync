class SafariBookmark
  include Bookmark

  attr_accessor :xml, :data
  attr_accessor :url, :date_added, :uuid, :title, :preview_text

  COMMAND = '/usr/bin/plutil -convert xml1 -o - ~/Library/Safari/Bookmarks.plist'

  # create with nokogiri xml fragment
  def initialize(bookmark_node)
    @xml = bookmark_node
    @data = extract_data(xml)
    @url = @data['URLString']
    @title = @data['title']
    @uuid = @data['WebBookmarkUUID']
    @date_added = @data['DateAdded']
    @preview_text = @data['PreviewText']
  end

  def extract_data(xml)
    data = {}
    xml.css('key').each do |key|
      data[key.text] = key.at_xpath('following-sibling::*').text
    end
    data
  end

  def self.reading_list
    xml, errors, status = Open3.capture3(COMMAND)
    Nokogiri::XML(xml).xpath('//dict[key="ReadingList"]').map do |bookmark_node|
      SafariBookmark.new(bookmark_node)
    end
  end
end
