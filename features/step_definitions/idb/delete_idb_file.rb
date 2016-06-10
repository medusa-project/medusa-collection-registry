When(/^IDB sends an delete request$/) do
  AmqpConnector.connector(:medusa).send_message(AmqpAccrual::Config.incoming_queue('idb'), IdbTestHelper.idb_delete_message)
end

Then(/^there should be an IDB delete delayed job reflecting the delete request$/) do
  message = IdbTestHelper.idb_delete_message
  expect(AmqpAccrual::DeleteJob.find_by(client: 'idb', cfs_file_uuid: message['uuid'])).to be_truthy
end