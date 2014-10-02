var task_refresh_timer;

var ready = function() {
    if ($('input[name="auto-update-frequency"]').length) {
        var Tasks = {

            init: function() {
                var frequency = parseInt($('input[name="auto-update-frequency"]').val());
                task_refresh_timer = setInterval(function() {
                    Tasks.refresh();
                }, frequency);
                Tasks.refresh();
            },

            refresh: function() {
                var frequency = parseInt($('input[name="auto-update-frequency"]').val());
                console.log('Refreshing task list...');

                var tasks_url = $('input[name="tasks-url"]').val();
                $.get(tasks_url, function(data) {
                    $('#tasks_list').html(data);
                    console.log('Refreshed task list');
                });
            }

        };

        Tasks.init();
    }
};

var teardown = function() {
    console.log('Clearing task list refresh timer');
    clearInterval(task_refresh_timer);
};

$(document).ready(ready);
$(document).on('page:load', ready);
$(document).on('page:before-change', teardown);
