<div class="item">
    <a class="item dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$comment.idmember}">
        <img src="{$GRAVATAR_URL}{$comment.hash}?d=identicon" alt="user image" class="offline"/>
    </a>

    <p class="message">

        <small class="text-muted pull-right">
            {if $LOGGED_ID == $comment.idmember || $IS_ADMIN}
                <a href="{$BASE_URL}{$MODELS}/{$comment.idmodel}/comments/{$comment.id}"><i class="removeicon glyphicon glyphicon-trash deletablecomment hidden"></i></a>
            {else}
                <i class="removeicon glyphicon hidden"></i>
            {/if}
            <time class="timeago" datetime="{$comment.createdate}">{$comment.createdate}</time>
            <i class="fa fa-clock-o"></i>
        </small>
        <label class="name">
        <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$comment.idmember}">
            {$comment.name}
        </a>
        </label>
        <label class="comment-body">
            {$comment.content}
        </label>
    </p>
</div>