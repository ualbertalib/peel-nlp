require_relative "./spec_helper"

include E

describe Entity do

  let(:entity){ entity = Entity.new("John Lennon", "person") }

  it "should have a model and a name" do
    expect(entity.model).to eq "person"
    expect(entity.name).to eq "John Lennon"
  end

  it "should validate a URL against dbpedia" do
    expect(entity.uri).to eq URI("http://dbpedia.org/resource/John_Lennon")
    expect(entity.valid?).to eq true
    unrecognized_entity = Entity.new("Sam Popowich", "person")
    expect(unrecognized_entity.valid?).to eq nil
  end

  it "should harvest triples from dbpedia if record exists" do
    expect(entity.statements.size).to eq 1331
    expect(entity.statements.first.to_s).to eq "<http://dbpedia.org/resource/Live_in_Rio_(Earth,_Wind_&_Fire_album)> <http://dbpedia.org/property/writer> <http://dbpedia.org/resource/John_Lennon> ."
  end

  it "should have a string representation" do
    expect(entity.to_s).to eq "John Lennon,person,http://dbpedia.org/resource/John_Lennon,true"
  end
end
