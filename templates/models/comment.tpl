<div class="item">
    <img src="{$GRAVATAR_URL}{$comment.hash}" alt="user image" class="offline" />
    <p class="message">
        <a class="dynamic_load" href="{$BASE_URL}member/{$comment.idmember}" class="name">
            <small class="text-muted pull-right">
                <i class="fa fa-clock-o"></i>
                <time class="timeago" datetime="{$comment.createdate}">{$comment.createdate}</time>
            </small>
            {$comment.name}
        </a>
        {$comment.content}
    </p>
</div>