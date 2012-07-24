require 'spec_helper'

describe "collections/edit" do
  before(:each) do
    @collection = assign(:collection, stub_model(Collection,
      :repository_id => 1,
      :title => "MyString",
      :published => false,
      :ongoing => false,
      :description => "MyText",
      :access_url => "MyText",
      :file_package_summary => "MyText",
      :rights_statement => "MyText",
      :rights_restrictions => "MyText",
      :notes => "MyText"
    ))
  end

  it "renders the edit collection form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => collections_path(@collection), :method => "post" do
      assert_select "input#collection_repository_id", :name => "collection[repository_id]"
      assert_select "input#collection_title", :name => "collection[title]"
      assert_select "input#collection_published", :name => "collection[published]"
      assert_select "input#collection_ongoing", :name => "collection[ongoing]"
      assert_select "textarea#collection_description", :name => "collection[description]"
      assert_select "textarea#collection_access_url", :name => "collection[access_url]"
      assert_select "textarea#collection_file_package_summary", :name => "collection[file_package_summary]"
      assert_select "textarea#collection_rights_statement", :name => "collection[rights_statement]"
      assert_select "textarea#collection_rights_restrictions", :name => "collection[rights_restrictions]"
      assert_select "textarea#collection_notes", :name => "collection[notes]"
    end
  end
end
