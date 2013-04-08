function initializeChart(storage) {
        $('.chart_container').highcharts({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false
            },
            title: {
                text: 'size(KB)'
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
                        formatter: function() {
                            return '<b>'+ this.point.name +'</b>';
                        }
                    }
                }
            },
            series: [{
                type: 'pie',
                name: 'Size share',
                data: [
                    ['Object Level', storage["object_level_total"]/storage["total"]],
                    {
                        name: 'Bit Level',
                        y: storage["bit_level_total"]/storage["total"],
                        sliced: false,
                        selected: true
                    },
                    ['Free space', storage["free"]/storage["total"] ],
                ]}]});
        $('#chart_container2').highcharts({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false
            },
            title: {
                text: 'size(KB)'
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
                        formatter: function() {
                            return '<b>'+ this.point.name +'</b>';
                        }
                    }
                }
            },
            series: [{
                type: 'pie',
                name: 'Size share',
                data: [
                    ['Object Level',   25.0],
                    {
                        name: 'Bit Level',
                        y: 50.0,
                        sliced: false,
                        selected: true
                    },
                    ['Free space',    25.0],
                ]}]});
    }
