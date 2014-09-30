require "open-uri"
require "open-nlp"
require_relative "./mods_article.rb"

class NLPParser

  def initialize(article_class)
    @article = article_class
    OpenNLP.load
  end

  def from_xml xml_record
    @article.parse xml_record
  end

  def text
    @article.text
  end

  def tokens
    @tokens || tokenize
  end

  def tokenize
    tokenizer = OpenNLP::TokenizerME.new
    @tokens = tokenizer.tokenize(text)
  end

  def tags
    tagger = OpenNLP::POSTaggerME.new
    tagger.tag(tokens).to_a
  end

  def names
    extracted_names
  end

  def extracted_names
    tokenizer   = OpenNLP::TokenizerME.new
    segmenter   = OpenNLP::SentenceDetectorME.new
    ner_models  = ['person']

    ner_finders = ner_models.map do |model|
      OpenNLP::NameFinderME.new("en-ner-#{model}.bin")

    end
    sentences = segmenter.sent_detect(text)
    names = []

    sentences.each do |sentence|
      tokens = tokenizer.tokenize(sentence)
      ner_models.each_with_index do |model,i|
        finder = ner_finders[i]
        name_spans = finder.find(tokens)
        name_spans.each do |name_span|
          start = name_span.get_start
          stop  = name_span.get_end-1
          slice = tokens[start..stop].to_a
          names << slice.join("_")
        end
      end
    end
    names
  end

  def uris
    @valid_uris = []
    extracted_names.each do |name|
      add_uri_if_valid name
    end
    @valid_uris
  end

  def add_uri_if_valid name
    base_uri = "http://dbpedia.org/resource/"
    uri = base_uri+name
    @valid_uris << uri if open(uri){ |f| OK f }
  end

  def OK uri
    uri.status.first == "200"
  end
end
