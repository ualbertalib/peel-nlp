require "open-uri"
require "open-nlp"
require "linkeddata"

class NLPParser

  attr_reader :entities

  def initialize(article_class)
    @article = article_class
    OpenNLP.load
    @tokenizer = OpenNLP::TokenizerME.new
    @entities = []
  end

  def from_xml xml_record
    @article.parse xml_record
  end

  def text
    @article.text
  end

  def tokens
    tokenize text
  end

  def tags
    tagger = OpenNLP::POSTaggerME.new
    tagger.tag(tokens).to_a
  end

  def extract_names
    segmenter   = OpenNLP::SentenceDetectorME.new
    segmenter.sent_detect(text).each do |sentence|
      tokens = tokenize(sentence)
      find_names_in(tokens)
    end
  end

  def report
    text = ""
    @entities.each do |e|
      text << e.to_s+"|"
    end
    text
  end

  private

  def tokenize text
    @tokenizer.tokenize(text)
  end

  def find_names_in(tokens)
    ner_models  = ['person'] # add more models to find more entity-types
    ner_finders = populate_finders_for ner_models
    ner_models.each_with_index do |model,i|
      find_names(ner_finders[i], model, tokens)
    end
  end

  def find_names(finder, model, tokens)
    name_spans = finder.find(tokens)
    name_spans.each do |name_span|
      name = slice(name_span, tokens)
      @entities << Entity.new(name, model)
    end
  end

  def slice(name_span, tokens)
      start = name_span.get_start
      stop  = name_span.get_end-1
      slice = tokens[start..stop].to_a
      slice.join("_")
  end

  def populate_finders_for ner_models
    ner_models.map do |model|
       OpenNLP::NameFinderME.new("en-ner-#{model}.bin")
    end
  end
end
