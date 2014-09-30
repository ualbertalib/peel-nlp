require "open-uri"
require "open-nlp"

class NLPParser

  def initialize(article_class)
    @article = article_class
    OpenNLP.load
    @tokenizer = OpenNLP::TokenizerME.new
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

  def tokenize text
    @tokenizer.tokenize(text)
  end

  def tags
    tagger = OpenNLP::POSTaggerME.new
    tagger.tag(tokens).to_a
  end

  def names
    extracted_names
  end

  def extracted_names
    segmenter   = OpenNLP::SentenceDetectorME.new
    @extracted_names = []

    segmenter.sent_detect(text).each do |sentence|
      tokens = tokenize(sentence)
      find_names_in(tokens)
    end
    @extracted_names
  end

  def find_names_in(tokens)
    ner_models  = ['person'] # add more models to find more entity-types
    ner_finders = populate_finders_for ner_models
    ner_models.each_with_index do |model,i|
      find_names(ner_finders[i], tokens)
    end
  end

  def find_names(finder, tokens)
    name_spans = finder.find(tokens)
    name_spans.each do |name_span|
      @extracted_names << slice(name_span, tokens)
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

  def uris
    @valid_uris = {}
    extracted_names.each do |name|
      add_uri_if_valid name
    end
    @valid_uris
  end

  def add_uri_if_valid name
    base_uri = "http://dbpedia.org/resource/"
    uri = base_uri+name
    @valid_uris[uri] = "OK" if open(uri){|f| OK f}
    rescue OpenURI::HTTPError => e
  end

  def OK uri
    uri.status.first == "200"
  end

  def status
    pretty = ""
    uris
    @valid_uris.each do |uri,status|
      pretty << "#{uri},#{status},"
    end
    pretty
  end
end
