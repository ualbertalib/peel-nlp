require "nokogiri"
require_relative "../lib/nlp_parser.rb"
require_relative "../lib/mods_article.rb"
require_relative "../lib/entity.rb"

module E
  def *(path)
    File.expand_path(path, File.dirname(__FILE__))
  end
end
