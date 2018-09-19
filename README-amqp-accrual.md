# AMQP Accrual

## Overview

Trusted systems can be configured to request ingest and deletion of content 
through AMQP. 

This was originally developed with a file system in mind and only now
transitioned to medusa_storage where we think of things as keys, either relative
to a root directory or an S3 bucket and possibly prefix. So some of the 
terminology may reflect this earlier bias, but should be taken in the
more general sense.

The two systems need to agree on two storage locations. One is used by the client
to stage content. The collection registry only needs to be able to read this one.
The other is where the collection registry will copy the content. This will be
somewhere under the collection registry's main storage and will be configured
by setting the appropriate file group. The client will probably want to be able
to read content out of this area.

## Collection Registry configuration

There are two sections of the settings that need to be configured. Under
the top-level 'amqp_accrual:' key, one needs to put an entry for each 
client that will ingest. The key is used as the name of that client in 
the code. This takes the following subkeys:

* active - boolean - if true this ingest path will be active, if not then
  nothing will happen if messages are sent to the queue.
* allow_delete - boolean - whether or not delete messages will be allowed. If
  false then any delete messages sent to the queue will be replied to with an 
  error
* delayed_job_queue - string - the name of the delayed job queue that will process
  messages for this client
* incoming/outgoing queue - string - the AMQP queues (in the same vhost as the rest
  of the queues) that are used to receive and return messages. The client
  will use the same queues, but inverting them of course. In this document we'll
  always talk about them from the collection registry's perspective.
* file_group_id - integer - the file group to which content will go. Paths/keys
  in the target are relative to the root cfs directory of the file group. For example,
  if we are in collection id '7' and file group id '11', then paths in the target
  are relative to '7/11/' in the main medusa storage root, so key 'my/content' for
  example would go to '7/11/my/content' under the medusa main storage root.
* return_directory_information - boolean - this is not well named. It returns some
  additional information that some systems use. It might be as well to replace this
  in some way in the future.
  
The other configuration is under the 'storage:amqp:' key. The value here should
be an array of hashes. Each hash is a medusa_storage entry that points to the 
location where the client system will put the content for the collection registry
to copy it. The value of the ':name:' key must correspond to the entry in the 
other section.

Example:

```yaml
amqp_accrual:
  idb:
    active: true
    allow_delete: false
    delayed_job_queue: idb
    incoming_queue: idb_to_medusa
    outgoing_queue: medusa_to_idb
    file_group_id: 2
    return_directory_information: true
storage:
    amqp:
      - :name: idb
        :type: filesystem
        :path: /path/to/staged/content
``` 

## Ingest Process

To ingest content the client puts content into the staging area. It then
sends a message to the incoming queue requesting ingest and containing the
key to ingest and possibly the target key (if not then one is inferred).
Also a pass-through hash may be given, i.e. something that is just returned
as-is to the client. 

The collection registry picks up the message and creates a delayed job to do the actual
ingest. When the ingest is done it returns some information about the ingested
content, the original key requested for ingest, and the pass-through if present.  If
there was a problem then an error message is returned. 

If the value of the 'operation' key is not recognized then the collection 
registry will simply log an error and swallow the message. Nothing is returned
to the client.

### Message formats

#### Ingest request

* operation - 'ingest'
* staging_key (alias staging_path) - string - location relative to the staging
  storage root that the client wishes to have ingested. If 'staging_key' is not
  given then 'staging_path' will be used if provided; however, 'staging_path'
  should be considered deprecated.
* target_key - string (optional) - location relative to the file groups root 
  storage where the content should be placed. If not given it is computed by
  by lopping off the first path component of the staging_key. E.g. 'my/content/here'
  in the staging area would be sent to 'content/here' under the configured
  file group. It should be considered deprecated _not_ to provide this key.
* pass_through - object (optional) - this is stored and returned unchanged.
  A client may use it, for example, to receive some sort of identifying 
  information in the return message (though note that the staging_key/staging_path 
  is also returned). 

#### Ingest response on success

* operation - 'ingest'
* staging_key/staging_path - string - returned as originally provided, or 
  null if not provided. 
* pass_through - object - returned as originally provided, or null if not
  provided.
* status - 'ok'
* uuid - string - the uuid of the content created in medusa
* medusa_key(new)/medusa_path(deprecated) - string - the key where the 
  content was created. This will be either the target_key or the key 
  inferred from staging_key. For the time being these will both be returned
  and will be identical. medusa_path is deprecated, though.  

If 'return_directory_information' is set to true in configuration then
three additional keys are provided: 'parent_dir', 'grandparent_dir', and
'item_root_dir'. Each of these is an object with keys 'id', 'uuid', 'relative_path',
and 'url_path' corresponding to that data in medusa for those three 'directories'.
Note that we may modify how this is handled in the future.

#### Ingest errors

There are two errors - the returned messages have the same form.

* operation - 'ingest'
* status - 'error'
* error - string - message describing the error
* staging_key/staging_path - string - as for success
* pass_through - as for success

##### Duplicate File Error

This is returned if there is already a file at the target key. In this case
nothing is ingested. If you want to replace content at a key and deletion is
supported, then delete the key and then ingest.

##### Unknown Error

This would typically happen if for some reason the ingest job can't be 
created from the provided message. 

## Delete Process

To delete content the client sends a message requesting such to the incoming
queue. If the configuration permits deletion then the content is deleted and
a success message returned. If not, then an error message is returned. 

### Message formats

#### Delete request

If configured, the client may request deletion of content identified by uuid.

* operation - 'delete'
* uuid - the uuid of the content to be deleted. Note that only individual
  content objects (CfsFiles) are supported.
* pass_through - object - returned unchanged

#### Delete response on success

If the content is deleted from storage and the database you get the following
return message:

* operation - 'delete'
* status - 'ok'
* uuid - string - the uuid you requested to be deleted
* pass_through - object - whatever you sent 

#### Delete errors

The error messages all have the same format:

* operation - 'delete'
* status - 'error'
* error - string - message describing error
* uuid - string - the uuid you requested to be deleted
* pass_through - object - whatever you sent

The following types of errors are recognized:

* delete not permitted - configuration does not permit deletion by this
  client
* wrong file group - the uuid you gave does not appear in the file group
  this client uses
* file not found - the file with the uuid you send could not be found
* unknown - most likely the incoming message could not be turned into
  a delete job.