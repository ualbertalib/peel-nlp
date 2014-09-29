require "open-nlp"
require_relative "./mods_article.rb"

class NLPParser

  def initialize
    @mods_article = ModsArticle.new
  end

  def from_xml xml_record
    @mods_article.parse xml_record
  end

  def text
    @mods_article.text
  end

  def tokens
    @tokens || tokenize
  end

  def tokenize
    OpenNLP.load
    tokenizer = OpenNLP::TokenizerME.new
    @tokens = tokenizer.tokenize(text)
  end

  def tags
    OpenNLP.load
    tagger = OpenNLP::POSTaggerME.new
    tagger.tag(tokens).to_a
  end
end
