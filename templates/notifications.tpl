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
                                        <i class="{$notification.icon}"></i>
                                        <div class="timeline-item">
                                            <span class="time"><time class="timeago" datetime="{$notification.createdate}">{$notification.createdate}</time></span>
                                            {if $notification.text|count_characters:true}
                                                <h3 class="timeline-header">{$notification.title}</h3>
                                                <div class="timeline-body">
                                                    {$notification.text}
                                                </div>
                                            {else}
                                                <h3 class="timeline-header no-border">{$notification.title}</h3>
                                            {/if}
                                            {if $notification.subtext|count_characters:true}
                                                <div class="timeline-footer">
                                                    {$notification.subtext}
                                                </div>
                                            {/if}
                                        </div>
                                    </li>
                                {/foreach}
                            </li>
                        {/foreach}
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>
