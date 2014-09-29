require "open-nlp"
require_relative "./mods_article.rb"

class NLPParser

  def initialize
    OpenNLP.load
    OpenNLP.jar_path = File.join(File.dirname(__FILE__), '/bin')
    OpenNLP.model_path = FIle.join(File.dirname(__FILE__), '/bin')
    @mods_article = ModsArticle.new
  end

  def from_xml xml_record
    @mods_article.parse xml_record
  end

  def text
    @mods_article.text
  end

  def tokens
    tokenizer = OpenNLP::SimpleTokenizer.new
    tokenizer.tokenize(@text).to_a
  end
end
