require "../../lib/nlp_parser.rb"

describe NLPParser do

  before(:each) do
    @nlp_parser = NLPParser.new
    mods_article = File.open("../fixtures/clean_mods_article.xml").read
    @nlp_parser.from_xml mods_article
  end

  context "Given a MODS XML file" do
    it "should populate a text field" do
      expect(@nlp_parser.text).to include "Here is a bunch of text I want to process"
    end
  end

  context "when the text field has been populated" do
    it "should tokenize the text" do
      expect(@nlp_parser.tokens.size).to eq 7
    end

    it "should tag the text with parts of speech"

    it "should find any personal names that are in the text"
  end
end
