require_relative "./spec_helper"

include E

describe NLPParser do

  before(:each) do
    mods_article = File.open(E::*("fixtures/clean_mods_article.xml")).read
    @nlp_parser = NLPParser.new ModsArticle.new
    @nlp_parser.from_xml mods_article
  end

  context "Given a MODS XML file" do
    it "should populate a text field" do
      expect(@nlp_parser.text).to include "Here is a bunch of text I want to process"
    end
  end

  context "when the text field has been populated" do
    it "should tokenize the text" do
      expect(@nlp_parser.tokens.size).to eq 28
      expect(@nlp_parser.tokens[9]).to eq "process"
    end

    it "should tag the text with parts of speech" do
      expect(@nlp_parser.tags.size).to eq 28
      expect(@nlp_parser.tags[9]).to eq "VB"
    end

    it "should find any personal names that are in the text" do
      expect(@nlp_parser.names.size).to eq 4
      expect(@nlp_parser.names.first).to eq "John_Lennon"
    end
  end

  context" given a list of extracted names" do
    it "should get a DBPedia URL for each person" do
      expect(@nlp_parser.uris.first).to eq "http://dbpedia.org/resource/John_Lennon"
      expect(@nlp_parser.uris.size).to eq 4
    end

    it "should create a validation table of all extracted names"

    it "should pull down a list of triples for each person from DBPedia"
  end
end
