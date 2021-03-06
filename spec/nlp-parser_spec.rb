require_relative "./spec_helper"

include E

describe NLPParser do

  before(:each) do
    mods_article = File.open(E::*("fixtures/clean_mods_article.xml")).read
    @nlp_parser = NLPParser.new ModsArticle.new
    @nlp_parser.from_xml mods_article
    @nlp_parser.extract_names
  end

  context "Given a MODS XML file" do
    it "should populate a text field" do
      expect(@nlp_parser.text).to include "Here is a bunch of text I want to process"
    end
  end

  context "when the text field has been populated" do
    it "should tokenize the text" do
      expect(@nlp_parser.tokens.size).to eq 31
      expect(@nlp_parser.tokens[9]).to eq "process"
    end

    it "should tag the text with parts of speech" do
      expect(@nlp_parser.tags.size).to eq 31
      expect(@nlp_parser.tags[9]).to eq "VB"
    end

    it "should find any personal names that are in the text" do
      expect(@nlp_parser.entities.size).to eq 5
      expect(@nlp_parser.entities.first.name).to eq "John_Lennon"
      expect(@nlp_parser.entities.first.model).to eq "person"
    end
  end

  context" given a list of extracted names" do
    it "should get a DBPedia URL for each person" do
      expect(@nlp_parser.entities.first.uri).to eq URI("http://dbpedia.org/resource/John_Lennon")
      expect(@nlp_parser.entities.first.valid?).to eq true
    end

    it "should create a validation table of all extracted names" do
      expect(@nlp_parser.report).to eq "John_Lennon,person,http://dbpedia.org/resource/John_Lennon,true|Marie_Curie,person,http://dbpedia.org/resource/Marie_Curie,true|Maddy_Prior,person,http://dbpedia.org/resource/Maddy_Prior,true|Tom_Waits,person,http://dbpedia.org/resource/Tom_Waits,true|Sam_Popowich,person,http://dbpedia.org/resource/Sam_Popowich,|"
    end
  end
end
