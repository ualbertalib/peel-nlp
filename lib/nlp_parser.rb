require "open-uri"
require "open-nlp"
require_relative "./mods_article.rb"

class NLPParser

  def initialize(article_class)
    @article = article_class
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
    OpenNLP.load
    tokenizer = OpenNLP::TokenizerME.new
    @tokens = tokenizer.tokenize(text)
  end

  def tags
    OpenNLP.load
    tagger = OpenNLP::POSTaggerME.new
    tagger.tag(tokens).to_a
  end

  def names
    @names || get_names
  end

  def get_names
    OpenNLP.load
    tokenizer   = OpenNLP::TokenizerME.new
    segmenter   = OpenNLP::SentenceDetectorME.new
    ner_models  = ['person']

    ner_finders = ner_models.map do |model|
      OpenNLP::NameFinderME.new("en-ner-#{model}.bin")
    end

    sentences = segmenter.sent_detect(text)
    named_entities = []

    sentences.each do |sentence|
      tokens = tokenizer.tokenize(sentence)
      ner_models.each_with_index do |model,i|
        finder = ner_finders[i]
        name_spans = finder.find(tokens)
        name_spans.each do |name_span|
          start = name_span.get_start
          stop  = name_span.get_end-1
          slice = tokens[start..stop].to_a
          named_entities << [slice, model]
        end
      @names = named_entities
      end
    end
  end

  def uris
    get_uris
    @uris
  end

  def get_uris
    @uris = []
    base_uri = "http://dbpedia.org/resource/"
    processed_names.each do |name|
      uri = base_uri+name
      open(uri) do |f|
        @uris << uri if OK f
      end
    end
  end

  def OK uri
    uri.status.first == "200"
  end

  def processed_names
    processed = []
    get_names
    @names.each do |name|
      processed << name.first.join("_")
    end
    processed
  end
end
