# Amazon Glacier integration

This is achieved using a separate service (medusa-glacier on Github). The
two applications should be running on the same server as the same user.
They communicate using AMQP (things are set up to work with a normal
installation of RabbitMQ).

In the amazon section of the medusa.yml config you need to set up the
queues that will be used incoming and outgoing (these must correspond to
those set up with the medusa-glacier server, though of course they will
be reversed).

When this application wants to store something in Glacier it will send a
message over the outgoing queue with the directory to upload. When the
medusa-glacier server picks up the message it will tar the directory, upload it,
remove the tar, and send back a message over the other queue that has the
archive id.

This application can then pick up that message and store the archive id and
otherwise indicate that the job is finished (e.g. mail the initiating user, etc.).
Picking up the message and acting on it is done via a rake task that should
be set up as a cron job.