<section class="content-header">
    <h1 id="myh122">
        Notifications
    </h1>
</section>

<section class="content">
    <div class="row">
        <div class="col-md-8 col-md-offset-2">
            <div class="box box-primary">
                <div class="box-body notifications-box">
                    <ul class="timeline">
                        {foreach $notifications as $date => $nots}
                            <li class="time-label">
                                <span class="bg-red">
                                    {$date}
                                </span>
                                {foreach $nots as $notification}
                                    <li>
                                        <i class="fa fa-envelope bg-blue"></i>
                                        <div class="timeline-item">
                                            <span class="time"><i class="fa fa-clock-o"></i> {$notification.createdate}</span>

                                            <h3 class="timeline-header"><a href="#">{$notification.nottype}</a> ...</h3>

                                            <div class="timeline-body">
                                                ...
                                                Content goes here
                                            </div>

                                            <div class='timeline-footer'>
                                                <a class="btn btn-primary btn-xs">...</a>
                                            </div>
                                        </div>
                                    </li>
                                {/foreach}
                            </li>
                        {/foreach}
                    </ul>
                </div>
                <!-- /.box-body -->
            </div>
        </div>
    </div>
</section>