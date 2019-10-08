require 'spec_helper'
require 'data_magic'
require 'hashie'

describe DataMagic::QueryBuilder do

  before :example do
    DataMagic.destroy
    DataMagic.client
    ENV['DATA_PATH'] = './spec/fixtures/nested_data_type'
    DataMagic.config = DataMagic::Config.new
  end

  after :example do
    DataMagic.destroy
  end

  RSpec.configure do |c|
    c.alias_it_should_behave_like_to :it_correctly, 'correctly:'
  end

  let(:nested_meta) { { post_es_response: {}, from: 0, size: 20, _source: false } }
  let(:options) { {} }
  let(:query_hash) { DataMagic::QueryBuilder.from_params(subject, options, DataMagic.config) }

  shared_examples "builds a query" do
    it "with a query section" do
      expect(query_hash[:query]).to eql expected_query
    end
    it "with query metadata" do
        expect(query_hash.reject { |k, _| k == :query }).to eql nested_meta
    end
  end

  describe "builds queries based on nested datatype fields" do
    context "in absence of all_programs param" do
      subject { { "2016.programs.cip_4_digit" => "1312" } }
      let(:expected_query) { 
          { bool: { filter: {
              nested: {
                  inner_hits: {},
                  path: "2016.programs.cip_4_digit",
                  query: {
                      bool: {
                          must: [{
                              match: { "2016.programs.cip_4_digit" => "1312" }
                          }]
                      }
                  }
              }
          } } } 
      }
      it_correctly "builds a query"
    end

    context "in presence of all_programs param" do
      subject {{ "2016.programs.cip_4_digit" => "1312" }}
      let(:options) {{ :all_programs => true }}

      let(:expected_query) {{ match: { "2016.programs.cip_4_digit" => "1312" }} }
      let(:nested_meta)    {{ post_es_response: {}, from: 0, size: 20, _source: {:exclude=>["_*"]} } }

      it_correctly "builds a query"
    end
  end
end