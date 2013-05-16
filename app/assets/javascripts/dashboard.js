initialize_data_table("table#file_stats_bits");
initialize_data_table("table#file_stats_objects");
initialize_data_table("table#red_flags_table");

$(function () {
  if (typeof storage_overview != "undefined") {
    initializeChart(storage_overview);
  }
});

function initializeChart(storage) {
  $('.chart_container').highcharts({
    chart: {
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false
    },
    title: {
      text: 'size(GB)'
    },
    tooltip: {
      pointFormat: '{series.name}: <b>{point.percentage}%</b>',
      percentageDecimals: 1
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels: {
          enabled: true,
          color: '#000000',
          connectorColor: '#000000',
          formatter: function () {
            return '<b>' + this.point.name + '</b>';
          }
        }
      }
    },
    series: [
      {
        type: 'pie',
        name: 'Size share',
        data: [
          ['Object Level', storage["object_level_total"] / storage["total"]],
          {
            name: 'Bit Level',
            y: storage["bit_level_total"] / storage["total"],
            sliced: false,
            selected: true
          },
          ['Free space', storage["free"] / storage["total"] ],
        ]}
    ]})
};
