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
end
