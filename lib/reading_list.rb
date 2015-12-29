Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'pry'
require 'awesome_print'
require 'yaml'

begin
  CONFIG = YAML.load_file('config/secrets.yml') 
#rescue 
#  raise "Error reading config file config/secrets.yml. Please check the README for instructions"
end

require 'nokogiri'
require 'pinboard'
require 'open3'
require 'typhoeus'

require 'bookmark'
require 'safari_bookmark'
require 'pinboard_bookmark'

module ReadingList
  def self.sync!
    counts = {total: 0, skipped: 0, replaced: 0, added: 0, removed: 0}
    SafariBookmark.reading_list.each do |bookmark|
      counts[:total] += 1
      p = PinboardBookmark.new(bookmark)
      puts "---"
      puts "title:   #{p.title}"
      puts "  url:   #{p.url}"
      puts " date:   #{p.date_added}"
      puts "  age:   #{p.post_age} days ago"
      puts " pinboard status/update:"

      if p.exists?
        if bookmark.still_online?
          puts "   => exists, current tags: #{p.tags}"
          if p.remote.tag.empty?
            p.tags = p.smart_tags
            puts "      ... suggested: #{p.tags}"
            # remove and re-add if there are some tags
            if p.tags.any?
              p.delete!
              p.save!
              # ap p
              puts "      ... replaced!"
              counts[:replaced] += 1
            else
              puts "      ... (skipped, no tags to add)"
              counts[:skipped] += 1
            end
          else
            puts "      ... (skipped, has tags)"
            counts[:skipped] += 1
          end
        else
          puts "   !> exists, but url no longer loads. removing!"
          p.delete!
          counts[:removed] += 1
        end
      else
        # move reading list to pinboard 
        p.save!
        puts "  * adding with tags #{p.smart_tags}"
        counts[:added] += 1
      end
    end
    puts "\nStats:\n"
    ap counts
    puts
  end

end
