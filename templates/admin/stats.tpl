<section class="content-header">
    <h1 id="myh122">
        Administration - Statistics
    </h1>
</section>

<link href="{$BASE_URL}css/morris/morris.css" rel="stylesheet" type="text/css"/>
<link href="{$BASE_URL}css/jQRangeSlider/iThing.css" rel="stylesheet" type="text/css" />
<style>
    .inner-content {
        width: 95%;
        margin: 0 auto;
    }

    .box.box-drop {
        height: 125px;
        background: rgba(182, 205, 229, 0.5);
        border-radius: 10px;
        border: 3px dashed rgba(0, 0, 255, 0.2);
        padding: 0;
        text-align: center;
        font-size: 2em;
        font-weight: bold;
    }

    .box.box-drop h2 {
        margin-top: 10px;
        font-size: 0.75em;
    }

    .btn.btn-drop {
        display: inline-block;
        margin-top: 10px;
        margin-bottom: 6px;
    }

    .hidden {
        visibility: hidden;
    }

    .col-centered {
        float: none;
        margin: 0 auto;
    }

    #drop-files {
        width: 90%;
        margin-top: 10px;
        margin-bottom: 10px;
    }

    #upload-form .form-group textarea {
        resize: vertical;
    }

    #upload-form .form-group {
        margin-bottom: 10px;
    }
</style>

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
                <div class="inner-content" id="slider"></div>
                <div class="tab-content no-padding">
                    <div id="slider"></div>
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
