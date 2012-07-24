require 'spec_helper'

describe "collections/index" do
  before(:each) do
    assign(:collections, [
      stub_model(Collection,
        :repository_id => 1,
        :title => "Title",
        :published => false,
        :ongoing => false,
        :description => "MyText",
        :access_url => "MyText",
        :file_package_summary => "MyText",
        :rights_statement => "MyText",
        :rights_restrictions => "MyText",
        :notes => "MyText"
      ),
      stub_model(Collection,
        :repository_id => 1,
        :title => "Title",
        :published => false,
        :ongoing => false,
        :description => "MyText",
        :access_url => "MyText",
        :file_package_summary => "MyText",
        :rights_statement => "MyText",
        :rights_restrictions => "MyText",
        :notes => "MyText"
      )
    ])
  end

  it "renders a list of collections" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
