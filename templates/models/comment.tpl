<div class="item">
    <a class="item dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$comment.idmember}">
        <img src="{$GRAVATAR_URL}{$comment.hash}?d=identicon" alt="user image" class="offline"/>
    </a>

    <p class="message">

        <small class="text-muted pull-right">
            <i class="fa fa-clock-o"></i>
            <time class="timeago" datetime="{$comment.createdate}">{$comment.createdate}</time>
            <i class="glyphicon {if $LOGGED_ID == $comment.idmember}glyphicon-trash{/if}"></i>
        </small>
        <a class="dynamic_load name" href="{$BASE_URL}{$MEMBERS}/{$comment.idmember}">
            {$comment.name}
        </a>
        {$comment.content}
    </p>
</div>