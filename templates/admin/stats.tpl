<section class="content-header">
    <h1 id="myh122">
        Administration - Statistics
    </h1>
</section>


<section class="content">
    <div class="row">
        <div class="col-md-12" id="upload-form">
            <!-- Custom tabs (Charts with tabs)-->
            <div class="nav-tabs-custom">
                <!-- Tabs within a box -->
                <ul class="nav nav-tabs pull-right">
                    <li class="pull-left header">
                        <i class="fa fa-inbox"></i>Number of registers
                    </li>
                </ul>
                <div class="inner-content" style="width: 95%; margin: 0 auto;" id="slider"></div>
                <div class="tab-content no-padding">
                    <div class="chart tab-pane active" id="revenue-chart"
                         style="position: relative; height: 300px;"></div>
                </div>
            </div>
            <!-- /.nav-tabs-custom -->
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/plugins/morris/raphael-min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/morris/morris.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/jQRangeSlider/jQDateRangeSlider-min.js" type="text/javascript"></script>
<script type="text/javascript">
    $(function() {

        $('#helpBtn').off().hide();

        var area = new Morris.Area({
            element: 'revenue-chart',
            resize: true,
            data: [
                {foreach $stats as $stat}
                    {literal}{{/literal}date: '{$stat.year}-{$stat.month}', users: {$stat.members}, groups: {$stat.groups}, models: {$stat.models}{literal}}{/literal},
                {/foreach}
            ],
            xkey: 'date',
            ykeys: ['users', 'groups', 'models'],
            labels: ['Users', 'Groups', 'Models'],
            lineColors: ['#a0d0e0', '#3c8dbc', '#ffba00'],
            hideHover: 'auto'
        });

        {literal}
        $("#slider").dateRangeSlider({
            defaultValues:{
                min: new Date(2014, 0, 1),
                max: new Date(2015, 0, 1)
            },
            bounds:{
                min: new Date(2010, 0, 1),
                max: new Date(2020, 0, 1)
            },
            range:{
                min: {months: 1}
            }});
        {/literal}

        $("#slider").bind("valuesChanged", function(e, data){
            // date format in JavaScript? No thanks.
            var minDay = data.values.min.getDay() + 1;
            var minMonth = data.values.min.getMonth() + 1;
            var minYear = data.values.min.getFullYear();
            var maxDay = data.values.max.getDay() + 1;
            var maxMonth = data.values.max.getMonth() + 1;
            var maxYear = data.values.max.getFullYear();

            var dates = {
                startDate: minYear + "-" + minMonth + "-" + minDay,
                endDate: maxYear + "-" + maxMonth + "-" + maxDay
            };

            $.get("{$BASE_URL}admin/stats", dates, function (data) {
                var properData = [];
                for (var i = 0; i < data.length; ++i) {
                    properData.push({
                        date: data[i].year + "-" + data[i].month,
                        users: data[i].members,
                        groups: data[i].groups,
                        models: data[i].models
                    });
                }

                area.setData(properData);
            });
        });
    });
</script>
