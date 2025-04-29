# spec/factories/rights_declarations.rb
FactoryBot.define do
  factory :rights_declaration do
    rights_basis { "copyright" } 
    copyright_jurisdiction { "us" }
    copyright_statement { "pd" } 
    access_restrictions { "DISSEMINATE" } 

    
    #declarable transient attribute link declaration to a collection
    transient do
      declarable { nil }
    end

    after(:build) do |rights_declaration, evaluator|
      rights_declaration.rights_declarable = evaluator.declarable if evaluator.declarable
    end
  end
end