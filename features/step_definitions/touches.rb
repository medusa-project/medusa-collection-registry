When(/^I touch a model the associated model's timestamp is updated for:$/) do |table|
  table.rows.each do |source_factory, targets|
    targets.split(',').collect(&:strip).each do |target|
      #make a source object with a timestamp in the past. Touch it. Make sure that the target's timestamp is >= than
      #the sources
      source = FactoryBot.create(source_factory.to_sym, updated_at: Time.now - 1.day)
      source.touch
      #reload the target
      associated = source.send("reload_#{target}")
      expect(associated.updated_at).to be >= source.updated_at
    end
  end
end